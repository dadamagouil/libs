import 'package:flutter/material.dart';

/// Single-line text entry in a dialog; pops the trimmed text, or null on cancel.
///
/// The controller belongs to the dialog: it is only disposed once the closing animation is over (a controller
/// owned by the caller would be disposed too early and crash the animation).
class TextPromptDialog extends StatefulWidget {
  const TextPromptDialog({
    super.key,
    required this.title,
    required this.label,
    required this.fieldKey,
    required this.submitKey,
    required this.submitLabel,
    required this.cancelLabel,
    this.message,
    this.initial = '',
    this.capitalization = TextCapitalization.none,
    this.keyboardType,
  });

  /// Warning text shown above the field.
  final String? message;
  final String title;
  final String label;
  final Key fieldKey;
  final Key submitKey;
  final String submitLabel;
  final String cancelLabel;
  final String initial;
  final TextCapitalization capitalization;
  final TextInputType? keyboardType;

  @override
  State<TextPromptDialog> createState() => _TextPromptDialogState();
}

class _TextPromptDialogState extends State<TextPromptDialog> {
  late final _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.message != null) ...[
            Text(widget.message!, key: const Key('prompt-message')),
            const SizedBox(height: 16),
          ],
          TextField(
            key: widget.fieldKey,
            controller: _controller,
            autofocus: true,
            textCapitalization: widget.capitalization,
            keyboardType: widget.keyboardType,
            decoration: InputDecoration(labelText: widget.label),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(widget.cancelLabel)),
        FilledButton(
          key: widget.submitKey,
          onPressed: () => Navigator.pop(context, _controller.text.trim()),
          child: Text(widget.submitLabel),
        ),
      ],
    );
  }
}
