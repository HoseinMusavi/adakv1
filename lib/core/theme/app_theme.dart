import 'package:flutter/material.dart';

class AppTheme {
  static const _neonCyan = Color(0xFF00E5FF);
  static const _fontFamily = 'Vazirmatn';

  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: _fontFamily,
      colorScheme: base.colorScheme.copyWith(
        primary: _neonCyan,
        secondary: _neonCyan,
        surface: const Color(0xFF12141A),
        surfaceContainerHighest: const Color(0xFF1A1E27),
      ),
      scaffoldBackgroundColor: const Color(0xFF0E1015),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF151923),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(56, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(56, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF151923),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}
