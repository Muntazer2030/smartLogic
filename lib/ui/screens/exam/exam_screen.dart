import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:smartlogic/const/colors.dart';
import 'package:smartlogic/services/api.dart';
import 'package:smartlogic/services/mqtt_service.dart';
import 'package:smartlogic/ui/screens/auth/auth_Screen.dart';
import 'package:smartlogic/ui/screens/exam/pages/questions_page.dart';
import 'package:smartlogic/ui/screens/exam/pages/exam_results_page.dart';

class ExamScreen extends StatefulWidget {
  final MqttService mqttService;
  final Api api;
  final Map examData;
  const ExamScreen({
    super.key,
    required this.mqttService,
    required this.api,
    required this.examData,
  });

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  int _currentQuestionIndex = 0;
  // Stores true for correct, false for incorrect/unanswered
  List<bool> _isCorrectList = [];
  double _finalScore = 0.0;
  double _totalPossibleScore = 0.0;
  bool? verfiyState;
  late StreamSubscription mqttSub;
  @override
  void initState() {
    super.initState();
    // Calculate total possible score once
    _totalPossibleScore = widget.examData['questions'].fold(
      0.0,
      (sum, question) => sum + (question['grade'] as num).toDouble(),
    );

    mqttSub = widget.mqttService.messages.listen((msg) {
      print("📨 Topic: ${msg['topic']}");
      print("📨 Payload: ${msg['payload']}");

      if (msg['topic'] == "MTU/BOARD_001/status") {
        try {
          final data = json.decode(msg['payload']!);

          if (data.containsKey("command") && data['command'] == "test_report") {
            if (data['success'] == true) {
              setState(() {
                verfiyState = true;
              });
            } else {
              setState(() {
                verfiyState = false;
                print("Verification failed");
              });
            }
          }
        } catch (e) {
          print(e);
        }
      }
    });
  }

  // --- MQTT PUBLISH LOGIC ---
  @override
  void dispose() {
    mqttSub.cancel();
    super.dispose();
  }

  void _publishTruthTableCheck(Map truthTable) async {
    setState(() {
      verfiyState = null;
    });
    Map<String, dynamic> cmd = {
      "command": "check_truth_table",
      "content": truthTable,
    };

    // Convert Map payload to JSON string
    final String payload = jsonEncode(cmd);
    final String topic =
        "MTU/BOARD_001/command"; // Assuming a common command topic
    try {
      // Use the injected MqttService to publish
      widget.mqttService.publish(topic, payload);
    } catch (e) {
      print("MQTT Publish Error: $e");
    }
  }

  // New method to process answers and calculate the final score
  // Update _calculateResults to call the API function at the end
  void _calculateResults() {
    print("Calculating final results...");
    double calculatedScore = 0.0;
    final int numQuestions = widget.examData['questions'].length;

    if (_isCorrectList.length < numQuestions) {
      for (int i = _isCorrectList.length; i < numQuestions; i++) {
        _isCorrectList.add(false);
      }
    }

    for (int i = 0; i < numQuestions; i++) {
      final question = widget.examData['questions'][i];
      final double grade = (question['grade'] as num).toDouble();

      if (_isCorrectList[i] == true) {
        calculatedScore += grade;
      }
    }

    setState(() {
      _finalScore = calculatedScore;
    });

    // NEW: Trigger API call once score is calculated
    _sendExamReportToApi();
  }

  // NEW: Constructs the detailed JSON and sends it via API
  void _sendExamReportToApi() async {
    List<Map<String, dynamic>> detailedResults = [];
    
    // Build a detailed report for every question
    for (int i = 0; i < widget.examData['questions'].length; i++) {
      detailedResults.add({
        "questionNumber": i + 1,
        "questionType": widget.examData['questions'][i]['questionType'],
        "questionText": widget.examData['questions'][i]['questionText'],
        "gradeWeight": widget.examData['questions'][i]['grade'],
        "isCorrect": _isCorrectList[i],
      });
    }

    // Assemble the final JSON payload
    Map<String, dynamic> reportPayload = {
      "subject": widget.examData['examName'] ?? "Circuit Simulation Exam",
      "score": _finalScore,
      "totalPossibleScore": _totalPossibleScore,
      "date": DateTime.now().toIso8601String(), // Current date & time
      "details": detailedResults, 
    };

    try {
      print("Sending exam report...");
      // Using the injected API service to send the report
      final response = await widget.api.sendExamReport(reportPayload);
      print("API Response: $response");
    } catch (e) {
      print("Failed to send exam report to server: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: darkColor,
        title: Text(
          widget.examData['examName'] ?? "Exam Screen",
          style: TextStyle(color: whiteColor),
        ),
        leading: Container(),
        actions: [
          IconButton(
            icon: Icon(
              Icons.logout,
              color: whiteColor,
              size: screenHeight / screenWidth * 60,
            ),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => AuthScreen(api: widget.api),
                ),
              );
            },
          ),
        ],
        centerTitle: true,
      ),
      backgroundColor: backgroundColor,
      body: _currentQuestionIndex < widget.examData['questions'].length
          ? QuestionsPage(
              question: {
                "truthTable":
                    widget
                        .examData['questions'][_currentQuestionIndex]['truthTable'] ??
                    "",

                'questionNumber': _currentQuestionIndex + 1,
                'questionTotal': widget.examData['questions'].length,
                'questionType': widget
                    .examData['questions'][_currentQuestionIndex]['questionType'],
                'questionText': widget
                    .examData['questions'][_currentQuestionIndex]['questionText'],
                'answers': widget
                    .examData['questions'][_currentQuestionIndex]['answers'],
              },

              onVerifyCircuit: (answer) {
                print("Verifying circuit via MQTT...");
                _publishTruthTableCheck(answer['truthTable']);
              },
              isVeried: verfiyState,
              onAnswerSelected: (answer) {
                setState(() {
                  bool isCorrect = false;
                  verfiyState = null;
                  // --- CASE 1: TIME IS UP ---
                  if (answer == "time_up") {
                    print("Time is up");

                    // 1. Mark current question as false
                    _isCorrectList.add(false);
                    _currentQuestionIndex++;

                    // 2. Mark remaining questions as false
                    final remainingQuestions =
                        widget.examData['questions'].length -
                        _currentQuestionIndex;
                    for (int i = 0; i < remainingQuestions; i++) {
                      _isCorrectList.add(false);
                      _currentQuestionIndex++;
                    }

                    // 3. CRITICAL FIX: Calculate results BEFORE returning
                    _calculateResults();

                    return; // Now it's safe to return, finalScore is updated
                  }

                  // --- CASE 2: NORMAL ANSWER ---
                  if (answer == null) {
                    print("No answer selected");
                    isCorrect = false; 
                  } else if (answer is bool) {
                    
                    print("Circuit verification result: $answer");
                    isCorrect = answer;
                  } else if (answer == widget.examData['questions'][_currentQuestionIndex]['answer']) {
                    print("Correct answer selected");
                    isCorrect = true;
                  } else {
                    print("Wrong answer selected");
                    isCorrect = false;
                  }

                  // Add result and move next
                  _isCorrectList.add(isCorrect);
                  _currentQuestionIndex++;

                  // --- CHECK END OF EXAM ---
                  if (_currentQuestionIndex >=
                      widget.examData['questions'].length) {
                    _calculateResults();
                  }
                });
              },
              timer: widget.examData['timeLimit'],
            )
          : ExamResultsPage(
              finalScore: _finalScore,
              totalPossibleScore: _totalPossibleScore,
              // You can pass the detailed results list if needed for review
              isCorrectList: _isCorrectList,
            ),
    );
  }
}
