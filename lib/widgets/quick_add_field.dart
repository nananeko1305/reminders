import 'package:flutter/material.dart';

/// Text field pinned under a list for adding items one after another: the
/// keyboard stays open after each one.
class QuickAddField extends StatefulWidget {
  const QuickAddField({super.key, required this.hint, required this.onAdd});

  final String hint;
  final ValueChanged<String> onAdd;

  @override
  State<QuickAddField> createState() => _QuickAddFieldState();
}

class _QuickAddFieldState extends State<QuickAddField> {
  final _controller = TextEditingController();
  final _focus = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onAdd(text);
    _controller.clear();
    _focus.requestFocus();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          child: TextField(
            controller: _controller,
            focusNode: _focus,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => _submit(),
            // Keeps the keyboard open after submitting.
            onEditingComplete: () {},
            decoration: InputDecoration(
              hintText: widget.hint,
              prefixIcon: const Icon(Icons.add),
              suffixIcon: IconButton(
                icon: const Icon(Icons.send),
                onPressed: _submit,
              ),
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      );
}
