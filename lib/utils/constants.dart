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
  // ============ CANDY CRUSH INSPIRED PALETTE ============
  
  // Primary vibrant colors - Candy-like saturated tones
  static const Color candyPink = Color(0xFFFF6B9D);       // Hot pink
  static const Color candyPurple = Color(0xFF9B59B6);     // Rich purple
  static const Color candyBlue = Color(0xFF3498DB);       // Bright blue
  static const Color candyGreen = Color(0xFF2ECC71);      // Emerald green
  static const Color candyOrange = Color(0xFFFF9F43);     // Vibrant orange
  static const Color candyYellow = Color(0xFFFECA57);     // Golden yellow
  static const Color candyRed = Color(0xFFFF6B6B);        // Coral red
  
  // UI Theme colors
  static const Color primaryPink = Color(0xFFFF6B9D);     // Main UI pink
  static const Color primaryPurple = Color(0xFF9B59B6);   // Main purple
  static const Color primaryBlue = Color(0xFF5DADE2);     // Sky blue
  static const Color primaryMint = Color(0xFF48DBDB);     // Turquoise
  static const Color accentGold = Color(0xFFFFD700);      // Pure gold
  
  // Vibrant accents
  static const Color magicPurple = Color(0xFF8E44AD);     // Deep magic purple
  static const Color crystalBlue = Color(0xFF00CED1);     // Crystal cyan
  static const Color sparkleGold = Color(0xFFFFD700);     // Sparkle gold
  static const Color glowPink = Color(0xFFFF69B4);        // Hot pink glow

  // Background colors - Candy Crush style gradients
  static const Color backgroundLight = Color(0xFFE8F4FD);  // Light sky blue
  static const Color backgroundGradientTop = Color(0xFF87CEEB);  // Sky blue
  static const Color backgroundGradientBottom = Color(0xFFB8E994); // Soft green
  static const Color cardBackground = Color(0xFFFFFFFF);

  // Cell colors - Glossy candy-like appearance
  static const Color cellCovered = Color(0xFF7B68EE);     // Medium slate blue
  static const Color cellCoveredHover = Color(0xFF6A5ACD); // Slate blue
  static const Color cellRevealed = Color(0xFFF0F8FF);    // Alice blue (light)
  static const Color cellMine = Color(0xFFFF4757);        // Bright red
  static const Color cellFlag = Color(0xFFFF6B9D);        // Hot pink
  static const Color cellSafe = Color(0xFF2ECC71);        // Emerald green

  // Number colors (1-8) - Vibrant candy colors
  static const List<Color> numberColors = [
    Color(0xFF3498DB), // 1 - Bright Blue
    Color(0xFF27AE60), // 2 - Emerald Green
    Color(0xFFE74C3C), // 3 - Bright Red
    Color(0xFF9B59B6), // 4 - Purple
    Color(0xFFE67E22), // 5 - Orange
    Color(0xFF1ABC9C), // 6 - Turquoise
    Color(0xFF2C3E50), // 7 - Dark Blue
    Color(0xFF7F8C8D), // 8 - Gray
  ];

  // Button colors - Candy-like gradients
  static const Color buttonPrimary = Color(0xFF9B59B6);   // Purple
  static const Color buttonSecondary = Color(0xFFFF6B9D); // Pink
  static const Color buttonSuccess = Color(0xFF2ECC71);   // Green
  static const Color buttonWarning = Color(0xFFFFD700);   // Gold
  static const Color buttonGray = Color(0xFF95A5A6);      // Cool gray

  // Status colors - Vibrant
  static const Color success = Color(0xFF2ECC71);
  static const Color warning = Color(0xFFF39C12);
  static const Color error = Color(0xFFE74C3C);
  static const Color info = Color(0xFF3498DB);

  // Mana color - Magical blue glow
  static const Color manaBlue = Color(0xFF00BFFF);
  static const Color manaGlow = Color(0xFF87CEFA);

  // Gradient for background - Candy Crush sky style
  static const LinearGradient menuGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF87CEEB),  // Sky blue
      Color(0xFFADD8E6),  // Light blue
      Color(0xFFB8E994),  // Soft green
    ],
    stops: [0.0, 0.5, 1.0],
  );

  // Game screen gradient - Vibrant game feel
  static const LinearGradient gameGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF87CEEB),  // Sky blue
      Color(0xFFE0F7FA),  // Very light cyan
    ],
  );

  // Pink panel gradient - Candy Crush style UI panels
  static const LinearGradient pinkPanelGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFF69B4),  // Hot pink
      Color(0xFFFF1493),  // Deep pink
    ],
  );

  // Purple panel gradient
  static const LinearGradient purplePanelGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFBA68C8),  // Medium purple
      Color(0xFF9B59B6),  // Purple
    ],
  );

  // Spell colors - Vibrant magical effects
  static const Color spellReveal = Color(0xFF2ECC71);     // Emerald
  static const Color spellScan = Color(0xFF00BFFF);       // Deep sky blue
  static const Color spellDisarm = Color(0xFFFFD700);     // Gold
  static const Color spellShield = Color(0xFF9B59B6);     // Purple
  static const Color spellTeleport = Color(0xFFFF69B4);   // Hot pink
  static const Color spellPurify = Color(0xFFFFFFFF);     // White/Rainbow

  // Scan effect colors - Pulsing glow
  static const Color scanGlow = Color(0xFFFF4757);        // Warning red
  static const Color scanPulse = Color(0xFFFFD700);       // Gold pulse
  
  // Purify effect colors
  static const Color purifyGlow = Color(0xFF00FF7F);      // Spring green
  static const Color purifySparkle = Color(0xFFFFFFFF);   // White sparkle
}

class AppTextStyles {
  static const TextStyle title = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: Color(0xFF2C3E50),
    shadows: [
      Shadow(
        color: Color(0x40000000),
        offset: Offset(2, 2),
        blurRadius: 4,
      ),
    ],
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Color(0xFF7F8C8D),
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    shadows: [
      Shadow(
        color: Color(0x60000000),
        offset: Offset(1, 1),
        blurRadius: 2,
      ),
    ],
  );

  static const TextStyle cellNumber = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    shadows: [
      Shadow(
        color: Color(0x40000000),
        offset: Offset(1, 1),
        blurRadius: 2,
      ),
    ],
  );

  static const TextStyle statsLabel = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Color(0xFF7F8C8D),
  );

  static const TextStyle statsValue = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Color(0xFF2C3E50),
  );
}
