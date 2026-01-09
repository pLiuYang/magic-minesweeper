import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../utils/constants.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2D0A31), // Deep purple
      body: Stack(
        children: [
          // Background decorations
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
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      _buildBackButton(context),
                      const Expanded(
                        child: Text(
                          'SETTINGS',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
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
                ),

                Expanded(
                  child: Consumer<SettingsProvider>(
                    builder: (context, settingsProvider, child) {
                      return ListView(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 8),
                        children: [
                          // Game Settings
                          _buildSectionHeader('GAME PREFERENCES'),
                          _buildSettingsCard([
                            _buildSwitchTile(
                              icon: Icons.volume_up,
                              title: 'SOUND EFFECTS',
                              subtitle: 'Play retro sounds',
                              value: settingsProvider.soundEnabled,
                              onChanged: (value) =>
                                  settingsProvider.setSoundEnabled(value),
                            ),
                            const Divider(height: 1, color: Color(0xFF374151)),
                            _buildSwitchTile(
                              icon: Icons.vibration,
                              title: 'HAPTICS',
                              subtitle: 'Vibrate on actions',
                              value: settingsProvider.vibrationEnabled,
                              onChanged: (value) =>
                                  settingsProvider.setVibrationEnabled(value),
                            ),
                          ]),
                          const SizedBox(height: 24),

                          // Difficulty Info
                          _buildSectionHeader('DIFFICULTY STATS'),
                          _buildSettingsCard([
                            ...GameConstants.difficulties.map((config) {
                              final bestTime =
                                  settingsProvider.formatBestTime(config.name);
                              return Column(
                                children: [
                                  _buildDifficultyTile(
                                    name: config.name.toUpperCase(),
                                    details:
                                        '${config.width}x${config.height} • ${config.mines} MINES',
                                    bestTime: bestTime,
                                  ),
                                  if (config != GameConstants.difficulties.last)
                                    const Divider(
                                        height: 1, color: Color(0xFF374151)),
                                ],
                              );
                            }),
                          ]),
                          const SizedBox(height: 24),

                          // Statistics
                          _buildSectionHeader('CAREER STATS'),
                          _buildSettingsCard([
                            _buildStatTile(
                              icon: Icons.videogame_asset,
                              title: 'GAMES PLAYED',
                              value: '${settingsProvider.gamesPlayed}',
                              color: const Color(0xFF60A5FA),
                            ),
                            const Divider(height: 1, color: Color(0xFF374151)),
                            _buildStatTile(
                              icon: Icons.emoji_events,
                              title: 'GAMES WON',
                              value: '${settingsProvider.gamesWon}',
                              color: const Color(0xFFFACC15),
                            ),
                            const Divider(height: 1, color: Color(0xFF374151)),
                            _buildStatTile(
                              icon: Icons.pie_chart,
                              title: 'WIN RATE',
                              value:
                                  '${(settingsProvider.winRate * 100).toStringAsFixed(1)}%',
                              color: const Color(0xFF4ADE80),
                            ),
                            const Divider(height: 1, color: Color(0xFF374151)),
                            _buildStatTile(
                              icon: Icons.local_fire_department,
                              title: 'BEST STREAK',
                              value: '${settingsProvider.bestStreak}',
                              color: const Color(0xFFF472B6),
                            ),
                          ]),
                          const SizedBox(height: 24),

                          // About
                          _buildSectionHeader('SYSTEM INFO'),
                          _buildSettingsCard([
                            _buildInfoTile(
                              icon: Icons.info_outline,
                              title: 'VERSION',
                              value: '1.0.0 (NEO-RETRO)',
                            ),
                            const Divider(height: 1, color: Color(0xFF374151)),
                            _buildInfoTile(
                              icon: Icons.code,
                              title: 'ENGINE',
                              value: 'FLUTTER',
                            ),
                          ]),
                          const SizedBox(height: 32),
                        ],
                      );
                    },
                  ),
                ),
              ],
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Color(0xFFFBBF24), // Gold
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF374151),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 0,
            offset: const Offset(0, 4),
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
          color: const Color(0xFF374151),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: const Color(0xFF60A5FA), size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 14,
          letterSpacing: 0.5,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFFFBBF24), // Gold
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const Color(0xFFFBBF24).withOpacity(0.5);
          }
          return Colors.grey.shade600;
        }),
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
      case 'BEGINNER':
        difficultyColor = const Color(0xFF4ADE80);
        break;
      case 'INTERMEDIATE':
        difficultyColor = const Color(0xFFFACC15);
        break;
      case 'EXPERT':
        difficultyColor = const Color(0xFFF472B6);
        break;
      default:
        difficultyColor = Colors.grey;
    }

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF374151),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: difficultyColor.withOpacity(0.5)),
        ),
        child: Center(
          child: Text(
            name[0],
            style: TextStyle(
              color: difficultyColor,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
        ),
      ),
      title: Text(
        name,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 14,
          letterSpacing: 0.5,
        ),
      ),
      subtitle: Text(
        details,
        style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Icon(Icons.emoji_events, color: const Color(0xFFFBBF24), size: 16),
          Text(
            bestTime,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
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
    required Color color,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF374151),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 14,
          letterSpacing: 0.5,
        ),
      ),
      trailing: Text(
        value,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w900,
          color: Colors.white,
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
          color: const Color(0xFF374151),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.grey.shade400, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 14,
          letterSpacing: 0.5,
        ),
      ),
      trailing: Text(
        value,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color(0xFF9CA3AF),
        ),
      ),
    );
  }
}
