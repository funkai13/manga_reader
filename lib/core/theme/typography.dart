import 'package:flutter/material.dart';

class AppTypography {
  static const TextTheme mobileTextTheme = TextTheme(
    displayLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    displayMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
    bodyLarge: TextStyle(fontSize: 16),
    bodyMedium: TextStyle(
      fontSize: 14,
    ),
    labelLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
  );

  static const TextTheme tabletTextTheme = TextTheme(
    displayLarge: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
    displayMedium: TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
    bodyLarge: TextStyle(fontSize: 20),
    bodyMedium: TextStyle(
      fontSize: 18,
    ),
    labelLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
  );
}
