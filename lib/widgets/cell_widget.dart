import 'package:flutter/material.dart';
import '../models/cell.dart';
import '../utils/constants.dart';

class CellWidget extends StatelessWidget {
  final Cell cell;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final bool gameOver;
  final bool isWon;

  const CellWidget({
    super.key,
    required this.cell,
    required this.onTap,
    required this.onLongPress,
    this.gameOver = false,
    this.isWon = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.all(GameConstants.cellSpacing / 2),
        decoration: BoxDecoration(
          color: _getCellColor(),
          borderRadius: BorderRadius.circular(GameConstants.cellBorderRadius),
          boxShadow: cell.isCovered || cell.isFlagged
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 2,
                    offset: const Offset(1, 1),
                  ),
                ]
              : null,
          border: cell.isRevealed
              ? Border.all(color: Colors.grey.shade300, width: 1)
              : null,
        ),
        child: Center(
          child: _buildCellContent(),
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

  Widget? _buildCellContent() {
    if (cell.isFlagged) {
      return const Icon(
        Icons.flag,
        color: AppColors.cellFlag,
        size: 20,
      );
    }

    if (cell.isRevealed) {
      if (cell.isMine) {
        return Icon(
          Icons.brightness_7,
          color: gameOver && !isWon ? Colors.white : Colors.black87,
          size: 20,
        );
      }

      if (cell.adjacentMines > 0) {
        return Text(
          '${cell.adjacentMines}',
          style: AppTextStyles.cellNumber.copyWith(
            color: AppColors.numberColors[cell.adjacentMines - 1],
          ),
        );
      }
    }

    return null;
  }
}
