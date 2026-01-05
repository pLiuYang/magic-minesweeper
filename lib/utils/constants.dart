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
  static const double cellBorderRadius = 8.0;
  static const double cellSpacing = 3.0;
}

class AppColors {
  // Primary colors - Cute pastel palette matching logo
  static const Color primaryPink = Color(0xFFE8A4C9);      // Soft pink
  static const Color primaryPurple = Color(0xFFB8A4E8);    // Soft lavender
  static const Color primaryBlue = Color(0xFFA4D4E8);      // Soft sky blue
  static const Color primaryMint = Color(0xFFA4E8D4);      // Soft mint
  static const Color accentGold = Color(0xFFE8D4A4);       // Soft gold
  
  // Vibrant accents
  static const Color magicPurple = Color(0xFF9B7ED9);      // Magic wand purple
  static const Color crystalBlue = Color(0xFF7ED9E8);      // Crystal blue
  static const Color sparkleGold = Color(0xFFD4A84E);      // Sparkle gold

  // Background colors - Soft and dreamy
  static const Color backgroundLight = Color(0xFFFDF8FC);  // Very light pink-white
  static const Color backgroundGradientTop = Color(0xFFF8E8F4);  // Light pink
  static const Color backgroundGradientBottom = Color(0xFFE8F4F8); // Light blue
  static const Color cardBackground = Color(0xFFFFFFFF);

  // Cell colors - Cute and soft
  static const Color cellCovered = Color(0xFFE8D8F0);      // Soft lavender
  static const Color cellCoveredHover = Color(0xFFD8C8E8); // Slightly darker lavender
  static const Color cellRevealed = Color(0xFFFFFBF8);     // Warm white
  static const Color cellMine = Color(0xFFE88A8A);         // Soft red
  static const Color cellFlag = Color(0xFFE8A4B4);         // Soft pink-red
  static const Color cellSafe = Color(0xFFA4E8C4);         // Soft mint green

  // Number colors (1-8) - Softer, cuter versions
  static const List<Color> numberColors = [
    Color(0xFF7EB8E8), // 1 - Soft Blue
    Color(0xFF7ED4A4), // 2 - Soft Green
    Color(0xFFE88A8A), // 3 - Soft Red
    Color(0xFF6B8AC4), // 4 - Deeper Blue
    Color(0xFFC47070), // 5 - Deeper Red
    Color(0xFF70C4C4), // 6 - Soft Cyan
    Color(0xFF8A7EB8), // 7 - Soft Purple
    Color(0xFFA4A4A4), // 8 - Soft Gray
  ];

  // Button colors - Pastel and inviting
  static const Color buttonPrimary = Color(0xFFB8A4E8);    // Lavender
  static const Color buttonSecondary = Color(0xFFE8A4C9);  // Pink
  static const Color buttonSuccess = Color(0xFFA4E8C4);    // Mint
  static const Color buttonWarning = Color(0xFFE8D4A4);    // Gold
  static const Color buttonGray = Color(0xFFD4D4D8);       // Soft gray

  // Status colors - Softer versions
  static const Color success = Color(0xFF7ED4A4);
  static const Color warning = Color(0xFFE8C870);
  static const Color error = Color(0xFFE88A8A);
  static const Color info = Color(0xFF7EB8E8);

  // Mana color
  static const Color manaBlue = Color(0xFF7EB8E8);
  static const Color manaGlow = Color(0xFFB8D8F0);

  // Gradient for background - Dreamy pastel
  static const LinearGradient menuGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFF0E4F8),  // Light lavender
      Color(0xFFE4F0F8),  // Light blue
      Color(0xFFF8E4F0),  // Light pink
    ],
    stops: [0.0, 0.5, 1.0],
  );

  // Game screen gradient
  static const LinearGradient gameGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFDF8FC),  // Very light pink-white
      Color(0xFFF8F4FC),  // Light lavender-white
    ],
  );

  // Spell colors
  static const Color spellReveal = Color(0xFF7ED4A4);      // Mint
  static const Color spellScan = Color(0xFF7EB8E8);        // Blue
  static const Color spellDisarm = Color(0xFFE8C870);      // Gold
  static const Color spellShield = Color(0xFFB8A4E8);      // Lavender
  static const Color spellTeleport = Color(0xFFE8A4C9);    // Pink
  static const Color spellPurify = Color(0xFFFFFFFF);      // White/Rainbow
}

class AppTextStyles {
  static const TextStyle title = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: Color(0xFF6B5B8C),  // Soft purple-gray
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: Color(0xFF8B7BA8),  // Lighter purple-gray
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static const TextStyle cellNumber = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle statsLabel = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Color(0xFF8B7BA8),
  );

  static const TextStyle statsValue = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Color(0xFF6B5B8C),
  );
}
