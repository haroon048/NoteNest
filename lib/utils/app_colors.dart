import 'package:flutter/material.dart';

class AppColors {
  // Brand & Accent Colors
  static const Color primary = Color(0xFF6366F1); // Indigo
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color secondary = Color(0xFFEC4899); // Pink / Rose
  static const Color accent = Color(0xFF8B5CF6); // Violet

  // Gradient Colors
  static const List<Color> primaryGradient = [
    Color(0xFF6366F1),
    Color(0xFF8B5CF6),
  ];

  static const List<Color> accentGradient = [
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
  ];

  // Light Theme Surfaces
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color textMutedLight = Color(0xFF94A3B8);

  // Dark Theme Surfaces
  static const Color backgroundDark = Color(0xFF0B0F19);
  static const Color surfaceDark = Color(0xFF131B2E);
  static const Color cardDark = Color(0xFF1A233A);
  static const Color borderDark = Color(0xFF263352);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textMutedDark = Color(0xFF64748B);

  // Status & Utility Colors
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Note Pastel Colors (Light Mode)
  static const List<Color> notePastelsLight = [
    Color(0xFFEEF2FF), // Soft Indigo / Lavender
    Color(0xFFF0FDF4), // Soft Mint Green
    Color(0xFFFFF7ED), // Soft Peach / Warm Amber
    Color(0xFFFDF2F8), // Soft Rose Pink
    Color(0xFFF0F9FF), // Soft Sky Blue
    Color(0xFFFAF5FF), // Soft Lilac Purple
  ];

  // Note Tints (Dark Mode)
  static const List<Color> notePastelsDark = [
    Color(0xFF1E2238),
    Color(0xFF152A20),
    Color(0xFF2A2318),
    Color(0xFF2B1826),
    Color(0xFF152738),
    Color(0xFF251938),
  ];

  // Category Tag Default Backgrounds & Texts
  static const Map<String, Color> categoryColors = {
    'Personal': Color(0xFF6366F1),
    'Work': Color(0xFF0EA5E9),
    'Ideas': Color(0xFFF59E0B),
    'Study': Color(0xFF10B981),
  };
}

