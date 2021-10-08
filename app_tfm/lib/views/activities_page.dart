import 'package:app_tfm/utils/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'add_activity_page.dart';

class ActivitiesPage extends StatefulWidget {
  final Function(bool) isHideBottomNavBar;

  ActivitiesPage({required this.isHideBottomNavBar});

  @override
  _ActivitiesPageState createState() => _ActivitiesPageState();
}

class _ActivitiesPageState extends State<ActivitiesPage>
    with AutomaticKeepAliveClientMixin<ActivitiesPage> {
  var items = [];
  _ActivitiesPageState() {
    firestoreInstance
        .collection("Hogar")
        .doc(FirebaseAuth.instance.currentUser!.email)
        .collection("Actividades")
        .get()
        .then((querySnapshot) {
      for (var q in querySnapshot.docs) {
        print(q["Nombre"]);
        setState(() {
          items.add(q["Nombre"]);
        });
      }
    });
  }
  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification.depth == 0) {
      if (notification is UserScrollNotification) {
        final UserScrollNotification userScroll = notification;
        switch (userScroll.direction) {
          case ScrollDirection.forward:
            widget.isHideBottomNavBar(true);
            break;
          case ScrollDirection.reverse:
            widget.isHideBottomNavBar(false);
            break;
          case ScrollDirection.idle:
            break;
        }
      }
    }
    return false;
  }

  late int selectedIndex;
  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: Scaffold(
        body: Center(
          child: ListView.separated(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Dismissible(
                key: Key(item),
                onDismissed: (direction) {
                  firestoreInstance
                      .collection("Hogar")
                      .doc(FirebaseAuth.instance.currentUser!.email)
                      .collection("Actividades")
                      .where('Nombre', isEqualTo: items[index])
                      .get()
                      .then((value) {
                    value.docs.forEach((element) {
                      firestoreInstance
                          .collection("Hogar")
                          .doc(FirebaseAuth.instance.currentUser!.email)
                          .collection("Actividades")
                          .doc(element.id)
                          .delete()
                          .then((value) {
                        print("Success!");
                      });
                    });
                  });

                  setState(() {
                    items.removeAt(index);
                  });

                  // Then show a snackbar.
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Actividad $item eliminada')));
                },
                child: ListTile(
                  title: Text(item),
                ),
              );
            },
            separatorBuilder: (BuildContext context, int index) =>
                const Divider(),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            try {
              String result = await Navigator.push(context,
                  MaterialPageRoute(builder: (_) => AddActivityPage()));
              setState(() {
                items.add(result);
              });
            } catch (e) {}
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
