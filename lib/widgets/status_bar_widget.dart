import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../utils/constants.dart';

class StatusBarWidget extends StatelessWidget {
  const StatusBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primaryPurple.withOpacity(0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryPurple.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Flag counter
              _buildStatusItem(
                icon: Icons.flag_rounded,
                iconColor: AppColors.primaryPink,
                value: '${gameProvider.remainingFlags}',
                label: 'Flags',
              ),
              // Mana bar
              _buildManaBar(gameProvider),
              // Timer
              _buildStatusItem(
                icon: Icons.timer_rounded,
                iconColor: AppColors.crystalBlue,
                value: gameProvider.timerDisplay,
                label: 'Time',
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.magicPurple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildManaBar(GameProvider gameProvider) {
    final manaPercentage = gameProvider.manaPercentage;
    final manaColor = _getManaColor(manaPercentage);
    
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: manaColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  size: 14,
                  color: manaColor,
                ),
                const SizedBox(width: 4),
                Text(
                  'MANA',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: manaColor,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${gameProvider.mana}/${gameProvider.maxMana}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppColors.magicPurple.withOpacity(0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: manaColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Stack(
                  children: [
                    // Mana fill with gradient
                    FractionallySizedBox(
                      widthFactor: manaPercentage,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              manaColor.withOpacity(0.8),
                              manaColor,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    // Shine effect
                    FractionallySizedBox(
                      widthFactor: manaPercentage,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white.withOpacity(0.4),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getManaColor(double percentage) {
    if (percentage > 0.6) {
      return AppColors.magicPurple;
    } else if (percentage > 0.3) {
      return AppColors.sparkleGold;
    } else {
      return AppColors.primaryPink;
    }
  }
}
