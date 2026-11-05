import 'package:flutter/material.dart';

import '../app_scope.dart';

/// Yes/no confirmation for something destructive. True only on confirm.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
}) async {
  final s = AppScope.of(context).strings;
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(s.cancel)),
        FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(s.delete)),
      ],
    ),
  );
  return ok ?? false;
}
