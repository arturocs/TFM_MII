import 'package:app_tfm/utils/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

class AddActivityPage extends StatefulWidget {
  static const String routeName = '/add_activity';

  @override
  _AddActivityPageState createState() => _AddActivityPageState();
}

class _AddActivityPageState extends State<AddActivityPage> {

  late double _height;
  late double _width;

  late String? _setTime, _setDate;

  late String _hour, _minute, _time;

  late String dateTime;

  DateTime selectedDate = DateTime.now();

  TimeOfDay selectedTime = TimeOfDay.now();

  TextEditingController _dateController = TextEditingController();
  TextEditingController _timeController = TextEditingController();

  TextEditingController marginEditingController = new TextEditingController();
  TextEditingController nameController = TextEditingController();

  TextEditingController descriptionEditingController =
      new TextEditingController();
  Future<Null> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        initialDatePickerMode: DatePickerMode.day,
        firstDate: DateTime(2021),
        lastDate: DateTime(2101));
    if (picked != null)
      setState(() {
        selectedDate = picked;
        _dateController.text =
            "${selectedDate.day}-${selectedDate.month}-${selectedDate.year} ${selectedTime.hour}:${selectedTime.minute}";
      });
  }

  Future<Null> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked != null)
      setState(() {
        selectedTime = picked;
        _hour = selectedTime.hour.toString();
        _minute = selectedTime.minute.toString();
        _time = _hour + ' : ' + _minute;
        _timeController.text =
            "${selectedDate.day}-${selectedDate.month}-${selectedDate.year} ${selectedTime.hour} : ${selectedTime.minute}";
      });
  }

  var items = [];
  _AddActivityPageState() {
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
  String? _character = "";

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    String selected = "";

    var children = <Widget>[
      Padding(
        padding: EdgeInsets.all(10),
        child: TextField(
          controller: nameController,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Nombre de la actividad',
          ),
        ),
      ),
      Padding(
        padding: EdgeInsets.all(10),
        child: TextField(
          controller: descriptionEditingController,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Descripción de la actividad',
          ),
        ),
      ),
      InkWell(
        onTap: () {
          _selectTime(context);
          _selectDate(context);
        },
        child: Container(
          margin: EdgeInsets.all(10),
          alignment: Alignment.center,
          child: TextFormField(
            textAlign: TextAlign.center,
            enabled: false,
            keyboardType: TextInputType.text,
            controller: _dateController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Fecha y hora de la actividad',
            ),
          ),
        ),
      ),
      Padding(
        padding: EdgeInsets.all(10),
        child: TextFormField(
          controller: marginEditingController,
          keyboardType: TextInputType.numberWithOptions(signed: false, decimal: true),
         /* inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.allow(RegExp(r'[0-9]|"."')),
          ],*/
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Margen de tiempo',
          ),
        ),
      ),
      Padding(
        padding: EdgeInsets.all(10),
        child: Text("Sensor asociado:"),
      )
    ];

    children.addAll(items.map((device) {
      return RadioListTile<String>(
        title: Text(device),
        value: device,
        groupValue: _character,
        onChanged: (String? value) {
          setState(() {
            _character = value!;
          });
        },
      );
    }));
    children.addAll([
      RaisedButton(
        child: Text('Añadir'),
        onPressed: () {
          DateTime hour = DateTime(selectedDate.year, selectedDate.month,
              selectedDate.day, selectedTime.hour, selectedTime.minute);
          firestoreInstance
              .collection("Hogar")
              .doc(FirebaseAuth.instance.currentUser!.email)
              .collection("Actividades")
              .add({
            "Nombre": nameController.text,
            "Hora": hour,
            "Margen": double.parse(marginEditingController.text),
            "Descripcion": descriptionEditingController.text,
            "Sensor": "zigbee2mqtt/$_character",
            "Realizada": false
          });
          Navigator.pop(context, nameController.text);
        },
      )
    ]);
    return Scaffold(
      appBar: AppBar(title: Text("AppTFM - Añadir nueva actividad")),
      body: SingleChildScrollView(
        child: Column(
          children: children,
        ),
      ),
    );
  }
}
