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
        child: SafeArea(
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
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        // Logo image with glow effect
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryPurple.withOpacity(0.4),
                blurRadius: 30,
                spreadRadius: 5,
              ),
              BoxShadow(
                color: AppColors.primaryPink.withOpacity(0.3),
                blurRadius: 50,
                spreadRadius: 10,
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
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primaryPurple,
                        AppColors.primaryPink,
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 60,
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 28),
        // Title with cute styling
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              AppColors.magicPurple,
              AppColors.primaryPink,
            ],
          ).createShader(bounds),
          child: const Text(
            'Magic',
            style: TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.w300,
              color: Colors.white,
              letterSpacing: 6,
            ),
          ),
        ),
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              AppColors.primaryPink,
              AppColors.magicPurple,
            ],
          ).createShader(bounds),
          child: const Text(
            'Sweeper',
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 3,
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Sparkle decoration
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star, color: AppColors.sparkleGold, size: 14),
            const SizedBox(width: 8),
            Icon(Icons.auto_awesome, color: AppColors.primaryPurple.withOpacity(0.7), size: 18),
            const SizedBox(width: 8),
            Icon(Icons.star, color: AppColors.sparkleGold, size: 14),
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
          color: AppColors.magicPurple,
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
          color: AppColors.buttonSuccess,
          enabled: false,
          onPressed: () {
            // TODO: Load saved game
          },
        ),
        const SizedBox(height: 14),
        MenuButton(
          text: 'Multiplayer',
          icon: Icons.people_rounded,
          color: AppColors.primaryPink,
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
            color: Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primaryPurple.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryPurple.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
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
                iconColor: AppColors.primaryPink,
                label: 'Games Won',
                value: '${settingsProvider.gamesWon}',
              ),
              _buildStatItem(
                icon: Icons.auto_awesome_rounded,
                iconColor: AppColors.magicPurple,
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
        Icon(icon, color: iconColor, size: 26),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AppColors.magicPurple.withOpacity(0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.magicPurple,
          ),
        ),
      ],
    );
  }
}
