import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smartlogic/const/colors.dart';
import 'package:smartlogic/const/truth_tables.dart'; // Ensure this path is correct for availableCircuits
import 'package:smartlogic/services/mqtt_service.dart';
import 'package:smartlogic/ui/widgets/text_widget.dart';
import 'package:smartlogic/services/api.dart'; // Assuming Api handles MQTT

class SubjectScreen extends StatefulWidget {
  final Map data;
  final Map<String, dynamic> userData, supjectIndo;
  final Api api; // Injecting the API dependency
  final MqttService mqttService;
  const SubjectScreen({
    super.key,
    required this.data,
    required this.api,
    required this.mqttService,
    required this.userData,
    required this.supjectIndo,
  });

  @override
  State<SubjectScreen> createState() => _SubjectScreenState();
}

class _SubjectScreenState extends State<SubjectScreen> {
  String _statusMessage = "";
  bool _testButtonLoading = false;

  String? localPath;
  bool isLoading = true;
  late StreamSubscription mqttSub;

  @override
  void initState() {
    super.initState();
    _preparePdf();

    mqttSub = widget.mqttService.messages.listen((msg) {
      print("📨 Topic: ${msg['topic']}");
      print("📨 Payload: ${msg['payload']}");

      if (msg['topic'] == "MTU/UUID_NOT_SET/status") {
        try {
          final data = json.decode(msg['payload']!);

          if (data.containsKey("command") && data['command'] == "test_report") {
            if (data['success'] == true) {
              
              setState(() {
                _statusMessage = "✅ Circuit verification PASSED!";
                _testButtonLoading = false;
                Map<String, dynamic> uData = widget.userData;

                uData["extra"][widget.supjectIndo["chapters"]][widget
                        .supjectIndo["index"]] =
                    1;

                widget.api.updateUserData(uData["extra"]);
              });
            } else {
              setState(() {
                _statusMessage = "❌ Circuit verification FAILED!";
                _testButtonLoading = false;
              });
            }
          }
        } catch (e) {
          print(e);
        }
      }
    });
  }

  @override
  void dispose() {
    mqttSub.cancel();
    super.dispose();
  }

  /// Copies asset to local storage so the Native Android viewer can read it
  Future<void> _preparePdf() async {
    try {
      final String assetPath = "assets/${widget.data['pdf']}";
      final name = widget.data['pdf'].split('/').last;
      final byteData = await rootBundle.load(assetPath);

      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$name');

      await file.writeAsBytes(byteData.buffer.asUint8List(), flush: true);

      setState(() {
        localPath = file.path;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading PDF: $e");
      setState(() {
        _statusMessage = "Error: Could not load PDF file.";
        isLoading = false;
      });
    }
  }

  // --- MQTT PUBLISH LOGIC ---

  void _publishTruthTableCheck(Map truthTable) async {
    final circuitName = truthTable['content']['circuitName'] ?? "Circuit";
  
    // Convert Map payload to JSON string
    final String payload = jsonEncode(truthTable);
    final String topic =
        "MTU/UUID_NOT_SET/command"; // Assuming a common command topic

    setState(() {
      _statusMessage = "Sending '$circuitName' verification command to ESP...";
    });

    try {
      // Use the injected MqttService to publish
      widget.mqttService.publish(topic, payload);

      // Update status to wait for the result
      setState(() {
        _statusMessage =
            "Command sent! Waiting for verification result for $circuitName...";
      });
    } catch (e) {
      print("MQTT Publish Error: $e");
      setState(() {
        _statusMessage = "Error sending command: $e";
      });
    }
  }

  // --- DIALOGS ---

  void _showVerificationConfirmationDialog(Map truthTable) {
    final circuitName = truthTable['content']['circuitName'] ?? "Circuit";
    final inputs = truthTable['content']['inputs'] as List<dynamic>;
    final outputs = truthTable['content']['outputs'] as List<dynamic>;
    final tableData = truthTable['content']['table'] as List<dynamic>;
    final headers = [...inputs, ...outputs];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: darkColor,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Confirm Wiring for $circuitName',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                icon: Icon(Icons.close, color: redColor),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Before proceeding, ensure your physical circuit on the trainer board matches the $circuitName truth table below. Pay close attention to the input (${inputs.join(', ')}) and output (${outputs.join(', ')}) pin assignments.',
                  style: TextStyle(color: whiteColor, fontSize: 14),
                ),
                const SizedBox(height: 20),

                // Truth Table Preview
                Table(
                  border: TableBorder.all(color: greyColor),
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  columnWidths: {
                    for (int i = 0; i < headers.length; i++)
                      i: const FlexColumnWidth(1.0),
                  },
                  children: [
                    // Header Row
                    TableRow(
                      decoration: BoxDecoration(
                        color: darkColor.withValues(alpha:  0.8),
                      ),
                      children: headers
                          .map(
                            (header) => Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  header,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    // Data Rows (showing only first 4 rows for brevity in dialog)
                    ...tableData
                        .take(4)
                        .map(
                          (row) => TableRow(
                            children: headers
                                .map(
                                  (header) => Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        row[header].toString(),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                  ],
                ),
                if (tableData.length > 4)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      '(${tableData.length - 4} more rows not shown...)',
                      style: TextStyle(color: greyColor, fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            Container(
              padding: const EdgeInsets.only(top: 5, bottom: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: primaryColor,
              ),
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  _publishTruthTableCheck(truthTable); // Publish MQTT message
                  setState(() {
                    _testButtonLoading = true;
                  });
                },
                child: Text(
                  'Start Verification',
                  style: TextStyle(
                    color: darkColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Handles the press event on the "Test Circuit" button
  void _onTestCircuitPressed() {
    final circuitName = widget.data['name'];
    final truthTable = availableCircuits[circuitName];

    if (truthTable != null) {
      // If the circuit exists for this subject, show the confirmation dialog
      _showVerificationConfirmationDialog(truthTable);
    } else {
      // If the subject name doesn't match an available circuit, show an error.
      setState(() {
        _statusMessage =
            "Error: No circuit verification data found for '$circuitName'.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          widget.data['name'] ?? 'Subject Screen',
          style: TextStyle(color: whiteColor),
        ),
        backgroundColor: darkColor,
        leading: const BackButton(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : localPath != null
                ? PDFView(
                    filePath: localPath,
                    enableSwipe: true,
                    autoSpacing: true,
                    pageSnap: true,
                    pageFling: true,
                    onError: (error) =>
                        setState(() => _statusMessage = error.toString()),
                  )
                : Center(
                    child: Text(
                      _statusMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
          ),

          // Status Message
          _statusMessage.isEmpty
              ? Container()
              : Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 8.0,
                  ),
                  child: Text(
                    _statusMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: primaryColor, fontSize: 14),
                  ),
                ),

          // BUTTON AT BOTTOM (Triggers Verification Flow)
          Container(
            padding: const EdgeInsets.only(top: 5.0, bottom: 15.0),
            margin: const EdgeInsets.all(5.0),
            child: _testButtonLoading
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: 250,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed:
                          _onTestCircuitPressed, // Start the verification flow
                      child: TextWidget(
                        text: "Test Circuit on Board",
                        color: darkColor,
                        isTitle: true,
                        textSize: 20,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
