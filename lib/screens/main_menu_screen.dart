import 'package:flutter/material.dart';
import '../widgets/menu_button.dart';
import 'settings_screen.dart';
import 'difficulty_selection_screen.dart';
import 'multiplayer_menu_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2D0A31), // Deep purple from mockup
      body: Stack(
        children: [
          // 1. Background Pixel Decorations
          _buildPixelDecorations(),

          // 2. Main Content
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: SafeArea(
                      child: Column(
                        children: [
                          // Top Bar with Badges
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Placeholder Left (maybe nothing or streaks)
                                const SizedBox(width: 48),

                                // Right Badges (Gold & Level)
                                Row(
                                  children: [
                                    _buildTopBadge(
                                      label: 'GOLD',
                                      value: '100',
                                      color: const Color(0xFFFACC15), // Yellow
                                      icon: Icons.monetization_on,
                                    ),
                                    const SizedBox(width: 12),
                                    _buildTopBadge(
                                      label: 'LEVEL',
                                      value: '5',
                                      color: const Color(0xFFC084FC), // Purple
                                      icon: Icons.shield,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const Spacer(flex: 1),

                          // Logo Section
                          _buildRetroLogo(),

                          const Spacer(flex: 1),

                          // Buttons Section
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Column(
                              children: [
                                MenuButton(
                                  text: 'New Game',
                                  icon: Icons.hardware, // Shovel for New Game
                                  color: const Color(0xFFFACC15), // Yellow
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const DifficultySelectionScreen(),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 20),
                                MenuButton(
                                  text: 'Continue',
                                  icon: Icons.flag,
                                  color: const Color(0xFFF472B6), // Pink
                                  enabled: false,
                                  badge: 'Lvl 3', // Suggests a saved game
                                  onPressed: () {},
                                ),
                                const SizedBox(height: 20),
                                MenuButton(
                                  text: 'Multiplayer',
                                  icon: Icons.people_alt,
                                  color: const Color(0xFF4ADE80), // Green/Mint
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const MultiplayerMenuScreen(),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 20),
                                MenuButton(
                                  text: 'Settings',
                                  icon: Icons.settings,
                                  color: const Color(0xFF2DD4BF), // Teal/Blue
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const SettingsScreen(),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),

                          const Spacer(flex: 2),

                          // Footer / Stats decorations (runes)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildRune('R'),
                                _buildRune('M'),
                                _buildRune('F'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPixelDecorations() {
    return Stack(
      children: [
        // Grid pattern overlay (subtle)
        Positioned.fill(
          child: Opacity(
            opacity: 0.05,
            child: Image.asset(
              'assets/images/grid_pattern.png', // Assuming we might have one, or fallback
              repeat: ImageRepeat.repeat,
              errorBuilder: (_, __, ___) =>
                  Container(color: Colors.transparent),
            ),
          ),
        ),
        // Scattered pixel stars (using Containers)
        _buildPixelStar(
            top: 50, left: 30, color: const Color(0xFFFFD700), size: 12),
        _buildPixelStar(
            top: 120, right: 40, color: const Color(0xFFF472B6), size: 16),
        _buildPixelStar(
            bottom: 100, left: 50, color: const Color(0xFF4ADE80), size: 10),
        _buildPixelStar(
            top: 300, left: -10, color: const Color(0xFFC084FC), size: 20),
        _buildPixelStar(
            bottom: 200, right: 20, color: const Color(0xFF2DD4BF), size: 14),
        // Crosses
        _buildPixelCross(top: 150, left: 80, color: Colors.white12),
        _buildPixelCross(bottom: 80, right: 60, color: Colors.white12),
      ],
    );
  }

  Widget _buildPixelStar(
      {double? top,
      double? bottom,
      double? left,
      double? right,
      required Color color,
      required double size}) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Transform.rotate(
        angle: 0.2, // Slight tilt for fun
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.5),
                blurRadius: 4,
                spreadRadius: 2,
              ),
            ],
            // Make it look like a diamond/star with border radius
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  Widget _buildPixelCross(
      {double? top,
      double? bottom,
      double? left,
      double? right,
      required Color color}) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Icon(Icons.add, color: color, size: 24),
    );
  }

  Widget _buildTopBadge(
      {required String label,
      required String value,
      required Color color,
      required IconData icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: Color(0xFF2D0A31),
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D0A31),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRune(String char) {
    return Text(
      char,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: const Color(0xFFC084FC).withOpacity(0.5),
        shadows: [
          Shadow(
            color: const Color(0xFFC084FC).withOpacity(0.3),
            blurRadius: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildRetroLogo() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // MAGIC
        Stack(
          children: [
            // Thick Outline (Shadow)
            Text(
              'MAGIC',
              style: TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 10
                  ..color = const Color(0xFF4C1D95), // Deep purple shadow
              ),
            ),
            // White Inner Outline
            Text(
              'MAGIC',
              style: TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 4
                  ..color = Colors.white,
              ),
            ),
            // Main Gradient Text
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [
                  Color(0xFFFEF08A),
                  Color(0xFFEAB308)
                ], // Pale yellow to Gold
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ).createShader(bounds),
              child: const Text(
                'MAGIC',
                style: TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 4,
                ),
              ),
            ),
          ],
        ),

        // SWEEPER (Overlapping slightly)
        Transform.translate(
          offset: const Offset(0, -10),
          child: Stack(
            children: [
              // Thick Outline
              Text(
                'SWEEPER',
                style: TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4,
                  foreground: Paint()
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 10
                    ..color = const Color(0xFF4C1D95),
                ),
              ),
              // White Inner Outline
              Text(
                'SWEEPER',
                style: TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4,
                  foreground: Paint()
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 4
                    ..color = Colors.white,
                ),
              ),
              // Main Gradient Text
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [
                    Color(0xFFF9A8D4),
                    Color(0xFFDB2777)
                  ], // Pink to Dark Pink
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ).createShader(bounds),
                child: const Text(
                  'SWEEPER',
                  style: TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
