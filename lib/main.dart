import 'package:flutter/material.dart';
import 'package:smartlogic/ui/screens/Home/home_screen.dart';
import 'package:smartlogic/ui/screens/exam/exam_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        
       
      ),
      home: const HomeScreen(),
    );
  }
}
