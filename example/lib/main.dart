import 'package:juxtapose/juxtapose.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Juxtapose Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Juxtapose(
        foregroundWidget: Container(
          alignment: Alignment.center,
          color: Colors.blue,
          child: Text(
            "Juxtapose",
            style: TextStyle(color: Colors.white, fontSize: 40),
          ),
        ),
        backgroundWidget: Container(
          alignment: Alignment.center,
          color: Colors.pink,
          child: Text(
            "Juxtapose",
            style: TextStyle(color: Colors.black, fontSize: 40),
          ),
        ),
      ),
    );
  }
}
