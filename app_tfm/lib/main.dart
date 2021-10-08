import 'package:app_tfm/views/register.dart';
import 'package:app_tfm/views/simple_screen.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'views/bottom_nav_bar.dart';
import 'views/login.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
  //call awesomenotification to how the push notification.
  AwesomeNotifications().createNotificationFromJsonData(message.data);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AwesomeNotifications().initialize(null, [
    NotificationChannel(
        channelKey: 'basic_channel',
        channelName: 'Basic notifications',
        channelDescription: 'Notification channel for basic tests',
        defaultColor: Color(0xFF9D50DD),
        ledColor: Colors.white)
  ]);
  await Firebase
      .initializeApp(); // initialize firebase before actual app get start.
  if (FirebaseAuth.instance.currentUser != null) {
    print(
        "suscribiendose a ${FirebaseAuth.instance.currentUser!.email!.replaceFirst("@", ".")}");
    FirebaseMessaging.instance.subscribeToTopic(
        FirebaseAuth.instance.currentUser!.email!.replaceFirst("@", "."));
  } else {
    print("no hay currentuser");
  }
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging.onMessage.listen(_firebaseMessagingBackgroundHandler);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

MaterialApp createApp(Widget widget) {
  return MaterialApp(
    title: 'AppTFM',
    theme: ThemeData(
      primarySwatch: Colors.green,
    ),
    home: widget,
  );
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize FlutterFire
      future: Firebase.initializeApp(),
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return createApp(SimpleScreen("Ha ocurrido un error"));
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          //Fluttertoast.showToast(msg: "${FirebaseAuth.instance.currentUser}");
          if (FirebaseAuth.instance.currentUser == null) {
            return createApp(LoginView());
          } else {
            return createApp(MainMenuView());
          }
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return createApp(SimpleScreen("Cargando"));
      },
    );
  }
}
