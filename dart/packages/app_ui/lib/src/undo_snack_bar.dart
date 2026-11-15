import 'dart:async';

import 'package:flutter/material.dart';

/// Shows a "message + Undo" bar that closes by itself after a few seconds.
///
/// Why a timer: a snack bar with an action no longer closes on its own in recent Flutter versions, it would
/// stay on screen until the next gesture.
void showUndoSnackBar(
  ScaffoldMessengerState messenger, {
  required String message,
  required String undoLabel,
  required VoidCallback onUndo,
  Duration duration = const Duration(seconds: 4),
}) {
  messenger.clearSnackBars();
  messenger.showSnackBar(
    SnackBar(
      content: _SelfClosing(message: message, messenger: messenger, duration: duration),
      action: SnackBarAction(label: undoLabel, onPressed: onUndo),
    ),
  );
}

/// Text of the bar; the timer lives with it, so it stops as soon as the bar disappears.
class _SelfClosing extends StatefulWidget {
  const _SelfClosing({required this.message, required this.messenger, required this.duration});

  final String message;
  final ScaffoldMessengerState messenger;
  final Duration duration;

  @override
  State<_SelfClosing> createState() => _SelfClosingState();
}

class _SelfClosingState extends State<_SelfClosing> {
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.duration, widget.messenger.hideCurrentSnackBar);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Text(widget.message);
}
