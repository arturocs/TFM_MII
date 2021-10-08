import 'dart:convert';
import 'dart:math';
import 'package:app_tfm_dependiente/utils/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:http/http.dart' as http;

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  var items = [];
  Random random = Random();
  var last_notification_time = DateTime.now();
  _NotificationsPageState() {
    userAccelerometerEvents.listen((UserAccelerometerEvent event) {
      var eventSpeed =
          sqrt(pow(event.x, 2) + pow(event.y, 2) + pow(event.z, 2));
      var now = DateTime.now();
      //print("$now $last_notification_time ${now.difference(last_notification_time)}");
      if (eventSpeed > fall_velocity &&
          (now.difference(last_notification_time)) > Duration(seconds: 2)) {
        print(event);

        String topic = "/topics/" +
            FirebaseAuth.instance.currentUser!.email!.replaceAll("@", ".");
        http.post(
          Uri.parse(fcm_url),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'key=' + serverToken,
          },
          body: jsonEncode({
            "to": topic,
            "notification": {
              "title": "¡Posible caida detectada!",
              "body": "Se ha detectado una posible caida a las $now",
              "mutable_content": true,
            },
            "data": {
              "content": {
                "id": random.nextInt(999999999),
                "channelKey": "basic_channel",
                "title": "¡Posible caida detectada!",
                "body": "Se ha detectado una posible caida a las $now",
              },
            }
          }),
        );
        String cuerpo =
            "Posible caida detectada el ${now.day}-${now.month}-${now.year} a las ${now.hour}:${now.minute}:${now.second}!";
        firestoreInstance
            .collection("Hogar")
            .doc(FirebaseAuth.instance.currentUser!.email)
            .collection("Notificaciones")
            .where("Cuerpo", isEqualTo: cuerpo)
            .get()
            .then((doc) {
          print("doc $doc");
          if (doc.docs.isEmpty) {
            firestoreInstance
                .collection("Hogar")
                .doc(FirebaseAuth.instance.currentUser!.email)
                .collection("Notificaciones")
                .add({
              "Cuerpo": cuerpo,
              "Timestamp": now,
            });
          }
        });

        Fluttertoast.showToast(
            msg: "Caida detectada",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);

        last_notification_time = now;
      }
    });

    firestoreInstance
        .collection("Hogar")
        .doc(FirebaseAuth.instance.currentUser!.email)
        .collection("Notificaciones")
        .get()
        .then((querySnapshot) {
      for (var q in querySnapshot.docs) {
        setState(() {
          items.add(q["Cuerpo"]);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("AppTFM - persona dependiente"),
          automaticallyImplyLeading: false),
      body: Center(
        child: ListView.separated(
          itemCount: items.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text('${items[index]}'),
            );
          },
          separatorBuilder: (BuildContext context, int index) =>
              const Divider(),
        ),
      ),
    );
  }
}
