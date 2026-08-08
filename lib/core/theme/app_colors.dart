import 'package:flutter/material.dart';

class AppColors {
  // Slate Neutral Palette
  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A);

  // Indigo & Sky Primary Palette
  static const Color indigo50 = Color(0xFFEEF2FF);
  static const Color indigo100 = Color(0xFFE0E7FF);
  static const Color indigo400 = Color(0xFF818CF8);
  static const Color indigo500 = Color(0xFF6366F1);
  static const Color indigo600 = Color(0xFF4F46E5);
  static const Color indigo700 = Color(0xFF4338CA);

  // Status & Financial Colors
  static const Color emerald500 = Color(0xFF10B981);
  static const Color emerald600 = Color(0xFF059669);
  static const Color amber500 = Color(0xFFF59E0B);
  static const Color amber600 = Color(0xFFD97706);
  static const Color rose500 = Color(0xFFEF4444);
  static const Color sky500 = Color(0xFF0EA5E9);
  static const Color sky600 = Color(0xFF0284C7);
  static const Color violet500 = Color(0xFF8B5CF6);
  static const Color mpBlue = Color(0xFF009EE3);

  // Dark Mode Base Palette (Black & Dark Blue Slate)
  static const Color darkBackground = Color(0xFF0B0F17); // Deep black-blue background
  static const Color darkSurface = Color(0xFF161F30);    // Dark navy blue surface
  static const Color darkCard = Color(0xFF1E293B);       // Dark slate card
  static const Color darkSubSurface = Color(0xFF0F172A); // Dark slate sub-surface
  static const Color darkBorder = Color(0xFF334155);     // Dark slate border
  static const Color darkTextPrimary = Color(0xFFFFFFFF); // Blanco puro para máximo contraste
  static const Color darkTextSecondary = Color(0xFFCBD5E1); // Slate 300 claro para subtítulos y números


  // Light Mode Base Palette
  static const Color lightBackground = Color(0xFFF1F5F9);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightSubSurface = Color(0xFFF8FAFC);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B);

  // Helpers adaptativos según el brillo del contexto
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  static Color cardBackground(BuildContext context) {
    return isDarkMode(context) ? darkCard : lightCard;
  }

  static Color surface(BuildContext context) {
    return isDarkMode(context) ? darkSurface : lightSurface;
  }

  static Color subSurface(BuildContext context) {
    return isDarkMode(context) ? darkSubSurface : lightSubSurface;
  }

  static Color textPrimary(BuildContext context) {
    return isDarkMode(context) ? darkTextPrimary : lightTextPrimary;
  }

  static Color textSecondary(BuildContext context) {
    return isDarkMode(context) ? darkTextSecondary : lightTextSecondary;
  }

  static Color borderColor(BuildContext context) {
    return isDarkMode(context) ? darkBorder : lightBorder;
  }
}
