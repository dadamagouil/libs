/// "01:05:09" for a running clock.
String formatClock(Duration duration) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(duration.inHours)}:${two(duration.inMinutes % 60)}:${two(duration.inSeconds % 60)}';
}

/// Short readable duration: "2 h 5 min", "12 min" or "40 s". The units are international on purpose, so no
/// translation is needed.
String formatShortDuration(int seconds) {
  final duration = Duration(seconds: seconds);
  if (duration.inHours > 0) return '${duration.inHours} h ${duration.inMinutes % 60} min';
  if (duration.inMinutes > 0) return '${duration.inMinutes} min';
  return '${duration.inSeconds} s';
}
