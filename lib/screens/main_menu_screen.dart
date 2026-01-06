import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../utils/constants.dart';
import '../widgets/menu_button.dart';
import 'game_screen.dart';
import 'settings_screen.dart';
import 'difficulty_selection_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.menuGradient,
        ),
        child: Stack(
          children: [
            // Decorative elements - Candy Crush style background elements
            _buildBackgroundDecorations(),
            // Main content
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    const Spacer(flex: 2),
                    // Logo
                    _buildLogo(),
                    const Spacer(flex: 2),
                    // Menu buttons
                    _buildMenuButtons(context),
                    const Spacer(flex: 1),
                    // Stats bar
                    _buildStatsBar(context),
                    const SizedBox(height: 24),
                  ],
                ),
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
        // Top left decoration
        Positioned(
          top: -50,
          left: -50,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.candyPink.withOpacity(0.3),
                  AppColors.candyPink.withOpacity(0.0),
                ],
              ),
            ),
          ),
        ),
        // Top right decoration
        Positioned(
          top: 100,
          right: -30,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.candyPurple.withOpacity(0.3),
                  AppColors.candyPurple.withOpacity(0.0),
                ],
              ),
            ),
          ),
        ),
        // Bottom decoration
        Positioned(
          bottom: -80,
          left: 50,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.candyYellow.withOpacity(0.2),
                  AppColors.candyYellow.withOpacity(0.0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        // Logo image with glow effect
        Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.candyPurple.withOpacity(0.5),
                blurRadius: 30,
                spreadRadius: 5,
              ),
              BoxShadow(
                color: AppColors.candyPink.withOpacity(0.4),
                blurRadius: 50,
                spreadRadius: 10,
              ),
              BoxShadow(
                color: AppColors.sparkleGold.withOpacity(0.3),
                blurRadius: 60,
                spreadRadius: 15,
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                // Fallback icon if image not found
                return Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.candyPurple,
                        AppColors.candyPink,
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 70,
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 32),
        // Title with Candy Crush style
        Stack(
          children: [
            // Shadow text
            Text(
              'Magic',
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.w300,
                letterSpacing: 6,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 6
                  ..color = AppColors.candyPurple.withOpacity(0.3),
              ),
            ),
            // Main text with gradient
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [
                  AppColors.candyPurple,
                  AppColors.candyPink,
                ],
              ).createShader(bounds),
              child: const Text(
                'Magic',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                  letterSpacing: 6,
                ),
              ),
            ),
          ],
        ),
        Stack(
          children: [
            // Shadow text
            Text(
              'Sweeper',
              style: TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.bold,
                letterSpacing: 3,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 6
                  ..color = AppColors.candyPink.withOpacity(0.3),
              ),
            ),
            // Main text with gradient
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [
                  AppColors.candyPink,
                  AppColors.candyPurple,
                ],
              ).createShader(bounds),
              child: const Text(
                'Sweeper',
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 3,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Sparkle decoration
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star, color: AppColors.sparkleGold, size: 16),
            const SizedBox(width: 8),
            Icon(Icons.auto_awesome, color: AppColors.candyPurple, size: 22),
            const SizedBox(width: 8),
            Icon(Icons.star, color: AppColors.sparkleGold, size: 16),
          ],
        ),
      ],
    );
  }

  Widget _buildMenuButtons(BuildContext context) {
    return Column(
      children: [
        MenuButton(
          text: 'New Game',
          icon: Icons.play_arrow_rounded,
          color: AppColors.candyPurple,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DifficultySelectionScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 14),
        MenuButton(
          text: 'Continue',
          icon: Icons.replay_rounded,
          color: AppColors.candyGreen,
          enabled: false,
          onPressed: () {
            // TODO: Load saved game
          },
        ),
        const SizedBox(height: 14),
        MenuButton(
          text: 'Multiplayer',
          icon: Icons.people_rounded,
          color: AppColors.candyPink,
          badge: 'Coming Soon',
          enabled: false,
          onPressed: null,
        ),
        const SizedBox(height: 14),
        MenuButton(
          text: 'Settings',
          icon: Icons.settings_rounded,
          color: AppColors.buttonGray,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SettingsScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatsBar(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.9),
                Colors.white.withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.sparkleGold.withOpacity(0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.candyPurple.withOpacity(0.15),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                icon: Icons.emoji_events_rounded,
                iconColor: AppColors.sparkleGold,
                label: 'Best Time',
                value: settingsProvider.formatBestTime('Beginner'),
              ),
              _buildStatItem(
                icon: Icons.favorite_rounded,
                iconColor: AppColors.candyPink,
                label: 'Games Won',
                value: '${settingsProvider.gamesWon}',
              ),
              _buildStatItem(
                icon: Icons.auto_awesome_rounded,
                iconColor: AppColors.candyPurple,
                label: 'Win Rate',
                value: '${(settingsProvider.winRate * 100).toStringAsFixed(0)}%',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 26),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }
}
