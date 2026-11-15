# libs

[![CI](https://github.com/dadamagouil/libs/actions/workflows/ci.yml/badge.svg)](https://github.com/dadamagouil/libs/actions/workflows/ci.yml)

Reusable building blocks for Flutter + Supabase apps.

**What it is for.** Every new app starts with the same needs: sign-in errors, a password policy, an amount
keypad, confirm dialogs, a persisted language, a few SQL triggers, push from an Edge Function. Instead of
copying them from app to app (and letting the copies drift), they live here, tested once.

Related repositories:
- [`dadamagouil/devops`](https://github.com/dadamagouil/devops): CI/CD reusable workflows and actions.
- [`dadamagouil/models`](https://github.com/dadamagouil/models): file models (README, `DEPLOY.md`, `CLAUDE.md`, lint rules, Dependabot, PR/issue templates).

## Structure: one top-level folder per technology

| Folder | Technology | Content |
|---|---|---|
| [`dart/`](dart) | Dart / Flutter | [`packages/app_core`](dart/packages/app_core): pure Dart helpers (password policy, e-mail check, auth-link parsing, money keypad and parsing, durations, CSV, colours, initials, language support). [`packages/app_supabase`](dart/packages/app_supabase): `AppConfig` (build-time values), `AuthStatus`, `AuthFailure` mapping, error messages, server error hints. [`packages/app_ui`](dart/packages/app_ui): confirm / prompt dialogs, undo snack bar, appearance picker, brand theme builder, persisted preferences, pie chart, image avatar, account menu |
| [`sql/`](sql) | SQL (Postgres / Supabase) | `touch_updated_at`, `forbid_column_change`, invite codes + attempt rate limit, each with its test |
| [`typescript/`](typescript) | TypeScript (Deno) | [`edge-functions`](typescript/edge-functions): `envKey`, JSON responses, Firebase Cloud Messaging sender |

A new technology (Python scripts, Kotlin, Swift, Terraform...) gets its **own top-level folder** with its own
README, tests and a CI job in `.github/workflows/ci.yml`; nothing technology-specific lives at the root except
this README, `CONTRIBUTING.md`, `LICENSE`, `.gitignore` and `tool/` (scripts that run the checks of all technologies).
File models live in [`dadamagouil/models`](https://github.com/dadamagouil/models), CI building blocks in
[`dadamagouil/devops`](https://github.com/dadamagouil/devops).

## Design rules

- **No text in the packages.** Every label is a parameter, so each app keeps its own translations (`gen-l10n`).
  Rules that produce messages (for example the password policy) return *codes* the app translates.
- **Pure logic apart from widgets.** Anything computable without Flutter is in `app_core` and unit-tested.
- **No project name, URL or key in the code.** Values come from `--dart-define` (`AppConfig`) or parameters.

## Implement it in a project

### 1. Add the packages (Flutter app)

In the app's `pubspec.yaml`, take only what you need (`app_ui` pulls `app_core` by itself):

```yaml
dependencies:
  app_core:
    git: { url: https://github.com/dadamagouil/libs, path: dart/packages/app_core, ref: v1.0.0 }
  app_supabase:
    git: { url: https://github.com/dadamagouil/libs, path: dart/packages/app_supabase, ref: v1.0.0 }
  app_ui:
    git: { url: https://github.com/dadamagouil/libs, path: dart/packages/app_ui, ref: v1.0.0 }
```

Then `flutter pub get`. Pin `ref:` to a tag once releases exist, so an update of `libs` never breaks an app by
surprise. (The relative dependency `app_ui -> app_core` still has to be confirmed from a git dependency; see
issue #1.)

### 2. Use them

```dart
import 'package:app_core/app_core.dart';
import 'package:app_supabase/app_supabase.dart';
import 'package:app_ui/app_ui.dart';

// Password rules, translated by the app
final issues = const PasswordPolicy().issues(password); // [PasswordIssue.tooShort, ...]
final message = issues.map((i) => switch (i) {
  PasswordIssue.tooShort => l10n.pwMinLength(10),
  PasswordIssue.noDigit => l10n.pwDigit,
  _ => l10n.pwWeak,
}).join(', ');

// Server and auth errors
try { await supabase.auth.signInWithPassword(email: e, password: p); }
catch (err) { final failure = authFailureFrom(err); /* failure.kind -> translated text */ }

// A destructive action, with the app's own labels
final ok = await confirmDestructive(context,
    title: l10n.deleteTitle, message: l10n.deleteBody,
    confirmLabel: l10n.delete, cancelLabel: l10n.cancel);
```

Build values are never written in code; pass them at build time:

```bash
flutter run --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
            --dart-define=SUPABASE_PUBLISHABLE_KEY=sb_publishable_... \
            --dart-define=APP_ENV=dev --dart-define=AUTH_SCHEME=ch.example.app.dev
```

More examples: the README of each package (`dart/packages/*/README.md`).

### 3. SQL helpers

Copy the needed file from [`sql/migrations`](sql/migrations) into the app's own `supabase/migrations` with a
timestamp newer than the last one (an applied migration is never edited, so nothing references this folder
remotely), copy its test from `sql/tests`, then attach the triggers to the app's tables (the usage line is in
each file's header).

### 4. Edge Function helpers

Copy [`typescript/edge-functions`](typescript/edge-functions) (without the test file if you prefer) to
`supabase/functions/_shared/` and import by relative path:
`import { envKey } from "../_shared/env.ts";`.

### 5. Models

Copy the file models you need from [`dadamagouil/models`](https://github.com/dadamagouil/models) (its README gives the target path of each) and
replace the `{{placeholders}}`.

## License

MIT, see [LICENSE](LICENSE).

## Runners

The CI follows the repository variable `RUNNER_LABELS`, like the apps: a **JSON list** such as
`["self-hosted","Linux","X64"]` runs the jobs on your own runner; without the variable they run on GitHub
runners. The SQL job always runs on GitHub runners (Docker service container). A value that is not valid JSON
breaks every workflow at start-up. **Do not set it on a public repository**: a pull request from a fork would run on your own machine. Details: the `devops` README.

## Versions

Releases are tags `vX.Y.Z`, created by the `Release` workflow (Actions → Release → Run workflow, or by the owner's
automated task) only when something changed since the last one. Use `patch` for fixes and documentation,
`minor` for something new, `major` for a change that breaks users.

Pin apps to a version: `ref: v1.0.0` in the git dependency.

## Develop this repository

```bash
tool/check_all.sh    # format + analyze + tests of every package, then the Edge Function tests
SUPABASE_DIR=sql STUB=1 ../devops/.github/actions/supabase-sql-tests/run.sh "postgresql://postgres@localhost:5432/test"
```

CI (`.github/workflows/ci.yml`) runs the same checks through the reusable workflows of `devops`.
Everything here is written in English; see [CONTRIBUTING.md](CONTRIBUTING.md).
