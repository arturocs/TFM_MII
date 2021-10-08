#!/usr/bin/env python

import random
import firebase_admin
from firebase_admin import credentials, firestore
import paho.mqtt.client as mqtt
import json
from datetime import datetime, timedelta
import threading
import pytz
import requests

utc = pytz.UTC


cred = credentials.Certificate("./credentials.json")
firebase_admin.initialize_app(cred)
firestore_db = firestore.client()
url = "https://fcm.googleapis.com/fcm/send"
serverToken = "SERVER_TOKEN"
headers = {
    'Content-Type': 'application/json',
    'Authorization': 'key=' + serverToken,
}

options = json.loads(open("/data/options.json").read())

email = options["app_user"]

timers = {}
pending_activities = []


def on_connect(client, userdata, flags, rc):
    print("Connected with result code "+str(rc))
    client.subscribe("zigbee2mqtt/bridge/devices/#")


def on_message(client, _, msg):
    if msg.topic == "zigbee2mqtt/bridge/devices":
        devices = json.loads(msg.payload.decode('unicode-escape'))
        for sensor in firestore_db.collection("Hogar").document(email).collection("Sensores").list_documents():
            sensor.delete()

        for d in devices:
            if d["definition"] != None:
                address = "zigbee2mqtt/"+d["friendly_name"]
                client.subscribe(address)
                print(d["definition"]["description"], " ", d["friendly_name"])
                firestore_db.collection(u"Hogar").document(email).collection(
                    "Sensores").add({'Nombre': d["friendly_name"], 'Direccion': address})

    else:
        friendly_name = msg.topic.split("/")[1]
        event = msg.payload.decode('unicode-escape')
        # firestore_db.collection("Hogar").document(email).collection("Eventos").add(
        #    {"Dispositivo": msg.topic, "Cuerpo": event, "Timestamp": datetime.now()})
        print("pending_activities", pending_activities)
        now = utc.localize(datetime.now())
        for activity in pending_activities:
            hour = activity["Hora"] + timedelta(hours=2)
            if activity["Sensor"] == msg.topic and now >= hour and now <= hour + timedelta(minutes=activity["Margen"]):
                print(f"Actividad {activity['Nombre']} realizada")
                timers[activity["id"]].cancel()
                a = activity.copy()
                del a["id"]
                a["Realizada"] = True
                firestore_db.collection(u'Hogar').document(email).collection("Notificaciones").add(
                    {"Cuerpo": f"Actividad {activity['Nombre']} realizada", "Timestamp": datetime.now()})
                firestore_db.collection(u'Hogar').document(email).collection(
                    "Actividades").document(activity["id"]).update(a)

        for room in firestore_db.collection(u'Hogar').document(email).collection("Habitaciones").list_documents():
            print(" room.get().to_dict()[]",
                  room.get().to_dict()["Sensor"], msg.topic)
            if room.get().to_dict()["Sensor"] == msg.topic:
                room.update({"Ocupada": True})
            else:
                room.update({"Ocupada": False})

        print(friendly_name, json.loads(msg.payload.decode('unicode-escape')))


def mqtt_process():
    client = mqtt.Client()
    client.on_connect = on_connect
    client.on_message = on_message
    client.username_pw_set(
        username=options["mqtt_user"], password=options["mqtt_password"])
    client.connect(options["home_assistant_ip"], 1883, 60)
    client.loop_forever()


# Create an Event for notifying main thread.
callback_done = threading.Event()

# Create a callback on_snapshot function to capture changes


def timer_stop(id, activity):
    print("timer de la actividad", id)
    activity_name = activity["Nombre"]
    firestore_db.collection(u'Hogar').document(email).collection("Notificaciones").add(
        {"Cuerpo": f"Actividad {activity_name} no realizada", "Timestamp": datetime.now()})

    topic = "/topics/"+email.replace("@", ".")

    body = {
        "to": topic,
        "notification": {
            "title":  f"Actividad {activity_name} no realizada",
            "body":  activity["Descripcion"],
            "mutable_content": True,
        },
        "data": {
            "content": {
                "id": random.randint(0, 999999999),
                "channelKey": "basic_channel",
                "title":  f"Actividad {activity_name} no realizada",
                "body": activity["Descripcion"],
            },
        }
    }
    response = requests.post(url, headers=headers, data=json.dumps(body))
    print(response.status_code, response.json())
    timers[id].cancel()


def on_snapshot(doc_snapshot, changes, read_time):

    activities = [i.to_dict() | {"id": i.id} for i in doc_snapshot]
    print(f'Received document snapshot: {activities}\n\n')
    activities = sorted(activities, key=lambda x: x["Hora"])
    now = utc.localize(datetime.now())

    global pending_activities
    pending_activities = [
        i for i in activities if i["Hora"]+timedelta(minutes=i["Margen"], hours=2) > now and not i["Realizada"]]

    for activity in pending_activities:
        hora = activity["Hora"] + timedelta(hours=2)
        # if not activity["Realizada"] and hora+timedelta(minutes=activity["Margen"]) > now:
        print("now", now, "hora", hora)
        delay = (hora + timedelta(
            minutes=activity["Margen"]) - now).total_seconds()
        print("delay", delay)
        id = activity["id"]
        if id in timers:
            timers[id].cancel()
        timers[id] = threading.Timer(
            delay, lambda: timer_stop(id, activity))
        print("Se inicia el timer", id)
        timers[id].start()

    print(timers)
    callback_done.set()


def check_activities():
    firestore_db.collection(u'Hogar').document(
        email).collection("Actividades").on_snapshot(on_snapshot)


t = threading.Thread(target=mqtt_process)
t2 = threading.Thread(target=check_activities)

t.start()
t2.start()
