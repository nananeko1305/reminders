import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../theme.dart';

/// Status of one Android permission with a button to fix it. [allowed] is
/// null while the status is still being read.
class PermissionTile extends StatelessWidget {
  const PermissionTile({
    super.key,
    required this.title,
    required this.allowed,
    required this.onFix,
  });

  final String title;
  final bool? allowed;
  final VoidCallback onFix;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context).strings;
    final p = palette(context);
    final ok = allowed;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        ok == false ? Icons.error_outline : Icons.check_circle,
        color: ok == false ? p.alarm : p.brand,
      ),
      title: Text(title),
      subtitle: ok == null ? null : Text(ok ? s.permAllowed : s.permMissing),
      trailing: ok == false
          ? TextButton(onPressed: onFix, child: Text(s.permFix))
          : null,
    );
  }
}
