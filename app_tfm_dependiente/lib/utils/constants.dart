import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final emailRegex = RegExp(
    r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');

final FirebaseAuth auth = FirebaseAuth.instance;
final firestoreInstance = FirebaseFirestore.instance;
const fall_velocity = 9;
const serverToken = "SERVER_TOKEN";
const fcm_url  = "https://fcm.googleapis.com/fcm/send";
