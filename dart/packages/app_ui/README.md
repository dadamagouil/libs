# app_ui

Material widgets, theme builder and persisted preferences. **The package owns no text**: every label is a
parameter, so the app keeps its own `gen-l10n` translations.

| Piece | Purpose |
|---|---|
| `confirmDestructive` | Confirm / cancel dialog for a destructive action |
| `confirmByTyping` | The person must type a word ("DELETE") to enable the button |
| `TextPromptDialog` | One-line text entry that owns (and disposes) its controller |
| `showUndoSnackBar` | "message + Undo" bar that closes by itself (timer included) |
| `Appearance`, `AppearanceAvatar`, `AppearancePicker`, `showAppearanceDialog`, `AppearanceLabels`, `appearancePalette`, `appearanceIcons`, `colorFromHex` | Icon + colour chosen for a vehicle, group or profile |
| `BrandPalette`, `buildLightTheme`, `buildDarkTheme` | Material 3 themes from a handful of brand colours; the app defines its own palettes |
| `PersistedPreference<T>`, `rememberedFilterProvider`, `languagePreferenceProvider` | A choice kept on the device as Riverpod state (language, theme, last used filter) |
| `PieChartView`, `PieSlice` | Pie chart with legend, values written by a callback |
| `AccountMenuButton`, `AccountMenuLabels` | Account picture in the app bar with a menu: who is signed in, edit account, log out (reports the choice) |
| `ImageAvatar` | Round picture with a fallback (initials, icon) that stays visible if the image fails |
| `AppBarTitle` | App icon + page name (the icon is an asset of the app) |

```dart
// A theme choice persisted on the device
enum Palette { mint, ocean }
final paletteProvider = StateNotifierProvider<PersistedPreference<Palette>, Palette>(
  (ref) => PersistedPreference<Palette>(
    storageKey: 'theme_palette',
    initial: Palette.mint,
    decode: (stored) => Palette.values.where((p) => p.name == stored).firstOrNull,
    encode: (palette) => palette.name,
  ),
);
```

Tests: `flutter test`.
