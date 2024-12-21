import 'package:flutter/material.dart';
import 'pages/start_page.dart';

void main() {
  runApp(MaterialApp(
      title: 'Start',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const StartPage()));
}
