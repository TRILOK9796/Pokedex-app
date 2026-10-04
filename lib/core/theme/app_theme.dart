import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';

/// Material 3 theme shared by all app screens.
abstract final class AppTheme {
  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        surface: AppColors.background,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      textTheme: _poppinsTextTheme(base.textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 12,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  static TextTheme _poppinsTextTheme(TextTheme textTheme) {
    return TextTheme(
      displayLarge: _poppinsStyle(textTheme.displayLarge),
      displayMedium: _poppinsStyle(textTheme.displayMedium),
      displaySmall: _poppinsStyle(textTheme.displaySmall),
      headlineLarge: _poppinsStyle(textTheme.headlineLarge),
      headlineMedium: _poppinsStyle(textTheme.headlineMedium),
      headlineSmall: _poppinsStyle(textTheme.headlineSmall),
      titleLarge: _poppinsStyle(textTheme.titleLarge),
      titleMedium: _poppinsStyle(textTheme.titleMedium),
      titleSmall: _poppinsStyle(textTheme.titleSmall),
      bodyLarge: _poppinsStyle(textTheme.bodyLarge),
      bodyMedium: _poppinsStyle(textTheme.bodyMedium),
      bodySmall: _poppinsStyle(textTheme.bodySmall),
      labelLarge: _poppinsStyle(textTheme.labelLarge),
      labelMedium: _poppinsStyle(textTheme.labelMedium),
      labelSmall: _poppinsStyle(textTheme.labelSmall),
    ).apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    );
  }

  static TextStyle? _poppinsStyle(TextStyle? style) {
    if (style == null) return null;
    // google_fonts 9 uses material_ui types; only its resolved family is needed here.
    final fontFamily = GoogleFonts.poppins(
      fontWeight: style.fontWeight,
      fontStyle: style.fontStyle,
    ).fontFamily;
    return style.copyWith(fontFamily: fontFamily);
  }
}
