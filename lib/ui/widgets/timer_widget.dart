import 'dart:async';

import 'package:flutter/material.dart';
import 'package:smartlogic/const/colors.dart';

class TimerWidget extends StatefulWidget {
  final int startSeconds;
  final VoidCallback onTimerEnd;
  final double diameter;
  const TimerWidget({
    super.key,
    required this.startSeconds,
    required this.onTimerEnd,
    this.diameter = 80.0,
  });

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget>
    with TickerProviderStateMixin {
  late int _currentSeconds;
  late AnimationController _controller;
  void startTimer() {
    // A timer to update the text display every second
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel(); // Stop the timer if the widget is removed
        return;
      }
      setState(() {
        if (_currentSeconds > 0) {
          _currentSeconds--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  void _handleTimerEnd() {
    // You can implement what happens when the time runs out here,
    // like automatically selecting an answer or moving to the next question.
    if (mounted) {
      print("Time's up!");
      widget.onTimerEnd();
    }
  }

  @override
  void dispose() {
    _controller.dispose(); // Important: dispose the controller
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _currentSeconds = widget.startSeconds;
    // Initialize the AnimationController
    _controller = AnimationController(
      vsync: this,
      duration: Duration(
        seconds: widget.startSeconds,
      ), // Set duration to total time
    );

    // Start the animation and countdown
    _controller.reverse(
      from: 1.0,
    ); // Start from 1.0 (full circle) and move to 0.0
    startTimer();

    // Listen to animation status changes (e.g., when it finishes)
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        // Timer finished!
        _handleTimerEnd();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: widget.diameter,
          height: widget.diameter,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CircularProgressIndicator(
                value: _controller.value, // Value goes from 1.0 to 0.0
                backgroundColor: darkGreyColor,

                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                strokeWidth: 5.0,
              );
            },
          ),
        ),
        // 2. The time text inside the circle, formatted as MM:SS
        Text(
          // Fix: Use integer division (~) for minutes and padLeft(2, '0') for seconds
          '${_currentSeconds ~/ 60}:${(_currentSeconds % 60).toString().padLeft(2, '0')}',
          style: TextStyle(
            color: whiteColor,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
