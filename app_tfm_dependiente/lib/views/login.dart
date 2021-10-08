import 'package:app_tfm_dependiente/utils/constants.dart';
import 'package:app_tfm_dependiente/views/notifications_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';


class LoginView extends StatefulWidget {
  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  TextEditingController emailEditingController = new TextEditingController();
  TextEditingController passwordEditingController = new TextEditingController();

  Future<void> LoginButtonPushed() async {
    var password = passwordEditingController.text;
    var email = emailEditingController.text;

    if (emailRegex.hasMatch(email)) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);
        print(userCredential.user);
        FirebaseMessaging.instance.subscribeToTopic(
            FirebaseAuth.instance.currentUser!.email!.replaceFirst("@", "."));
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => NotificationsPage()));
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          Fluttertoast.showToast(msg: 'El usuario no existe');
        } else if (e.code == 'wrong-password') {
          Fluttertoast.showToast(msg: 'Contraseña incorrecta');
        } else {
          Fluttertoast.showToast(msg: e.toString());
        }
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
        title: Text("AppTFM - Inicio de sesión"),
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
                  controller: emailEditingController),
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
                  left: 15.0, right: 15.0, top: 15, bottom: 15),
              //padding: EdgeInsets.symmetric(horizontal: 15),
            ),
            Container(
              height: 50,
              width: 250,
              decoration: BoxDecoration(color: Colors.green),
              child: FlatButton(
                onPressed: LoginButtonPushed,
                child: Text(
                  'Iniciar sesión',
                ),
              ),
            ),
            SizedBox(
              height: 50,
            ),

          ],
        ),
      ),
    );
  }
}
