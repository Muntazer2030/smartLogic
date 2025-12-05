import 'package:flutter/material.dart';
import 'package:smartlogic/const/colors.dart';
import 'package:smartlogic/services/api.dart';
import 'package:smartlogic/ui/screens/auth/auth_Screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final Api api = Api();
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: buildDarkTheme(),
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      home: AuthScreen(api: api),
    );
  }
}
