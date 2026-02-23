import 'package:flutter/material.dart';

class AppTheme {
  static const Color forestGreen = Color(0xFF2D5016);
  static const Color leafGreen = Color(0xFF4CAF50);
  static const Color lightGreen = Color(0xFF81C784);
  static const Color paleGreen = Color(0xFFC8E6C9);
  static const Color skyBlue = Color(0xFF87CEEB);
  static const Color earthBrown = Color(0xFF795548);
  static const Color warmBrown = Color(0xFF8D6E63);
  static const Color sunYellow = Color(0xFFFFD54F);
  static const Color fruitOrange = Color(0xFFFF8A65);
  static const Color blossom = Color(0xFFF8BBD0);
  static const Color backgroundCream = Color(0xFFFFF8E1);
  static const Color backgroundLight = Color(0xFFF1F8E9);
  static const Color textDark = Color(0xFF2E2E2E);
  static const Color textSecondary = Color(0xFF757575);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: leafGreen,
        brightness: Brightness.light,
        primary: forestGreen,
        secondary: leafGreen,
        surface: backgroundLight,
      ),
      scaffoldBackgroundColor: backgroundLight,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: forestGreen,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: forestGreen),
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: leafGreen,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: forestGreen,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: paleGreen),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: paleGreen),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: leafGreen, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: leafGreen,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: forestGreen,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: paleGreen.withValues(alpha: 0.5),
        selectedColor: leafGreen,
        labelStyle: const TextStyle(fontSize: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  static Color getCategoryColor(int categoryIndex) {
    const colors = [
      Color(0xFF66BB6A), // health
      Color(0xFF42A5F5), // career
      Color(0xFFFFCA28), // finance
      Color(0xFFAB47BC), // learning
      Color(0xFFEF5350), // social
      Color(0xFFFF7043), // hobby
      Color(0xFF78909C), // custom
    ];
    return colors[categoryIndex % colors.length];
  }
}
