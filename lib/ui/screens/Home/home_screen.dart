import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:smartlogic/const/colors.dart';
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
  final MqttService mqttService = MqttService();
  late StreamSubscription mqttSub;
  late StreamSubscription<bool> connSub;
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
  List<Map> sub = [
    {'pdf': 'and_gate.pdf','name':'And Gate'},
    {'pdf': 'and_gate.pdf','name':'Or Gate'},
    {'pdf': 'not_gate.pdf','name':'Not Gate'},
    {'pdf': 'and_gate.pdf','name':'NAND Gate'},
    {'pdf': 'and_gate.pdf','name':'XOR Gate'},
    {'pdf': 'and_gate.pdf','name':''},
    {'pdf': 'and_gate.pdf','name':''},
    {'pdf': 'and_gate.pdf','name':''},
    {'pdf': 'and_gate.pdf','name':''},
    {'pdf': 'and_gate.pdf','name':''},
  ];

  List userBasicChaptersProgress = [1, 0, 0, 0, 0, 0, 0];
  List userAdvancedChaptersProgress = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

  Future getData() async {
    return;
    // Example of using the API service
    var data = await widget.api.fetchUserData();
    print(data);
    if (data == null) {
      await widget.api.createUserData({
        "basicChapters": [0, 0, 0, 0, 0, 0, 0],
        "advancedChapters": [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        "grades": [],
      });
    } else if (data is Map && data.containsKey("extra")) {
      if (data["extra"] == null) {
        await widget.api.createUserData({
          "basicChapters": [0, 0, 0, 0, 0, 0, 0],
          "advancedChapters": [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
          "grades": [],
        });
      } else {
        setState(() {
          userBasicChaptersProgress = data["extra"]["basicChapters"];
          userAdvancedChaptersProgress = data["extra"]["advancedChapters"];
        });
      }
    }
  }

  bool isConnectedToMqtt = false;
  @override
  void initState() {
    super.initState();
    mqttService.init(
      server: 'test.mosquitto.org',
      clientId: 'app_id_${DateTime.now().millisecondsSinceEpoch}',
      port: 1883,
    );

    // Listen to MQTT connection status
    connSub = mqttService.connectionStatus.listen((connected) {
      if (connected) {
        print("MQTT is connected → Subscribing to topic...");
        mqttService.subscribe("MTU/UUID_NOT_SET/device/status");
        mqttService.subscribe("MTU/ADMIN");
        if (mounted) {
          setState(() {
            isConnectedToMqtt = true;
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

      if (msg['topic'] == "MTU/ADMIN") {
        try {
          final data = json.decode(msg['payload']!);

          if (data.containsKey("command") && data['command'] == "EXAM_MODE") {
            print("Entering test mode...");

            if (mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ExamScreen(api: widget.api, mqttService: mqttService, examData: data['examData'],)),
              );
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
          text: 'Welcome Muntadher',
          color: whiteColor,
          textSize: 30,
          isTitle: true,
        ),
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
                        shrinkWrap: true,
                        itemCount: basicChapters.length,
                        itemBuilder: (context, index) {
                          return ListTileWidget(
                            title: '${index + 1} : ${basicChapters[index]}',
                            subtitle:
                                'Learn about ${basicChapters[index]} and their applications.',
                            screen: SubjectScreen(data: sub[index], api: widget.api, mqttService: mqttService,),
                            isCompleted: userBasicChaptersProgress[index] == 1,
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
                          return ListTileWidget(
                            title: '${index + 1} : ${advancedChapters[index]}',
                            subtitle:
                                'Explore the workings of ${advancedChapters[index]}.',
                            screen: SubjectScreen(data: sub[index], api: widget.api, mqttService: mqttService,),
                            isCompleted:
                                userAdvancedChaptersProgress[index] == 1,
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
