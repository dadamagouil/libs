import 'package:flutter/material.dart';

/// The colours of one theme of an app: a brand "deep" colour (text, buttons), an "accent", a "warm" secondary,
/// a light background ("cream") and the dark-mode surfaces.
@immutable
class BrandPalette {
  const BrandPalette({
    required this.deep,
    required this.accent,
    required this.warm,
    required this.cream,
    required this.warmSoft,
    required this.darkSurface,
    required this.darkContainer,
  });

  final Color deep;
  final Color accent;
  final Color warm;
  final Color cream;
  final Color warmSoft;
  final Color darkSurface;
  final Color darkContainer;
}

/// Bottom navigation labels a bit smaller, so long words ("Einstellungen", "Impostazioni") fit on one line.
NavigationBarThemeData _navigationBarTheme(ColorScheme scheme) => NavigationBarThemeData(
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 11,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: selected ? scheme.onSurface : scheme.onSurfaceVariant,
        );
      }),
    );

/// Light theme built from a [BrandPalette].
ThemeData buildLightTheme(BrandPalette p) {
  final scheme = ColorScheme.fromSeed(
    seedColor: p.accent,
    primary: p.deep,
    onPrimary: p.cream,
    primaryContainer: p.accent,
    onPrimaryContainer: p.deep,
    secondary: p.warm,
    onSecondary: p.deep,
    secondaryContainer: p.warmSoft,
    onSecondaryContainer: p.deep,
    tertiary: p.accent,
    onTertiary: p.deep,
    surface: p.cream,
    onSurface: p.deep,
  );
  return ThemeData(
    colorScheme: scheme,
    scaffoldBackgroundColor: p.cream,
    navigationBarTheme: _navigationBarTheme(scheme),
    useMaterial3: true,
  );
}

/// Dark theme built from a [BrandPalette].
ThemeData buildDarkTheme(BrandPalette p) {
  final scheme = ColorScheme.fromSeed(
    seedColor: p.accent,
    brightness: Brightness.dark,
    primary: p.accent,
    onPrimary: p.deep,
    primaryContainer: p.darkContainer,
    onPrimaryContainer: p.accent,
    secondary: p.warm,
    onSecondary: p.deep,
    surface: p.darkSurface,
    onSurface: p.cream,
  );
  return ThemeData(
    colorScheme: scheme,
    scaffoldBackgroundColor: p.darkSurface,
    navigationBarTheme: _navigationBarTheme(scheme),
    useMaterial3: true,
  );
}
