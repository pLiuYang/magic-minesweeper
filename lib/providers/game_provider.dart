import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/cell.dart';
import '../models/game_board.dart';
import '../utils/constants.dart';

class GameProvider extends ChangeNotifier {
  late GameBoard _board;
  DifficultyConfig _difficulty;
  Timer? _timer;
  int _elapsedSeconds = 0;
  bool _isFirstGame = true;

  GameProvider({DifficultyConfig? difficulty})
      : _difficulty = difficulty ?? GameConstants.beginner {
    _board = GameBoard.fromDifficulty(_difficulty);
  }

  // Getters
  GameBoard get board => _board;
  DifficultyConfig get difficulty => _difficulty;
  int get elapsedSeconds => _elapsedSeconds;
  GameStatus get status => _board.status;
  int get remainingFlags => _board.remainingFlags;
  int get width => _board.width;
  int get height => _board.height;
  bool get isPlaying => _board.status == GameStatus.playing;
  bool get isGameOver => _board.status == GameStatus.won || _board.status == GameStatus.lost;
  bool get isWon => _board.status == GameStatus.won;
  bool get isLost => _board.status == GameStatus.lost;

  String get timerDisplay {
    final minutes = (_elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_elapsedSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  // Actions
  void setDifficulty(DifficultyConfig difficulty) {
    _difficulty = difficulty;
    newGame();
  }

  void newGame() {
    _stopTimer();
    _elapsedSeconds = 0;
    _board = GameBoard.fromDifficulty(_difficulty);
    _isFirstGame = false;
    notifyListeners();
  }

  void revealCell(int row, int col) {
    if (isGameOver) return;

    final cell = _board.getCell(row, col);
    
    // If cell is revealed and has adjacent mines, try chord
    if (cell.isRevealed && cell.adjacentMines > 0) {
      _board.chordCell(row, col);
    } else {
      // Start timer on first reveal
      if (_board.status == GameStatus.notStarted) {
        _startTimer();
      }
      _board.revealCell(row, col);
    }

    if (isGameOver) {
      _stopTimer();
    }

    notifyListeners();
  }

  void toggleFlag(int row, int col) {
    if (isGameOver) return;

    // Start timer if not started
    if (_board.status == GameStatus.notStarted) {
      _startTimer();
    }

    _board.toggleFlag(row, col);
    notifyListeners();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _elapsedSeconds++;
      notifyListeners();
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  Cell getCell(int row, int col) {
    return _board.getCell(row, col);
  }

  // Calculate score based on time and difficulty
  int calculateScore() {
    if (!isWon) return 0;

    final baseScore = _difficulty.mines * 100;
    final timeBonus = (_difficulty.totalCells * 10) ~/ (_elapsedSeconds + 1);
    return baseScore + timeBonus;
  }

  // Calculate star rating (1-3 stars)
  int calculateStars() {
    if (!isWon) return 0;

    // Base time expectations per difficulty
    final expectedTime = _difficulty.totalCells * 2; // 2 seconds per cell as baseline

    if (_elapsedSeconds <= expectedTime * 0.5) {
      return 3; // Under 50% of expected time
    } else if (_elapsedSeconds <= expectedTime) {
      return 2; // Under expected time
    } else {
      return 1; // Over expected time
    }
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}
