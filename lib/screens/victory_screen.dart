import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'game_screen.dart';
import 'main_menu_screen.dart';

class VictoryScreen extends StatelessWidget {
  final bool isWon;
  final int time;
  final int tilesCleared;
  final int totalTiles;
  final int score;
  final int stars;
  final DifficultyConfig difficulty;
  final bool isNewBestTime;
  final int spellsUsed;
  final int manaRemaining;

  const VictoryScreen({
    super.key,
    required this.isWon,
    required this.time,
    required this.tilesCleared,
    required this.totalTiles,
    required this.score,
    required this.stars,
    required this.difficulty,
    this.isNewBestTime = false,
    this.spellsUsed = 0,
    this.manaRemaining = 0,
  });

  String get _timeDisplay {
    final minutes = (time ~/ 60).toString().padLeft(2, '0');
    final seconds = (time % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

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
                children: [
                  const Spacer(),
                  // Trophy/Icon
                  _buildResultIcon(),
                  const SizedBox(height: 24),
                  // Title
                  _buildTitle(),
                  const SizedBox(height: 24),
                  // Stars (only for win)
                  if (isWon) _buildStars(),
                  const SizedBox(height: 32),
                  // Stats card
                  _buildStatsCard(),
                  const SizedBox(height: 24),
                  // New best time badge
                  if (isNewBestTime) _buildNewBestTimeBadge(),
                  const Spacer(),
                  // Action buttons
                  _buildActionButtons(context),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
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
        if (isWon) ...[
          _buildPixelSquare(
              top: 80, left: 30, color: const Color(0xFFFACC15), size: 16),
          _buildPixelSquare(
              top: 150, right: 40, color: const Color(0xFFF472B6), size: 12),
          _buildPixelSquare(
              bottom: 200, left: 20, color: const Color(0xFF4ADE80), size: 14),
          _buildPixelSquare(
              bottom: 100, right: 30, color: const Color(0xFF2DD4BF), size: 18),
        ],
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
            borderRadius: BorderRadius.circular(2),
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

  Widget _buildResultIcon() {
    final color = isWon ? const Color(0xFFFACC15) : const Color(0xFF9CA3AF);

    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.black.withOpacity(0.3),
          width: 4,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          isWon ? Icons.emoji_events_rounded : Icons.close_rounded,
          color: const Color(0xFF111827),
          size: 50,
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        Text(
          isWon ? 'VICTORY!' : 'GAME OVER',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 2,
            shadows: [
              Shadow(
                color:
                    isWon ? const Color(0xFFCA8A04) : const Color(0xFF374151),
                offset: const Offset(4, 4),
                blurRadius: 0,
              ),
            ],
          ),
        ),
        if (isWon) ...[
          const SizedBox(height: 8),
          const Text(
            'CONGRATULATIONS!',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFACC15),
              letterSpacing: 1,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStars() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final isActive = index < stars;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Icon(
            Icons.star_rounded,
            size: 48,
            color: isActive ? const Color(0xFFFACC15) : const Color(0xFF374151),
            shadows: isActive
                ? [
                    const Shadow(
                      color: Color(0xFFCA8A04),
                      offset: Offset(0, 4),
                      blurRadius: 0,
                    ),
                  ]
                : [],
          ),
        );
      }),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isWon ? const Color(0xFFFBBF24) : const Color(0xFF374151),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            offset: const Offset(0, 8),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatColumn('TIME', _timeDisplay, const Color(0xFF60A5FA)),
              _buildStatColumn('SCORE', '$score', const Color(0xFFFACC15)),
              _buildStatColumn('TILES', '$tilesCleared/$totalTiles',
                  const Color(0xFF4ADE80)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: color.withOpacity(0.7),
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: color,
            shadows: [
              Shadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNewBestTimeBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFBBF24),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.emoji_events, size: 16, color: Colors.black),
          SizedBox(width: 8),
          Text(
            'NEW BEST TIME!',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        // Menu button
        Expanded(
          child: _buildButton(
            label: 'MENU',
            icon: Icons.home_rounded,
            color: const Color(0xFF9CA3AF),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const MainMenuScreen()),
                (route) => false,
              );
            },
          ),
        ),
        const SizedBox(width: 16),
        // Play Again button
        Expanded(
          flex: 2,
          child: _buildButton(
            label: 'PLAY AGAIN',
            icon: Icons.replay_rounded,
            color: isWon ? const Color(0xFF4ADE80) : const Color(0xFFC084FC),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => GameScreen(difficulty: difficulty),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.black.withOpacity(0.2),
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              offset: const Offset(0, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: const Color(0xFF111827),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: Color(0xFF111827),
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
