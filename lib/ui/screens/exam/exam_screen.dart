import 'package:flutter/material.dart';
import 'package:smartlogic/const/colors.dart';
import 'package:smartlogic/services/api.dart';
import 'package:smartlogic/services/mqtt_service.dart';
import 'package:smartlogic/ui/screens/auth/auth_Screen.dart';
import 'package:smartlogic/ui/screens/exam/pages/questions_page.dart';
// Import the new results screen (you will create this)
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

  @override
  void initState() {
    super.initState();
    // Calculate total possible score once
    _totalPossibleScore = widget.examData['questions'].fold(
      0.0,
      (sum, question) => sum + (question['grade'] as num).toDouble(),
    );
  }

  // New method to process answers and calculate the final score
  void _calculateResults() {
    double calculatedScore = 0.0;
    
    // Check if the number of recorded answers matches the number of questions
    final int numQuestions = widget.examData['questions'].length;

    // The length of _isCorrectList should match the number of questions
    // If not, it means the time ran out before all questions were processed in the loop
    // This padding ensures we don't crash when iterating through results
    if (_isCorrectList.length < numQuestions) {
       // Pad with 'false' for any remaining unanswered questions
       for (int i = _isCorrectList.length; i < numQuestions; i++) {
         _isCorrectList.add(false);
       }
    }


    for (int i = 0; i < numQuestions; i++) {
      final question = widget.examData['questions'][i];
      final double grade = (question['grade'] as num).toDouble();
      
      // If the answer for this question was correct, add its grade to the score
      if (_isCorrectList[i] == true) {
        calculatedScore += grade;
      }
    }
    
    setState(() {
      _finalScore = calculatedScore;
    });
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
              size: screenHeight / screenWidth * 80,
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
                    widget.examData['questions'][_currentQuestionIndex]
                        ['truthTable']??"",
                
                'questionNumber': _currentQuestionIndex + 1,
                'questionTotal': widget.examData['questions'].length,
                'questionType': widget
                    .examData['questions'][_currentQuestionIndex]['questionType'],
                'questionText': widget
                    .examData['questions'][_currentQuestionIndex]['questionText'],
                'answers': widget
                    .examData['questions'][_currentQuestionIndex]['answers'],
              },
              onAnswerSelected: (answer) {
                setState(() {
                  bool isCorrect = false;

                  if (answer == null) {
                    print("No answer selected");
                  } else if (answer == "time_up") {
                    print("Time is up for this question or exam");
                    // If time_up is received, it means we need to fast-forward
                    // and mark all remaining questions as incorrect/unanswered.
                    // The loop below handles the padding correctly now.
                    
                    // First, process the current question as unanswered
                    _isCorrectList.add(false); 
                    _currentQuestionIndex++;
                    
                    // Then, mark all remaining questions as unanswered/incorrect
                    // and advance the index to the end
                    final remainingQuestions = widget.examData['questions'].length - _currentQuestionIndex;
                    for (int i = 0; i < remainingQuestions; i++) {
                        _isCorrectList.add(false);
                        _currentQuestionIndex++;
                    }
                    
                    // Exit setState and let the build method handle the transition to the results screen
                    return; 

                  } else if (answer ==
                      widget
                          .examData['questions'][_currentQuestionIndex]['answer']) {
                    print("Correct answer selected");
                    isCorrect = true;
                  } else {
                    print("Wrong answer selected");
                    isCorrect = false;
                  }

                  _isCorrectList.add(isCorrect);
                  _currentQuestionIndex++; // move to next question
                  
                  // If we have just processed the last question, calculate results
                  if (_currentQuestionIndex >= widget.examData['questions'].length) {
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
