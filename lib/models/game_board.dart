import 'dart:math';
import 'cell.dart';
import '../utils/constants.dart';

enum GameStatus {
  notStarted,
  playing,
  won,
  lost,
}

class GameBoard {
  final int width;
  final int height;
  final int totalMines;
  late List<List<Cell>> cells;
  GameStatus status;
  int flagsPlaced;
  int revealedCount;
  bool minesPlaced;

  GameBoard({
    required this.width,
    required this.height,
    required this.totalMines,
  })  : status = GameStatus.notStarted,
        flagsPlaced = 0,
        revealedCount = 0,
        minesPlaced = false {
    _initializeBoard();
  }

  factory GameBoard.fromDifficulty(DifficultyConfig config) {
    return GameBoard(
      width: config.width,
      height: config.height,
      totalMines: config.mines,
    );
  }

  int get totalCells => width * height;
  int get remainingFlags => totalMines - flagsPlaced;
  int get safeCells => totalCells - totalMines;
  bool get isWon => revealedCount == safeCells;

  void _initializeBoard() {
    cells = List.generate(
      height,
      (row) => List.generate(
        width,
        (col) => Cell(row: row, col: col),
      ),
    );
  }

  void placeMines(int excludeRow, int excludeCol) {
    if (minesPlaced) return;

    final random = Random();
    int minesPlacedCount = 0;

    // Create a set of positions to exclude (the first click and its neighbors)
    final excludePositions = <String>{};
    for (int dr = -1; dr <= 1; dr++) {
      for (int dc = -1; dc <= 1; dc++) {
        final r = excludeRow + dr;
        final c = excludeCol + dc;
        if (r >= 0 && r < height && c >= 0 && c < width) {
          excludePositions.add('$r,$c');
        }
      }
    }

    while (minesPlacedCount < totalMines) {
      final row = random.nextInt(height);
      final col = random.nextInt(width);
      final posKey = '$row,$col';

      if (!cells[row][col].isMine && !excludePositions.contains(posKey)) {
        cells[row][col].isMine = true;
        minesPlacedCount++;
      }
    }

    _calculateAdjacentMines();
    minesPlaced = true;
  }

  void _calculateAdjacentMines() {
    for (int row = 0; row < height; row++) {
      for (int col = 0; col < width; col++) {
        if (!cells[row][col].isMine) {
          cells[row][col].adjacentMines = _countAdjacentMines(row, col);
        }
      }
    }
  }

  int _countAdjacentMines(int row, int col) {
    int count = 0;
    for (int dr = -1; dr <= 1; dr++) {
      for (int dc = -1; dc <= 1; dc++) {
        if (dr == 0 && dc == 0) continue;
        final r = row + dr;
        final c = col + dc;
        if (r >= 0 && r < height && c >= 0 && c < width) {
          if (cells[r][c].isMine) count++;
        }
      }
    }
    return count;
  }

  /// Reveals a cell and returns true if the game should continue
  bool revealCell(int row, int col) {
    if (row < 0 || row >= height || col < 0 || col >= width) return true;

    final cell = cells[row][col];

    // Can't reveal flagged or already revealed cells
    if (cell.isFlagged || cell.isRevealed) return true;

    // First click - place mines
    if (!minesPlaced) {
      placeMines(row, col);
      status = GameStatus.playing;
    }

    // Hit a mine - game over
    if (cell.isMine) {
      cell.reveal();
      status = GameStatus.lost;
      _revealAllMines();
      return false;
    }

    // Reveal the cell
    _floodReveal(row, col);

    // Check for win
    if (isWon) {
      status = GameStatus.won;
      _flagAllMines();
      return false;
    }

    return true;
  }

  void _floodReveal(int row, int col) {
    if (row < 0 || row >= height || col < 0 || col >= width) return;

    final cell = cells[row][col];
    if (cell.isRevealed || cell.isFlagged || cell.isMine) return;

    cell.reveal();
    revealedCount++;

    // If empty cell, reveal neighbors
    if (cell.isEmpty) {
      for (int dr = -1; dr <= 1; dr++) {
        for (int dc = -1; dc <= 1; dc++) {
          if (dr == 0 && dc == 0) continue;
          _floodReveal(row + dr, col + dc);
        }
      }
    }
  }

  /// Chord action - reveal all neighbors if flags match adjacent mines
  bool chordCell(int row, int col) {
    if (row < 0 || row >= height || col < 0 || col >= width) return true;

    final cell = cells[row][col];
    if (!cell.isRevealed || cell.adjacentMines == 0) return true;

    // Count adjacent flags
    int adjacentFlags = 0;
    for (int dr = -1; dr <= 1; dr++) {
      for (int dc = -1; dc <= 1; dc++) {
        if (dr == 0 && dc == 0) continue;
        final r = row + dr;
        final c = col + dc;
        if (r >= 0 && r < height && c >= 0 && c < width) {
          if (cells[r][c].isFlagged) adjacentFlags++;
        }
      }
    }

    // If flags match adjacent mines, reveal all non-flagged neighbors
    if (adjacentFlags == cell.adjacentMines) {
      for (int dr = -1; dr <= 1; dr++) {
        for (int dc = -1; dc <= 1; dc++) {
          if (dr == 0 && dc == 0) continue;
          final r = row + dr;
          final c = col + dc;
          if (r >= 0 && r < height && c >= 0 && c < width) {
            if (!cells[r][c].isFlagged && !cells[r][c].isRevealed) {
              if (!revealCell(r, c)) return false;
            }
          }
        }
      }
    }

    return status != GameStatus.lost;
  }

  void toggleFlag(int row, int col) {
    if (row < 0 || row >= height || col < 0 || col >= width) return;
    if (status != GameStatus.playing && status != GameStatus.notStarted) return;

    final cell = cells[row][col];
    if (cell.isRevealed) return;

    if (cell.isFlagged) {
      cell.toggleFlag();
      flagsPlaced--;
    } else if (flagsPlaced < totalMines) {
      cell.toggleFlag();
      flagsPlaced++;
    }

    // Start the game if not started
    if (status == GameStatus.notStarted) {
      status = GameStatus.playing;
    }
  }

  void _revealAllMines() {
    for (int row = 0; row < height; row++) {
      for (int col = 0; col < width; col++) {
        if (cells[row][col].isMine) {
          cells[row][col].state = CellState.revealed;
        }
      }
    }
  }

  void _flagAllMines() {
    for (int row = 0; row < height; row++) {
      for (int col = 0; col < width; col++) {
        if (cells[row][col].isMine && !cells[row][col].isFlagged) {
          cells[row][col].state = CellState.flagged;
        }
      }
    }
    flagsPlaced = totalMines;
  }

  void reset() {
    _initializeBoard();
    status = GameStatus.notStarted;
    flagsPlaced = 0;
    revealedCount = 0;
    minesPlaced = false;
  }

  Cell getCell(int row, int col) {
    return cells[row][col];
  }
}
