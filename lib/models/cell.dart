/// Represents the state of a single cell in the Minesweeper grid
enum CellState {
  covered,    // Cell is hidden
  revealed,   // Cell has been uncovered
  flagged,    // Cell is marked with a flag
}

class Cell {
  final int row;
  final int col;
  bool isMine;
  int adjacentMines;
  CellState state;

  Cell({
    required this.row,
    required this.col,
    this.isMine = false,
    this.adjacentMines = 0,
    this.state = CellState.covered,
  });

  bool get isCovered => state == CellState.covered;
  bool get isRevealed => state == CellState.revealed;
  bool get isFlagged => state == CellState.flagged;
  bool get isEmpty => !isMine && adjacentMines == 0;

  void reveal() {
    if (state == CellState.covered) {
      state = CellState.revealed;
    }
  }

  void toggleFlag() {
    if (state == CellState.covered) {
      state = CellState.flagged;
    } else if (state == CellState.flagged) {
      state = CellState.covered;
    }
  }

  void reset() {
    isMine = false;
    adjacentMines = 0;
    state = CellState.covered;
  }

  Cell copyWith({
    int? row,
    int? col,
    bool? isMine,
    int? adjacentMines,
    CellState? state,
  }) {
    return Cell(
      row: row ?? this.row,
      col: col ?? this.col,
      isMine: isMine ?? this.isMine,
      adjacentMines: adjacentMines ?? this.adjacentMines,
      state: state ?? this.state,
    );
  }

  @override
  String toString() {
    return 'Cell($row, $col, mine: $isMine, adjacent: $adjacentMines, state: $state)';
  }
}
