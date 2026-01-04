import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../utils/constants.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Game Settings
              _buildSectionHeader('Game Settings'),
              _buildSettingsCard([
                _buildSwitchTile(
                  icon: Icons.volume_up,
                  title: 'Sound Effects',
                  subtitle: 'Play sounds during gameplay',
                  value: settingsProvider.soundEnabled,
                  onChanged: (value) => settingsProvider.setSoundEnabled(value),
                ),
                const Divider(height: 1),
                _buildSwitchTile(
                  icon: Icons.vibration,
                  title: 'Vibration',
                  subtitle: 'Vibrate on actions',
                  value: settingsProvider.vibrationEnabled,
                  onChanged: (value) => settingsProvider.setVibrationEnabled(value),
                ),
              ]),
              const SizedBox(height: 24),

              // Difficulty Info
              _buildSectionHeader('Difficulty Levels'),
              _buildSettingsCard([
                ...GameConstants.difficulties.map((config) {
                  final bestTime = settingsProvider.formatBestTime(config.name);
                  return _buildDifficultyTile(
                    name: config.name,
                    details: '${config.width}×${config.height} • ${config.mines} mines',
                    bestTime: bestTime,
                  );
                }),
              ]),
              const SizedBox(height: 24),

              // Statistics
              _buildSectionHeader('Statistics'),
              _buildSettingsCard([
                _buildStatTile(
                  icon: Icons.games,
                  title: 'Games Played',
                  value: '${settingsProvider.gamesPlayed}',
                ),
                const Divider(height: 1),
                _buildStatTile(
                  icon: Icons.emoji_events,
                  title: 'Games Won',
                  value: '${settingsProvider.gamesWon}',
                ),
                const Divider(height: 1),
                _buildStatTile(
                  icon: Icons.percent,
                  title: 'Win Rate',
                  value: '${(settingsProvider.winRate * 100).toStringAsFixed(1)}%',
                ),
                const Divider(height: 1),
                _buildStatTile(
                  icon: Icons.local_fire_department,
                  title: 'Best Streak',
                  value: '${settingsProvider.bestStreak}',
                ),
              ]),
              const SizedBox(height: 24),

              // About
              _buildSectionHeader('About'),
              _buildSettingsCard([
                _buildInfoTile(
                  icon: Icons.info_outline,
                  title: 'Version',
                  value: '1.0.0 (Phase 1)',
                ),
                const Divider(height: 1),
                _buildInfoTile(
                  icon: Icons.code,
                  title: 'Built with',
                  value: 'Flutter',
                ),
              ]),
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primaryBlue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primaryBlue, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primaryBlue,
      ),
    );
  }

  Widget _buildDifficultyTile({
    required String name,
    required String details,
    required String bestTime,
  }) {
    Color difficultyColor;
    switch (name) {
      case 'Beginner':
        difficultyColor = Colors.green;
        break;
      case 'Intermediate':
        difficultyColor = Colors.orange;
        break;
      case 'Expert':
        difficultyColor = Colors.red;
        break;
      default:
        difficultyColor = Colors.grey;
    }

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: difficultyColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            name[0],
            style: TextStyle(
              color: difficultyColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      ),
      title: Text(
        name,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        details,
        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Icon(Icons.emoji_events, color: Colors.amber, size: 16),
          Text(
            bestTime,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.amber.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.amber.shade700, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      trailing: Text(
        value,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.grey.shade600, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      trailing: Text(
        value,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }
}
