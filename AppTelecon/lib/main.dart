import 'package:flutter/material.dart';
import 'package:moove/login.dart';
import 'package:flutter/material.dart';
// Adicione esta linha

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPage(),
    );
  }
}
