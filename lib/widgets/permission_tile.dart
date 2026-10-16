import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../theme.dart';

/// Status of one Android permission with a button to fix it. [allowed] null
/// means the status cannot be read, so only the button is offered.
class PermissionTile extends StatelessWidget {
  const PermissionTile({
    super.key,
    required this.title,
    required this.allowed,
    required this.onFix,
    this.hint,
  });

  final String title;
  final bool? allowed;
  final VoidCallback onFix;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context).strings;
    final p = palette(context);
    final ok = allowed;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        ok == null
            ? Icons.fullscreen
            : ok
                ? Icons.check_circle
                : Icons.error_outline,
        color: ok == false ? p.alarm : p.brand,
      ),
      title: Text(title),
      subtitle: Text(ok == null ? (hint ?? '') : (ok ? s.permAllowed : s.permMissing)),
      trailing: ok == true
          ? null
          : TextButton(onPressed: onFix, child: Text(s.permFix)),
    );
  }
}
