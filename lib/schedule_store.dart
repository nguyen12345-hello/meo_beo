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
    this.date,
    this.endHour,
    this.endMinute,
    this.seconds = 5,
    this.enabled = true,
  });

  final String id;
  final bool isFeed; // true: cho ăn (set1), false: cho nước (set2)
  final DateTime? date;
  final int hour;
  final int minute;
  final int? endHour;
  final int? endMinute;
  final int seconds;
  bool enabled;

  String get timeText =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  Map<String, dynamic> toJson() => {
        'id': id,
        'isFeed': isFeed,
        'date': date?.toIso8601String(),
        'hour': hour,
        'minute': minute,
        'endHour': endHour,
        'endMinute': endMinute,
        'seconds': seconds,
        'enabled': enabled,
      };

  factory ScheduleItem.fromJson(Map<String, dynamic> j) => ScheduleItem(
        id: j['id'] as String,
        isFeed: j['isFeed'] as bool,
        date: j['date'] == null ? null : DateTime.parse(j['date'] as String),
        hour: j['hour'] as int,
        minute: j['minute'] as int,
        endHour: j['endHour'] as int?,
        endMinute: j['endMinute'] as int?,
        seconds: j['seconds'] as int? ?? 5,
        enabled: j['enabled'] as bool? ?? true,
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
  final Set<String> _activeSchedules = {};

  List<ScheduleItem> byType(bool isFeed) {
    final list = items.where((e) => e.isFeed == isFeed).toList();
    list.sort((a, b) => (a.hour * 60 + a.minute) - (b.hour * 60 + b.minute));
    return list;
  }

  Future<void> add({
    required bool isFeed,
    required DateTime date,
    required int hour,
    required int minute,
    required int endHour,
    required int endMinute,
  }) async {
    items.add(ScheduleItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      isFeed: isFeed,
      date: DateTime(date.year, date.month, date.day),
      hour: hour,
      minute: minute,
      endHour: endHour,
      endMinute: endMinute,
    ));
    await _save();
    notifyListeners();
  }

  Future<void> toggle(ScheduleItem item, bool value) async {
    item.enabled = value;
    if (!value && _activeSchedules.remove(item.id)) {
      item.isFeed ? mqtt.setFeed(false) : mqtt.setWater(false);
    }
    await _save();
    notifyListeners();
  }

  Future<void> remove(ScheduleItem item) async {
    items.removeWhere((e) => e.id == item.id);
    if (_activeSchedules.remove(item.id)) {
      item.isFeed ? mqtt.setFeed(false) : mqtt.setWater(false);
    }
    await _save();
    notifyListeners();
  }

  void _tick() {
    if (!mqtt.connected) return;
    final now = DateTime.now();
    final key = '${now.year}-${now.month}-${now.day} ${now.hour}:${now.minute}';
    for (final it in items) {
      if (!it.enabled) {
        if (_activeSchedules.remove(it.id)) {
          it.isFeed ? mqtt.setFeed(false) : mqtt.setWater(false);
        }
        continue;
      }
      if (it.date == null || it.endHour == null || it.endMinute == null) {
        if (it.hour == now.hour &&
            it.minute == now.minute &&
            _lastFired[it.id] != key) {
          _lastFired[it.id] = key;
          mqtt.runFor(isFeed: it.isFeed, seconds: it.seconds);
        }
        continue;
      }

      final start = DateTime(
        it.date!.year,
        it.date!.month,
        it.date!.day,
        it.hour,
        it.minute,
      );
      var end = DateTime(
        it.date!.year,
        it.date!.month,
        it.date!.day,
        it.endHour!,
        it.endMinute!,
      );
      if (!end.isAfter(start)) {
        end = end.add(const Duration(days: 1));
      }

      final isActive = !now.isBefore(start) && now.isBefore(end);
      if (isActive && _activeSchedules.add(it.id)) {
        it.isFeed ? mqtt.setFeed(true) : mqtt.setWater(true);
      } else if (!isActive && _activeSchedules.remove(it.id)) {
        it.isFeed ? mqtt.setFeed(false) : mqtt.setWater(false);
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
