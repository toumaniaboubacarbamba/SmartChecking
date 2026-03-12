import 'package:flutter/material.dart';

class AppColors {
  // Couleurs principales
  static const primary = Color(0xFF0CC17C); // vert principal
  static const cancel = Color(0xFFF52626); // rouge annuler
  static const role = Color(0xFF03A9F4); // bleu rôle
  static const textDark = Color(0xFF4B4B4B); // gris texte

  // Neutres
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);
  static const background = Color(0xFFFFFFFF); // fond blanc

  // Variantes utiles
  static const primaryLight = Color(
    0xFFE8FAF3,
  ); // vert très clair (backgrounds)
  static const primaryDark = Color(0xFF09A068); // vert foncé (hover/pressed)
}

class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.role,
      error: AppColors.cancel,
      surface: AppColors.white,
    ),

    // AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.white,
      foregroundColor: AppColors.textDark,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'Gotham',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
      ),
    ),

    // Texte
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'Gotham',
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.textDark,
      ),
      displayMedium: TextStyle(
        fontFamily: 'Gotham',
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Arial',
        fontSize: 16,
        color: AppColors.textDark,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Arial',
        fontSize: 14,
        color: AppColors.textDark,
      ),
      labelLarge: TextStyle(
        fontFamily: 'Gotham',
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.white,
      ),
    ),

    // Bouton principal (vert)
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(
          fontFamily: 'Gotham',
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // Bouton annuler (rouge) → on l'utilisera avec OutlinedButton
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.cancel,
        side: const BorderSide(color: AppColors.cancel),
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(
          fontFamily: 'Gotham',
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // Input
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.primaryLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.cancel, width: 1.5),
      ),
      labelStyle: const TextStyle(
        fontFamily: 'Arial',
        color: AppColors.textDark,
      ),
      prefixIconColor: AppColors.primary,
    ),

    // Card
    cardTheme: CardThemeData(
      color: AppColors.white,
      elevation: 2,
      shadowColor: AppColors.primary.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),

    // Badge rôle (chip)
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.role.withValues(alpha: 0.1),
      labelStyle: const TextStyle(
        fontFamily: 'Gotham',
        color: AppColors.role,
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
      side: const BorderSide(color: AppColors.role, width: 0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
    ),
  );
}
