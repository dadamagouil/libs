# app_core

Pure Dart helpers (no Flutter), shared by the apps.

| Helper | Purpose |
|---|---|
| `PasswordPolicy`, `PasswordIssue` | Sign-up password rules returned as codes the app translates; `PasswordPolicy.lengthOnly()` for the light version |
| `isValidEmail` | Loose shape check before a server round trip |
| `isAuthLink`, `recoveryTokenHash`, `isRecentRecovery` | Recognise arrival through a Supabase e-mail link; browser-independent recovery link |
| `keypadPress`, `parseMinor`, `minorToInput`, `formatMinor`, `displayInput`, `decimalSeparator`, `parseRate`, `formatRate` | Amount keypad and money in minor units |
| `formatClock`, `formatShortDuration` | Durations |
| `toCsv`, `csvCell`, `csvDateTime` | CSV with formula-injection guard |
| `shareFractions` | Share of each value in a total (pie charts) |
| `matchesConfirmWord` | Type-to-confirm check |
| `parseHexColor` | `#RRGGBB` to ARGB integer, strict about digits |
| `initialsOf` | Up to two initials, grapheme-safe |
| `LanguageSupport`, `languageNativeNames` | Offered languages, normalisation with a chosen fallback |

```dart
const support = LanguageSupport(codes: ['fr', 'en', 'de', 'it'], fallback: 'fr');
support.normalize('DE'); // 'de'
const PasswordPolicy().issues('abc'); // [tooShort, noUppercase, noDigit, noSpecial]
```

Tests: `dart test`.
