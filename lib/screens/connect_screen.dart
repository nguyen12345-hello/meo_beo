import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../mqtt_service.dart';
import 'home_shell.dart';

class ConnectScreen extends StatefulWidget {
  const ConnectScreen({super.key});

  @override
  State<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State<ConnectScreen> {
  final _name = TextEditingController(text: 'MOS');
  final _host = TextEditingController(text: '192.168.1.10');
  // Web dùng cổng WebSocket (9001), iOS dùng cổng MQTT thường (1883)
  final _port = TextEditingController(text: kIsWeb ? '9001' : '1883');
  final _user = TextEditingController();
  final _pass = TextEditingController();
  bool _hidePass = true;
  bool _tls = false;

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      _name.text = p.getString('name') ?? _name.text;
      _host.text = p.getString('host') ?? _host.text;
      _port.text = p.getString('port') ?? _port.text;
      _user.text = p.getString('user') ?? '';
      _pass.text = p.getString('pass') ?? '';
      _tls = p.getBool('tls') ?? false;
    });
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('name', _name.text);
    await p.setString('host', _host.text.trim());
    await p.setString('port', _port.text.trim());
    await p.setString('user', _user.text);
    await p.setString('pass', _pass.text);
    await p.setBool('tls', _tls);
  }

  Future<void> _connect() async {
    await _save();
    final mqtt = context.read<MqttService>();
    final ok = await mqtt.connect(
      host: _host.text.trim(),
      port: int.tryParse(_port.text.trim()) ?? 1883,
      user: _user.text,
      pass: _pass.text,
      useTls: _tls,
    );
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeShell()),
      );
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(mqtt.error ?? 'Lỗi kết nối')));
    }
  }

  InputDecoration _dec(String label, {Widget? suffix, IconData? icon}) =>
      InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF8794A8), fontSize: 12),
        prefixIcon: icon == null
            ? null
            : Icon(icon, color: const Color(0xFF18B99A), size: 19),
        filled: true,
        fillColor: const Color(0xFFF5F8FB),
        suffixIcon: suffix,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 15, vertical: 17),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Color(0xFFE8EDF2))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Color(0xFF18B99A), width: 1.5)),
      );

  @override
  Widget build(BuildContext context) {
    final connecting = context.watch<MqttService>().connecting;
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FA),
      body: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
              Color(0xFFEAF8F5),
              Color(0xFFF5F7FB),
              Color(0xFFFFF2E9)
            ])),
        child: SafeArea(
            child: Center(
                child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),
                  Center(
                      child: Container(
                          width: 82,
                          height: 82,
                          decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [
                                Color(0xFF13B99A),
                                Color(0xFF56D9BB)
                              ]),
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                    color: const Color(0xFF18B99A)
                                        .withOpacity(.25),
                                    blurRadius: 25,
                                    offset: const Offset(0, 10))
                              ]),
                          child: const Icon(Icons.pets_rounded,
                              color: Colors.white, size: 43))),
                  const SizedBox(height: 17),
                  const Text('MÈO BÉO',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Color(0xFF17233B),
                          fontSize: 27,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2)),
                  const SizedBox(height: 5),
                  const Text('SMART PET CARE · CAT AI',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Color(0xFF8A98AA),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2)),
                  const SizedBox(height: 25),
                  Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(26),
                          boxShadow: [
                            BoxShadow(
                                color: const Color(0xFF253B56).withOpacity(.07),
                                blurRadius: 30,
                                offset: const Offset(0, 12))
                          ]),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text('Đăng nhập hệ thống',
                                style: TextStyle(
                                    color: Color(0xFF17233B),
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900)),
                            const SizedBox(height: 5),
                            const Text(
                                'Kết nối thiết bị để bắt đầu chăm sóc Boss.',
                                style: TextStyle(
                                    color: Color(0xFF8794A8), fontSize: 11)),
                            const SizedBox(height: 20),
                            TextField(
                                controller: _name,
                                decoration: _dec('Tên kết nối',
                                    icon: Icons.devices_rounded)),
                            const SizedBox(height: 12),
                            Row(children: [
                              Expanded(
                                  child: TextField(
                                      controller: _host,
                                      keyboardType: TextInputType.url,
                                      decoration: _dec('Địa chỉ máy chủ',
                                          icon: Icons.dns_rounded))),
                              const SizedBox(width: 10),
                              SizedBox(
                                  width: 92,
                                  child: TextField(
                                      controller: _port,
                                      keyboardType: TextInputType.number,
                                      decoration:
                                          _dec(kIsWeb ? 'Cổng WS' : 'Cổng'))),
                            ]),
                            const SizedBox(height: 12),
                            TextField(
                                controller: _user,
                                decoration: _dec('Tên đăng nhập',
                                    icon: Icons.person_outline_rounded)),
                            const SizedBox(height: 12),
                            TextField(
                                controller: _pass,
                                obscureText: _hidePass,
                                decoration: _dec('Mật khẩu',
                                    icon: Icons.lock_outline_rounded,
                                    suffix: IconButton(
                                        icon: Icon(
                                            _hidePass
                                                ? Icons.visibility_off_rounded
                                                : Icons.visibility_rounded,
                                            color: const Color(0xFF8794A8)),
                                        onPressed: () => setState(
                                            () => _hidePass = !_hidePass)))),
                            const SizedBox(height: 5),
                            SwitchListTile(
                                contentPadding: EdgeInsets.zero,
                                dense: true,
                                title: const Text('Mã hóa kết nối TLS',
                                    style: TextStyle(
                                        color: Color(0xFF536176),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600)),
                                value: _tls,
                                activeColor: const Color(0xFF18B99A),
                                onChanged: (v) => setState(() {
                                      _tls = v;
                                      if (!kIsWeb) {
                                        if (v && _port.text == '1883')
                                          _port.text = '8883';
                                        if (!v && _port.text == '8883')
                                          _port.text = '1883';
                                      }
                                    })),
                            const SizedBox(height: 12),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 54,
                              child: FilledButton.icon(
                                  onPressed: connecting ? null : _connect,
                                  icon: connecting
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white))
                                      : const Icon(Icons.wifi_find_rounded),
                                  label: Text(connecting
                                      ? 'ĐANG KẾT NỐI...'
                                      : 'KẾT NỐI MQTT'),
                                  style: FilledButton.styleFrom(
                                      backgroundColor: const Color(0xFF18B99A),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15)),
                                      textStyle: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: .5))),
                            ),
                            const SizedBox(height: 9),
                            OutlinedButton.icon(
                                onPressed: () async {
                                  await _save();
                                  if (mounted)
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Đã lưu cấu hình kết nối')));
                                },
                                icon: const Icon(Icons.bookmark_add_outlined,
                                    size: 18),
                                label: const Text('Lưu cấu hình'),
                                style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF536176),
                                    side: const BorderSide(
                                        color: Color(0xFFE4EAF0)),
                                    minimumSize: const Size.fromHeight(48),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(14)))),
                          ])),
                  const SizedBox(height: 18),
                  const Text('SECURE CONNECTION  ·  YOUR PET, OUR PRIORITY',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Color(0xFF9AA6B5),
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2)),
                ],
              )),
        ))),
      ),
    );
  }
}
