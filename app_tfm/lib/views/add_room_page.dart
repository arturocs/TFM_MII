import 'package:app_tfm/utils/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddRoomPage extends StatefulWidget {
  static const String routeName = '/tab';
  @override
  _State createState() => _State();
}

class _State extends State<AddRoomPage> {
  TextEditingController nameController = TextEditingController();
  void addItemToList() {
    firestoreInstance
        .collection("Hogar")
        .doc(FirebaseAuth.instance.currentUser!.email)
        .collection("Habitaciones")
        .add({
      "Nombre": nameController.text,
      "Sensor": "zigbee2mqtt/$selected",
      "Ocupada": false
    });
    Navigator.pop(context, nameController.text);
  }

  _State() {
    firestoreInstance
        .collection("Hogar")
        .doc(FirebaseAuth.instance.currentUser!.email)
        .collection("Sensores")
        .get()
        .then((querySnapshot) {
      for (var q in querySnapshot.docs){
        print(q["Nombre"]);
        setState(() {
          items.add(q["Nombre"]);
        });
      }
    });
  }

  String selected = "";
  var items = [];
  @override
  Widget build(BuildContext context) {
    var children = <Widget>[
      Padding(
        padding: EdgeInsets.all(20),
        child: TextField(
          controller: nameController,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Nombre de la habitación',
          ),
        ),
      ),
    ];

    children.addAll(items.map((device) {
      return RadioListTile<String>(
        title: Text(device),
        value: device,
        groupValue: selected,
        onChanged: (value) {
          setState(() {
            selected = value!;
          });
        },
      );
    }));

    children.add(
      RaisedButton(
        child: Text('Añadir'),
        onPressed: () {
          addItemToList();
        },
      ),
    );
    return Scaffold(
        appBar: AppBar(
          title: Text('AppTFM - Añadir habitaciones'),
        ),
        body: SingleChildScrollView(child: Column(children: children)));
  }
}
