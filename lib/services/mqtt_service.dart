import 'dart:async';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService {
  static final MqttService _instance = MqttService._internal();
  factory MqttService() => _instance;
  MqttService._internal();

  late MqttServerClient _client;

  // Stream for all incoming messages
  final StreamController<Map<String, String>> _messageStreamController =
      StreamController<Map<String, String>>.broadcast();

  Stream<Map<String, String>> get messages => _messageStreamController.stream;

  // Connection status stream
  final StreamController<bool> _connectionStreamController =
      StreamController<bool>.broadcast();
  Stream<bool> get connectionStatus => _connectionStreamController.stream;

  bool _isConnecting = false;
  bool get isConnected =>
      _client.connectionStatus?.state == MqttConnectionState.connected;
  Future<void> init({
    required String server,
    required String clientId,
    required int port,
    String? username,
    String? password,
  }) async {
    _client = MqttServerClient(server, clientId);
    _client.port = port;
    _client.keepAlivePeriod = 30;

    _client.logging(on: false);
    _client.onDisconnected = _onDisconnected;

    // Set connection message
    _client.connectionMessage = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);

    if (username != null && password != null) {
      _client.connectionMessage = MqttConnectMessage()
          .withClientIdentifier(clientId)
          .authenticateAs(username, password)
          .startClean()
          .withWillQos(MqttQos.atLeastOnce);
    }

    await connect();
  }

  // -------------------------------
  // CONNECT TO MQTT SERVER
  // -------------------------------
  Future<void> connect() async {
    if (_isConnecting) return;
    _isConnecting = true;

    try {
      final result = await _client.connect();
      if (result?.state == MqttConnectionState.connected) {
        print("MQTT Connected");
        _connectionStreamController.add(true);

        _client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> event) {
          final topic = event[0].topic;

          final MqttPublishMessage message =
              event[0].payload as MqttPublishMessage;

          final payload = MqttPublishPayload.bytesToStringAsString(
            message.payload.message,
          );

          _messageStreamController.add({"topic": topic, "payload": payload});
        });
      } else {
        print("MQTT: Failed to connect");
        _connectionStreamController.add(false);
        reconnect();
      }
    } catch (e) {
      print("MQTT Exception: $e");
      _connectionStreamController.add(false);
      reconnect();
    }

    _isConnecting = false;
  }

  // -------------------------------
  // AUTO-RECONNECT
  // -------------------------------
  Future<void> reconnect() async {
    print("MQTT: Reconnecting in 5 seconds...");
    await Future.delayed(const Duration(seconds: 5));
    await connect();
  }

  // -------------------------------
  // SUBSCRIBE TO TOPIC
  // -------------------------------
  void subscribe(String topic) {
    if (_client.connectionStatus!.state == MqttConnectionState.connected) {
      print("MQTT: Subscribed to this topic $topic");
      _client.subscribe(topic, MqttQos.atLeastOnce);
      
    } else {
      print("MQTT: Cannot subscribe, not connected");
    }
  }

  // -------------------------------
  // PUBLISH MESSAGE
  // -------------------------------
  void publish(String topic, String payload, {bool retain = false}) {
    if (_client.connectionStatus?.state == MqttConnectionState.connected) {
      final builder = MqttClientPayloadBuilder();
      builder.addString(payload);
      
      _client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!,
          retain: retain);
    } else {
      print("MQTT: Cannot publish, not connected");
    }
  }

  // -------------------------------
  // DISCONNECT
  // -------------------------------
  void disconnect() {
    _client.disconnect();
  }

  // -------------------------------
  // WHEN DISCONNECTED
  // -------------------------------
  void _onDisconnected() {
    print("MQTT: Disconnected");
    _connectionStreamController.add(false);
    reconnect();
  }
}
