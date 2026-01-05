import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/cell.dart';
import '../models/game_board.dart';
import '../models/spell.dart';
import '../utils/constants.dart';

class GameProvider extends ChangeNotifier {
  late GameBoard _board;
  DifficultyConfig _difficulty;
  Timer? _timer;
  Timer? _scanTimer;
  int _elapsedSeconds = 0;
  bool _isFirstGame = true;

  // Mana system
  int _mana = 0;
  int _maxMana = 100;
  int _manaPerTile = 2; // Mana gained per tile revealed
  
  // Spell system
  List<SpellType> _equippedSpells = Spell.defaultEquippedSpells;
  SpellType? _selectedSpell;
  bool _isSpellMode = false;
  List<SpellUsage> _spellHistory = [];

  GameProvider({DifficultyConfig? difficulty})
      : _difficulty = difficulty ?? GameConstants.beginner {
    _board = GameBoard.fromDifficulty(_difficulty);
    _initializeMana();
  }

  void _initializeMana() {
    // Scale max mana based on difficulty
    _maxMana = 50 + (_difficulty.totalCells ~/ 4);
    _mana = 20; // Start with some mana
    _manaPerTile = 2;
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

  // Mana getters
  int get mana => _mana;
  int get maxMana => _maxMana;
  double get manaPercentage => _mana / _maxMana;
  
  // Spell getters
  List<SpellType> get equippedSpells => _equippedSpells;
  SpellType? get selectedSpell => _selectedSpell;
  bool get isSpellMode => _isSpellMode;
  bool get hasShield => _board.hasShield;
  List<SpellUsage> get spellHistory => _spellHistory;
  int get spellsUsed => _spellHistory.length;

  String get timerDisplay {
    final minutes = (_elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_elapsedSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  // Check if a spell can be cast
  bool canCastSpell(SpellType type) {
    if (isGameOver) return false;
    final spell = Spell.getSpell(type);
    return _mana >= spell.manaCost;
  }

  // Actions
  void setDifficulty(DifficultyConfig difficulty) {
    _difficulty = difficulty;
    newGame();
  }

  void newGame() {
    _stopTimer();
    _stopScanTimer();
    _elapsedSeconds = 0;
    _board = GameBoard.fromDifficulty(_difficulty);
    _initializeMana();
    _selectedSpell = null;
    _isSpellMode = false;
    _spellHistory = [];
    _isFirstGame = false;
    notifyListeners();
  }

  void revealCell(int row, int col) {
    if (isGameOver) return;

    // If in spell mode, cast the spell instead
    if (_isSpellMode && _selectedSpell != null) {
      _castSpellOnCell(row, col);
      return;
    }

    final cell = _board.getCell(row, col);
    final prevRevealed = _board.revealedCount;
    
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

    // Award mana for revealed tiles
    final newRevealed = _board.revealedCount - prevRevealed;
    if (newRevealed > 0) {
      _addMana(newRevealed * _manaPerTile);
    }

    if (isGameOver) {
      _stopTimer();
      _stopScanTimer();
    }

    notifyListeners();
  }

  void toggleFlag(int row, int col) {
    if (isGameOver) return;

    // If in spell mode, cancel it
    if (_isSpellMode) {
      cancelSpellMode();
      return;
    }

    // Start timer if not started
    if (_board.status == GameStatus.notStarted) {
      _startTimer();
    }

    _board.toggleFlag(row, col);
    notifyListeners();
  }

  // Spell methods
  void selectSpell(SpellType type) {
    if (isGameOver) return;
    
    final spell = Spell.getSpell(type);
    
    if (_mana < spell.manaCost) {
      // Not enough mana
      return;
    }

    if (spell.requiresTarget) {
      // Enter spell targeting mode
      _selectedSpell = type;
      _isSpellMode = true;
    } else {
      // Cast immediately (e.g., Shield)
      _castNonTargetedSpell(type);
    }
    
    notifyListeners();
  }

  void cancelSpellMode() {
    _selectedSpell = null;
    _isSpellMode = false;
    notifyListeners();
  }

  void _castSpellOnCell(int row, int col) {
    if (_selectedSpell == null) return;
    
    final spell = Spell.getSpell(_selectedSpell!);
    if (_mana < spell.manaCost) {
      cancelSpellMode();
      return;
    }

    bool success = false;
    
    switch (_selectedSpell!) {
      case SpellType.reveal:
        success = _board.castReveal(row, col);
        break;
      case SpellType.scan:
        // Scan always succeeds - it shows the area was scanned
        // Even if no mines are found, the spell is cast
        _board.castScan(row, col);
        _startScanTimer();
        success = true;
        break;
      case SpellType.disarm:
        success = _board.castDisarm(row, col);
        break;
      case SpellType.teleport:
        success = _board.castTeleport(row, col);
        break;
      case SpellType.purify:
        success = _board.castPurify(row, col);
        break;
      case SpellType.shield:
        // Shield doesn't need a target
        break;
    }

    if (success) {
      _mana -= spell.manaCost;
      _spellHistory.add(SpellUsage(
        type: _selectedSpell!,
        row: row,
        col: col,
        timestamp: _elapsedSeconds,
      ));
    }

    // Exit spell mode
    cancelSpellMode();

    if (isGameOver) {
      _stopTimer();
      _stopScanTimer();
    }

    notifyListeners();
  }

  void _castNonTargetedSpell(SpellType type) {
    final spell = Spell.getSpell(type);
    
    if (type == SpellType.shield) {
      _board.castShield();
      _mana -= spell.manaCost;
      _spellHistory.add(SpellUsage(
        type: type,
        row: -1,
        col: -1,
        timestamp: _elapsedSeconds,
      ));
    }
    
    notifyListeners();
  }

  void _addMana(int amount) {
    _mana = (_mana + amount).clamp(0, _maxMana);
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

  void _startScanTimer() {
    _stopScanTimer();
    // Scan effect lasts for 5 seconds
    _scanTimer = Timer(const Duration(seconds: 5), () {
      _board.clearScannedCells();
      notifyListeners();
    });
  }

  void _stopScanTimer() {
    _scanTimer?.cancel();
    _scanTimer = null;
    _board.clearScannedCells();
  }

  // Check if a cell is currently highlighted by scan
  bool isCellScanned(int row, int col) {
    return _board.isCellScanned(row, col);
  }

  // Update equipped spells
  void updateEquippedSpells(List<SpellType> spells) {
    if (spells.length <= 4) {
      _equippedSpells = spells;
      notifyListeners();
    }
  }

  Cell getCell(int row, int col) {
    return _board.getCell(row, col);
  }

  // Calculate score based on time, difficulty, and spell usage
  int calculateScore() {
    if (!isWon) return 0;

    final baseScore = _difficulty.mines * 100;
    final timeBonus = (_difficulty.totalCells * 10) ~/ (_elapsedSeconds + 1);
    final manaBonus = _mana * 2; // Bonus for remaining mana
    final spellPenalty = _spellHistory.length * 10; // Small penalty for using spells
    
    return (baseScore + timeBonus + manaBonus - spellPenalty).clamp(0, 999999);
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
    _stopScanTimer();
    super.dispose();
  }
}
