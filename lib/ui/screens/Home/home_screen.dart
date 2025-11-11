import 'package:flutter/material.dart';
import 'package:smartlogic/const/colors.dart';
import 'package:smartlogic/services/api.dart';
import 'package:smartlogic/ui/screens/auth/auth_Screen.dart';
import 'package:smartlogic/ui/widgets/text_widget.dart';

class HomeScreen extends StatefulWidget {
  final Api api;
  const HomeScreen({super.key, required this.api});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> basicChapters = [
    'And Gate',
    'Or Gate',
    'Not Gate',
    'NAND Gate',
    'NOR Gate',
    'XOR Gate',
    'XNOR Gate',
  ];
  List<String> advancedChapters = [
    'Half Adder',
    'Full Adder',
    'Half Subtractor',
    'Full Subtractor',
    'D Flip-Flop',
    'JK Flip-Flop',
    'T Flip-Flop',
    'Decoder',
    'Encoder',
    'Multiplexer',
  ];
  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: TextWidget(
          text: 'Welcome Muntadher',
          color: whiteColor,
          textSize: 30,
          isTitle: true,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: whiteColor, size: screenHeight / screenWidth * 80),
            onPressed: () {
              Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AuthScreen(api: widget.api),
                            ),
                          );
            },
        )],
        backgroundColor: darkColor,

        centerTitle: true,
      ),
      body: ListView(
        shrinkWrap: true,
        children: [
          Container(
            margin: EdgeInsets.all(20),
            padding: EdgeInsets.all(20),

            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: whiteColor2, width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,

              children: [
                TextWidget(
                  text: 'Chapter 1 : Basic Logic Gates',
                  color: whiteColor,
                  textSize: 28,
                  isTitle: true,
                ),
                SizedBox(height: 10),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: basicChapters.length,
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: darkColor,
                      ),
                      margin: EdgeInsets.symmetric(vertical: 5),
                      alignment: Alignment.center,
                      child: ListTile(
                        title: TextWidget(
                          text: '${index + 1} : ${basicChapters[index]}',
                          color: whiteColor,
                          textSize: 26,
                        ),
                        subtitle: TextWidget(
                          text:
                              'Learn about ${basicChapters[index]} and their applications.',
                          color: whiteColor2,
                          textSize: 18,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check,
                              color: greenColor,
                              size: screenHeight / screenWidth * 100,
                            ),
                            SizedBox(width: screenWidth * 0.02),
                            Icon(
                              Icons.arrow_forward,
                              color: whiteColor,
                              size: screenHeight / screenWidth * 100,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          Container(
            margin: EdgeInsets.all(20),
            padding: EdgeInsets.all(20),

            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: whiteColor2, width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,

              children: [
                TextWidget(
                  text: 'Chapter 2 : Logic Circuits',
                  color: whiteColor,
                  textSize: 28,
                  isTitle: true,
                ),
                SizedBox(height: 10),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: advancedChapters.length,
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: darkColor,
                      ),
                      margin: EdgeInsets.symmetric(vertical: 5),
                      alignment: Alignment.center,
                      child: ListTile(
                        title: TextWidget(
                          text:
                              '${index + 1} : ${advancedChapters[index]}',
                          color: whiteColor,
                          textSize: 26,
                        ),
                        subtitle: TextWidget(
                          text:
                              'Learn about ${advancedChapters[index]} and their applications.',
                          color: whiteColor2,
                          textSize: 18,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check,
                              color: greenColor,
                              size: screenHeight / screenWidth * 100,
                            ),
                            SizedBox(width: screenWidth * 0.02),
                            Icon(
                              Icons.arrow_forward,
                              color: whiteColor,
                              size: screenHeight / screenWidth * 100,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
