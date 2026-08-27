import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryViolet = Color(0xFF087E8B);
  static const Color primaryVioletDark = Color(0xFF075E68);
  static const Color successGreen = Color(0xFF2ECC71);
  static const Color dangerRed = Color(0xFFE74C3C);

  static final ColorScheme _lightColorScheme = ColorScheme.fromSeed(
    seedColor: primaryViolet,
    brightness: Brightness.light,
  );

  static final ColorScheme _darkColorScheme = ColorScheme.fromSeed(
    seedColor: primaryViolet,
    brightness: Brightness.dark,
  );

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'sans',
    colorScheme: _lightColorScheme,
    primaryColor: _lightColorScheme.primary,
    scaffoldBackgroundColor: Colors.white,
    textTheme: const TextTheme(
      headlineSmall: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      bodyMedium: TextStyle(fontSize: 15, height: 1.35),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: _lightColorScheme.surface,
      foregroundColor: _lightColorScheme.onSurface,
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: _lightColorScheme.primary),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: _lightColorScheme.surface,
      selectedItemColor: primaryViolet,
      unselectedItemColor: _lightColorScheme.onSurface.withValues(alpha: 0.6),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 72,
      indicatorColor: _lightColorScheme.secondaryContainer,
      labelTextStyle: WidgetStatePropertyAll(
        TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    ),
    cardTheme: CardThemeData(
      color: _lightColorScheme.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: _lightColorScheme.outlineVariant),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryViolet,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 18),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryViolet,
        side: BorderSide(color: primaryViolet.withValues(alpha: 0.9)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryViolet,
      foregroundColor: Colors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _lightColorScheme.surfaceContainerHighest.withValues(
        alpha: 0.45,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      hintStyle: TextStyle(
        color: _lightColorScheme.onSurface.withValues(alpha: 0.6),
      ),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: primaryViolet,
      selectionColor: primaryViolet.withValues(alpha: 0.3),
      selectionHandleColor: primaryViolet,
    ),
    iconTheme: IconThemeData(color: _lightColorScheme.onSurface),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: _lightColorScheme.surface,
      contentTextStyle: TextStyle(color: _lightColorScheme.onSurface),
      actionTextColor: primaryViolet,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'sans',
    colorScheme: _darkColorScheme,
    primaryColor: _darkColorScheme.primary,
    scaffoldBackgroundColor: const Color(0xFF0B0B0E),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF0B0B0E),
      foregroundColor: _darkColorScheme.onSurface,
      elevation: 0,
      iconTheme: IconThemeData(color: _darkColorScheme.primary),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: const Color(0xFF111114),
      selectedItemColor: primaryViolet,
      unselectedItemColor: _darkColorScheme.onSurface.withValues(alpha: 0.6),
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF111114),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryVioletDark,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryViolet,
        side: BorderSide(color: primaryViolet.withValues(alpha: 0.9)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryVioletDark,
      foregroundColor: Colors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1A1A1D),
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      hintStyle: TextStyle(
        color: _darkColorScheme.onSurface.withValues(alpha: 0.6),
      ),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: primaryViolet,
      selectionColor: primaryViolet.withValues(alpha: 0.28),
      selectionHandleColor: primaryViolet,
    ),
    iconTheme: IconThemeData(color: _darkColorScheme.onSurface),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: const Color(0xFF111114),
      contentTextStyle: TextStyle(color: _darkColorScheme.onSurface),
      actionTextColor: primaryViolet,
    ),
  );
}
