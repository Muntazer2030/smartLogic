import 'package:flutter/material.dart';
import 'package:smartlogic/const/colors.dart';

class ExamResultsPage extends StatelessWidget {
  final double finalScore;
  final double totalPossibleScore;
  final List<bool> isCorrectList;

  const ExamResultsPage({
    super.key,
    required this.finalScore,
    required this.totalPossibleScore,
    required this.isCorrectList,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate percentage for display
    final double percentage = (finalScore / totalPossibleScore) * 100;
    final int correctCount = isCorrectList
        .where((isCorrect) => isCorrect)
        .length;
    final int totalQuestions = isCorrectList.length;

    return Center(
      child: Container(
        padding: const EdgeInsets.all(100),
        decoration: BoxDecoration(
          color: darkColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "📝 Exam Finished!",
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Your Score: ${finalScore.toStringAsFixed(1)} / ${totalPossibleScore.toStringAsFixed(1)}",
              style: const TextStyle(color: Colors.white, fontSize: 24),
            ),
            const SizedBox(height: 10),
            Text(
              "Percentage: ${percentage.toStringAsFixed(1)}%",
              style: TextStyle(
                color: percentage >= 50 ? Colors.greenAccent : Colors.redAccent,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Correct Answers: $correctCount out of $totalQuestions",
              style: const TextStyle(color: Colors.white70, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
