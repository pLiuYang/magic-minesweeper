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
  // ============ NEO-RETRO GAMING PALETTE ============
  
  // Primary colors - Bold arcade style
  static const Color retroGold = Color(0xFFFBBF24);       // Primary gold
  static const Color retroPink = Color(0xFFF472B6);       // Vibrant pink
  static const Color retroMint = Color(0xFF34D399);       // Fresh mint
  static const Color retroSky = Color(0xFF60A5FA);        // Sky blue
  static const Color retroOrange = Color(0xFFFB923C);     // Warm orange
  static const Color retroPurple = Color(0xFFA78BFA);     // Soft purple
  static const Color retroRed = Color(0xFFF87171);        // Coral red
  
  // Legacy aliases for compatibility
  static const Color candyPink = retroPink;
  static const Color candyPurple = retroPurple;
  static const Color candyBlue = retroSky;
  static const Color candyGreen = retroMint;
  static const Color candyOrange = retroOrange;
  static const Color candyYellow = retroGold;
  static const Color candyRed = retroRed;
  
  // UI Theme colors
  static const Color primaryPink = retroPink;
  static const Color primaryPurple = retroPurple;
  static const Color primaryBlue = retroSky;
  static const Color primaryMint = retroMint;
  static const Color accentGold = retroGold;
  
  // Vibrant accents
  static const Color magicPurple = Color(0xFF8B5CF6);     // Electric purple
  static const Color crystalBlue = Color(0xFF22D3EE);     // Cyan
  static const Color sparkleGold = Color(0xFFFBBF24);     // Gold sparkle
  static const Color glowPink = Color(0xFFF472B6);        // Pink glow

  // Background colors - Dark warm tones
  static const Color backgroundDark = Color(0xFF111827);   // Deep dark
  static const Color backgroundMedium = Color(0xFF1F2937); // Warm dark
  static const Color surfaceDark = Color(0xFF374151);      // Card surface
  static const Color surfaceLight = Color(0xFF4B5563);     // Lighter surface
  static const Color cardBackground = Color(0xFF1F2937);
  
  // Legacy light backgrounds (for compatibility)
  static const Color backgroundLight = Color(0xFF1F2937);
  static const Color backgroundGradientTop = Color(0xFF1F2937);
  static const Color backgroundGradientBottom = Color(0xFF111827);

  // Cell colors - Chunky retro arcade style
  static const Color cellCovered = Color(0xFF6366F1);     // Indigo
  static const Color cellCoveredHover = Color(0xFF818CF8); // Light indigo
  static const Color cellRevealed = Color(0xFF374151);    // Dark surface
  static const Color cellMine = Color(0xFFF87171);        // Coral red
  static const Color cellFlag = Color(0xFFFBBF24);        // Gold flag
  static const Color cellSafe = Color(0xFF34D399);        // Mint green

  // Number colors (1-8) - Bright retro colors
  static const List<Color> numberColors = [
    Color(0xFF60A5FA), // 1 - Sky Blue
    Color(0xFF34D399), // 2 - Mint Green
    Color(0xFFF87171), // 3 - Coral Red
    Color(0xFFA78BFA), // 4 - Purple
    Color(0xFFFB923C), // 5 - Orange
    Color(0xFF22D3EE), // 6 - Cyan
    Color(0xFFFBBF24), // 7 - Gold
    Color(0xFFE5E7EB), // 8 - Light Gray
  ];

  // Button colors - Chunky arcade style
  static const Color buttonPrimary = Color(0xFFFBBF24);   // Gold
  static const Color buttonSecondary = Color(0xFFF472B6); // Pink
  static const Color buttonSuccess = Color(0xFF34D399);   // Mint
  static const Color buttonWarning = Color(0xFFFB923C);   // Orange
  static const Color buttonGray = Color(0xFF6B7280);      // Dark gray

  // Status colors - Bright arcade
  static const Color success = Color(0xFF34D399);
  static const Color warning = Color(0xFFFBBF24);
  static const Color error = Color(0xFFF87171);
  static const Color info = Color(0xFF60A5FA);

  // Mana color - Electric blue glow
  static const Color manaBlue = Color(0xFF22D3EE);
  static const Color manaGlow = Color(0xFF67E8F9);

  // Gradient for background - Dark arcade style
  static const LinearGradient menuGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF1F2937),  // Warm dark
      Color(0xFF111827),  // Deep dark
    ],
  );

  // Game screen gradient - Dark with subtle warmth
  static const LinearGradient gameGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF1F2937),  // Warm dark
      Color(0xFF111827),  // Deep dark
    ],
  );

  // Gold panel gradient - Retro arcade style
  static const LinearGradient goldPanelGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFDE047),  // Light gold
      Color(0xFFFBBF24),  // Gold
      Color(0xFFD97706),  // Dark gold
    ],
    stops: [0.0, 0.5, 1.0],
  );
  
  // Pink panel gradient - Arcade pink
  static const LinearGradient pinkPanelGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFF9A8D4),  // Light pink
      Color(0xFFF472B6),  // Pink
      Color(0xFFDB2777),  // Dark pink
    ],
    stops: [0.0, 0.5, 1.0],
  );

  // Mint panel gradient
  static const LinearGradient mintPanelGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF6EE7B7),  // Light mint
      Color(0xFF34D399),  // Mint
      Color(0xFF059669),  // Dark mint
    ],
    stops: [0.0, 0.5, 1.0],
  );

  // Purple panel gradient
  static const LinearGradient purplePanelGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFC4B5FD),  // Light purple
      Color(0xFFA78BFA),  // Purple
      Color(0xFF7C3AED),  // Dark purple
    ],
    stops: [0.0, 0.5, 1.0],
  );

  // Spell colors - Vibrant magical effects
  static const Color spellReveal = Color(0xFF34D399);     // Mint
  static const Color spellScan = Color(0xFF22D3EE);       // Cyan
  static const Color spellDisarm = Color(0xFFFBBF24);     // Gold
  static const Color spellShield = Color(0xFFA78BFA);     // Purple
  static const Color spellTeleport = Color(0xFFF472B6);   // Pink
  static const Color spellPurify = Color(0xFFFFFFFF);     // White

  // Scan effect colors - Pulsing glow
  static const Color scanGlow = Color(0xFFF87171);        // Coral red
  static const Color scanPulse = Color(0xFFFBBF24);       // Gold pulse
  
  // Purify effect colors
  static const Color purifyGlow = Color(0xFF34D399);      // Mint green
  static const Color purifySparkle = Color(0xFFFFFFFF);   // White sparkle
  
  // Text colors for dark theme
  static const Color textPrimary = Color(0xFFF9FAFB);     // Near white
  static const Color textSecondary = Color(0xFF9CA3AF);   // Gray
  static const Color textMuted = Color(0xFF6B7280);       // Dark gray
}

class AppTextStyles {
  static const TextStyle title = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: Color(0xFFF9FAFB),  // Light text for dark theme
    shadows: [
      Shadow(
        color: Color(0x60000000),
        offset: Offset(2, 2),
        blurRadius: 4,
      ),
    ],
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Color(0xFF9CA3AF),  // Secondary gray
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Color(0xFF111827),  // Dark text on bright buttons
    shadows: [
      Shadow(
        color: Color(0x40FFFFFF),
        offset: Offset(0, 1),
        blurRadius: 1,
      ),
    ],
  );

  static const TextStyle cellNumber = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    shadows: [
      Shadow(
        color: Color(0x60000000),
        offset: Offset(1, 1),
        blurRadius: 2,
      ),
    ],
  );

  static const TextStyle statsLabel = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Color(0xFF9CA3AF),  // Secondary gray
  );

  static const TextStyle statsValue = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Color(0xFFF9FAFB),  // Light text
  );
}

