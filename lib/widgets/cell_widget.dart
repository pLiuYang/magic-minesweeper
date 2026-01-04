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
    final borderRadius = (cellSize * 0.15).clamp(4.0, 8.0);
    final margin = (cellSize * 0.04).clamp(1.0, 2.0);

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.all(margin),
        decoration: BoxDecoration(
          color: _getCellColor(),
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
            // Scan overlay
            if (isScanned)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(borderRadius),
                    border: Border.all(
                      color: Colors.red,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.warning,
                      color: Colors.red.withOpacity(0.8),
                      size: iconSize * 0.8,
                    ),
                  ),
                ),
              ),
            // Spell target overlay
            if (isSpellTarget)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(borderRadius),
                    color: AppColors.primaryPurple.withOpacity(0.2),
                    border: Border.all(
                      color: AppColors.primaryPurple,
                      width: 2,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getCellColor() {
    if (cell.isFlagged) {
      return AppColors.cellCovered;
    }

    if (cell.isRevealed) {
      if (cell.isMine) {
        return gameOver && !isWon ? AppColors.cellMine : AppColors.cellCovered;
      }
      return AppColors.cellRevealed;
    }

    return AppColors.cellCovered;
  }

  List<BoxShadow>? _getCellShadow() {
    if (isScanned) {
      return [
        BoxShadow(
          color: Colors.red.withOpacity(0.4),
          blurRadius: 8,
          spreadRadius: 1,
        ),
      ];
    }
    
    if (cell.isCovered || cell.isFlagged) {
      return [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 2,
          offset: const Offset(1, 1),
        ),
      ];
    }
    
    return null;
  }

  Border? _getCellBorder() {
    if (isScanned) {
      return Border.all(color: Colors.red, width: 2);
    }
    
    if (cell.isRevealed) {
      return Border.all(color: Colors.grey.shade300, width: 1);
    }
    
    return null;
  }

  Widget? _buildCellContent(double iconSize, double fontSize) {
    if (cell.isFlagged) {
      return Icon(
        Icons.flag,
        color: AppColors.cellFlag,
        size: iconSize,
      );
    }

    if (cell.isRevealed) {
      if (cell.isMine) {
        return Icon(
          Icons.brightness_7,
          color: gameOver && !isWon ? Colors.white : Colors.black87,
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
