import 'package:juxtapose/juxtapose.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Juxtapose(
        foregroundWidget: Container(color: Colors.lightBlue),
        backgroundWidget: Container(color: Colors.pink),
      ),
    );
  }
}
