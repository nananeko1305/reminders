import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../updates/update_checker.dart';
import 'update_dialog.dart';

/// Settings row: installed version, tap to check for updates.
class UpdateTile extends StatefulWidget {
  const UpdateTile({super.key});

  @override
  State<UpdateTile> createState() => _UpdateTileState();
}

class _UpdateTileState extends State<UpdateTile> {
  Future<String>? _version;
  bool _checking = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _version ??= AppScope.of(context).services.updates.currentVersion();
  }

  Future<void> _check() async {
    final scope = AppScope.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _checking = true);
    final result = await scope.services.updates.check();
    if (!mounted) return;
    setState(() => _checking = false);
    switch (result) {
      case UpdateAvailable():
        await showUpdateDialog(context, result);
      case UpToDate():
        messenger.showSnackBar(SnackBar(content: Text(scope.strings.upToDate)));
      case UpdateCheckFailed():
        messenger.showSnackBar(
            SnackBar(content: Text(scope.strings.updateCheckFailed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context).strings;
    return FutureBuilder<String>(
      future: _version,
      builder: (context, snap) {
        final version = snap.data;
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.system_update_rounded),
          title: Text(s.checkUpdates),
          subtitle: version == null ? null : Text(s.appVersion(version)),
          trailing: _checking
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : null,
          onTap: _checking ? null : _check,
        );
      },
    );
  }
}
