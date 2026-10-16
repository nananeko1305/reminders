import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../theme.dart';

/// Warning shown above the events when notifications are turned off, since
/// then nothing will ring.
class NotificationsBanner extends StatelessWidget {
  const NotificationsBanner({super.key, required this.onFix});

  final VoidCallback onFix;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context).strings;
    final p = palette(context);
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      decoration: BoxDecoration(
        color: p.bannerBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(Icons.notifications_off_outlined, color: p.bannerFg),
          const SizedBox(width: 12),
          Expanded(
            child: Text(s.notificationsOffBanner,
                style: TextStyle(color: p.bannerFg)),
          ),
          TextButton(onPressed: onFix, child: Text(s.turnOn)),
        ],
      ),
    );
  }
}
