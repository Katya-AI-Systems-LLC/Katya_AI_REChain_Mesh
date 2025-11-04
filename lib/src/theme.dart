import 'package:flutter/material.dart';

class KatyaTheme {
  // Katya AI REChain космическая цветовая палитра
  static const Color primary = Color(0xFF6C63FF); // Фиолетовый
  static const Color accent = Color(0xFF00D1FF); // Голубой
  static const Color background = Color(0xFF0B1020); // Темно-синий космос
  static const Color surface = Color(0xFF1A1F3A); // Поверхность
  static const Color onSurface = Color(0xFFE8EAF6); // Текст на поверхности
  static const Color secondary = Color(0xFF9C27B0); // Пурпурный
  static const Color tertiary = Color(0xFFFF6B6B); // Коралловый
  static const Color success = Color(0xFF4CAF50); // Зеленый
  static const Color warning = Color(0xFFFF9800); // Оранжевый
  static const Color error = Color(0xFFF44336); // Красный

  // Дополнительные цвета для текста
  static const Color textPrimary = Color(0xFFE8EAF6);
  static const Color textSecondary = Color(0xFF9E9E9E);
  static const Color border = Color(0xFF2A2F4A);

  // Стили текста
  static const TextStyle heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: textPrimary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: textSecondary,
  );

  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: primary,
          secondary: secondary,
          tertiary: tertiary,
          surface: surface,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onTertiary: Colors.white,
          onSurface: onSurface,
          error: error,
          onError: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: surface,
          foregroundColor: onSurface,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: onSurface,
          ),
        ),
        scaffoldBackgroundColor: background,
        cardTheme: CardThemeData(
          color: surface,
          elevation: 8,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: onSurface,
          ),
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: onSurface,
          ),
          titleLarge: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: onSurface,
          ),
          bodyLarge: TextStyle(fontSize: 16, color: onSurface),
          bodyMedium: TextStyle(fontSize: 14, color: onSurface),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primary),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primary, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: accent, width: 2),
          ),
          labelStyle: const TextStyle(color: onSurface),
          hintStyle: const TextStyle(color: Colors.grey),
        ),
      );

  // Градиенты для космической тематики
  static const LinearGradient spaceGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [background, surface, primary],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, accent, secondary],
  );

  // Тени для космического эффекта
  static List<BoxShadow> get spaceShadow => [
        BoxShadow(
          color: primary.withOpacity(0.3),
          blurRadius: 20,
          spreadRadius: 0,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: accent.withOpacity(0.2),
          blurRadius: 40,
          spreadRadius: 0,
          offset: const Offset(0, 16),
        ),
      ];
}
