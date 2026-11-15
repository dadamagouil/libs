import 'package:intl/intl.dart';

const _maxIntegerDigits = 7;
const _maxDecimals = 2;

/// Press of a key on the amount keypad: a digit, `.` (decimal separator) or `<` (erase).
///
/// The text always stays in the `1234.5` form; localised display is a separate step ([displayInput]).
String keypadPress(String current, String key) {
  if (key == '<') {
    return current.isEmpty ? current : current.substring(0, current.length - 1);
  }
  if (key == '.') {
    if (current.contains('.')) return current;
    return current.isEmpty ? '0.' : '$current.';
  }
  final dot = current.indexOf('.');
  if (dot >= 0) {
    return current.length - dot - 1 >= _maxDecimals ? current : current + key;
  }
  if (current == '0') return key == '0' ? current : key;
  return current.length >= _maxIntegerDigits ? current : current + key;
}

/// "45.5" -> 4550 (minor units, e.g. cents). Null when empty or unreadable.
///
/// Why integers: money is stored in minor units so sums never drift like floating point does.
int? parseMinor(String text) {
  if (text.isEmpty) return null;
  final parts = text.split('.');
  final whole = int.tryParse(parts[0].isEmpty ? '0' : parts[0]);
  if (whole == null) return null;
  final fraction = (parts.length > 1 ? parts[1] : '').padRight(2, '0').substring(0, 2);
  final cents = int.tryParse(fraction);
  return cents == null ? null : whole * 100 + cents;
}

/// Minor units -> input text: 4550 -> "45.5", 4500 -> "45", 5 -> "0.05".
String minorToInput(int minor) {
  final whole = minor ~/ 100;
  final cents = (minor % 100).toString().padLeft(2, '0');
  final fraction = cents.replaceFirst(RegExp(r'0+$'), '');
  return fraction.isEmpty ? '$whole' : '$whole.$fraction';
}

/// Amount in minor units, formatted for the language (e.g. "45,50 CHF" in French).
String formatMinor(int minor, String currency, String locale) =>
    NumberFormat.currency(locale: locale, symbol: currency, decimalDigits: 2).format(minor / 100);

/// The decimal separator of [locale] ("." or ",").
String decimalSeparator(String locale) => NumberFormat.decimalPattern(locale).symbols.DECIMAL_SEP;

/// Keypad text shown with the separator of the language; "0" while empty.
String displayInput(String text, String locale) =>
    text.isEmpty ? '0' : text.replaceFirst('.', decimalSeparator(locale));

/// An exchange rate typed by hand ("0,93" or "0.93"); null if empty, unreadable or out of range.
double? parseRate(String raw) {
  final value = double.tryParse(raw.trim().replaceAll(',', '.'));
  if (value == null || !value.isFinite || value <= 0 || value >= 1000000) return null;
  return value;
}

/// A rate shown without useless zeros ("0,93"), at most 6 decimals, with the language's separator.
String formatRate(double rate, String locale) => NumberFormat('0.######', locale).format(rate);
