import 'package:app_core/app_core.dart';
import 'package:flutter/material.dart';

/// Confirmation for an irreversible action: the person must type the requested word ("DELETE") to enable the
/// button. Returns true if confirmed.
///
/// [typeToConfirmLabel] is the instruction shown above the field, for example "Type DELETE to confirm".
Future<bool> confirmByTyping(
  BuildContext context, {
  required String title,
  required String body,
  required String actionLabel,
  required String cancelLabel,
  required String word,
  required String typeToConfirmLabel,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (_) => _TypeToConfirmDialog(
      title: title,
      body: body,
      actionLabel: actionLabel,
      cancelLabel: cancelLabel,
      word: word,
      typeToConfirmLabel: typeToConfirmLabel,
    ),
  );
  return confirmed == true;
}

class _TypeToConfirmDialog extends StatefulWidget {
  const _TypeToConfirmDialog({
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.cancelLabel,
    required this.word,
    required this.typeToConfirmLabel,
  });

  final String title;
  final String body;
  final String actionLabel;
  final String cancelLabel;
  final String word;
  final String typeToConfirmLabel;

  @override
  State<_TypeToConfirmDialog> createState() => _TypeToConfirmDialogState();
}

class _TypeToConfirmDialogState extends State<_TypeToConfirmDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.body),
            const SizedBox(height: 16),
            Text(
              widget.typeToConfirmLabel,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextField(
              key: const Key('confirm-typing-field'),
              controller: _controller,
              autofocus: true,
              textCapitalization: TextCapitalization.characters,
              onChanged: (_) => setState(() {}),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(widget.cancelLabel),
        ),
        FilledButton(
          key: const Key('confirm-typing-action'),
          style: FilledButton.styleFrom(
            backgroundColor: scheme.error,
            foregroundColor: scheme.onError,
          ),
          onPressed: matchesConfirmWord(_controller.text, widget.word)
              ? () => Navigator.pop(context, true)
              : null,
          child: Text(widget.actionLabel),
        ),
      ],
    );
  }
}
