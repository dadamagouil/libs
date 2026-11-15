/// Reads a `#RRGGBB` (or `RRGGBB`) text into an opaque ARGB integer (`0xFFRRGGBB`); null if absent or invalid.
///
/// Strict about the digits (a lenient parser would turn `#12345` into a wrong colour) and tolerant about the
/// leading `#`.
int? parseHexColor(String? hex) {
  if (hex == null) return null;
  final digits = hex.startsWith('#') ? hex.substring(1) : hex;
  if (!RegExp(r'^[0-9a-fA-F]{6}$').hasMatch(digits)) return null;
  return 0xFF000000 | int.parse(digits, radix: 16);
}
