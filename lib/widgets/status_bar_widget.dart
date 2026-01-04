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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Flag counter
              _buildStatusItem(
                icon: Icons.flag,
                iconColor: AppColors.cellFlag,
                value: '${gameProvider.remainingFlags}',
              ),
              // Mana bar
              _buildManaBar(gameProvider),
              // Timer
              _buildStatusItem(
                icon: Icons.timer,
                iconColor: AppColors.primaryBlue,
                value: gameProvider.timerDisplay,
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
  }) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildManaBar(GameProvider gameProvider) {
    final manaPercentage = gameProvider.manaPercentage;
    final manaColor = _getManaColor(manaPercentage);
    
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.water_drop,
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
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${gameProvider.mana}/${gameProvider.maxMana}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Container(
              height: 10,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(5),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Stack(
                  children: [
                    // Background
                    Container(
                      color: Colors.grey.shade200,
                    ),
                    // Mana fill with gradient
                    FractionallySizedBox(
                      widthFactor: manaPercentage,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              manaColor.withOpacity(0.7),
                              manaColor,
                            ],
                          ),
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
                              Colors.white.withOpacity(0.3),
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
      return AppColors.primaryBlue;
    } else if (percentage > 0.3) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}
