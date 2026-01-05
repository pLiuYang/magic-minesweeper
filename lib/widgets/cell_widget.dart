import 'package:flutter/material.dart';
import '../models/cell.dart';
import '../utils/constants.dart';

class CellWidget extends StatelessWidget {
  final Cell cell;
  final double cellSize;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final bool gameOver;
  final bool isWon;
  final bool isScanned;
  final bool isSpellTarget;

  const CellWidget({
    super.key,
    required this.cell,
    required this.onTap,
    required this.onLongPress,
    this.cellSize = 36.0,
    this.gameOver = false,
    this.isWon = false,
    this.isScanned = false,
    this.isSpellTarget = false,
  });

  @override
  Widget build(BuildContext context) {
    // Scale icon and font sizes based on cell size
    final iconSize = (cellSize * 0.55).clamp(16.0, 24.0);
    final fontSize = (cellSize * 0.5).clamp(14.0, 22.0);
    final borderRadius = (cellSize * 0.2).clamp(6.0, 10.0);
    final margin = (cellSize * 0.04).clamp(1.5, 2.5);

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.all(margin),
        decoration: BoxDecoration(
          gradient: _getCellGradient(),
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: _getCellShadow(),
          border: _getCellBorder(),
        ),
        child: Stack(
          children: [
            // Main content
            Center(
              child: _buildCellContent(iconSize, fontSize),
            ),
            // Scan overlay - shows mine warning
            if (isScanned)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(borderRadius),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.error.withOpacity(0.3),
                        AppColors.primaryPink.withOpacity(0.3),
                      ],
                    ),
                    border: Border.all(
                      color: AppColors.error,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.error,
                      size: iconSize * 0.9,
                    ),
                  ),
                ),
              ),
            // Spell target overlay
            if (isSpellTarget && !cell.isRevealed)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(borderRadius),
                    color: AppColors.magicPurple.withOpacity(0.15),
                    border: Border.all(
                      color: AppColors.magicPurple,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.auto_awesome,
                      color: AppColors.magicPurple.withOpacity(0.5),
                      size: iconSize * 0.7,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  LinearGradient? _getCellGradient() {
    if (cell.isFlagged) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.cellCovered,
          AppColors.cellCoveredHover,
        ],
      );
    }

    if (cell.isRevealed) {
      if (cell.isMine) {
        if (gameOver && !isWon) {
          return LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.cellMine,
              AppColors.cellMine.withOpacity(0.8),
            ],
          );
        }
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.cellSafe,
            AppColors.cellSafe.withOpacity(0.8),
          ],
        );
      }
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.cellRevealed,
          AppColors.cellRevealed.withOpacity(0.95),
        ],
      );
    }

    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AppColors.cellCovered,
        AppColors.cellCoveredHover.withOpacity(0.7),
      ],
    );
  }

  List<BoxShadow>? _getCellShadow() {
    if (isScanned) {
      return [
        BoxShadow(
          color: AppColors.error.withOpacity(0.4),
          blurRadius: 8,
          spreadRadius: 1,
        ),
      ];
    }
    
    if (cell.isCovered || cell.isFlagged) {
      return [
        BoxShadow(
          color: AppColors.primaryPurple.withOpacity(0.15),
          blurRadius: 4,
          offset: const Offset(2, 2),
        ),
        BoxShadow(
          color: Colors.white.withOpacity(0.8),
          blurRadius: 2,
          offset: const Offset(-1, -1),
        ),
      ];
    }
    
    return [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 2,
        offset: const Offset(1, 1),
      ),
    ];
  }

  Border? _getCellBorder() {
    if (isScanned) {
      return Border.all(color: AppColors.error, width: 2);
    }
    
    if (cell.isRevealed) {
      return Border.all(color: AppColors.primaryPurple.withOpacity(0.15), width: 1);
    }
    
    return Border.all(color: Colors.white.withOpacity(0.5), width: 1);
  }

  Widget? _buildCellContent(double iconSize, double fontSize) {
    if (cell.isFlagged) {
      return Icon(
        Icons.flag_rounded,
        color: AppColors.primaryPink,
        size: iconSize,
      );
    }

    if (cell.isRevealed) {
      if (cell.isMine) {
        return Icon(
          gameOver && !isWon ? Icons.close_rounded : Icons.check_circle_rounded,
          color: gameOver && !isWon ? Colors.white : AppColors.success,
          size: iconSize,
        );
      }

      if (cell.adjacentMines > 0) {
        return Text(
          '${cell.adjacentMines}',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: AppColors.numberColors[cell.adjacentMines - 1],
          ),
        );
      }
    }

    return null;
  }
}
