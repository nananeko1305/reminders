import 'package:flutter/material.dart';

import '../app_scope.dart';

/// Asks for a name (new list, rename). Returns the trimmed name, or null if
/// cancelled or empty.
Future<String?> showNameDialog(
  BuildContext context, {
  required String title,
  required String label,
  String hint = '',
  String initial = '',
}) =>
    showDialog<String>(
      context: context,
      builder: (_) =>
          _NameDialog(title: title, label: label, hint: hint, initial: initial),
    );

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

class _NameDialog extends StatefulWidget {
  const _NameDialog({
    required this.title,
    required this.label,
    required this.hint,
    required this.initial,
  });

  final String title;
  final String label;
  final String hint;
  final String initial;

  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  late final _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _controller.text.trim();
    Navigator.pop(context, name.isEmpty ? null : name);
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context).strings;
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        onSubmitted: (_) => _submit(),
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hint,
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context), child: Text(s.cancel)),
        FilledButton(onPressed: _submit, child: Text(s.save)),
      ],
    );
  }
}
