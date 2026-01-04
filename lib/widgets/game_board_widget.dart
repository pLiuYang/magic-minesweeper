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
              // Calculate available space
              final maxWidth = constraints.maxWidth - 16; // padding
              final maxHeight = constraints.maxHeight - 16;

              // Determine minimum cell size for playability
              const double minCellSize = 32.0;
              const double maxCellSize = 44.0;

              // Calculate cell size that fits within constraints
              final cellWidthFit = maxWidth / board.width;
              final cellHeightFit = maxHeight / board.height;
              
              // Use the smaller dimension to maintain square cells
              double cellSize = (cellWidthFit < cellHeightFit ? cellWidthFit : cellHeightFit);
              
              // Clamp to reasonable bounds
              cellSize = cellSize.clamp(minCellSize, maxCellSize);

              // Calculate total board dimensions
              final boardWidth = cellSize * board.width;
              final boardHeight = cellSize * board.height;

              // Determine if scrolling is needed
              final needsHorizontalScroll = boardWidth > maxWidth;
              final needsVerticalScroll = boardHeight > maxHeight;
              final needsScroll = needsHorizontalScroll || needsVerticalScroll;

              Widget boardWidget = SizedBox(
                width: boardWidth,
                height: boardHeight,
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
                      cellSize: cellSize,
                      gameOver: gameProvider.isGameOver,
                      isWon: gameProvider.isWon,
                      isScanned: gameProvider.isCellScanned(row, col),
                      isSpellTarget: gameProvider.isSpellMode,
                      onTap: () => gameProvider.revealCell(row, col),
                      onLongPress: () => gameProvider.toggleFlag(row, col),
                    );
                  },
                ),
              );

              // Wrap in scrollable container if needed
              if (needsScroll) {
                boardWidget = InteractiveViewer(
                  constrained: false,
                  boundaryMargin: const EdgeInsets.all(20),
                  minScale: 0.5,
                  maxScale: 2.0,
                  child: boardWidget,
                );
              }

              return Center(child: boardWidget);
            },
          ),
        );
      },
    );
  }
}
