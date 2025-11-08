import 'package:flutter/material.dart';
import 'package:smartlogic/const/colors.dart';
import 'package:smartlogic/ui/screens/exam/pages/questions_page.dart';

class ExamScreen extends StatefulWidget {
  const ExamScreen({super.key});

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

// Add TickerProviderStateMixin for AnimationController
class _ExamScreenState extends State<ExamScreen> {
  int? selectedIndex;

  final String questionText =
      "Simplify the Boolean function using Karnaugh Map: Y(A, B, C, D)= Σ m(1, 3, 5, 7, 9, 11, 13, 15)\nWhich of the following is the simplified form?";

  final List<String> answers = [
    "Y= B + D",
    "Y= B · D",
    "Y= A + C",
    "Y= A · B + C",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: QuestionsPage(
        question: {'questionText': questionText, 'answers': answers},
      ),
    );
  }
}
