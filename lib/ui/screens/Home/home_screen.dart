import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:smartlogic/const/colors.dart';
import 'package:smartlogic/models/chapters.dart';
import 'package:smartlogic/services/api.dart';
import 'package:smartlogic/services/mqtt_service.dart';
import 'package:smartlogic/ui/screens/auth/auth_Screen.dart';
import 'package:smartlogic/ui/screens/exam/exam_screen.dart';
import 'package:smartlogic/ui/screens/subject/subject_screen.dart';
import 'package:smartlogic/ui/widgets/list_tile_widget.dart';
import 'package:smartlogic/ui/widgets/text_widget.dart';

class HomeScreen extends StatefulWidget {
  final Api api;

  const HomeScreen({super.key, required this.api});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Chapters chapters = Chapters();
  Map<String, dynamic> userData = {};
  final MqttService mqttService = MqttService();
  late StreamSubscription mqttSub;
  late StreamSubscription<bool> connSub;

  Future getData() async {
    // Example of using the API service
    userData = await widget.api.fetchUserData() ?? {};
    print("userData: $userData");
    if (userData == {} || userData.isEmpty) {
      print("no user data found");
      await widget.api.createUserData({
        "basicChapters": [0, 0, 0, 0, 0, 0, 0],
        "advancedChapters": [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        "grades": [],
      });
      userData = {
        ...userData,
        "extra": {
          "basicChapters": [0, 0, 0, 0, 0, 0, 0],
          "advancedChapters": [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
          "grades": [],
        },

      };
    } else if (userData["profile"].containsKey("extra")) {
      if (userData["profile"]["extra"] == null) {
        print("no extra data found");
        await widget.api.createUserData({
          "basicChapters": [0, 0, 0, 0, 0, 0, 0],
          "advancedChapters": [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
          "grades": [],
        });
        userData = {
          ...userData,
          "extra": {
            "basicChapters": [0, 0, 0, 0, 0, 0, 0],
            "advancedChapters": [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
            "grades": [],
          },
        };
      } else if (userData["profile"]["extra"].isEmpty) {
        print("no extra data found");
        await widget.api.updateUserData({
          "basicChapters": [0, 0, 0, 0, 0, 0, 0],
          "advancedChapters": [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
          "grades": [],
        });
        userData = {
          ...userData,
          "extra": {
            "basicChapters": [0, 0, 0, 0, 0, 0, 0],
            "advancedChapters": [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
            "grades": [],
          },
        };
      } else {
        setState(() {
          print("user data found");
          print(userData);
          print(userData["profile"]["extra"]);
          chapters.userBasicChaptersProgress =
              userData["profile"]["extra"]["basicChapters"];
          chapters.userAdvancedChaptersProgress =
              userData["profile"]["extra"]["advancedChapters"];
        });
      }
    }
  }

  var examPage;

  bool isConnectedToMqtt = false;
  @override
  void initState() {
    super.initState();
    mqttService.init(
      server: 'broker.emqx.io',
      clientId: 'app_id_${DateTime.now().millisecondsSinceEpoch}',
      port: 1883,
    );

    // Listen to MQTT connection status
    connSub = mqttService.connectionStatus.listen((connected) {
      if (connected) {
        print("MQTT is connected → Subscribing to topic...");
        mqttService.subscribe("MTU/BOARD_001/device/status");
        mqttService.subscribe("MTU/BOARD_001/status");
        mqttService.subscribe("MTU/BOARD_001/ADMIN");
        if (mounted) {
          setState(() {
            isConnectedToMqtt = true;
            mqttService.publish( "MTU/BOARD_001/app/status",  userData["name"] ?? "Unknown User", retain: true);
          });
        }
      } else {
        print("MQTT disconnected");
        if (mounted) {
          setState(() {
            isConnectedToMqtt = false;
          });
        }
      }
    });

    // Also listen to messages
    mqttSub = mqttService.messages.listen((msg) {
      print("📨 Topic: ${msg['topic']}");
      print("📨 Payload: ${msg['payload']}");

      if (msg['topic'] == "MTU/BOARD_001/ADMIN") {
        try {
          final data = json.decode(msg['payload']!);

          if (data.containsKey("command") && data['command'] == "EXAM_MODE") {
            print("Entering test mode...");

            if (mounted) {
              if (examPage == null) {
                examPage = Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ExamScreen(
                      api: widget.api,
                      mqttService: mqttService,
                      examData: data['examData'],
                    ),
                  ),
                );
              } else {
                //destroy previous exam page
                Navigator.pop(context);
                examPage = Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ExamScreen(
                      api: widget.api,
                      mqttService: mqttService,
                      examData: data['examData'],
                    ),
                  ),
                );
              }
            }
          }
        } catch (e) {
          print(e);
        }
      }
    });

    getData();
  }

  @override
  void dispose() {
    mqttSub.cancel();
    connSub.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: TextWidget(
          text: 'Welcome ${userData["name"] ?? "User"}',
          color: whiteColor,
          textSize: 28,
          isTitle: true,
        ),
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
        backgroundColor: darkColor,

        centerTitle: true,
      ),
      body: !isConnectedToMqtt
          ? Center(child: CircularProgressIndicator())
          : ListView(
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
                        physics: BouncingScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: chapters.basicChapters.length,
                        itemBuilder: (context, index) {
                          return ListTileWidget(
                            title:
                                '${index + 1} : ${chapters.basicChapters[index]}',
                            subtitle:
                                'Learn about ${chapters.basicChapters[index]} and their applications.',
                            screen: SubjectScreen(
                              data: chapters.sub[index],
                              api: widget.api,
                              mqttService: mqttService,
                              userData: userData,
                              supjectIndo: {
                                "chapters": "basicChapters",
                                "index": index,
                              },
                            ),
                            isCompleted:
                                chapters.userBasicChaptersProgress[index] == 1,
                            onBack: () {
                              getData();
                            },
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
                      SizedBox(height: 5),
                      ListView.builder(
                        physics: BouncingScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: chapters.advancedChapters.length,
                        itemBuilder: (context, index) {
                          return ListTileWidget(
                            title:
                                '${index + 1} : ${chapters.advancedChapters[index]}',
                            subtitle:
                                'Explore the workings of ${chapters.advancedChapters[index]}.',
                            screen: SubjectScreen(
                              data: chapters.sub[index],
                              api: widget.api,
                              mqttService: mqttService,
                              userData: userData,
                              supjectIndo: {
                                "chapters": "advancedChapters",
                                "index": index,
                              },
                            ),
                            isCompleted:
                                chapters.userAdvancedChaptersProgress[index] ==
                                1,
                            onBack: () {
                              getData();
                            },
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
