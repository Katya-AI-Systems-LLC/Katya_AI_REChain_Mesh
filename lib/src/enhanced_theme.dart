import 'package:flutter/material.dart';

/// Расширенная система дизайна с Material Design 3, поддержка темных/светлых тем
class EnhancedTheme {
  // ============ ОСНОВНАЯ ЦВЕТОВАЯ ПАЛИТРА ============
  // Темная тема - "Cosmic" (космос)
  static const Color darkBg = Color(0xFF0B1020);      // Фон космоса
  static const Color darkSurface = Color(0xFF1A1F3A); // Поверхность
  static const Color darkSurfaceAlt = Color(0xFF24293F); // Альтернативная поверхность
  
  static const Color primary = Color(0xFF6C63FF);     // Фиолетовый первичный
  static const Color primaryLight = Color(0xFF8B84FF); // Светлый фиолетовый
  static const Color primaryDark = Color(0xFF4D47CC); // Темный фиолетовый
  
  static const Color accent = Color(0xFF00D1FF);      // Голубой аккент
  static const Color accentLight = Color(0xFF40E1FF); // Светлый голубой
  static const Color accentDark = Color(0xFF00A8CC); // Темный голубой
  
  static const Color secondary = Color(0xFF9C27B0);   // Пурпурный
  static const Color tertiary = Color(0xFFFF6B6B);    // Коралловый
  
  static const Color success = Color(0xFF4CAF50);     // Зеленый успешный
  static const Color warning = Color(0xFFFF9800);     // Оранжевый предупреждение
  static const Color error = Color(0xFFF44336);       // Красный ошибка
  static const Color info = Color(0xFF00BCD4);        // Голубой информация
  
  static const Color textPrimary = Color(0xFFE8EAF6); // Основной текст
  static const Color textSecondary = Color(0xFF9E9E9E); // Вторичный текст
  static const Color textTertiary = Color(0xFF616161);   // Третичный текст
  
  static const Color border = Color(0xFF2A2F4A);      // Границы
  static const Color borderLight = Color(0xFF3F4666); // Светлые границы
  
  // ============ СВЕТЛАЯ ТЕМА ============
  static const Color lightBg = Color(0xFFFAFAFA);      // Светлый фон
  static const Color lightSurface = Color(0xFFFFFFFF); // Белая поверхность
  static const Color lightTextPrimary = Color(0xFF212121); // Темный текст
  static const Color lightTextSecondary = Color(0xFF757575); // Серый вторичный
  
  // ============ ДОПОЛНИТЕЛЬНЫЕ ЦВЕТА ============
  static const Color shimmerBase = Color(0xFF2A2F4A);
  static const Color shimmerHighlight = Color(0xFF3F4666);
  
  // ============ ТЕНИ И ЭФФЕКТЫ ============
  static List<BoxShadow> get primaryShadow => [
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

  static List<BoxShadow> get lightShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 12,
      spreadRadius: 0,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 24,
      spreadRadius: 0,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.12),
      blurRadius: 16,
      spreadRadius: 0,
      offset: const Offset(0, 6),
    ),
  ];

  // ============ ГРАДИЕНТЫ ============
  static const LinearGradient spaceGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [darkBg, darkSurface, primary],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, accent, secondary],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
  );

  static const LinearGradient errorGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF44336), Color(0xFFEF5350)],
  );

  // ============ СТИЛИ ТЕКСТА ============
  static const TextStyle headingXL = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    color: textPrimary,
  );

  static const TextStyle headingL = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
    color: textPrimary,
  );

  static const TextStyle headingM = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    color: textPrimary,
  );

  static const TextStyle headingS = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: textPrimary,
  );

  static const TextStyle titleL = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: textPrimary,
  );

  static const TextStyle titleM = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
    color: textPrimary,
  );

  static const TextStyle titleS = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    color: textPrimary,
  );

  static const TextStyle bodyL = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.5,
    color: textPrimary,
  );

  static const TextStyle bodyM = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.25,
    color: textSecondary,
  );

  static const TextStyle bodyS = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.4,
    color: textSecondary,
  );

  static const TextStyle labelL = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    color: textPrimary,
  );

  static const TextStyle labelM = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: textSecondary,
  );

  static const TextStyle labelS = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: textSecondary,
  );

  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    color: Colors.white,
  );

  // ============ ТЕМЫ ============
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: primary,
      onPrimary: Colors.white,
      primaryContainer: primaryLight,
      onPrimaryContainer: darkBg,
      secondary: secondary,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFB39DDB),
      onSecondaryContainer: darkBg,
      tertiary: tertiary,
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFFEF9A9A),
      onTertiaryContainer: darkBg,
      error: error,
      onError: Colors.white,
      errorContainer: Color(0xFFEF5350),
      onErrorContainer: darkBg,
      surface: darkSurface,
      onSurface: textPrimary,
      surfaceContainerHighest: darkSurfaceAlt,
      outline: border,
    ),
    scaffoldBackgroundColor: darkBg,
    appBarTheme: AppBarTheme(
      backgroundColor: darkSurface,
      foregroundColor: textPrimary,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: textPrimary),
      titleTextStyle: headingM.copyWith(color: textPrimary),
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      color: darkSurface,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      shadowColor: Colors.black.withOpacity(0.2),
      margin: EdgeInsets.zero,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 8,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: button,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: button,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: accent,
        side: const BorderSide(color: accent, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: button.copyWith(color: accent),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: accent,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        textStyle: button.copyWith(color: accent),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      elevation: 8,
      extendedSizeConstraints: const BoxConstraints(
        minHeight: 56,
        minWidth: 56,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: darkSurface,
      selectedItemColor: accent,
      unselectedItemColor: textSecondary.withOpacity(0.6),
      type: BottomNavigationBarType.fixed,
      elevation: 16,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: darkSurface,
      indicatorColor: accent.withOpacity(0.2),
      labelTextStyle: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return labelM.copyWith(color: accent, fontWeight: FontWeight.w600);
        }
        return labelM.copyWith(color: textSecondary);
      }),
      height: 80,
    ),
    textTheme: TextTheme(
      displayLarge: headingXL,
      displayMedium: headingL,
      displaySmall: headingM,
      headlineLarge: headingM,
      headlineMedium: headingS,
      headlineSmall: titleL,
      titleLarge: titleL,
      titleMedium: titleM,
      titleSmall: titleS,
      bodyLarge: bodyL,
      bodyMedium: bodyM,
      bodySmall: bodyS,
      labelLarge: labelL,
      labelMedium: labelM,
      labelSmall: labelS,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkSurfaceAlt,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: border, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: border, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: accent, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: error, width: 2),
      ),
      labelStyle: labelM,
      hintStyle: labelM.copyWith(color: textSecondary),
      prefixIconColor: textSecondary,
      suffixIconColor: textSecondary,
      counterStyle: bodyS,
      helperStyle: bodyS,
      errorStyle: bodyS.copyWith(color: error),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: darkSurfaceAlt,
      disabledColor: darkSurfaceAlt.withOpacity(0.5),
      selectedColor: accent,
      secondarySelectedColor: secondary,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      labelStyle: labelM,
      secondaryLabelStyle: labelM.copyWith(color: Colors.white),
      brightness: Brightness.dark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    iconTheme: const IconThemeData(color: textPrimary),
    sliderTheme: SliderThemeData(
      activeTrackColor: accent,
      inactiveTrackColor: border,
      thumbColor: accent,
      overlayColor: accent.withOpacity(0.2),
      valueIndicatorColor: accent,
      valueIndicatorTextStyle: labelM.copyWith(color: darkBg),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: accent,
      linearMinHeight: 4,
      circularTrackColor: border,
      refreshBackgroundColor: darkSurface,
    ),
    dialogTheme: DialogTheme(
      backgroundColor: darkSurface,
      elevation: 24,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titleTextStyle: headingS.copyWith(color: textPrimary),
      contentTextStyle: bodyM,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: darkSurface,
      elevation: 24,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: darkSurfaceAlt,
      contentTextStyle: bodyM.copyWith(color: textPrimary),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
      insetPadding: const EdgeInsets.all(16),
    ),
    tabBarTheme: TabBarTheme(
      labelColor: accent,
      unselectedLabelColor: textSecondary,
      indicator: const UnderlineTabIndicator(
        borderSide: BorderSide(color: accent, width: 3),
      ),
      labelStyle: titleM,
      unselectedLabelStyle: titleM.copyWith(color: textSecondary),
    ),
    dividerTheme: const DividerThemeData(
      color: border,
      thickness: 1,
      space: 16,
    ),
    listTileTheme: ListTileThemeData(
      textColor: textPrimary,
      iconColor: textPrimary,
      tileColor: darkSurfaceAlt,
      selectedColor: accent,
      selectedTileColor: accent.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: primary,
      onPrimary: Colors.white,
      primaryContainer: primaryLight,
      onPrimaryContainer: darkBg,
      secondary: secondary,
      onSecondary: Colors.white,
      tertiary: tertiary,
      onTertiary: Colors.white,
      error: error,
      onError: Colors.white,
      surface: lightSurface,
      onSurface: lightTextPrimary,
      surfaceContainerHighest: Color(0xFFF5F5F5),
      outline: Color(0xFFBDBDBD),
    ),
    scaffoldBackgroundColor: lightBg,
    appBarTheme: AppBarTheme(
      backgroundColor: lightSurface,
      foregroundColor: lightTextPrimary,
      elevation: 0,
      centerTitle: true,
      surfaceTintColor: Colors.transparent,
      iconTheme: const IconThemeData(color: lightTextPrimary),
      titleTextStyle: headingM.copyWith(color: lightTextPrimary),
    ),
    cardTheme: CardThemeData(
      color: lightSurface,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      shadowColor: Colors.black.withOpacity(0.08),
    ),
    textTheme: TextTheme(
      displayLarge: headingXL.copyWith(color: lightTextPrimary),
      displayMedium: headingL.copyWith(color: lightTextPrimary),
      displaySmall: headingM.copyWith(color: lightTextPrimary),
      headlineLarge: headingM.copyWith(color: lightTextPrimary),
      headlineMedium: headingS.copyWith(color: lightTextPrimary),
      headlineSmall: titleL.copyWith(color: lightTextPrimary),
      titleLarge: titleL.copyWith(color: lightTextPrimary),
      titleMedium: titleM.copyWith(color: lightTextPrimary),
      titleSmall: titleS.copyWith(color: lightTextPrimary),
      bodyLarge: bodyL.copyWith(color: lightTextPrimary),
      bodyMedium: bodyM.copyWith(color: lightTextSecondary),
      bodySmall: bodyS.copyWith(color: lightTextSecondary),
      labelLarge: labelL.copyWith(color: lightTextPrimary),
      labelMedium: labelM.copyWith(color: lightTextSecondary),
      labelSmall: labelS.copyWith(color: lightTextSecondary),
    ),
  );
}
