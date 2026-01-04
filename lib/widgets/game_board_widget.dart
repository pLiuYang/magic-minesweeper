import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../utils/constants.dart';
import 'cell_widget.dart';

class GameBoardWidget extends StatelessWidget {
  const GameBoardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        final board = gameProvider.board;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(8),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Calculate cell size based on available space
              final maxWidth = constraints.maxWidth - 16; // padding
              final maxHeight = constraints.maxHeight - 16;

              final cellWidth = maxWidth / board.width;
              final cellHeight = maxHeight / board.height;
              final cellSize = (cellWidth < cellHeight ? cellWidth : cellHeight)
                  .clamp(24.0, GameConstants.cellSize);

              return Center(
                child: SizedBox(
                  width: cellSize * board.width,
                  height: cellSize * board.height,
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: board.width,
                      childAspectRatio: 1,
                    ),
                    itemCount: board.width * board.height,
                    itemBuilder: (context, index) {
                      final row = index ~/ board.width;
                      final col = index % board.width;
                      final cell = board.getCell(row, col);

                      return CellWidget(
                        cell: cell,
                        gameOver: gameProvider.isGameOver,
                        isWon: gameProvider.isWon,
                        onTap: () => gameProvider.revealCell(row, col),
                        onLongPress: () => gameProvider.toggleFlag(row, col),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
