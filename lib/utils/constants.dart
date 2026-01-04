import 'package:flutter/material.dart';

/// Game difficulty configurations
class DifficultyConfig {
  final String name;
  final int width;
  final int height;
  final int mines;

  const DifficultyConfig({
    required this.name,
    required this.width,
    required this.height,
    required this.mines,
  });

  int get totalCells => width * height;
}

class GameConstants {
  // Difficulty presets
  static const DifficultyConfig beginner = DifficultyConfig(
    name: 'Beginner',
    width: 9,
    height: 9,
    mines: 10,
  );

  static const DifficultyConfig intermediate = DifficultyConfig(
    name: 'Intermediate',
    width: 16,
    height: 16,
    mines: 40,
  );

  static const DifficultyConfig expert = DifficultyConfig(
    name: 'Expert',
    width: 30,
    height: 16,
    mines: 99,
  );

  static const List<DifficultyConfig> difficulties = [
    beginner,
    intermediate,
    expert,
  ];

  // Cell size
  static const double cellSize = 36.0;
  static const double cellBorderRadius = 6.0;
  static const double cellSpacing = 2.0;
}

class AppColors {
  // Primary colors
  static const Color primaryBlue = Color(0xFF4A90E2);
  static const Color primaryPurple = Color(0xFF8B5CF6);
  static const Color primaryGreen = Color(0xFF10B981);

  // Background colors
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color backgroundDark = Color(0xFF1E293B);
  static const Color cardBackground = Color(0xFFFFFFFF);

  // Cell colors
  static const Color cellCovered = Color(0xFFCBD5E1);
  static const Color cellCoveredHover = Color(0xFFB0BEC5);
  static const Color cellRevealed = Color(0xFFF1F5F9);
  static const Color cellMine = Color(0xFFEF4444);
  static const Color cellFlag = Color(0xFFDC2626);

  // Number colors (1-8)
  static const List<Color> numberColors = [
    Color(0xFF3B82F6), // 1 - Blue
    Color(0xFF22C55E), // 2 - Green
    Color(0xFFEF4444), // 3 - Red
    Color(0xFF1E3A8A), // 4 - Dark Blue
    Color(0xFF7F1D1D), // 5 - Dark Red
    Color(0xFF0891B2), // 6 - Cyan
    Color(0xFF000000), // 7 - Black
    Color(0xFF6B7280), // 8 - Gray
  ];

  // Button colors
  static const Color buttonBlue = Color(0xFF3B82F6);
  static const Color buttonGreen = Color(0xFF22C55E);
  static const Color buttonPurple = Color(0xFF8B5CF6);
  static const Color buttonGray = Color(0xFF6B7280);

  // Status colors
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Gradient for background
  static const LinearGradient menuGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF1E3A5F),
      Color(0xFF2D1B4E),
    ],
  );
}

class AppTextStyles {
  static const TextStyle title = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: Colors.white70,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static const TextStyle cellNumber = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle statsLabel = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.grey,
  );

  static const TextStyle statsValue = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );
}
