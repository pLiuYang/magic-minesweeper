import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/multiplayer_match.dart';
import '../models/competitive_spell.dart';
import '../models/game_board.dart';
import '../models/leaderboard_entry.dart';

/// Provider for managing multiplayer game state
class MultiplayerProvider extends ChangeNotifier {
  // Current player
  Player _currentPlayer = Player.player1();
  Player get currentPlayer => _currentPlayer;

  // Current match
  MultiplayerMatch? _currentMatch;
  MultiplayerMatch? get currentMatch => _currentMatch;

  // Match timer
  Timer? _matchTimer;

  // AI opponent timer (for simulated multiplayer)
  Timer? _aiTimer;

  // Active spell effects
  final List<ActiveSpellEffect> _activeEffects = [];
  List<ActiveSpellEffect> get activeEffects => List.unmodifiable(_activeEffects);

  // Spell cooldown tracker
  final SpellCooldownTracker _cooldownTracker = SpellCooldownTracker();
  SpellCooldownTracker get cooldownTracker => _cooldownTracker;

  // Leaderboard data
  List<LeaderboardEntry> _leaderboardEntries = [];
  List<LeaderboardEntry> get leaderboardEntries => _leaderboardEntries;

  // Match history
  final List<MultiplayerMatch> _matchHistory = [];
  List<MultiplayerMatch> get matchHistory => List.unmodifiable(_matchHistory);

  // Connection status (for future online play)
  bool _isConnected = false;
  bool get isConnected => _isConnected;

  // Searching for match
  bool _isSearching = false;
  bool get isSearching => _isSearching;

  MultiplayerProvider() {
    _loadLeaderboard();
  }

  /// Set current player
  void setCurrentPlayer(Player player) {
    _currentPlayer = player;
    notifyListeners();
  }

  /// Update current player name
  void updatePlayerName(String name) {
    _currentPlayer = _currentPlayer.copyWith(name: name);
    notifyListeners();
  }

  /// Create a new match
  Future<MultiplayerMatch> createMatch({
    required MultiplayerMode mode,
    required String difficulty,
    int? timeLimit,
  }) async {
    // Create opponent (AI for local play)
    final opponent = Player.player2();

    // Create match based on mode
    MultiplayerMatch match;
    switch (mode) {
      case MultiplayerMode.race:
        match = MultiplayerMatch.race(
          players: [_currentPlayer, opponent],
          difficulty: difficulty,
          timeLimit: timeLimit ?? 300,
        );
        break;
      case MultiplayerMode.versus:
        match = MultiplayerMatch.versus(
          players: [_currentPlayer, opponent],
          difficulty: difficulty,
          timeLimit: timeLimit ?? 300,
        );
        break;
      case MultiplayerMode.coop:
        match = MultiplayerMatch.coop(
          players: [_currentPlayer, opponent],
          difficulty: difficulty,
          timeLimit: timeLimit ?? 600,
        );
        break;
    }

    _currentMatch = match;
    notifyListeners();
    return match;
  }

  /// Start the current match
  void startMatch() {
    if (_currentMatch == null) return;

    _currentMatch!.start();
    _cooldownTracker.reset();
    _activeEffects.clear();

    // Initialize player scores
    for (final player in _currentMatch!.players) {
      _currentMatch!.updatePlayerScore(player.id, 0);
    }

    // Start match timer
    _startMatchTimer();

    // Start AI opponent simulation if needed
    if (_currentMatch!.mode != MultiplayerMode.coop) {
      _startAISimulation();
    }

    notifyListeners();
  }

  /// Start match timer
  void _startMatchTimer() {
    _matchTimer?.cancel();
    _matchTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentMatch == null || !_currentMatch!.isActive) {
        timer.cancel();
        return;
      }

      final timeUp = _currentMatch!.tick();
      if (timeUp) {
        _endMatchByTimeout();
      }

      // Update active effects
      _updateActiveEffects();

      notifyListeners();
    });
  }

  /// Start AI simulation for opponent
  void _startAISimulation() {
    _aiTimer?.cancel();
    
    // AI makes progress at random intervals
    _aiTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (_currentMatch == null || !_currentMatch!.isActive) {
        timer.cancel();
        return;
      }

      // Simulate AI progress
      _simulateAIProgress();
    });
  }

  /// Simulate AI opponent progress
  void _simulateAIProgress() {
    if (_currentMatch == null) return;

    final opponent = _currentMatch!.players.firstWhere(
      (p) => p.id != _currentPlayer.id,
      orElse: () => _currentMatch!.players.last,
    );

    // Random chance to make progress
    final random = Random();
    if (random.nextDouble() < 0.3) {
      final currentScore = _currentMatch!.getPlayerScore(opponent.id);
      final scoreIncrease = random.nextInt(50) + 10;
      _currentMatch!.updatePlayerScore(opponent.id, currentScore + scoreIncrease);

      // Random chance to gain mana
      if (random.nextDouble() < 0.2) {
        opponent.mana = (opponent.mana + random.nextInt(10) + 5).clamp(0, opponent.maxMana);
      }

      // Random chance for AI to cast spell in versus mode
      if (_currentMatch!.mode == MultiplayerMode.versus && random.nextDouble() < 0.05) {
        _simulateAISpellCast(opponent);
      }

      notifyListeners();
    }
  }

  /// Simulate AI casting a spell
  void _simulateAISpellCast(Player aiPlayer) {
    final availableSpells = CompetitiveSpell.defaultVersusSpells
        .where((s) => aiPlayer.mana >= s.manaCost && !_cooldownTracker.isOnCooldown(s))
        .toList();

    if (availableSpells.isEmpty) return;

    final random = Random();
    final spell = availableSpells[random.nextInt(availableSpells.length)];

    // Cast spell on current player
    _applySpellEffect(spell, aiPlayer.id, _currentPlayer.id);
    aiPlayer.mana -= spell.manaCost;
  }

  /// Update player score
  void updatePlayerScore(String oderId, int score) {
    if (_currentMatch == null) return;
    _currentMatch!.updatePlayerScore(oderId, score);
    notifyListeners();
  }

  /// Add score to player
  void addScore(String oderId, int points) {
    if (_currentMatch == null) return;
    final currentScore = _currentMatch!.getPlayerScore(oderId);
    _currentMatch!.updatePlayerScore(oderId, currentScore + points);
    notifyListeners();
  }

  /// Cast a competitive spell
  bool castCompetitiveSpell(CompetitiveSpell spell, String targetId) {
    if (_currentMatch == null || !_currentMatch!.isActive) return false;
    if (_currentPlayer.mana < spell.manaCost) return false;
    if (_cooldownTracker.isOnCooldown(spell)) return false;

    // Deduct mana
    _currentPlayer.mana -= spell.manaCost;

    // Record cooldown
    _cooldownTracker.recordCast(spell.type);

    // Apply effect
    _applySpellEffect(spell, _currentPlayer.id, targetId);

    notifyListeners();
    return true;
  }

  /// Apply spell effect
  void _applySpellEffect(CompetitiveSpell spell, String casterId, String targetId) {
    final effect = ActiveSpellEffect(
      spellType: spell.type,
      casterId: casterId,
      targetId: targetId,
      startTime: DateTime.now(),
      duration: spell.duration,
      effectData: _generateEffectData(spell),
    );

    _activeEffects.add(effect);

    // Handle instant effects
    if (spell.duration == 0) {
      _processInstantEffect(effect);
    }

    notifyListeners();
  }

  /// Generate effect-specific data
  Map<String, dynamic> _generateEffectData(CompetitiveSpell spell) {
    final random = Random();
    switch (spell.type) {
      case CompetitiveSpellType.minefield:
        // Generate fake mine positions
        return {
          'fakeMines': List.generate(3, (_) => {
            'row': random.nextInt(10),
            'col': random.nextInt(10),
          }),
        };
      case CompetitiveSpellType.scramble:
        // Generate number mappings
        return {
          'numberMap': {
            for (int i = 1; i <= 8; i++)
              i.toString(): (random.nextInt(8) + 1),
          },
        };
      default:
        return {};
    }
  }

  /// Process instant spell effects
  void _processInstantEffect(ActiveSpellEffect effect) {
    switch (effect.spellType) {
      case CompetitiveSpellType.curse:
        // Mark next click as cursed (handled in game logic)
        break;
      case CompetitiveSpellType.manaDrain:
        // Transfer mana
        final target = _currentMatch?.players.firstWhere(
          (p) => p.id == effect.targetId,
          orElse: () => _currentPlayer,
        );
        if (target != null && target.id != _currentPlayer.id) {
          final drainAmount = 30.clamp(0, target.mana);
          target.mana -= drainAmount;
          _currentPlayer.mana = (_currentPlayer.mana + drainAmount).clamp(0, _currentPlayer.maxMana);
        }
        break;
      default:
        break;
    }
  }

  /// Update active effects (remove expired ones)
  void _updateActiveEffects() {
    _activeEffects.removeWhere((effect) => !effect.isActive && effect.duration > 0);
  }

  /// Check if player has active effect
  bool hasActiveEffect(String oderId, CompetitiveSpellType type) {
    return _activeEffects.any(
      (e) => e.targetId == oderId && e.spellType == type && e.isActive,
    );
  }

  /// Get active effect for player
  ActiveSpellEffect? getActiveEffect(String oderId, CompetitiveSpellType type) {
    try {
      return _activeEffects.firstWhere(
        (e) => e.targetId == oderId && e.spellType == type && e.isActive,
      );
    } catch (_) {
      return null;
    }
  }

  /// End match by timeout
  void _endMatchByTimeout() {
    if (_currentMatch == null) return;

    final winnerId = _currentMatch!.determineWinner();
    endMatch(winnerId: winnerId);
  }

  /// End the current match
  void endMatch({String? winnerId, bool completed = false}) {
    if (_currentMatch == null) return;

    _matchTimer?.cancel();
    _aiTimer?.cancel();

    // Determine winner if not provided
    final finalWinnerId = winnerId ?? _currentMatch!.determineWinner();
    _currentMatch!.end(winner: finalWinnerId);

    // Update player stats
    _updatePlayerStats(finalWinnerId);

    // Add to history
    _matchHistory.add(_currentMatch!);

    // Update leaderboard
    _updateLeaderboard();

    notifyListeners();
  }

  /// Update player statistics after match
  void _updatePlayerStats(String? winnerId) {
    _currentPlayer.gamesPlayed++;
    if (winnerId == _currentPlayer.id) {
      _currentPlayer.gamesWon++;
    }
    _currentPlayer.totalScore += _currentMatch!.getPlayerScore(_currentPlayer.id);
    _currentPlayer.lastPlayed = DateTime.now();
  }

  /// Cancel current match
  void cancelMatch() {
    _matchTimer?.cancel();
    _aiTimer?.cancel();
    _currentMatch?.cancel();
    _currentMatch = null;
    _activeEffects.clear();
    notifyListeners();
  }

  /// Start searching for online match (placeholder for future)
  Future<void> startMatchmaking(MultiplayerMode mode, String difficulty) async {
    _isSearching = true;
    notifyListeners();

    // Simulate matchmaking delay
    await Future.delayed(const Duration(seconds: 2));

    // Create local match for now
    await createMatch(mode: mode, difficulty: difficulty);

    _isSearching = false;
    notifyListeners();
  }

  /// Cancel matchmaking
  void cancelMatchmaking() {
    _isSearching = false;
    notifyListeners();
  }

  /// Load leaderboard data
  void _loadLeaderboard() {
    // Load sample data for now
    _leaderboardEntries = SampleLeaderboardData.generateSampleEntries();
    notifyListeners();
  }

  /// Update leaderboard with current match result
  void _updateLeaderboard() {
    if (_currentMatch == null) return;

    final score = _currentMatch!.getPlayerScore(_currentPlayer.id);
    final entry = LeaderboardEntry(
      id: 'entry_${DateTime.now().millisecondsSinceEpoch}',
      playerId: _currentPlayer.id,
      playerName: _currentPlayer.name,
      avatarAsset: _currentPlayer.avatarAsset,
      score: score,
      rank: 0, // Will be calculated
      difficulty: _currentMatch!.difficulty,
      gameMode: _currentMatch!.mode.name,
      timeSeconds: _currentMatch!.duration,
      timestamp: DateTime.now(),
      gamesPlayed: _currentPlayer.gamesPlayed,
      gamesWon: _currentPlayer.gamesWon,
    );

    // Add to leaderboard and sort
    _leaderboardEntries.add(entry);
    _leaderboardEntries.sort((a, b) => b.score.compareTo(a.score));

    // Update ranks
    for (int i = 0; i < _leaderboardEntries.length; i++) {
      _leaderboardEntries[i] = _leaderboardEntries[i].copyWithRank(i + 1);
    }

    notifyListeners();
  }

  /// Get filtered leaderboard
  List<LeaderboardEntry> getFilteredLeaderboard({
    LeaderboardCategory? category,
    LeaderboardGameMode? gameMode,
    String? difficulty,
  }) {
    var filtered = _leaderboardEntries;

    if (gameMode != null && gameMode != LeaderboardGameMode.all) {
      filtered = filtered.where((e) {
        switch (gameMode) {
          case LeaderboardGameMode.singlePlayer:
            return e.gameMode == 'single';
          case LeaderboardGameMode.race:
            return e.gameMode == 'race';
          case LeaderboardGameMode.versus:
            return e.gameMode == 'versus';
          case LeaderboardGameMode.coop:
            return e.gameMode == 'coop';
          default:
            return true;
        }
      }).toList();
    }

    if (difficulty != null && difficulty != 'all') {
      filtered = filtered.where((e) => e.difficulty == difficulty).toList();
    }

    if (category != null) {
      final now = DateTime.now();
      switch (category) {
        case LeaderboardCategory.daily:
          filtered = filtered.where((e) => 
            e.timestamp.isAfter(now.subtract(const Duration(days: 1)))
          ).toList();
          break;
        case LeaderboardCategory.weekly:
          filtered = filtered.where((e) => 
            e.timestamp.isAfter(now.subtract(const Duration(days: 7)))
          ).toList();
          break;
        case LeaderboardCategory.allTime:
          // No filter needed
          break;
      }
    }

    // Re-rank filtered results
    for (int i = 0; i < filtered.length; i++) {
      filtered[i] = filtered[i].copyWithRank(i + 1);
    }

    return filtered;
  }

  /// Get player's rank in leaderboard
  int? getPlayerRank() {
    final entry = _leaderboardEntries.firstWhere(
      (e) => e.playerId == _currentPlayer.id,
      orElse: () => LeaderboardEntry(
        id: '',
        playerId: '',
        playerName: '',
        score: 0,
        rank: -1,
        difficulty: '',
        gameMode: '',
        timeSeconds: 0,
        timestamp: DateTime.now(),
      ),
    );
    return entry.rank > 0 ? entry.rank : null;
  }

  @override
  void dispose() {
    _matchTimer?.cancel();
    _aiTimer?.cancel();
    super.dispose();
  }
}
