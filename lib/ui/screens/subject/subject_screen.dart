import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smartlogic/const/colors.dart';
import 'package:smartlogic/const/truth_tables.dart'; // Ensure this path is correct for availableCircuits
import 'package:smartlogic/services/mqtt_service.dart';
import 'package:smartlogic/ui/widgets/text_widget.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:smartlogic/services/api.dart'; // Assuming Api handles MQTT

class SubjectScreen extends StatefulWidget {
  final Map data;
  final Api api; // Injecting the API dependency
  final MqttService mqttService;
  const SubjectScreen({
    super.key,
    required this.data,
    required this.api,
    required this.mqttService,
  });

  @override
  State<SubjectScreen> createState() => _SubjectScreenState();
}

class _SubjectScreenState extends State<SubjectScreen> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  Uint8List pdfBytes = Uint8List(0);
  String _statusMessage = "";

  @override
  void initState() {
    super.initState();
    loadPdf();
  }

  Future<void> loadPdf() async {
    try {
      pdfBytes = await rootBundle
          .load("assets/${widget.data['pdf']}")
          .then((data) => data.buffer.asUint8List());
    } catch (e) {
      print(
        "Error loading PDF: $e. Check if assets/${widget.data['pdf']} exists.",
      );
      // Optional: Set a placeholder message if PDF loading fails
    }
    setState(() {}); // trigger rebuild
  }

  // --- MQTT PUBLISH LOGIC ---

  void _publishTruthTableCheck(Map truthTable) async {
    final circuitName = truthTable['content']['circuitName'] ?? "Circuit";

    // Convert Map payload to JSON string
    final String payload = jsonEncode(truthTable);
    final String topic =
        "smartlogic/esp/command"; // Assuming a common command topic

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
    final inputs = truthTable['content']['INPUTS'] as List<dynamic>;
    final outputs = truthTable['content']['OUTPUTS'] as List<dynamic>;
    final tableData = truthTable['content']['DATA'] as List<dynamic>;
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
                style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
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
                      i: const FlexColumnWidth(1.0)
                  },
                  children: [
                    // Header Row
                    TableRow(
                      decoration: BoxDecoration(color: darkColor.withOpacity(0.8)),
                      children: headers.map((header) => Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            header,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      )).toList(),
                    ),
                    // Data Rows (showing only first 4 rows for brevity in dialog)
                    ...tableData.take(4).map((row) => TableRow(
                      children: headers.map((header) => Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            row[header].toString(),
                            style: TextStyle(color: Colors.white70, fontSize: 16),
                          ),
                        ),
                      )).toList(),
                    )),
                  ],
                ),
                if (tableData.length > 4)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      '(${tableData.length - 4} more rows not shown...)',
                      style: TextStyle(color: greyColor, fontSize: 12),
                    ),
                  )
              ],
            ),
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            
            Container(
              padding: const EdgeInsets.only(top: 5, bottom: 5),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: primaryColor),
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  _publishTruthTableCheck(truthTable); // Publish MQTT message
                },
                child: Text('Start Verification', style: TextStyle(color: darkColor, fontWeight: FontWeight.bold)),
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
        _statusMessage = "Error: No circuit verification data found for '$circuitName'.";
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
          // PDF Viewer
          pdfBytes.isEmpty
              ? const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              : Expanded(
                  child: SfPdfViewer.memory(
                    pdfBytes,
                    key: _pdfViewerKey,
                    scrollDirection: PdfScrollDirection.vertical,
                    pageSpacing: 0,
                    enableDoubleTapZooming: true,
                  ),
                ),

          // Status Message
          Padding(
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
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SizedBox(
              width: 250,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _onTestCircuitPressed, // Start the verification flow
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