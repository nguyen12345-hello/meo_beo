import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_browser_client.dart';

/// Web: kết nối WebSocket tới broker (ws://host:9001, hoặc wss với TLS).
MqttClient createMqttClient({
  required String host,
  required int port,
  required String clientId,
  required bool useTls,
}) {
  final scheme = useTls ? 'wss' : 'ws';
  final c = MqttBrowserClient.withPort('$scheme://$host', clientId, port);
  // Mosquitto chỉ nhận đúng một giao thức con là "mqtt"
  c.websocketProtocols = MqttClientConstants.protocolsSingleDefault;
  return c;
}