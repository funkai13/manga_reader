import 'package:flutter/material.dart';

// Inspired by Apple Books color palette for a modern, clean reading experience.

class AppColorsDark {
  /// Near-black for the main background, reduces eye strain. (e.g. page background)
  static const Color primaryColor = Color(0xFF000000);

  /// A dark gray for secondary elements like tab bars or side panels.
  static const Color secondaryColor = Color(0xFF1C1C1E);

  /// The deepest black for the absolute background of the app screen.
  static const Color backgroundColor = Color(0xFF000000);

  /// Dark gray for card-like elements to differentiate them from the background.
  static const Color cardColor = Color(0xFF1C1C1E);

  /// A subtle gray for dividers.
  static const Color dividerColor = Color(0xFF444446);

  /// Off-white text for comfortable reading in dark mode.
  static const Color textColor = Color(0xFFE8E8E8);

  /// A vibrant, accessible blue for interactive elements and accents.
  static const Color accentColor = Color(0xFF0A84FF);

  /// A vibrant blue for buttons to make actions clear.
  static const Color buttonColor = Color(0xFF0A84FF);
}

class AppColorsLight {
  /// A clean, paper-like white for the main reading background.
  static const Color primaryColor = Color(0xFF0B0A0A);

  /// A very light gray for secondary surfaces.
  static const Color secondaryColor = Color(0xFFF2F2F7);

  /// A soft, slightly off-white for the main app background.
  static const Color backgroundColor = Color(0xFFFFFFFF);

  /// Pure white for cards to make them pop from the light background.
  static const Color cardColor = Color(0xFFFFFFFF);

  /// A light gray for subtle dividers.
  static const Color dividerColor = Color(0xFFD1D1D6);

  /// A dark, highly readable black for text.
  static const Color textColor = Color(0xFF000000);

  /// Apple's classic blue for accents and interactive elements.
  static const Color accentColor = Color(0xFF007AFF);

  /// Apple's classic blue for buttons.
  static const Color buttonColor = Color(0xFF007AFF);
}
