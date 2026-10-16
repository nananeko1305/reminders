import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_scope.dart';
import '../app_services.dart';
import '../models/event.dart';
import '../theme.dart';

/// Full-screen alarm for an event that is starting, shown over the lock
/// screen. "Ugasi" silences it; if the alarm itself launched the app, the app
/// closes again so the phone goes back to being locked.
class AlarmScreen extends StatefulWidget {
  const AlarmScreen({
    super.key,
    required this.notificationId,
    required this.event,
    required this.closeAppWhenDone,
  });

  final int notificationId;

  /// Null for the test alarm (or an event deleted meanwhile).
  final Event? event;
  final bool closeAppWhenDone;

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  late AppServices _services;
  bool _dismissed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _services = AppScope.of(context).services;
  }

  @override
  void dispose() {
    // Left without "Ugasi" (e.g. back button): still drop the lock-screen pass.
    if (!_dismissed) _services.lockScreen.release();
    super.dispose();
  }

  Future<void> _dismiss() async {
    if (_dismissed) return;
    _dismissed = true;
    await _services.scheduler.dismiss(widget.notificationId);
    // Cancelling also drops a repeating series' next alarm; re-plan it.
    await _services.events.resync();
    await _services.lockScreen.release();
    if (widget.closeAppWhenDone) {
      await SystemNavigator.pop();
    } else if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context).strings;
    final p = palette(context);
    final text = Theme.of(context).textTheme;
    final event = widget.event;
    const white = Colors.white;

    return Scaffold(
      backgroundColor: p.alarm,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              const Icon(Icons.alarm, size: 96, color: white),
              const SizedBox(height: 12),
              Text(s.time(DateTime.now()),
                  style: text.displayLarge?.copyWith(color: white)),
              const SizedBox(height: 24),
              Text(
                event?.title ?? s.testAlarmTitle,
                textAlign: TextAlign.center,
                style: text.headlineMedium
                    ?.copyWith(color: white, fontWeight: FontWeight.w600),
              ),
              if (event != null && event.note.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(event.note,
                    textAlign: TextAlign.center,
                    style: text.bodyLarge?.copyWith(color: white)),
              ],
              const SizedBox(height: 8),
              Text(s.startsNow,
                  style: text.titleMedium?.copyWith(color: white.withValues(alpha: 0.85))),
              const Spacer(),
              FilledButton.icon(
                onPressed: _dismiss,
                icon: const Icon(Icons.alarm_off),
                label: Text(s.dismissAlarm),
                style: FilledButton.styleFrom(
                  backgroundColor: white,
                  foregroundColor: p.alarm,
                  minimumSize: const Size.fromHeight(64),
                  textStyle: text.titleLarge,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
