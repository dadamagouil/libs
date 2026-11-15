# app_supabase

Supabase-facing helpers shared by the apps.

| Piece | Purpose |
|---|---|
| `AppConfig` | Build-time values read with `--dart-define`: `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`, `WEB_URL`, `APP_ENV`, `GOOGLE_AUTH`, `AUTH_SCHEME`; `isConfigured`, `emailRedirect`, `oauthRedirect` |
| `devDiagnosticsEnabled` | True outside production: technical error details are shown in dev only |
| `AuthStatus` | Signed-in user + "recovering" flag, with value equality so a token refresh does not reload the profile |
| `AuthFailure`, `AuthFailureKind`, `authFailureFrom` | Any auth error reduced to a kind the app translates, with a technical `detail` for dev builds |
| `errorMessage`, `errorDetail`, `hintCodeOf` | Messages raised by SQL functions, and `hint = 'PREFIX:code'` parsing (for example a plan limit) |

Not included on purpose: the concrete `AuthRepository` (sign-in, sign-up, redirects) because its method list is
tied to each app's flows (sign-up, redirects, what is created for a new account).

Config values are evaluated by the *app's* build, so the app passes its own defines:
`flutter run --dart-define=SUPABASE_URL=... --dart-define=AUTH_SCHEME=ch.example.app.dev`.
