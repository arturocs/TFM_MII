import 'package:app_tfm/views/rooms_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'activities_page.dart';
import 'notifications_page.dart';

class MainMenuView extends StatefulWidget {
  const MainMenuView({Key? key}) : super(key: key);

  @override
  _MainMenuViewState createState() => _MainMenuViewState();
}

class _MainMenuViewState extends State<MainMenuView> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    FirebaseMessaging.instance.subscribeToTopic("yourTopicName");
    List<Widget> _pages = <Widget>[
      RoomPage(
        isHideBottomNavBar: (value) {
          return false;
        },
      ),
      ActivitiesPage(
        isHideBottomNavBar: (value) {
          return false;
        },
      ),
      NotificationsPage(
        isHideBottomNavBar: (value) {
          return false;
        },
      ),
    ];

    return Scaffold(
      appBar:
          AppBar(title: const Text('AppTFM'), automaticallyImplyLeading: false),
      body: Center(
        child: _pages.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Habitaciones',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_walk),
            label: 'Actividades',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_none),
            label: 'Historial de eventos',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
