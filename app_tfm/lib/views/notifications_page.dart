import 'package:app_tfm/utils/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class NotificationsPage extends StatefulWidget {
  final Function(bool) isHideBottomNavBar;

  NotificationsPage({required this.isHideBottomNavBar});

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage>
    with AutomaticKeepAliveClientMixin<NotificationsPage> {
  var items = [];
  _NotificationsPageState(){

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
                      .collection("Notificaciones")
                      .where('Cuerpo', isEqualTo: items[index])
                      .get()
                      .then((value) {
                    value.docs.forEach((element) {
                      firestoreInstance
                          .collection("Hogar")
                          .doc(FirebaseAuth.instance.currentUser!.email)
                          .collection("Notificaciones")
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
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text('Notificacion eliminada')));
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
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
