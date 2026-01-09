import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../utils/constants.dart';
import 'game_screen.dart';

class DifficultySelectionScreen extends StatelessWidget {
  const DifficultySelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2D0A31), // Deep purple
      body: Stack(
        children: [
          // Background decorations
          _buildBackgroundDecorations(),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  // Header
                  Row(
                    children: [
                      _buildBackButton(context),
                      const Expanded(
                        child: Text(
                          'SELECT LEVEL',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 2,
                            shadows: [
                              Shadow(
                                color: Color(0xFF4C1D95),
                                offset: Offset(2, 2),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 48), // Balance back button
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Difficulty Cards
                  Expanded(
                    child: ListView(
                      children: [
                        _buildDifficultyCard(
                          context,
                          config: GameConstants.beginner,
                          color: const Color(0xFF4ADE80), // Mint for Easy
                          icon: Icons.filter_1,
                          stars: 1,
                        ),
                        const SizedBox(height: 20),
                        _buildDifficultyCard(
                          context,
                          config: GameConstants.intermediate,
                          color: const Color(0xFFFACC15), // Yellow for Medium
                          icon: Icons.filter_2,
                          stars: 2,
                        ),
                        const SizedBox(height: 20),
                        _buildDifficultyCard(
                          context,
                          config: GameConstants.expert,
                          color: const Color(0xFFF472B6), // Pink for Hard
                          icon: Icons.filter_3,
                          stars: 3,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFF4C1D95), // Dark purple button
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: const Icon(Icons.arrow_back_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildDifficultyCard(
    BuildContext context, {
    required DifficultyConfig config,
    required Color color,
    required IconData icon,
    required int stars,
  }) {
    final settingsProvider = context.read<SettingsProvider>();
    final bestTime = settingsProvider.formatBestTime(config.name);

    return GestureDetector(
      onTap: () {
        settingsProvider.setDifficulty(config);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => GameScreen(difficulty: config),
          ),
        );
      },
      child: Container(
        height: 140, // Chunky card
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.black.withOpacity(0.2),
            width: 4,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              offset: const Offset(0, 8),
              blurRadius: 0,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Inner Highlight
            Positioned(
              top: 4,
              left: 8,
              right: 8,
              height: 24,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Icon Box
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(icon, size: 36, color: const Color(0xFF111827)),
                  ),
                  const SizedBox(width: 20),

                  // Text Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          config.name.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF111827),
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.timer_outlined,
                                size: 16, color: Color(0xFF111827)),
                            const SizedBox(width: 4),
                            Text(
                              'BEST: $bestTime',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF111827),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Play Arrow
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF111827),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.play_arrow_rounded,
                        color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundDecorations() {
    return Stack(
      children: [
        // Grid pattern overlay (subtle)
        Positioned.fill(
          child: Opacity(
            opacity: 0.05,
            child: Image.asset(
              'assets/images/grid_pattern.png',
              repeat: ImageRepeat.repeat,
              errorBuilder: (_, __, ___) =>
                  Container(color: Colors.transparent),
            ),
          ),
        ),
        // Scattered pixel elements
        _buildPixelSquare(
            top: 100, left: 20, color: const Color(0xFFFACC15), size: 16),
        _buildPixelSquare(
            top: 200, right: 30, color: const Color(0xFFF472B6), size: 12),
        _buildPixelSquare(
            bottom: 150, left: 40, color: const Color(0xFF4ADE80), size: 14),
        _buildPixelSquare(
            bottom: 50, right: 60, color: const Color(0xFF2DD4BF), size: 18),
      ],
    );
  }

  Widget _buildPixelSquare(
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
        angle: 0.1,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(
                2), // Slight rounding for "soft pixel" look
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.5),
                blurRadius: 4,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
