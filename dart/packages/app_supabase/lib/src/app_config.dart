import 'package:flutter/foundation.dart' show kIsWeb;

/// Values injected at build time:
/// `flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_PUBLISHABLE_KEY=...`
///
/// Why `--dart-define`: no URL or key is ever written in the code, so one codebase serves every environment.
/// (`String.fromEnvironment` is evaluated by the app's build, even though it is written in this package.)
class AppConfig {
  const AppConfig._();

  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabasePublishableKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

  /// Address of this environment's web app (invitation links, e-mail links).
  static const webUrl = String.fromEnvironment('WEB_URL');

  /// "dev" or "prd": dev shows a banner and technical error details.
  static const env = String.fromEnvironment('APP_ENV', defaultValue: 'dev');

  /// Sign-in with Google offered (set once Google is configured in Supabase); otherwise the button stays hidden.
  static const googleAuth = bool.fromEnvironment('GOOGLE_AUTH');

  /// Android application id, used as the scheme of the OAuth return link. Each app passes its own
  /// `--dart-define=AUTH_SCHEME=...` (dev and prd have different ids).
  static const authScheme = String.fromEnvironment('AUTH_SCHEME');

  static bool get isConfigured => supabaseUrl.isNotEmpty && supabasePublishableKey.isNotEmpty;

  /// Page the e-mail links lead to (confirmation, forgotten password, address change): the environment's web
  /// app. Without it Supabase redirects to the site root.
  static String? get emailRedirect => webUrl.isEmpty ? null : webUrl;

  /// Where to come back after an OAuth sign-in: the web app, or the Android app's own link.
  static String? get oauthRedirect => kIsWeb ? emailRedirect : '$authScheme://login-callback';
}

/// Technical error details (server message, cause of a sync failure) are shown outside production only: they
/// help diagnose a self-hosted backend and must never appear in prd.
bool get devDiagnosticsEnabled => AppConfig.env != 'prd';
