import 'package:flutter/material.dart';

/// Colours that follow the light / dark theme. Brand colours (orange, green) stay as they are.
/// [dark] is set before every rebuild, see theme_provider.dart.
class AppColors {
  AppColors._();

  static bool dark = false;

  /// Cards, sheets and bars (white in light mode).
  static Color get surface => dark ? const Color(0xFF1A2030) : Colors.white;

  /// Page background.
  static Color get background => dark ? const Color(0xFF0F1420) : const Color(0xFFF9F9FB);

  static const _slate = <int, int>{
    50: 0xFFF8FAFC,
    100: 0xFFF1F5F9,
    200: 0xFFE2E8F0,
    300: 0xFFCBD5E1,
    400: 0xFF94A3B8,
    500: 0xFF64748B,
    600: 0xFF475569,
    700: 0xFF334155,
    800: 0xFF1E293B,
    900: 0xFF0F172A,
  };

  // Dark mode mirrors the scale: light 50 becomes 900, 100 becomes 800, and so on.
  static const _mirror = <int, int>{50: 900, 100: 800, 200: 700, 300: 600, 400: 500, 500: 400, 600: 300, 700: 200, 800: 100, 900: 50};

  /// Blue-grey scale used for text, borders and soft backgrounds.
  static Color slate(int shade) => Color(_slate[dark ? _mirror[shade]! : shade]!);

  /// Neutral grey scale (same idea as Colors.grey.shadeN).
  static Color grey(int shade) {
    final s = dark ? _mirror[shade]! : shade;
    return Colors.grey[s]!;
  }
}
