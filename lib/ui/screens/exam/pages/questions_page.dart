import 'package:flutter/material.dart';
import 'package:smartlogic/const/colors.dart';
import 'package:smartlogic/ui/widgets/timer_widget.dart';

class QuestionsPage extends StatefulWidget {
  final Map question;
  final int timer;
  final bool? isVeried;
  //on selected answer
  final Function(dynamic answer) onAnswerSelected, onVerifyCircuit;

  const QuestionsPage({
    super.key,
    required this.question,
    required this.onAnswerSelected,
    required this.timer,
    required this.onVerifyCircuit,
    this.isVeried,
  }); // Assign the global key

  @override
  State<QuestionsPage> createState() => _QuestionsPageState();
}

class _QuestionsPageState extends State<QuestionsPage> {
  static const int maxAttempts = 3;

  int? selectedIndex;
  bool isTimeUp = false;

  // Circuit Simulation State
  bool _isSimulating = false; // True when waiting for MQTT response
  int _verificationAttempts = 0;
  bool? _isVerifiedCorrect; // null, true, or false
  // Handles submitting the answer for any question type
  void _submitAnswer() {
    if (isTimeUp) {
      widget.onAnswerSelected("time_up");
      return;
    }

    if (widget.question['questionType'] == 'MCQ') {
      var answers = widget.question['answers'];
      print("DEBUG: Answers Type: ${answers.runtimeType}");
      print("DEBUG: Value at index: ${answers[selectedIndex!]}");
      // For MCQ, submit the selected index (0, 1, 2, ...)
      if (selectedIndex != null) {
        widget.onAnswerSelected(
          widget.question['answers'][selectedIndex!],
        ); // Submit the actual answer text/value
      } else {
        widget.onAnswerSelected(null); // Unanswered
      }
      // Reset selectedIndex for the next question
      selectedIndex = null;
    } else if (widget.question['questionType'] == 'circuit_simulation') {
      widget.onAnswerSelected(null);
    }
  }

  // New method to handle the circuit verification trigger
  void _startCircuitVerification() {
    if (_verificationAttempts >= maxAttempts) return;

    setState(() {
      _isSimulating = true;
      _verificationAttempts++;
    });

    // Signal the parent ExamScreen to execute the MQTT publish action
    widget.onVerifyCircuit({
      "truthTable": widget.question['truthTable'],
      "attempt": _verificationAttempts,
    });
  }

  @override
  void initState() {
    
    super.initState();
    _isVerifiedCorrect = widget.isVeried;
    _verificationAttempts = 0;
  }

  @override
  void didUpdateWidget(covariant QuestionsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isVeried != widget.isVeried &&
        (widget.isVeried != null || _isSimulating == false)) {
      setState(() {
        _isVerifiedCorrect = widget.isVeried;
        _isSimulating = false; // Add this! Stop the loading spinner
      });
    } else if (oldWidget.question['questionNumber'] != widget.question['questionNumber']) {
      print("New question loaded, resetting simulation state.");
      // Reset state for new question
      setState(() {
        _verificationAttempts = 0;
        _isVerifiedCorrect = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          double sidePadding = constraints.maxWidth * 0.08;
          double fontSize = constraints.maxWidth * 0.025;
          double timerDiameter = constraints.maxWidth * 0.08; // Adjust size

          // Determine if an answer has been selected/entered for button logic
          bool hasMCQAnswer = selectedIndex != null;
          bool isMCQ = widget.question['questionType'] == 'MCQ';
          bool isCircuitSimulation =
              widget.question['questionType'] == 'circuit_simulation';

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
                    // Question Text
                    Flexible(
                      child: Text(
                        "Q${widget.question['questionNumber']} - ${widget.question['questionText']}",
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
                    // Timer
                    TimerWidget(
                      startSeconds: widget.timer,
                      diameter: timerDiameter,
                      onTimerEnd: () {
                        setState(() {
                          selectedIndex = null;
                          isTimeUp = true;
                          // If time is up, submit null to move to next question
                          _submitAnswer();
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Dynamic Content Area (MCQ List or Circuit Simulation Widget)
                Expanded(
                  child: isMCQ
                      ? _buildMCQOptions(fontSize)
                      : isCircuitSimulation
                      ? CircuitSimulationView(
                          onVerifyCircuit: _startCircuitVerification,
                          isVerifying: _isSimulating,
                          isTimeUp: isTimeUp,
                          currentAttempts: _verificationAttempts,
                          isVerifiedCorrect: _isVerifiedCorrect,
                          maxAttempts: maxAttempts,
                          truthTable: widget.question['truthTable'],
                        )
                      : Center(
                          child: Text(
                            "Unsupported Question Type: ${widget.question['questionType']}",
                            style: TextStyle(color: redColor),
                          ),
                        ),
                ),
                const SizedBox(height: 10),
                // Next button container
                Center(
                  child: isMCQ
                      ? _buildMCQNextButton(isTimeUp, hasMCQAnswer)
                      : isCircuitSimulation
                      ? _buildCircuitNextButton()
                      : Container(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildMCQOptions(double fontSize) {
    // ... (MCQ options list logic remains unchanged)
    return ListView.separated(
      itemCount: widget.question['answers']?.length ?? 0,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        bool isSelected = selectedIndex == index;
        return GestureDetector(
          onTap: isTimeUp
              ? null // Disable taps if time is up
              : () {
                  setState(() => selectedIndex = index);
                },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
            decoration: BoxDecoration(
              color: isSelected
                  ? primaryColor.withValues(alpha: 0.4)
                  : darkColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? primaryColor
                    : isTimeUp
                    ? Colors
                          .grey
                          .shade700 // Visually disable answers
                    : greyColor,
                width: isSelected ? 2.5 : 1.3,
              ),
            ),
            child: Text(
              widget.question['answers']![index],
              style: TextStyle(color: whiteColor, fontSize: fontSize),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMCQNextButton(bool isTimeUp, bool hasMCQAnswer) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: (isTimeUp || hasMCQAnswer)
            ? Colors.teal
            : Colors.blueGrey,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        side: isTimeUp
            ? BorderSide(color: redColor, width: 2)
            : BorderSide.none,
      ),
      onPressed: isTimeUp || hasMCQAnswer
          ? _submitAnswer // Submit if selected or time is up (skip)
          : null, // Disabled if no answer selected and time is running
      child: Text(
        isTimeUp ? "Time's Up!" : "Next",
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildCircuitNextButton() {
    final bool canProceed =
        (_isVerifiedCorrect == true) || (_verificationAttempts >= maxAttempts);

    // Only show the next button if the conditions are met
    if (!canProceed) {
      return Container();
    }

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.teal,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      onPressed: _submitAnswer,
      child: Text(
        _isVerifiedCorrect == true
            ? "Next Question"
            : "Skip (Max Attempts Reached)",
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}

// =========================================================================
// CIRCUIT SIMULATION WIDGET
// =========================================================================

class CircuitSimulationView extends StatelessWidget {
  final VoidCallback onVerifyCircuit;
  final Map truthTable;
  final bool isVerifying;
  final bool isTimeUp;
  final int currentAttempts;
  final int maxAttempts;
  final bool? isVerifiedCorrect; // null, true, or false

  const CircuitSimulationView({
    super.key,
    required this.onVerifyCircuit,
    required this.truthTable,
    required this.isVerifying,
    required this.isTimeUp,
    required this.currentAttempts,
    required this.maxAttempts,
    required this.isVerifiedCorrect,
  });

  @override
  Widget build(BuildContext context) {
    final attemptsLeft = maxAttempts - currentAttempts;
    final maxAttemptsReached = currentAttempts >= maxAttempts;
    final isVerificationPossible =
        !isVerifying &&
        !isTimeUp &&
        !maxAttemptsReached &&
        isVerifiedCorrect != true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          "Trainer Board Simulation Mode",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          "Ensure your physical circuit is wired correctly on the trainer board and use the same input and output ports before verification.",
          style: TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 10),

        // Truth Table Display (Inputs visible, Output hidden/revealed)
        Expanded(child: _buildTruthTable()),

        const SizedBox(height: 8),

        // Status Message
        _buildStatusMessage(attemptsLeft, maxAttemptsReached),

        const SizedBox(height: 5),

        // Verify Button
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isTimeUp ? redColor : Colors.lightBlue,
            padding: const EdgeInsets.symmetric(vertical: 10),

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onPressed: isVerificationPossible ? onVerifyCircuit : null,
          child: isVerifying
              ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                    SizedBox(width: 15),
                    Text(
                      "Verifying with Trainer Board...",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                )
              : Text(
                  isTimeUp
                      ? "Time's Up!"
                      : "Verify Circuit (Attempt ${currentAttempts + 1}/$maxAttempts)",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
        ),
      ],
    );
  }

  // Builds the truth table UI
  Widget _buildTruthTable() {
    final inputs = truthTable['inputs'] as List<dynamic>;
    final outputs = truthTable['outputs'] as List<dynamic>;
    final tableData = truthTable['table'] as List<dynamic>;

    final headers = [...inputs, ...outputs];
    final showOutput = isVerifiedCorrect == true;

    return SingleChildScrollView(
      child: Table(
        border: TableBorder.all(color: greyColor),
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        columnWidths: {
          // Dynamic width allocation based on number of headers (3 inputs + 1 output = 4)
          for (int i = 0; i < headers.length; i++)
            i: FlexColumnWidth(i < inputs.length ? 1.0 : 1.5),
        },
        children: [
          // Header Row
          TableRow(
            decoration: BoxDecoration(color: darkColor),
            children: headers
                .map(
                  (header) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        header,
                        style: TextStyle(
                          color: (outputs.contains(header) && !showOutput)
                              ? Colors.white54
                              : Colors.white, // Dim the output header if hidden
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          // Data Rows
          ...tableData.map(
            (row) => TableRow(
              children: headers.map((header) {
                final isOutputColumn = outputs.contains(header);
                final content = isOutputColumn
                    ? (showOutput
                          ? row[header].toString()
                          : "?") // Hide or show output
                    : row[header].toString();

                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      content,
                      style: TextStyle(
                        color: isOutputColumn
                            ? (showOutput ? primaryColor : Colors.white24)
                            : Colors.white70,
                        fontWeight: isOutputColumn && showOutput
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: 20,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // Builds the dynamic status message
  Widget _buildStatusMessage(int attemptsLeft, bool maxAttemptsReached) {
    if (isVerifying) {
      return const Text(
        "Waiting for the board test response ...",
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.yellow, fontSize: 14),
      );
    }

    if (isTimeUp) {
      return const Text(
        "Cannot verify circuit: Time limit exceeded.",
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.redAccent, fontSize: 14),
      );
    }

    if (isVerifiedCorrect == true) {
      return const Text(
        "✅ Verification Successful! Circuit is CORRECT. Press Next.",
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.lightGreen,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    if (isVerifiedCorrect == false) {
      if (maxAttemptsReached) {
        return const Text(
          "❌ Verification Failed. Maximum attempts reached. Press Next to continue.",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.redAccent,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        );
      } else {
        return Text(
          "❌ Verification Failed. Try again. Attempts remaining: $attemptsLeft",
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.orange, fontSize: 16),
        );
      }
    }

    return Text(
      "You have $maxAttempts attempts to verify the circuit.",
      textAlign: TextAlign.center,
      style: const TextStyle(color: Colors.white54, fontSize: 14),
    );
  }
}
