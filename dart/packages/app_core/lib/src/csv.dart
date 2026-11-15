// Spreadsheet-friendly CSV writing.

/// One CSV cell.
///
/// Two traps handled here:
///  - a text starting with `= + - @` would be run as a formula by a spreadsheet (CSV injection), so it is
///    prefixed with an apostrophe;
///  - a cell holding the [separator], a quote or a line break is quoted, quotes doubled.
String csvCell(Object? value, {String separator = ';'}) {
  var text = '${value ?? ''}';
  if (text.isNotEmpty && '=+-@'.contains(text[0])) text = "'$text";
  final needsQuotes =
      text.contains(separator) || text.contains('"') || text.contains('\n') || text.contains('\r');
  return needsQuotes ? '"${text.replaceAll('"', '""')}"' : text;
}

/// A whole CSV text: [header] line, then one line per row.
///
/// The default separator is `;` because French-language spreadsheets open it directly.
String toCsv(String header, Iterable<List<Object?>> rows, {String separator = ';'}) => [
      header,
      for (final row in rows)
        row.map((cell) => csvCell(cell, separator: separator)).join(separator),
    ].join('\n');

/// "2026-03-15 19:05" in the device's time zone, or '' for null.
String csvDateTime(DateTime? value) {
  if (value == null) return '';
  final local = value.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${local.year}-${two(local.month)}-${two(local.day)} ${two(local.hour)}:${two(local.minute)}';
}
