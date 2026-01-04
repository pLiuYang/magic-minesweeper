import 'dart:math';
import 'cell.dart';
import 'spell.dart';
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
  int _currentMineCount;
  
  // Spell-related state
  bool hasShield;
  Set<String> scannedCells; // Cells currently showing mine hints from Scan

  GameBoard({
    required this.width,
    required this.height,
    required this.totalMines,
  })  : status = GameStatus.notStarted,
        flagsPlaced = 0,
        revealedCount = 0,
        minesPlaced = false,
        _currentMineCount = totalMines,
        hasShield = false,
        scannedCells = {} {
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
  int get safeCells => totalCells - _currentMineCount;
  int get currentMineCount => _currentMineCount;
  bool get isWon => revealedCount == safeCells && status != GameStatus.lost;

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
        cells[row][col].adjacentMines = _countAdjacentMines(row, col);
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

    // Hit a mine
    if (cell.isMine) {
      // Check for shield
      if (hasShield) {
        hasShield = false;
        // Shield consumed - don't reveal the mine, just mark it
        cell.state = CellState.flagged;
        flagsPlaced++;
        return true;
      }
      
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

  // ============ SPELL METHODS ============

  /// Reveal spell - safely reveal one tile
  bool castReveal(int row, int col) {
    if (row < 0 || row >= height || col < 0 || col >= width) return false;
    
    final cell = cells[row][col];
    if (cell.isRevealed || cell.isFlagged) return false;

    // First click - place mines
    if (!minesPlaced) {
      placeMines(row, col);
      status = GameStatus.playing;
    }

    // If it's a mine, just flag it instead of revealing
    if (cell.isMine) {
      cell.state = CellState.flagged;
      flagsPlaced++;
    } else {
      _floodReveal(row, col);
    }

    // Check for win
    if (isWon) {
      status = GameStatus.won;
      _flagAllMines();
    }

    return true;
  }

  /// Scan spell - highlight mines in a 3x3 area
  List<String> castScan(int row, int col) {
    final scanned = <String>[];
    
    for (int dr = -1; dr <= 1; dr++) {
      for (int dc = -1; dc <= 1; dc++) {
        final r = row + dr;
        final c = col + dc;
        if (r >= 0 && r < height && c >= 0 && c < width) {
          if (cells[r][c].isMine && !cells[r][c].isRevealed) {
            final key = '$r,$c';
            scanned.add(key);
            scannedCells.add(key);
          }
        }
      }
    }
    
    return scanned;
  }

  /// Clear scanned cells (after scan effect expires)
  void clearScannedCells() {
    scannedCells.clear();
  }

  /// Check if a cell is currently scanned
  bool isCellScanned(int row, int col) {
    return scannedCells.contains('$row,$col');
  }

  /// Disarm spell - remove a flagged mine
  bool castDisarm(int row, int col) {
    if (row < 0 || row >= height || col < 0 || col >= width) return false;
    
    final cell = cells[row][col];
    if (!cell.isFlagged || !cell.isMine) return false;

    // Remove the mine
    cell.isMine = false;
    cell.state = CellState.covered;
    flagsPlaced--;
    _currentMineCount--;

    // Recalculate adjacent mines for all cells
    _calculateAdjacentMines();

    // Check for win
    if (isWon) {
      status = GameStatus.won;
      _flagAllMines();
    }

    return true;
  }

  /// Shield spell - activate shield
  void castShield() {
    hasShield = true;
  }

  /// Teleport spell - move a mine to a random safe location
  bool castTeleport(int row, int col) {
    if (row < 0 || row >= height || col < 0 || col >= width) return false;
    
    final cell = cells[row][col];
    if (!cell.isMine || cell.isRevealed) return false;

    // Find a random safe cell to move the mine to
    final safeCellsList = <Cell>[];
    for (int r = 0; r < height; r++) {
      for (int c = 0; c < width; c++) {
        final targetCell = cells[r][c];
        if (!targetCell.isMine && !targetCell.isRevealed && !targetCell.isFlagged) {
          safeCellsList.add(targetCell);
        }
      }
    }

    if (safeCellsList.isEmpty) return false;

    // Move the mine
    final random = Random();
    final targetCell = safeCellsList[random.nextInt(safeCellsList.length)];
    
    cell.isMine = false;
    if (cell.isFlagged) {
      cell.state = CellState.covered;
      flagsPlaced--;
    }
    
    targetCell.isMine = true;

    // Recalculate adjacent mines
    _calculateAdjacentMines();

    return true;
  }

  /// Purify spell - safely clear a 3x3 area
  bool castPurify(int row, int col) {
    if (row < 0 || row >= height || col < 0 || col >= width) return false;

    // First click - place mines
    if (!minesPlaced) {
      placeMines(row, col);
      status = GameStatus.playing;
    }

    bool anyRevealed = false;
    
    for (int dr = -1; dr <= 1; dr++) {
      for (int dc = -1; dc <= 1; dc++) {
        final r = row + dr;
        final c = col + dc;
        if (r >= 0 && r < height && c >= 0 && c < width) {
          final cell = cells[r][c];
          if (!cell.isRevealed && !cell.isFlagged) {
            if (cell.isMine) {
              // Flag mines instead of revealing
              cell.state = CellState.flagged;
              flagsPlaced++;
            } else {
              _floodReveal(r, c);
            }
            anyRevealed = true;
          }
        }
      }
    }

    // Check for win
    if (isWon) {
      status = GameStatus.won;
      _flagAllMines();
    }

    return anyRevealed;
  }

  void reset() {
    _initializeBoard();
    status = GameStatus.notStarted;
    flagsPlaced = 0;
    revealedCount = 0;
    minesPlaced = false;
    _currentMineCount = totalMines;
    hasShield = false;
    scannedCells.clear();
  }

  Cell getCell(int row, int col) {
    return cells[row][col];
  }
}
