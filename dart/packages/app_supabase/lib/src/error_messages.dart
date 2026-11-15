import 'package:supabase_flutter/supabase_flutter.dart';

/// Readable message for the user. Messages raised by SQL functions (for example "Invalid or expired
/// invitation.") are already written for people, so they are shown as they are.
String errorMessage(Object error) {
  if (error is PostgrestException) return error.message;
  if (error is AuthException) return error.message;
  return error.toString();
}

/// Message with the technical code, so the user can pass it on to support.
String errorDetail(Object error) {
  if (error is PostgrestException) return '${error.message} (${error.code ?? '?'})';
  return errorMessage(error);
}

/// Code carried by a server error hint of the form `<prefix><code>`, or null.
///
/// Why hints: a SQL function raises `... using hint = 'PLAN_LIMIT:members'` so the app can react to a specific
/// rule (show an upgrade page) without parsing a human sentence. Example: `hintCodeOf(e, 'PLAN_LIMIT:')`.
String? hintCodeOf(Object error, String prefix) {
  if (error is! PostgrestException) return null;
  final hint = error.hint;
  if (hint == null || !hint.startsWith(prefix)) return null;
  return hint.substring(prefix.length);
}
