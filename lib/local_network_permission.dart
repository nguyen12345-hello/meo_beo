import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Xin quyền "Mạng cục bộ" (Local Network) trên iOS.
///
/// iOS 14+ chặn mọi kết nối tới thiết bị trong mạng LAN (broker MQTT 192.168.x.x,
/// camera ESP32 192.168.4.2...) cho tới khi người dùng bấm "Cho phép". Nếu không xin
/// quyền trước, lần kết nối đầu tiên sẽ hết thời gian chờ trong lúc hộp thoại còn hiện.
/// Trên Web/nền tảng khác không cần quyền này nên luôn trả về true.
class LocalNetworkPermission {
  LocalNetworkPermission._();

  static const MethodChannel _channel = MethodChannel('meo_beo/local_network');

  static bool _granted = false;
  static Future<bool>? _pending;

  static bool get _needed =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  /// Hiện hộp thoại xin quyền (nếu chưa hỏi) và trả về true khi đã được cho phép.
  /// Chỉ ghi nhớ kết quả "đã cho phép"; nếu bị từ chối, lần gọi sau sẽ kiểm tra lại
  /// để nhận biết người dùng vừa bật quyền trong Cài đặt.
  static Future<bool> ensure() {
    if (!_needed || _granted) return Future.value(true);
    return _pending ??= _request().whenComplete(() => _pending = null);
  }

  static Future<bool> _request() async {
    try {
      final ok = await _channel.invokeMethod<bool>('request') ?? false;
      _granted = ok;
      return ok;
    } on MissingPluginException {
      return true; // Không có phần native: để kết nối thật quyết định.
    } on PlatformException {
      return true;
    }
  }

  static Future<void> openSettings() async {
    try {
      await _channel.invokeMethod<void>('openSettings');
    } catch (_) {}
  }

  /// Hiện hướng dẫn khi quyền bị từ chối. Trả về true nếu người dùng chọn vẫn thử
  /// kết nối (ví dụ máy chủ nằm ngoài mạng nội bộ).
  static Future<bool> showDeniedDialog(BuildContext context) async {
    final tryAnyway = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cần quyền Mạng cục bộ'),
        content: const Text(
          'Meo Beo chưa được phép truy cập mạng nội bộ nên không kết nối được '
          'máy chủ MQTT và camera.\n\n'
          'Vào Cài đặt > Meo Beo > bật "Mạng cục bộ", rồi quay lại ứng dụng.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Vẫn thử kết nối'),
          ),
          FilledButton(
            onPressed: () {
              openSettings();
              Navigator.of(ctx).pop(false);
            },
            child: const Text('Mở Cài đặt'),
          ),
        ],
      ),
    );
    return tryAnyway ?? false;
  }
}
