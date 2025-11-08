import 'package:flutter/material.dart';
import 'package:smartlogic/const/colors.dart';
import 'package:smartlogic/ui/widgets/timer_widget.dart';

class QuestionsPage extends StatefulWidget {
  final Map question;


  const QuestionsPage({super.key, required this.question});

  @override
  State<QuestionsPage> createState() => _QuestionsPageState();
}

class _QuestionsPageState extends State<QuestionsPage> {
  int? selectedIndex;
  bool isTimeUp = false;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            double sidePadding = constraints.maxWidth * 0.08;
            double fontSize = constraints.maxWidth * 0.03;
            double timerDiameter = constraints.maxWidth * 0.08; // Adjust size

            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: sidePadding,
                vertical: 30,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Timer and Question Header
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Timer (placed on the left, for example)

                      // Question
                      Flexible(
                        child: Text(
                          widget.question['questionText']??"Unknown Question",
                          maxLines: 4,
                          style: TextStyle(
                            color: whiteColor,
                            fontSize: fontSize,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 20),
                      TimerWidget(
                        startSeconds: widget.question['timeLimit'] ?? 10,
                        diameter: timerDiameter,
                        onTimerEnd: () {
                          setState(() {
                        
                            selectedIndex = null;
                            isTimeUp = true;
                          });
                        },

                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // Answer options
                  Expanded(
                    child: ListView.separated(
                      itemCount:widget.question['answers']?.length??0,
                      separatorBuilder: (_, __) => const SizedBox(height: 18),
                      itemBuilder: (context, index) {
                        bool isSelected = selectedIndex == index;
                        return GestureDetector(
                          onTap: () {
                            setState(() => selectedIndex = index);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              vertical: 22,
                              horizontal: 18,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? primaryColor.withValues(alpha: 0.4)
                                  : darkColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? primaryColor : greyColor,
                                width: isSelected ? 2.5 : 1.3,
                              ),
                            ),
                            child: Text(
                              widget.question['answers']![index],
                              style: TextStyle(
                                color: whiteColor,
                                fontSize: fontSize,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Next button
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 18,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        // Disable if time is up or no answer is selected
                        side: isTimeUp
                            ? BorderSide(color: redColor, width: 2)
                            : BorderSide.none,
                      ),
                      // Disable the button when time is 0 or no answer is selected
                      onPressed: selectedIndex == null || isTimeUp
                          ? null
                          : () {
                              // TODO: Go to next question
                              
                            },
                      child: Text(
                        isTimeUp  ? "Time's Up!" : "Next",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
  }
}



