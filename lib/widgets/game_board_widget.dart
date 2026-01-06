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
            // Candy Crush style board background
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF5B86E5),  // Blue top
                Color(0xFF36D1DC),  // Cyan bottom
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFFFFD700),  // Gold border
              width: 3,
            ),
            boxShadow: [
              // Outer glow
              BoxShadow(
                color: const Color(0xFF5B86E5).withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              // Inner shadow for depth
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              // Inner board area
              color: const Color(0xFF4A7BC7).withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 2,
              ),
            ),
            padding: const EdgeInsets.all(8),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Calculate available space
                final maxWidth = constraints.maxWidth - 16;
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

                Widget boardWidget = Container(
                  width: boardWidth,
                  height: boardHeight,
                  decoration: BoxDecoration(
                    // Subtle grid background
                    color: const Color(0xFF3A6BC5).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
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
                        isPurified: gameProvider.isCellPurified(row, col),
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
          ),
        );
      },
    );
  }
}
