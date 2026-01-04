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
  });

  String get _timeDisplay {
    final minutes = (time ~/ 60).toString().padLeft(2, '0');
    final seconds = (time % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isWon
                ? [Colors.amber.shade100, Colors.white]
                : [Colors.grey.shade300, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(),
              // Trophy/Icon
              _buildResultIcon(),
              const SizedBox(height: 24),
              // Title
              Text(
                isWon ? 'Victory!' : 'Game Over',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: isWon ? Colors.amber.shade700 : Colors.grey.shade700,
                  shadows: [
                    Shadow(
                      color: (isWon ? Colors.amber : Colors.grey).withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Stars (only for win)
              if (isWon) _buildStars(),
              const SizedBox(height: 24),
              // Stats card
              _buildStatsCard(),
              const SizedBox(height: 16),
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
    );
  }

  Widget _buildResultIcon() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: isWon ? Colors.amber : Colors.grey.shade400,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: (isWon ? Colors.amber : Colors.grey).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(
        isWon ? Icons.emoji_events : Icons.sentiment_dissatisfied,
        color: Colors.white,
        size: 60,
      ),
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
            Icons.star,
            size: 48,
            color: isActive ? Colors.amber : Colors.grey.shade300,
          ),
        );
      }),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildStatRow(Icons.timer, 'Time', _timeDisplay),
          const Divider(height: 24),
          _buildStatRow(Icons.grid_view, 'Tiles Cleared', '$tilesCleared/$totalTiles'),
          const Divider(height: 24),
          _buildStatRow(Icons.auto_fix_high, 'Spells Used', '0', isGrayed: true),
          const Divider(height: 24),
          _buildStatRow(Icons.diamond, 'Mana Remaining', '--', isGrayed: true),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.monetization_on, color: Colors.amber, size: 28),
              const SizedBox(width: 12),
              Text(
                'Score: ',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                '${score.toString()} pts',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isWon ? Colors.amber.shade700 : Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String label, String value, {bool isGrayed = false}) {
    return Row(
      children: [
        Icon(
          icon,
          color: isGrayed ? Colors.grey.shade300 : Colors.grey.shade600,
          size: 24,
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: isGrayed ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isGrayed ? Colors.grey.shade400 : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildNewBestTimeBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade400, Colors.orange.shade400],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.emoji_events, color: Colors.white, size: 24),
          const SizedBox(width: 8),
          const Text(
            'New Best Time!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const MainMenuScreen()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade200,
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Menu',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GameScreen(difficulty: difficulty),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Play Again',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
