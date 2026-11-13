import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'mqtt_service.dart';

class ScheduleItem {
  ScheduleItem({
    required this.id,
    required this.isFeed,
    required this.hour,
    required this.minute,
    this.seconds = 5,
    this.enabled = true,
  });

  final String id;
  final bool isFeed; // true: cho ăn (set1), false: cho nước (set2)
  final int hour;
  final int minute;
  final int seconds;
  bool enabled;

  String get timeText =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  Map<String, dynamic> toJson() => {
        'id': id,
        'isFeed': isFeed,
        'hour': hour,
        'minute': minute,
        'seconds': seconds,
        'enabled': enabled,
      };

  factory ScheduleItem.fromJson(Map<String, dynamic> j) => ScheduleItem(
        id: j['id'] as String,
        isFeed: j['isFeed'] as bool,
        hour: j['hour'] as int,
        minute: j['minute'] as int,
        seconds: j['seconds'] as int,
        enabled: j['enabled'] as bool,
      );
}

/// Lưu lịch trong máy và tự gửi lệnh MQTT đúng giờ.
/// Lưu ý: lịch này chỉ chạy khi app đang mở. Muốn chạy khi tắt app,
/// hãy đưa lịch xuống ESP32 hoặc dùng một máy chủ luôn bật (Node-RED...).
class ScheduleStore extends ChangeNotifier {
  ScheduleStore(this.mqtt) {
    _load();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  final MqttService mqtt;
  List<ScheduleItem> items = [];
  Timer? _timer;
  final Map<String, String> _lastFired = {};

  List<ScheduleItem> byType(bool isFeed) {
    final list = items.where((e) => e.isFeed == isFeed).toList();
    list.sort((a, b) => (a.hour * 60 + a.minute) - (b.hour * 60 + b.minute));
    return list;
  }

  Future<void> add(bool isFeed, int hour, int minute, {int seconds = 5}) async {
    items.add(ScheduleItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      isFeed: isFeed,
      hour: hour,
      minute: minute,
      seconds: seconds,
    ));
    await _save();
    notifyListeners();
  }

  Future<void> toggle(ScheduleItem item, bool value) async {
    item.enabled = value;
    await _save();
    notifyListeners();
  }

  Future<void> remove(ScheduleItem item) async {
    items.removeWhere((e) => e.id == item.id);
    await _save();
    notifyListeners();
  }

  void _tick() {
    if (!mqtt.connected) return;
    final now = DateTime.now();
    final key = '${now.year}-${now.month}-${now.day} ${now.hour}:${now.minute}';
    for (final it in items) {
      if (!it.enabled) continue;
      if (it.hour == now.hour && it.minute == now.minute && _lastFired[it.id] != key) {
        _lastFired[it.id] = key;
        mqtt.runFor(isFeed: it.isFeed, seconds: it.seconds);
      }
    }
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('schedules');
    if (raw != null) {
      final list = jsonDecode(raw) as List;
      items = list
          .map((e) => ScheduleItem.fromJson(e as Map<String, dynamic>))
          .toList();
      notifyListeners();
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'schedules', jsonEncode(items.map((e) => e.toJson()).toList()));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
