import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

/// iOS: kết nối TCP tới broker (mqtt://host:1883, hoặc mqtts với TLS).
MqttClient createMqttClient({
  required String host,
  required int port,
  required String clientId,
  required bool useTls,
}) {
  final c = MqttServerClient.withPort(host, clientId, port);
  c.secure = useTls;
  return c;
}
