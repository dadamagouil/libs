import 'package:supabase_flutter/supabase_flutter.dart';

enum AuthFailureKind {
  invalidCredentials,
  emailTaken,
  weakPassword,
  signupDisabled,
  emailRejected,
  rateLimited,
  network,
  other,
}

/// An authentication error reduced to a kind the app can translate.
class AuthFailure implements Exception {
  const AuthFailure(this.kind, {this.detail});

  final AuthFailureKind kind;

  /// Technical detail (code, status, server message): shown in development builds to diagnose a self-hosted
  /// backend, never in production (see `devDiagnosticsEnabled`).
  final String? detail;
}

const _networkHints = [
  'SocketException',
  'ClientException',
  'HandshakeException',
  'TimeoutException',
  'Failed host lookup',
  'XMLHttpRequest',
];

AuthFailureKind _kindOfCode(String? code) => switch (code) {
      'invalid_credentials' => AuthFailureKind.invalidCredentials,
      'user_already_exists' || 'email_exists' => AuthFailureKind.emailTaken,
      'weak_password' => AuthFailureKind.weakPassword,
      'signup_disabled' => AuthFailureKind.signupDisabled,
      'email_address_invalid' => AuthFailureKind.emailRejected,
      'over_request_rate_limit' ||
      'over_email_send_rate_limit' ||
      'over_sms_send_rate_limit' =>
        AuthFailureKind.rateLimited,
      _ => AuthFailureKind.other,
    };

/// Turns any error raised during authentication into an [AuthFailure].
///
/// What is not recognised keeps its technical detail instead of disappearing behind a generic message.
AuthFailure authFailureFrom(Object error) {
  if (error is AuthRetryableFetchException) {
    return AuthFailure(
      AuthFailureKind.network,
      detail: 'status=${error.statusCode}, ${error.message}',
    );
  }
  if (error is AuthException) {
    return AuthFailure(
      _kindOfCode(error.code),
      detail: 'code=${error.code}, status=${error.statusCode}, ${error.message}',
    );
  }
  final text = error.toString();
  final isNetwork = _networkHints.any(text.contains);
  return AuthFailure(
    isNetwork ? AuthFailureKind.network : AuthFailureKind.other,
    detail: text.length > 200 ? text.substring(0, 200) : text,
  );
}
