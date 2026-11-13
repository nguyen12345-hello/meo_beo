
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../local_network_permission.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  static const String _cameraUrl = 'http://192.168.4.2/stream';

  static const Color _mint = Color(0xFF16B89A);
  static const Color _ink = Color(0xFF17233B);
  static const Color _muted = Color(0xFF7D8AA2);
  static const Color _dark = Color(0xFF101B2D);

  WebViewController? _web;

  bool _busy = false;
  bool _connected = false;

  String? _error;

  @override
  void dispose() {
    super.dispose();
  }

  // CONNECT / DISCONNECT CAMERA
  Future<void> _toggleCamera() async {
    if (_connected) {
      _stopCamera();
      return;
    }

    if (_busy) return;

    setState(() {
      _busy = true;
      _error = null;
      _web = null;
    });

<<<<<<< HEAD
    // iOS cần quyền "Mạng nội bộ" để mở được http://192.168.4.2/stream.
=======
    // iOS cần quyền "Mạng cục bộ" để mở được http://192.168.4.2/stream.
>>>>>>> 88e53c1 (final1)
    var allowed = await LocalNetworkPermission.ensure();
    if (!mounted) return;
    if (!allowed) {
      setState(() => _busy = false);
      allowed = await LocalNetworkPermission.showDeniedDialog(context);
      if (!mounted) return;
      if (!allowed) {
        setState(() {
<<<<<<< HEAD
          _error = 'Chưa có quyền Mạng nội bộ. Vào Cài đặt > Meo Beo để bật quyền này.';
=======
          _error = 'Chưa có quyền Mạng cục bộ. Vào Cài đặt > Meo Beo để bật quyền này.';
>>>>>>> 88e53c1 (final1)
        });
        return;
      }
      setState(() => _busy = true);
    }

    final html = '''
<!doctype html>
<html>
<head>
<meta name="viewport" content="width=device-width,initial-scale=1">
<style>
html,body {
  margin:0;
  width:100%;
  height:100%;
  background:#101B2D;
  display:flex;
  align-items:center;
  justify-content:center;
  overflow:hidden;
}
img {
  width:100%;
  height:100%;
  object-fit:contain;
}
</style>
</head>
<body>
<img src="$_cameraUrl" alt="Camera stream">
</body>
</html>
''';

    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.disabled)
      ..setBackgroundColor(_dark)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (!mounted) return;

            setState(() {
              _busy = false;
              _connected = true;
            });
          },
          onWebResourceError: (_) {
            if (!mounted) return;

            setState(() {
              _busy = false;
              _connected = false;
              _error =
                  'Không nhận được hình ảnh. Hãy kiểm tra Wi-Fi ESP32.';
            });
          },
        ),
      );

    try {
      await controller.loadHtmlString(html);

      if (!mounted) return;

      setState(() {
        _web = controller;
        _busy = false;
        _connected = true;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _busy = false;
        _connected = false;
        _error =
            'Không thể mở camera. Hãy kiểm tra Wi-Fi và thử lại.';
      });
    }
  }

  // STOP CAMERA
  void _stopCamera() {
    if (!mounted) return;

    setState(() {
      _web = null;
      _connected = false;
      _busy = false;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: const Color(0xFFEAEFF4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.045),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // HEADER
          Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF16B89A),
                      Color(0xFF54D8BD),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.videocam_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),

              const SizedBox(width: 11),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CAMERA GIÁM SÁT',
                      style: TextStyle(
                        color: _ink,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: .5,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'ESP32 · LIVE STREAM',
                      style: TextStyle(
                        color: _muted,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),

              _statusChip,
            ],
          ),

          const SizedBox(height: 16),

          // CAMERA VIEW
          Container(
            decoration: BoxDecoration(
              color: _dark,
              borderRadius: BorderRadius.circular(21),
              border: Border.all(
                color: const Color(0xFF25364B),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.13),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // VIDEO
                    if (_connected && _web != null)
                      WebViewWidget(controller: _web!)
                    else
                      _cameraPlaceholder(),

                    // TOP INFORMATION
                    Positioned(
                      top: 12,
                      left: 12,
                      right: 12,
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          _tag(
                            _connected ? '● LIVE' : '● OFFLINE',
                            live: _connected,
                          ),
                        ],
                      ),
                    ),

                    // LOADING
                    if (_busy)
                      Container(
                        color: Colors.black.withOpacity(.65),
                        child: const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(
                                color: Color(0xFF48D8B5),
                                strokeWidth: 3,
                              ),
                              SizedBox(height: 12),
                              Text(
                                'ĐANG KẾT NỐI CAMERA...',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // BOTTOM ADDRESS
                    Positioned(
                      bottom: 10,
                      left: 12,
                      right: 12,
                      child: Row(
                        children: [
                          const Icon(
                            Icons.wifi_rounded,
                            color: Colors.white70,
                            size: 13,
                          ),
                          const SizedBox(width: 5),
                          const Expanded(
                            child: Text(
                              '192.168.4.2/stream',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (_connected)
                            const Text(
                              'STREAMING',
                              style: TextStyle(
                                color: Color(0xFF5BE7C4),
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                letterSpacing: .7,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 15),

          // CONNECT BUTTON
          SizedBox(
            height: 52,
            child: FilledButton.icon(
              onPressed: _busy ? null : _toggleCamera,
              icon: Icon(
                _connected
                    ? Icons.stop_circle_rounded
                    : Icons.play_circle_fill_rounded,
                size: 23,
              ),
              label: Text(
                _busy
                    ? 'ĐANG KẾT NỐI...'
                    : _connected
                        ? 'DỪNG CAMERA'
                        : 'KẾT NỐI CAMERA',
              ),
              style: FilledButton.styleFrom(
                backgroundColor: _connected
                    ? const Color(0xFFFFE9E6)
                    : _mint,
                foregroundColor: _connected
                    ? const Color(0xFFB64242)
                    : Colors.white,
                disabledBackgroundColor: _mint.withOpacity(.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  letterSpacing: .7,
                ),
              ),
            ),
          ),

          // ERROR MESSAGE
          if (_error != null) ...[
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0EE),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                  color: const Color(0xFFFFD9D4),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFFCB5A50),
                    size: 19,
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: Text(
                      _error!,
                      style: const TextStyle(
                        color: Color(0xFF9E413A),
                        fontSize: 10,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 13),

          // WIFI INFORMATION
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.info_outline_rounded,
                size: 14,
                color: _muted,
              ),

              const SizedBox(width: 7),

              const Expanded(
                child: Text(
                  'Điện thoại cần kết nối cùng mạng Wi-Fi với ESP32 hoặc kết nối vào Wi-Fi do ESP32 phát.',
                  style: TextStyle(
                    color: _muted,
                    fontSize: 10,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // CAMERA PLACEHOLDER
  Widget _cameraPlaceholder() {
    return Container(
      color: _dark,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 66,
              height: 66,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.06),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(.1),
                ),
              ),
              child: Icon(
                Icons.videocam_off_rounded,
                size: 30,
                color: Colors.white.withOpacity(.55),
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              'CAMERA ĐANG CHỜ',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),

            const SizedBox(height: 5),

            const Text(
              'Nhấn kết nối để xem trực tiếp',
              style: TextStyle(
                color: Color(0xFF91A1B5),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // STATUS CHIP
  Widget get _statusChip {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: _connected
            ? const Color(0xFFE4F8F1)
            : const Color(0xFFF0F3F7),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: _connected ? _mint : _muted,
              shape: BoxShape.circle,
            ),
          ),

          const SizedBox(width: 6),

          Text(
            _connected ? 'ĐANG PHÁT' : 'SẴN SÀNG',
            style: TextStyle(
              color: _connected
                  ? const Color(0xFF12866F)
                  : _muted,
              fontSize: 9,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  // CAMERA TAG
  Widget _tag(String label, {bool live = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(.65),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withOpacity(.13),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: live
              ? const Color(0xFF5BE7C4)
              : Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w900,
          letterSpacing: .6,
        ),
      ),
    );
  }
}
