import 'package:app_tfm/utils/constants.dart';
import 'package:app_tfm/views/add_room_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class RoomPage extends StatefulWidget {
  final Function(bool) isHideBottomNavBar;

  RoomPage({required this.isHideBottomNavBar});

  @override
  _RoomPageState createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage>
    with AutomaticKeepAliveClientMixin<RoomPage> {
  List items = [];

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

  _RoomPageState() {
    print("constructor");
    firestoreInstance
        .collection("Hogar")
        .doc(FirebaseAuth.instance.currentUser!.email)
        .collection("Habitaciones")
        .get()
        .then((querySnapshot) {
      for (var q in querySnapshot.docs) {
        setState(() {
          items.add({"Nombre": q["Nombre"], "Ocupada": q["Ocupada"]});
        });
      }
    });
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
              print(items);
              final item =
                  "${items[index]["Nombre"]}${items[index]["Ocupada"] ? " - Actividad reciente" : ""}";
              return Dismissible(
                key: Key(item),
                onDismissed: (direction) {
                  firestoreInstance
                      .collection("Hogar")
                      .doc(FirebaseAuth.instance.currentUser!.email)
                      .collection("Habitaciones")
                      .where('Nombre', isEqualTo: items[index]["Nombre"])
                      .get()
                      .then((value) {
                    value.docs.forEach((element) {
                      firestoreInstance
                          .collection("Hogar")
                          .doc(FirebaseAuth.instance.currentUser!.email)
                          .collection("Habitaciones")
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
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Habitacion $item eliminada')));
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
              String result = await Navigator.push(
                  context, MaterialPageRoute(builder: (_) => AddRoomPage()));
              setState(() {
                items.add({"Nombre": result, "Ocupada": false});
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
