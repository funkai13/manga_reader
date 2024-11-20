import 'package:flutter/material.dart';
import 'package:manga_reader/core/theme/typography.dart';

import '../utils/constanst.dart';
import 'colors.dart';

class AppTheme {
  static ThemeData lightTheme(BuildContext context) {
    final textTheme = _getTextTheme(context);
    return ThemeData(
      primaryColor: AppColorsLight.primaryColor,
      scaffoldBackgroundColor: AppColorsLight.backgroundColor,
      colorScheme: const ColorScheme.light(
        primary: AppColorsLight.buttonColor,
        secondary: AppColorsLight.accentColor,
        surface: AppColorsLight.cardColor,
        onPrimary: Colors.white,
        onSurface: AppColorsLight.textColor,
      ),
      textTheme: textTheme,
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColorsLight.buttonColor,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColorsLight.buttonColor,
          foregroundColor: Colors.white,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColorsLight.buttonColor,
        ),
      ),
    );
  }

  static ThemeData darkTheme(BuildContext context) {
    final textTheme = _getTextTheme(context);
    return ThemeData(
      primaryColor: AppColorsDark.primaryColor,
      scaffoldBackgroundColor: AppColorsDark.backgroundColor,
      textTheme: textTheme,
      colorScheme: const ColorScheme.dark(
        primary: AppColorsDark.buttonColor,
        secondary: AppColorsDark.accentColor,
        surface: AppColorsDark.cardColor,
        onSurface: AppColorsDark.textColor,
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColorsDark.buttonColor,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColorsDark.buttonColor,
          foregroundColor: Colors.white,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColorsDark.buttonColor,
        ),
      ),
    );
  }

  static TextTheme _getTextTheme(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return screenWidth >= Breakpoints.mobile
        ? AppTypography.tabletTextTheme
        : AppTypography.mobileTextTheme;
  }
}
