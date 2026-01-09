import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';

class StatusBarWidget extends StatelessWidget {
  const StatusBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1F2937),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF4B5563),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Flag counter
              _buildStatusItem(
                icon: Icons.flag,
                iconColor: const Color(0xFFFACC15), // Yellow/Gold
                value: '${gameProvider.remainingFlags}',
                label: 'FLAGS',
              ),
              // Mana bar (Expanded)
              _buildManaBar(gameProvider),
              // Timer
              _buildStatusItem(
                icon: Icons.timer,
                iconColor: const Color(0xFF2DD4BF), // Teal/Mint
                value: gameProvider.timerDisplay,
                label: 'TIME',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusItem({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white.withOpacity(0.5),
                letterSpacing: 1,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildManaBar(GameProvider gameProvider) {
    final manaPercentage = gameProvider.manaPercentage;
    final manaColor = _getManaColor(manaPercentage);

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'MANA',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF60A5FA), // Blue
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  '${gameProvider.mana}/${gameProvider.maxMana}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF60A5FA),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Retro Progress Bar
            Container(
              height: 12,
              decoration: BoxDecoration(
                color: const Color(0xFF111827),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: const Color(0xFF374151),
                  width: 2,
                ),
              ),
              child: Stack(
                children: [
                  FractionallySizedBox(
                    widthFactor: manaPercentage,
                    child: Container(
                      decoration: BoxDecoration(
                        color: manaColor,
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: manaColor.withOpacity(0.5),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Shine lines for retro effect
                  if (manaPercentage > 0)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: FractionallySizedBox(
                        widthFactor: manaPercentage,
                        child: Image.asset(
                          'assets/images/grid_pattern.png', // Reusing pattern if available, or just lines
                          fit: BoxFit.cover,
                          color: Colors.white.withOpacity(0.2),
                          colorBlendMode: BlendMode.overlay,
                          errorBuilder: (_, __, ___) => const SizedBox(),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getManaColor(double percentage) {
    if (percentage > 0.6) {
      return const Color(0xFF60A5FA); // Blue
    } else if (percentage > 0.3) {
      return const Color(0xFFFACC15); // Yellow
    } else {
      return const Color(0xFFF87171); // Red
    }
  }
}
