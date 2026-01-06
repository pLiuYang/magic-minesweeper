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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isWon
                ? [const Color(0xFFFFE4B5), const Color(0xFFFFF8E7), Colors.white]
                : [const Color(0xFFE8E8E8), const Color(0xFFF5F5F5), Colors.white],
          ),
        ),
        child: Stack(
          children: [
            // Background decorations
            _buildBackgroundDecorations(),
            SafeArea(
              child: Column(
                children: [
                  const Spacer(),
                  // Trophy/Icon
                  _buildResultIcon(),
                  const SizedBox(height: 24),
                  // Title
                  _buildTitle(),
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
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundDecorations() {
    return Stack(
      children: [
        if (isWon) ...[
          Positioned(
            top: -30,
            left: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.sparkleGold.withOpacity(0.3),
                    AppColors.sparkleGold.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 100,
            right: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.candyPink.withOpacity(0.2),
                    AppColors.candyPink.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildResultIcon() {
    final color = isWon ? AppColors.sparkleGold : Colors.grey.shade500;
    final lightColor = Color.lerp(color, Colors.white, 0.3)!;
    final darkColor = Color.lerp(color, Colors.black, 0.2)!;
    
    return Container(
      width: 130,
      height: 130,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [lightColor, color, darkColor],
          stops: const [0.0, 0.5, 1.0],
        ),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withOpacity(0.5),
          width: 4,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 40,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Glossy highlight
          Positioned(
            top: 8,
            left: 20,
            right: 20,
            height: 35,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(60),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.5),
                    Colors.white.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: Icon(
              isWon ? Icons.emoji_events_rounded : Icons.sentiment_dissatisfied_rounded,
              color: Colors.white,
              size: 65,
              shadows: const [
                Shadow(
                  color: Color(0x60000000),
                  offset: Offset(2, 2),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: isWon
                ? [AppColors.sparkleGold, const Color(0xFFFFB347)]
                : [Colors.grey.shade600, Colors.grey.shade500],
          ).createShader(bounds),
          child: Text(
            isWon ? 'Victory!' : 'Game Over',
            style: const TextStyle(
              fontSize: 44,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Color(0x40000000),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
          ),
        ),
        if (isWon) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.auto_awesome, color: AppColors.sparkleGold, size: 18),
              const SizedBox(width: 8),
              Text(
                'Congratulations!',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.auto_awesome, color: AppColors.sparkleGold, size: 18),
            ],
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
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: isActive
                ? BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.sparkleGold.withOpacity(0.5),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  )
                : null,
            child: Icon(
              Icons.star_rounded,
              size: 52,
              color: isActive ? AppColors.sparkleGold : Colors.grey.shade300,
              shadows: isActive
                  ? const [
                      Shadow(
                        color: Color(0x60000000),
                        offset: Offset(1, 2),
                        blurRadius: 3,
                      ),
                    ]
                  : null,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 28),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.white.withOpacity(0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isWon
              ? AppColors.sparkleGold.withOpacity(0.3)
              : Colors.grey.shade300,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isWon ? AppColors.sparkleGold : Colors.grey).withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildStatRow(Icons.timer_rounded, 'Time', _timeDisplay, AppColors.candyBlue),
          _buildDivider(),
          _buildStatRow(Icons.grid_view_rounded, 'Tiles Cleared', '$tilesCleared/$totalTiles', AppColors.candyGreen),
          _buildDivider(),
          _buildStatRow(Icons.auto_fix_high_rounded, 'Spells Used', '$spellsUsed', AppColors.candyPurple),
          _buildDivider(),
          _buildStatRow(Icons.water_drop_rounded, 'Mana Remaining', '$manaRemaining', AppColors.manaBlue),
          _buildDivider(),
          const SizedBox(height: 8),
          // Score row - special styling
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isWon
                    ? [AppColors.sparkleGold.withOpacity(0.15), AppColors.sparkleGold.withOpacity(0.05)]
                    : [Colors.grey.shade100, Colors.grey.shade50],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isWon
                    ? AppColors.sparkleGold.withOpacity(0.3)
                    : Colors.grey.shade300,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.monetization_on_rounded,
                  color: AppColors.sparkleGold,
                  size: 28,
                  shadows: const [
                    Shadow(
                      color: Color(0x40000000),
                      offset: Offset(1, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
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
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: isWon ? AppColors.sparkleGold : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        height: 1,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.transparent,
              Colors.grey.shade300,
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String label, String value, Color color) {
    final lightColor = Color.lerp(color, Colors.white, 0.3)!;
    
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [lightColor, color],
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 18,
            shadows: const [
              Shadow(
                color: Color(0x60000000),
                offset: Offset(1, 1),
                blurRadius: 2,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  Widget _buildNewBestTimeBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.sparkleGold, Color(0xFFFFB347)],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withOpacity(0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.sparkleGold.withOpacity(0.5),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.emoji_events_rounded,
            color: Colors.white,
            size: 24,
            shadows: [
              Shadow(
                color: Color(0x60000000),
                offset: Offset(1, 1),
                blurRadius: 2,
              ),
            ],
          ),
          const SizedBox(width: 8),
          const Text(
            'New Best Time!',
            style: TextStyle(
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
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.auto_awesome, color: Colors.white.withOpacity(0.9), size: 16),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Row(
        children: [
          // Menu button
          Expanded(
            child: _buildButton(
              label: 'Menu',
              icon: Icons.home_rounded,
              color: AppColors.buttonGray,
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const MainMenuScreen()),
                  (route) => false,
                );
              },
            ),
          ),
          const SizedBox(width: 14),
          // Play Again button
          Expanded(
            flex: 2,
            child: _buildButton(
              label: 'Play Again',
              icon: Icons.replay_rounded,
              color: isWon ? AppColors.candyGreen : AppColors.candyPurple,
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
      ),
    );
  }

  Widget _buildButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    final lightColor = Color.lerp(color, Colors.white, 0.3)!;
    final darkColor = Color.lerp(color, Colors.black, 0.2)!;
    
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [lightColor, color, darkColor],
            stops: const [0.0, 0.5, 1.0],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.4),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 22,
              shadows: const [
                Shadow(
                  color: Color(0x60000000),
                  offset: Offset(1, 1),
                  blurRadius: 2,
                ),
              ],
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Color(0x60000000),
                    offset: Offset(1, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
