import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../models/ring_mode.dart';
import '../theme.dart';

/// Settings: how reminders ring (alarm / notification / vibration), the
/// sound played at the event time, and whether the alarm goes full screen.
class RingSection extends StatefulWidget {
  const RingSection({super.key});

  @override
  State<RingSection> createState() => _RingSectionState();
}

class _RingSectionState extends State<RingSection> {
  static const _icons = {
    RingMode.alarm: Icons.alarm,
    RingMode.notification: Icons.notifications_active_outlined,
    RingMode.vibrate: Icons.vibration,
  };

  late final AppLifecycleListener _lifecycle;
  bool _fullScreenAllowed = true;

  @override
  void initState() {
    super.initState();
    // Back from the system screen: show whether full screen is now allowed.
    _lifecycle = AppLifecycleListener(onResume: _checkFullScreen);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkFullScreen());
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  Future<void> _checkFullScreen() async {
    final allowed =
        await AppScope.of(context).services.permissions.fullScreenAllowed();
    if (mounted) setState(() => _fullScreenAllowed = allowed);
  }

  Future<void> _pickSound() async {
    final scope = AppScope.of(context);
    final picked = await scope.services.sounds
        .pick(current: scope.ring.sound, title: scope.strings.soundPickerTitle);
    if (picked != null) scope.setRing(scope.ring.copyWith(sound: picked));
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final s = scope.strings;
    final ring = scope.ring;
    final needsPermission = ring.fullScreen && !_fullScreenAllowed;

    return Column(
      children: [
        RadioGroup<RingMode>(
          groupValue: ring.mode,
          onChanged: (mode) {
            if (mode != null) scope.setRing(ring.copyWith(mode: mode));
          },
          child: Column(
            children: [
              for (final mode in RingMode.values)
                RadioListTile<RingMode>(
                  value: mode,
                  contentPadding: EdgeInsets.zero,
                  secondary: Icon(_icons[mode]),
                  title: Text(s.ringModeLabel(mode)),
                  subtitle: Text(s.ringModeHint(mode)),
                ),
            ],
          ),
        ),
        if (ring.mode != RingMode.vibrate)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.music_note_outlined),
            title: Text(s.soundLabel),
            subtitle: Text(s.soundSubtitle(
                ring.sound.isDefault ? s.soundDefault : ring.sound.title ?? s.soundLabel)),
            trailing: const Icon(Icons.chevron_right),
            onTap: _pickSound,
          ),
        if (ring.mode == RingMode.alarm)
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: Icon(Icons.fullscreen,
                color: needsPermission ? palette(context).alarm : null),
            title: Text(s.fullScreenLabel),
            subtitle: Text(!ring.fullScreen
                ? s.fullScreenOffHint
                : needsPermission
                    ? s.fullScreenNeedsPermission
                    : s.fullScreenOnHint),
            value: ring.fullScreen,
            onChanged: (on) => scope.setRing(ring.copyWith(fullScreen: on)),
          ),
        if (ring.mode == RingMode.alarm && needsPermission)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: scope.services.permissions.requestFullScreen,
              child: Text(s.permFix),
            ),
          ),
      ],
    );
  }
}
