import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'mqtt_client_factory.dart';

/// Quy ước tín hiệu của hệ thống:
///  pet/control/set1 : '0' = cho ăn,   '1' = dừng
///  pet/control/set2 : '2' = cấp nước, '3' = dừng
///  pet/control/cam  : '4' = thấy mèo, '5' = không thấy (thiết bị gửi lên, app chỉ đọc)
class MqttService extends ChangeNotifier {
  static const topicSet1 = 'pet/control/set1';
  static const topicSet2 = 'pet/control/set2';
  static const topicCam = 'pet/control/cam';

  MqttClient? _client;

  bool connecting = false;
  bool connected = false;
  String? error;

  bool feeding = false;
  bool watering = false;
  bool catDetected = false;

  Future<bool> connect({
    required String host,
    required int port,
    String user = '',
    String pass = '',
    bool useTls = false,
  }) async {
    connecting = true;
    error = null;
    notifyListeners();

    final clientId = 'boss_app_${DateTime.now().millisecondsSinceEpoch}';
    final c = createMqttClient(
      host: host,
      port: port,
      clientId: clientId,
      useTls: useTls,
    );
    c.keepAlivePeriod = 20;
    c.connectTimeoutPeriod = 5000; // ms
    c.logging(on: false);
    c.setProtocolV311();
    c.onDisconnected = _onDisconnected;
    c.connectionMessage =
        MqttConnectMessage().withClientIdentifier(clientId).startClean();

    try {
      await c.connect(
        user.isEmpty ? null : user,
        user.isEmpty ? null : pass,
      );
    } catch (e) {
      c.disconnect();
      return _fail('Không kết nối được tới $host:$port ($e)');
    }

    if (c.connectionStatus?.state != MqttConnectionState.connected) {
      c.disconnect();
      return _fail('Máy chủ từ chối kết nối, kiểm tra user và password');
    }

    _client = c;
    connected = true;
    connecting = false;

    for (final t in [topicSet1, topicSet2, topicCam]) {
      c.subscribe(t, MqttQos.atLeastOnce);
    }
    c.updates!.listen(_onMessage);
    notifyListeners();
    return true;
  }

  bool _fail(String message) {
    error = message;
    connecting = false;
    connected = false;
    notifyListeners();
    return false;
  }

  void disconnect() {
    _client?.disconnect();
  }

  void _onDisconnected() {
    connected = false;
    notifyListeners();
  }

  void _onMessage(List<MqttReceivedMessage<MqttMessage>> events) {
    for (final e in events) {
      final msg = e.payload as MqttPublishMessage;
      final p =
          MqttPublishPayload.bytesToStringAsString(msg.payload.message).trim();
      switch (e.topic) {
        case topicSet1:
          if (p == '0') feeding = true;
          if (p == '1') feeding = false;
          break;
        case topicSet2:
          if (p == '2') watering = true;
          if (p == '3') watering = false;
          break;
        case topicCam:
          if (p == '4') catDetected = true;
          if (p == '5') catDetected = false;
          break;
      }
    }
    notifyListeners();
  }

  void _publish(String topic, String payload) {
    if (!connected) return;
    final b = MqttClientPayloadBuilder()..addString(payload);
    _client?.publishMessage(topic, MqttQos.atLeastOnce, b.payload!);
  }

  void setFeed(bool on) {
    _publish(topicSet1, on ? '0' : '1');
    feeding = on;
    notifyListeners();
  }

  void setWater(bool on) {
    _publish(topicSet2, on ? '2' : '3');
    watering = on;
    notifyListeners();
  }

  /// Chạy [seconds] giây rồi tự gửi lệnh dừng.
  /// Dùng cho nút "Thời gian chạy" và cho lịch hẹn giờ.
  Future<void> runFor({required bool isFeed, required int seconds}) async {
    isFeed ? setFeed(true) : setWater(true);
    await Future.delayed(Duration(seconds: seconds));
    isFeed ? setFeed(false) : setWater(false);
  }
}
