import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/competitive_spell.dart';
import '../models/game_board.dart';
import '../utils/constants.dart';

class VersusBoardWidget extends StatefulWidget {
  final String playerId;
  final bool isInteractive;
  final String difficulty;
  final Function(int) onScoreUpdate;
  final VoidCallback onGameComplete;
  final List<ActiveSpellEffect> activeEffects;

  const VersusBoardWidget({
    super.key,
    required this.playerId,
    required this.isInteractive,
    required this.difficulty,
    required this.onScoreUpdate,
    required this.onGameComplete,
    required this.activeEffects,
  });

  @override
  State<VersusBoardWidget> createState() => _VersusBoardWidgetState();
}

class _VersusBoardWidgetState extends State<VersusBoardWidget>
    with TickerProviderStateMixin {
  late GameBoard _board;
  int _score = 0;
  bool _isGameOver = false;
  bool _isVictory = false;
  Timer? _aiTimer;
  
  // Effect states
  bool _isBlinded = false;
  bool _isFrozen = false;
  bool _isCursed = false;
  Map<String, int>? _scrambleMap;
  List<Map<String, int>>? _fakeMines;

  @override
  void initState() {
    super.initState();
    _initializeBoard();
    
    if (!widget.isInteractive) {
      _startAIPlay();
    }
  }

  void _initializeBoard() {
    int rows, cols, mines;
    switch (widget.difficulty) {
      case 'easy':
        rows = 8;
        cols = 8;
        mines = 10;
        break;
      case 'hard':
        rows = 12;
        cols = 12;
        mines = 30;
        break;
      case 'medium':
      default:
        rows = 10;
        cols = 10;
        mines = 20;
    }
    
    _board = GameBoard(rows: rows, cols: cols, mineCount: mines);
  }

  void _startAIPlay() {
    _aiTimer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      if (_isGameOver || _isVictory) {
        timer.cancel();
        return;
      }
      _makeAIMove();
    });
  }

  void _makeAIMove() {
    if (_isGameOver || _isVictory) return;

    // Find a safe cell to reveal
    final random = Random();
    final hiddenCells = <List<int>>[];
    
    for (int r = 0; r < _board.rows; r++) {
      for (int c = 0; c < _board.cols; c++) {
        if (!_board.cells[r][c].isRevealed && !_board.cells[r][c].isFlagged) {
          hiddenCells.add([r, c]);
        }
      }
    }

    if (hiddenCells.isEmpty) return;

    // AI has some intelligence - prefer cells near revealed numbers
    List<int>? bestCell;
    for (final cell in hiddenCells) {
      if (!_board.cells[cell[0]][cell[1]].isMine) {
        // Check if adjacent to revealed cell
        bool isAdjacent = false;
        for (int dr = -1; dr <= 1; dr++) {
          for (int dc = -1; dc <= 1; dc++) {
            final nr = cell[0] + dr;
            final nc = cell[1] + dc;
            if (nr >= 0 && nr < _board.rows && nc >= 0 && nc < _board.cols) {
              if (_board.cells[nr][nc].isRevealed) {
                isAdjacent = true;
                break;
              }
            }
          }
          if (isAdjacent) break;
        }
        if (isAdjacent || bestCell == null) {
          bestCell = cell;
          if (isAdjacent) break;
        }
      }
    }

    final cellToReveal = bestCell ?? hiddenCells[random.nextInt(hiddenCells.length)];
    _revealCell(cellToReveal[0], cellToReveal[1]);
  }

  @override
  void didUpdateWidget(VersusBoardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _processActiveEffects();
  }

  void _processActiveEffects() {
    setState(() {
      _isBlinded = widget.activeEffects.any(
        (e) => e.spellType == CompetitiveSpellType.blind && e.isActive,
      );
      _isFrozen = widget.activeEffects.any(
        (e) => e.spellType == CompetitiveSpellType.freeze && e.isActive,
      );
      _isCursed = widget.activeEffects.any(
        (e) => e.spellType == CompetitiveSpellType.curse,
      );
      
      final scrambleEffect = widget.activeEffects.firstWhere(
        (e) => e.spellType == CompetitiveSpellType.scramble && e.isActive,
        orElse: () => ActiveSpellEffect(
          spellType: CompetitiveSpellType.scramble,
          casterId: '',
          targetId: '',
          startTime: DateTime.now(),
          duration: 0,
        ),
      );
      _scrambleMap = scrambleEffect.duration > 0 
          ? scrambleEffect.effectData['numberMap'] as Map<String, int>?
          : null;
      
      final minefieldEffect = widget.activeEffects.firstWhere(
        (e) => e.spellType == CompetitiveSpellType.minefield && e.isActive,
        orElse: () => ActiveSpellEffect(
          spellType: CompetitiveSpellType.minefield,
          casterId: '',
          targetId: '',
          startTime: DateTime.now(),
          duration: 0,
        ),
      );
      _fakeMines = minefieldEffect.duration > 0
          ? (minefieldEffect.effectData['fakeMines'] as List?)
              ?.cast<Map<String, int>>()
          : null;
    });
  }

  @override
  void dispose() {
    _aiTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Game board
        Container(
          color: const Color(0xFF1a1a2e),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final cellSize = min(
                constraints.maxWidth / _board.cols,
                constraints.maxHeight / _board.rows,
              );
              
              return Center(
                child: SizedBox(
                  width: cellSize * _board.cols,
                  height: cellSize * _board.rows,
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _board.cols,
                    ),
                    itemCount: _board.rows * _board.cols,
                    itemBuilder: (context, index) {
                      final row = index ~/ _board.cols;
                      final col = index % _board.cols;
                      return _buildCell(row, col, cellSize);
                    },
                  ),
                ),
              );
            },
          ),
        ),
        
        // Frozen overlay
        if (_isFrozen)
          Container(
            color: Colors.cyan.withOpacity(0.3),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.ac_unit,
                    color: Colors.white,
                    size: 48,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'FROZEN',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.cyan.shade300,
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        
        // Score indicator
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Score: $_score',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
        
        // Active effects indicator
        if (widget.activeEffects.isNotEmpty)
          Positioned(
            top: 8,
            left: 8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.activeEffects
                  .where((e) => e.isActive)
                  .map((e) => _buildEffectIndicator(e))
                  .toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildCell(int row, int col, double size) {
    final cell = _board.cells[row][col];
    final isFakeMine = _fakeMines?.any(
      (m) => m['row'] == row && m['col'] == col,
    ) ?? false;

    return GestureDetector(
      onTap: widget.isInteractive && !_isFrozen && !_isGameOver
          ? () => _revealCell(row, col)
          : null,
      onLongPress: widget.isInteractive && !_isFrozen && !_isGameOver
          ? () => _toggleFlag(row, col)
          : null,
      child: Container(
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          gradient: cell.isRevealed
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF2d2d44),
                    const Color(0xFF1f1f35),
                  ],
                )
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF4a4a6a),
                    const Color(0xFF3a3a5a),
                  ],
                ),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: cell.isRevealed
                ? Colors.white.withOpacity(0.1)
                : Colors.white.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: cell.isRevealed
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    offset: const Offset(1, 1),
                    blurRadius: 2,
                  ),
                ],
        ),
        child: Center(
          child: _buildCellContent(cell, isFakeMine),
        ),
      ),
    );
  }

  Widget _buildCellContent(Cell cell, bool isFakeMine) {
    if (cell.isFlagged) {
      return Icon(
        Icons.flag,
        color: Colors.red.shade400,
        size: 16,
      );
    }

    if (isFakeMine && !cell.isRevealed) {
      // Show fake mine warning
      return Icon(
        Icons.warning,
        color: Colors.orange.withOpacity(0.7),
        size: 14,
      );
    }

    if (!cell.isRevealed) {
      return const SizedBox();
    }

    if (cell.isMine) {
      return Icon(
        Icons.brightness_7,
        color: Colors.red.shade400,
        size: 16,
      );
    }

    if (cell.adjacentMines > 0) {
      if (_isBlinded) {
        return Text(
          '?',
          style: TextStyle(
            color: Colors.grey.withOpacity(0.5),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        );
      }

      int displayNumber = cell.adjacentMines;
      if (_scrambleMap != null) {
        displayNumber = _scrambleMap![cell.adjacentMines.toString()] ?? displayNumber;
      }

      return Text(
        displayNumber.toString(),
        style: TextStyle(
          color: _getNumberColor(cell.adjacentMines),
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      );
    }

    return const SizedBox();
  }

  Widget _buildEffectIndicator(ActiveSpellEffect effect) {
    final spell = CompetitiveSpell.getSpell(effect.spellType);
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: spell.color.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: spell.color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(spell.icon, size: 12, color: spell.color),
          const SizedBox(width: 4),
          Text(
            '${effect.remainingDuration}s',
            style: TextStyle(
              color: spell.color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getNumberColor(int number) {
    switch (number) {
      case 1:
        return Colors.blue.shade300;
      case 2:
        return Colors.green.shade400;
      case 3:
        return Colors.red.shade400;
      case 4:
        return Colors.purple.shade400;
      case 5:
        return Colors.orange.shade400;
      case 6:
        return Colors.cyan.shade400;
      case 7:
        return Colors.pink.shade400;
      case 8:
        return Colors.grey.shade400;
      default:
        return Colors.white;
    }
  }

  void _revealCell(int row, int col) {
    if (_isGameOver || _isVictory) return;
    if (_board.cells[row][col].isRevealed || _board.cells[row][col].isFlagged) return;

    // Handle curse effect
    if (_isCursed && widget.isInteractive) {
      setState(() {
        _isCursed = false;
      });
      // Curse consumed - do nothing this turn
      return;
    }

    setState(() {
      if (!_board.isInitialized) {
        _board.initializeMines(row, col);
      }

      if (_board.cells[row][col].isMine) {
        // Game over
        _board.revealAllMines();
        _isGameOver = true;
      } else {
        // Reveal cell and calculate score
        final revealedCount = _board.revealCell(row, col);
        _score += revealedCount * 10;
        widget.onScoreUpdate(_score);

        // Check victory
        if (_board.checkVictory()) {
          _isVictory = true;
          _score += 500; // Bonus for completing
          widget.onScoreUpdate(_score);
          widget.onGameComplete();
        }
      }
    });
  }

  void _toggleFlag(int row, int col) {
    if (_isGameOver || _isVictory) return;
    if (_board.cells[row][col].isRevealed) return;

    setState(() {
      _board.cells[row][col].isFlagged = !_board.cells[row][col].isFlagged;
    });
  }
}
