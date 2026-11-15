import 'package:characters/characters.dart';

/// Up to two initials of a name ("Anne-Claire Martin" -> "AM"), "?" for an empty name.
///
/// Why graphemes: `name[0]` would cut an emoji or an accented letter written with combining marks in half.
String initialsOf(String name) {
  final words = name.trim().split(RegExp(r'\s+')).where((word) => word.isNotEmpty);
  if (words.isEmpty) return '?';
  return words.take(2).map((word) => word.characters.first.toUpperCase()).join();
}
