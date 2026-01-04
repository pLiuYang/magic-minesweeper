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
        // Magic icon
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue.shade400,
                Colors.purple.shade400,
              ],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.auto_awesome,
            color: Colors.white,
            size: 50,
          ),
        ),
        const SizedBox(height: 24),
        // Title
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.white, Colors.white70],
          ).createShader(bounds),
          child: const Text(
            'Magic',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w300,
              color: Colors.white,
              letterSpacing: 4,
            ),
          ),
        ),
        const Text(
          'MineSweeper',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuButtons(BuildContext context) {
    return Column(
      children: [
        MenuButton(
          text: 'New Game',
          icon: Icons.play_arrow,
          color: AppColors.buttonBlue,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DifficultySelectionScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        MenuButton(
          text: 'Continue',
          icon: Icons.replay,
          color: AppColors.buttonGreen,
          enabled: false, // Will be enabled when save game is implemented
          onPressed: () {
            // TODO: Load saved game
          },
        ),
        const SizedBox(height: 16),
        MenuButton(
          text: 'Multiplayer',
          icon: Icons.people,
          color: AppColors.buttonPurple,
          badge: 'Coming Soon',
          enabled: false,
          onPressed: null,
        ),
        const SizedBox(height: 16),
        MenuButton(
          text: 'Settings',
          icon: Icons.settings,
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
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                icon: Icons.emoji_events,
                iconColor: Colors.amber,
                label: 'Best Time',
                value: settingsProvider.formatBestTime('Beginner'),
              ),
              _buildStatItem(
                icon: Icons.star,
                iconColor: Colors.yellow,
                label: 'Games Won',
                value: '${settingsProvider.gamesWon}',
              ),
              _buildStatItem(
                icon: Icons.diamond,
                iconColor: Colors.cyan,
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
        Icon(icon, color: iconColor, size: 28),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
