// Recognising an arrival through an e-mail link ("forgot password", confirmation).
//
// Supabase exchanges the link's code and clears the address before the first screen is drawn, so the app reads
// the launch address BEFORE initialising Supabase, then checks whether the account just received a reset e-mail.

/// True if [uri] is a sign-in link (code, token or recovery type) sent by Supabase.
bool isAuthLink(Uri uri) {
  var fragment = const <String, String>{};
  if (uri.fragment.contains('=')) {
    try {
      fragment = Uri.splitQueryString(uri.fragment.replaceFirst(RegExp(r'^[^?]*\?'), ''));
    } on FormatException {
      // A fragment that is not a list of parameters (a route name, for instance) is ignored.
    }
  }
  bool has(String key) => uri.queryParameters.containsKey(key) || fragment.containsKey(key);
  return has('code') || has('access_token') || uri.toString().contains('type=recovery');
}

/// Token of the "forgot password" link of the e-mail template (`?token_hash=…&type=recovery`).
///
/// Why: unlike the classic PKCE link, it is valid in ANY browser (mail apps open links in their own browser).
/// Null when the address holds none.
String? recoveryTokenHash(Uri uri) {
  final hash = uri.queryParameters['token_hash'];
  if (hash == null || hash.isEmpty) return null;
  return uri.queryParameters['type'] == 'recovery' ? hash : null;
}

/// True if the account's reset e-mail was sent less than [within] ago (the link itself is valid 1 hour).
bool isRecentRecovery(
  String? recoverySentAt,
  DateTime now, {
  Duration within = const Duration(hours: 2),
}) {
  final sent = recoverySentAt == null ? null : DateTime.tryParse(recoverySentAt);
  if (sent == null) return false;
  final age = now.difference(sent);
  return !age.isNegative && age <= within;
}
