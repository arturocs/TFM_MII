import 'package:flutter/material.dart';

class SimpleScreen extends StatefulWidget {
  final String message;

  SimpleScreen(this.message);
  @override
  _SimpleScreenState createState() => _SimpleScreenState(message);
}

class _SimpleScreenState extends State<SimpleScreen> {
  String _message;
  _SimpleScreenState(this._message);
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(

        title: Text("AppTFM"),
      ),
      body: Center(

        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _message,
            ),

          ],
        ),
      ),
    );
  }
}
