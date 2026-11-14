import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../mqtt_service.dart';
import '../schedule_store.dart';

import 'connect_screen.dart';
import 'camera_page.dart';

const _ink = Color(0xFF17233B);
const _muted = Color(0xFF8490A5);
const _mint = Color(0xFF16B89A);
const _cream = Color(0xFFF4F7FB);
const _orange = Color(0xFFFFA45B);
const _blue = Color(0xFF559CEB);
const _line = Color(0xFFE9EEF5);

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.cameraHost});

  final String cameraHost;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  @override
  Widget build(BuildContext context) {
    final mqtt = context.watch<MqttService>();

    return Scaffold(
      backgroundColor: _cream,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 30),
                children: [
                  // HEADER
                  _buildHeader(context, mqtt),

                  const SizedBox(height: 18),

                  // CONNECTION WARNING
                  if (!mqtt.connected) ...[
                    const _ConnectionWarning(),
                    const SizedBox(height: 16),
                  ],

                  // CAMERA
                  CameraPage(host: widget.cameraHost),

                  const SizedBox(height: 25),

                  // SYSTEM STATUS
                  const _SectionTitle(
                    title: 'TỔNG QUAN HỆ THỐNG',
                    subtitle: 'Theo dõi hoạt động của thiết bị',
                    icon: Icons.dashboard_rounded,
                  ),

                  const SizedBox(height: 13),

                  Row(
                    children: [
                      Expanded(
                        child: _MetricCard(
                          icon: Icons.restaurant_rounded,
                          title: 'Máy cho ăn',
                          value: mqtt.feeding ? 'Đang hoạt động' : 'Đang nghỉ',
                          active: mqtt.feeding,
                          tint: _orange,
                          activeLabel: 'ĐANG CHẠY',
                          inactiveLabel: 'TẠM NGHỈ',
                        ),
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: _MetricCard(
                          icon: Icons.water_drop_rounded,
                          title: 'Cấp nước',
                          value: mqtt.watering ? 'Đang hoạt động' : 'Đang nghỉ',
                          active: mqtt.watering,
                          tint: _blue,
                          activeLabel: 'ĐANG CHẠY',
                          inactiveLabel: 'TẠM NGHỈ',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 11),

                  _CatStatusCard(
                    detected: mqtt.catDetected,
                  ),

                  const SizedBox(height: 27),

                  // MANUAL CONTROL
                  const _SectionTitle(
                    title: 'ĐIỀU KHIỂN THIẾT BỊ',
                    subtitle: 'Chủ động vận hành các thiết bị',
                    icon: Icons.tune_rounded,
                  ),

                  const SizedBox(height: 13),

                  _ActionPanel(
                    icon: Icons.restaurant_rounded,
                    title: 'Máy cho ăn',
                    subtitle: 'Điều khiển khay thức ăn',
                    color: _orange,
                    active: mqtt.feeding,
                    onChanged: mqtt.setFeed,
                  ),

                  const SizedBox(height: 12),

                  _ActionPanel(
                    icon: Icons.water_drop_rounded,
                    title: 'Máy cấp nước',
                    subtitle: 'Điều khiển máy bơm nước',
                    color: _blue,
                    active: mqtt.watering,
                    onChanged: mqtt.setWater,
                  ),

                  const SizedBox(height: 27),

                  // SCHEDULE
                  const _SectionTitle(
                    title: 'LỊCH CHĂM SÓC TỰ ĐỘNG',
                    subtitle: 'Chọn ngày và khung giờ cho ăn hoặc cấp nước',
                    icon: Icons.calendar_month_rounded,
                  ),

                  const SizedBox(height: 13),

                  const _ScheduleSection(),

                  const SizedBox(height: 25),

                  const _Footer(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, MqttService mqtt) {
    return Row(
      children: [
        Container(
          width: 51,
          height: 51,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_mint, Color(0xFF55D9BC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: _mint.withOpacity(.22),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(
            Icons.pets_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MÈO BÉO',
                style: TextStyle(
                  color: _ink,
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'SMART PET CARE  ·  CAT AI',
                style: TextStyle(
                  color: _muted,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
        _ConnectionPill(connected: mqtt.connected),
        const SizedBox(width: 5),
        PopupMenuButton<String>(
          tooltip: 'Tùy chọn',
          icon: const Icon(
            Icons.more_vert_rounded,
            color: _muted,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          onSelected: (value) {
            if (value == 'logout') {
              mqtt.disconnect();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => const ConnectScreen(),
                ),
              );
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout_rounded, color: Colors.redAccent),
                  SizedBox(width: 10),
                  Text('Ngắt kết nối'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// CONNECTION WARNING
class _ConnectionWarning extends StatelessWidget {
  const _ConnectionWarning();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEFED),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFFFD8D3)),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.cloud_off_rounded,
            color: Color(0xFFD95750),
            size: 23,
          ),
          SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mất kết nối máy chủ MQTT',
                  style: TextStyle(
                    color: Color(0xFFB64242),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Thiết bị có thể chưa nhận được lệnh điều khiển.',
                  style: TextStyle(
                    color: Color(0xFFB96B68),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// CONNECTION STATUS
class _ConnectionPill extends StatelessWidget {
  const _ConnectionPill({required this.connected});

  final bool connected;

  @override
  Widget build(BuildContext context) {
    final color = connected ? _mint : const Color(0xFFE45B5B);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(.10),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(.20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(.35),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            connected ? 'ONLINE' : 'OFFLINE',
            style: TextStyle(
              color:
                  connected ? const Color(0xFF12866F) : const Color(0xFFC74444),
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: .4,
            ),
          ),
        ],
      ),
    );
  }
}

// SECTION TITLE
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: _mint.withOpacity(.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: _mint,
            size: 19,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: _ink,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: .7,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  color: _muted,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// METRIC CARD
class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.active,
    required this.tint,
    required this.activeLabel,
    required this.inactiveLabel,
  });

  final IconData icon;
  final String title;
  final String value;
  final bool active;
  final Color tint;
  final String activeLabel;
  final String inactiveLabel;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(
          color: active ? tint.withOpacity(.45) : _line,
          width: active ? 1.4 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.025),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: tint.withOpacity(.13),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: tint, size: 23),
              ),
              _StatusDot(active: active, color: tint),
            ],
          ),
          const SizedBox(height: 13),
          Text(
            title,
            style: const TextStyle(
              color: _muted,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _ink,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 9),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: tint.withOpacity(active ? .13 : .07),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              active ? activeLabel : inactiveLabel,
              style: TextStyle(
                color: active ? tint : _muted,
                fontSize: 8,
                fontWeight: FontWeight.w900,
                letterSpacing: .4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// CAT AI STATUS
class _CatStatusCard extends StatelessWidget {
  const _CatStatusCard({required this.detected});

  final bool detected;

  @override
  Widget build(BuildContext context) {
    final color = detected ? _mint : const Color(0xFF9AA5B5);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(
          color: detected ? _mint.withOpacity(.45) : _line,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.025),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 47,
            height: 47,
            decoration: BoxDecoration(
              color: color.withOpacity(.13),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              Icons.center_focus_strong_rounded,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nhận diện CatAI',
                  style: TextStyle(
                    color: _muted,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  detected ? 'Đã phát hiện mèo' : 'Chưa phát hiện mèo',
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: color.withOpacity(.12),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              detected ? 'DETECTED' : 'WAITING',
              style: TextStyle(
                color: detected ? _mint : _muted,
                fontSize: 8,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// STATUS DOT
class _StatusDot extends StatelessWidget {
  const _StatusDot({
    required this.active,
    required this.color,
  });

  final bool active;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: 9,
      height: 9,
      decoration: BoxDecoration(
        color: active ? color : const Color(0xFFD5DCE6),
        shape: BoxShape.circle,
        boxShadow: active
            ? [
                BoxShadow(
                  color: color.withOpacity(.35),
                  blurRadius: 7,
                ),
              ]
            : [],
      ),
    );
  }
}

// MANUAL CONTROL
class _ActionPanel extends StatelessWidget {
  const _ActionPanel({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.active,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool active;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(
          color: active ? color.withOpacity(.50) : _line,
          width: active ? 1.4 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.025),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 49,
            height: 49,
            decoration: BoxDecoration(
              color: color.withOpacity(active ? .19 : .11),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: color,
              size: 25,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 7),
                Row(
                  children: [
                    _StatusDot(active: active, color: color),
                    const SizedBox(width: 6),
                    Text(
                      active ? 'ĐANG BẬT' : 'ĐANG TẮT',
                      style: TextStyle(
                        color: active ? color : _muted,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: .4,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 91,
            height: 39,
            child: FilledButton(
              onPressed: () => onChanged(!active),
              style: FilledButton.styleFrom(
                backgroundColor: active ? const Color(0xFFF0F2F6) : color,
                foregroundColor: active ? _muted : Colors.white,
                elevation: 0,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    active
                        ? Icons.power_settings_new_rounded
                        : Icons.play_arrow_rounded,
                    size: 17,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    active ? 'TẮT' : 'BẬT',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// AUTOMATIC SCHEDULE
class _ScheduleSection extends StatelessWidget {
  const _ScheduleSection();

  @override
  Widget build(BuildContext context) {
    final store = context.watch<ScheduleStore>();
    final list = [...store.items]..sort((a, b) {
        final aDate = a.date ?? DateTime(1900);
        final bDate = b.date ?? DateTime(1900);
        final byDate = aDate.compareTo(bDate);
        return byDate != 0
            ? byDate
            : (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute);
      });

    return Container(
      padding: const EdgeInsets.fromLTRB(15, 14, 12, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: _line),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.02),
            blurRadius: 13,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _mint.withOpacity(.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.calendar_month_rounded,
                  color: _mint,
                  size: 22,
                ),
              ),
              const SizedBox(width: 11),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lịch chăm sóc',
                      style: TextStyle(
                        color: _ink,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Chọn ngày để thêm khung giờ',
                      style: TextStyle(color: _muted, fontSize: 10),
                    ),
                  ],
                ),
              ),
              IconButton.filledTonal(
                tooltip: 'Chọn ngày',
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (date == null || !context.mounted) return;

                  final isFeed = await showDialog<bool>(
                    context: context,
                    builder: (context) => SimpleDialog(
                      title: const Text('Chọn thiết bị'),
                      children: [
                        SimpleDialogOption(
                          onPressed: () => Navigator.pop(context, true),
                          child: const ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(
                              Icons.restaurant_rounded,
                              color: _orange,
                            ),
                            title: Text('Cho ăn'),
                          ),
                        ),
                        SimpleDialogOption(
                          onPressed: () => Navigator.pop(context, false),
                          child: const ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(
                              Icons.water_drop_rounded,
                              color: _blue,
                            ),
                            title: Text('Cấp nước'),
                          ),
                        ),
                      ],
                    ),
                  );
                  if (isFeed == null || !context.mounted) return;

                  final start = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                    helpText: 'Chọn giờ bắt đầu',
                  );
                  if (start == null || !context.mounted) return;

                  final end = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay(
                      hour: (start.hour + 1) % 24,
                      minute: start.minute,
                    ),
                    helpText: 'Chọn giờ tắt',
                  );
                  if (end == null) return;

                  await store.add(
                    isFeed: isFeed,
                    date: date,
                    hour: start.hour,
                    minute: start.minute,
                    endHour: end.hour,
                    endMinute: end.minute,
                  );
                },
                icon: const Icon(Icons.add_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: _mint.withOpacity(.12),
                  foregroundColor: _mint,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(color: _line, height: 1),
          if (list.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Column(
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    color: _muted.withOpacity(.6),
                    size: 27,
                  ),
                  const SizedBox(height: 7),
                  const Text(
                    'Chưa có lịch tự động',
                    style: TextStyle(
                      color: _ink,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'Nhấn nút + để thiết lập thời gian',
                    style: TextStyle(
                      color: _muted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          for (final it in list)
            Dismissible(
              key: ValueKey(it.id),
              direction: DismissDirection.endToStart,
              onDismissed: (_) => store.remove(it),
              background: Container(
                margin: const EdgeInsets.symmetric(vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE8E5),
                  borderRadius: BorderRadius.circular(13),
                ),
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 18),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.redAccent,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 7),
                child: Row(
                  children: [
                    Container(
                      width: 37,
                      height: 37,
                      decoration: BoxDecoration(
                        color: (it.isFeed ? _orange : _blue).withOpacity(.10),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        it.isFeed
                            ? Icons.restaurant_rounded
                            : Icons.water_drop_rounded,
                        color: it.isFeed ? _orange : _blue,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            it.date == null
                                ? '${it.isFeed ? 'Cho ăn' : 'Cấp nước'} · Hằng ngày'
                                : '${it.isFeed ? 'Cho ăn' : 'Cấp nước'} · ${it.date!.day.toString().padLeft(2, '0')}/${it.date!.month.toString().padLeft(2, '0')}/${it.date!.year}',
                            style: const TextStyle(
                              color: _ink,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            it.endHour == null || it.endMinute == null
                                ? '${it.timeText} · ${it.seconds} giây'
                                : '${it.timeText} – ${it.endHour!.toString().padLeft(2, '0')}:${it.endMinute!.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              color: _muted,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: it.enabled,
                      onChanged: (v) => store.toggle(it, v),
                      activeThumbColor: it.isFeed ? _orange : _blue,
                    ),
                    IconButton(
                      tooltip: 'Xóa lịch',
                      visualDensity: VisualDensity.compact,
                      onPressed: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Xóa lịch này?'),
                            content: const Text(
                              'Lịch chăm sóc đã chọn sẽ bị xóa.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Hủy'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Xóa'),
                              ),
                            ],
                          ),
                        );
                        if (confirmed == true) {
                          await store.remove(it);
                        }
                      },
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.redAccent,
                        size: 21,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// FOOTER
class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 42,
          height: 4,
          decoration: BoxDecoration(
            color: const Color(0xFFDDE4ED),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(height: 13),
        const Text(
          'MÈO BÉO',
          style: TextStyle(
            color: _ink,
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'SMART PET ECOSYSTEM',
          style: TextStyle(
            color: _muted,
            fontSize: 8,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}
