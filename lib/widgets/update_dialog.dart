import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_scope.dart';
import '../updates/update_checker.dart';

/// "New version available" with Download (opens the APK link in the
/// browser, which downloads it) and Later.
Future<void> showUpdateDialog(BuildContext context, UpdateAvailable update) {
  final s = AppScope.of(context).strings;
  final r = update.release;
  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      icon: const Icon(Icons.system_update_rounded, size: 36),
      title: Text(s.newVersionTitle),
      content: Text(s.newVersionBody(r.version, update.currentVersion)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text(s.later)),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
          onPressed: () {
            Navigator.pop(ctx);
            launchUrl(
              Uri.parse(r.downloadUrl),
              mode: LaunchMode.externalApplication,
            );
          },
          child: Text(s.download),
        ),
      ],
    ),
  );
}
