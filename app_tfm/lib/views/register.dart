import 'package:app_tfm/utils/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'bottom_nav_bar.dart';

class RegisterView extends StatefulWidget {
  @override
  _RegisterViewState createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  TextEditingController emailEditingController = new TextEditingController();
  TextEditingController passwordEditingController = new TextEditingController();
  TextEditingController repeatPasswordEditingController =
      new TextEditingController();

  Future<void> RegisterButtonPushed() async {
    var password = passwordEditingController.text;
    var repeatedPassword = repeatPasswordEditingController.text;
    var email = emailEditingController.text;
    print("$password, $repeatedPassword, $email");
    if (emailRegex.hasMatch(email)) {
      if (password == repeatedPassword) {
        try {
          UserCredential userCredential = await FirebaseAuth.instance
              .createUserWithEmailAndPassword(email: email, password: password);
          print(userCredential.user);
          FirebaseMessaging.instance.subscribeToTopic(
              FirebaseAuth.instance.currentUser!.email!.replaceFirst("@", "."));
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => MainMenuView()));
        } on FirebaseAuthException catch (e) {
          if (e.code == 'weak-password') {
            Fluttertoast.showToast(msg: 'La contraseña es demasiado debil');
          } else if (e.code == 'email-already-in-use') {
            Fluttertoast.showToast(msg: 'Ya existe un usuario con ese email');
          }
        } catch (e) {
          Fluttertoast.showToast(msg: e.toString());
        }
      } else {
        Fluttertoast.showToast(
          msg: "Las contraseñas son distintas",
        );
      }
    } else {
      Fluttertoast.showToast(
        msg: "Email inválido",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("AppTFM - Registrar hogar"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 60.0),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: TextField(
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Email',
                    hintText: 'Introduce tu email'),
                controller: emailEditingController,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 15.0, right: 15.0, top: 15, bottom: 0),
              //padding: EdgeInsets.symmetric(horizontal: 15),
              child: TextField(
                obscureText: true,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Contraseña',
                    hintText: 'Introduce tu contraseña'),
                controller: passwordEditingController,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 15.0, right: 15.0, top: 15, bottom: 0),
              //padding: EdgeInsets.symmetric(horizontal: 15),
              child: TextField(
                obscureText: true,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Vuelve a introducir tu contraseña',
                    hintText: 'Vuelve a introducir tu contraseña'),
                controller: repeatPasswordEditingController,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 15.0, right: 15.0, top: 15, bottom: 15),
              //padding: EdgeInsets.symmetric(horizontal: 15),
            ),
            Container(
              height: 50,
              width: 250,
              decoration: BoxDecoration(color: Colors.green),
              child: FlatButton(
                onPressed: RegisterButtonPushed,
                child: Text(
                  'Registrar',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
