import 'package:flutter/material.dart';
import 'player.dart';
import 'game_board.dart';

/// Game mode types for multiplayer
enum MultiplayerMode {
  race,    // Both players race to complete the same board
  versus,  // Head-to-head with competitive spells
  coop,    // Cooperative play on shared board
}

/// Match status
enum MatchStatus {
  waiting,    // Waiting for players
  starting,   // Match is starting (countdown)
  inProgress, // Match is active
  paused,     // Match is paused
  finished,   // Match has ended
  cancelled,  // Match was cancelled
}

/// Represents a multiplayer match
class MultiplayerMatch {
  final String id;
  final MultiplayerMode mode;
  final String difficulty;
  final List<Player> players;
  final Map<String, GameBoard> playerBoards;
  final Map<String, int> playerScores;
  final int seed; // Seed for generating identical boards
  MatchStatus status;
  DateTime? startTime;
  DateTime? endTime;
  int timeLimit; // in seconds, 0 = no limit
  int remainingTime;
  String? winnerId;
  
  MultiplayerMatch({
    required this.id,
    required this.mode,
    required this.difficulty,
    required this.players,
    Map<String, GameBoard>? playerBoards,
    Map<String, int>? playerScores,
    int? seed,
    this.status = MatchStatus.waiting,
    this.startTime,
    this.endTime,
    this.timeLimit = 300, // 5 minutes default
    this.remainingTime = 300,
    this.winnerId,
  }) : 
    playerBoards = playerBoards ?? {},
    playerScores = playerScores ?? {},
    seed = seed ?? DateTime.now().millisecondsSinceEpoch;

  /// Check if match is active
  bool get isActive => status == MatchStatus.inProgress;

  /// Check if match has ended
  bool get isFinished => status == MatchStatus.finished || status == MatchStatus.cancelled;

  /// Get the winner player
  Player? get winner {
    if (winnerId == null) return null;
    return players.firstWhere(
      (p) => p.id == winnerId,
      orElse: () => players.first,
    );
  }

  /// Get match duration in seconds
  int get duration {
    if (startTime == null) return 0;
    final end = endTime ?? DateTime.now();
    return end.difference(startTime!).inSeconds;
  }

  /// Get formatted time remaining
  String get formattedTimeRemaining {
    final minutes = remainingTime ~/ 60;
    final seconds = remainingTime % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Get player's score
  int getPlayerScore(String playerId) {
    return playerScores[playerId] ?? 0;
  }

  /// Update player's score
  void updatePlayerScore(String playerId, int score) {
    playerScores[playerId] = score;
  }

  /// Get player's board
  GameBoard? getPlayerBoard(String playerId) {
    return playerBoards[playerId];
  }

  /// Set player's board
  void setPlayerBoard(String playerId, GameBoard board) {
    playerBoards[playerId] = board;
  }

  /// Start the match
  void start() {
    status = MatchStatus.inProgress;
    startTime = DateTime.now();
    remainingTime = timeLimit;
  }

  /// End the match
  void end({String? winner}) {
    status = MatchStatus.finished;
    endTime = DateTime.now();
    winnerId = winner;
  }

  /// Pause the match
  void pause() {
    if (status == MatchStatus.inProgress) {
      status = MatchStatus.paused;
    }
  }

  /// Resume the match
  void resume() {
    if (status == MatchStatus.paused) {
      status = MatchStatus.inProgress;
    }
  }

  /// Cancel the match
  void cancel() {
    status = MatchStatus.cancelled;
    endTime = DateTime.now();
  }

  /// Tick the timer (call every second)
  bool tick() {
    if (status == MatchStatus.inProgress && timeLimit > 0) {
      remainingTime--;
      if (remainingTime <= 0) {
        return true; // Time's up
      }
    }
    return false;
  }

  /// Determine winner based on scores
  String? determineWinner() {
    if (playerScores.isEmpty) return null;
    
    String? highestScorer;
    int highestScore = -1;
    
    for (final entry in playerScores.entries) {
      if (entry.value > highestScore) {
        highestScore = entry.value;
        highestScorer = entry.key;
      }
    }
    
    return highestScorer;
  }

  /// Create a copy with updated values
  MultiplayerMatch copyWith({
    String? id,
    MultiplayerMode? mode,
    String? difficulty,
    List<Player>? players,
    Map<String, GameBoard>? playerBoards,
    Map<String, int>? playerScores,
    int? seed,
    MatchStatus? status,
    DateTime? startTime,
    DateTime? endTime,
    int? timeLimit,
    int? remainingTime,
    String? winnerId,
  }) {
    return MultiplayerMatch(
      id: id ?? this.id,
      mode: mode ?? this.mode,
      difficulty: difficulty ?? this.difficulty,
      players: players ?? this.players,
      playerBoards: playerBoards ?? this.playerBoards,
      playerScores: playerScores ?? this.playerScores,
      seed: seed ?? this.seed,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      timeLimit: timeLimit ?? this.timeLimit,
      remainingTime: remainingTime ?? this.remainingTime,
      winnerId: winnerId ?? this.winnerId,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mode': mode.index,
      'difficulty': difficulty,
      'players': players.map((p) => p.toJson()).toList(),
      'playerScores': playerScores,
      'seed': seed,
      'status': status.index,
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'timeLimit': timeLimit,
      'remainingTime': remainingTime,
      'winnerId': winnerId,
    };
  }

  /// Create from JSON
  factory MultiplayerMatch.fromJson(Map<String, dynamic> json) {
    return MultiplayerMatch(
      id: json['id'] as String,
      mode: MultiplayerMode.values[json['mode'] as int],
      difficulty: json['difficulty'] as String,
      players: (json['players'] as List)
          .map((p) => Player.fromJson(p as Map<String, dynamic>))
          .toList(),
      playerScores: Map<String, int>.from(json['playerScores'] as Map),
      seed: json['seed'] as int,
      status: MatchStatus.values[json['status'] as int],
      startTime: json['startTime'] != null 
          ? DateTime.parse(json['startTime'] as String) 
          : null,
      endTime: json['endTime'] != null 
          ? DateTime.parse(json['endTime'] as String) 
          : null,
      timeLimit: json['timeLimit'] as int,
      remainingTime: json['remainingTime'] as int,
      winnerId: json['winnerId'] as String?,
    );
  }

  /// Create a new Race mode match
  factory MultiplayerMatch.race({
    required List<Player> players,
    required String difficulty,
    int timeLimit = 300,
  }) {
    return MultiplayerMatch(
      id: 'race_${DateTime.now().millisecondsSinceEpoch}',
      mode: MultiplayerMode.race,
      difficulty: difficulty,
      players: players,
      timeLimit: timeLimit,
      remainingTime: timeLimit,
    );
  }

  /// Create a new Versus mode match
  factory MultiplayerMatch.versus({
    required List<Player> players,
    required String difficulty,
    int timeLimit = 300,
  }) {
    return MultiplayerMatch(
      id: 'versus_${DateTime.now().millisecondsSinceEpoch}',
      mode: MultiplayerMode.versus,
      difficulty: difficulty,
      players: players,
      timeLimit: timeLimit,
      remainingTime: timeLimit,
    );
  }

  /// Create a new Co-op mode match
  factory MultiplayerMatch.coop({
    required List<Player> players,
    required String difficulty,
    int timeLimit = 600, // Longer time for co-op
  }) {
    return MultiplayerMatch(
      id: 'coop_${DateTime.now().millisecondsSinceEpoch}',
      mode: MultiplayerMode.coop,
      difficulty: difficulty,
      players: players,
      timeLimit: timeLimit,
      remainingTime: timeLimit,
    );
  }
}

/// Mode configuration
class MultiplayerModeConfig {
  final MultiplayerMode mode;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final int minPlayers;
  final int maxPlayers;
  final int defaultTimeLimit;

  const MultiplayerModeConfig({
    required this.mode,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    this.minPlayers = 2,
    this.maxPlayers = 2,
    this.defaultTimeLimit = 300,
  });

  static const List<MultiplayerModeConfig> modes = [
    MultiplayerModeConfig(
      mode: MultiplayerMode.race,
      name: 'Race',
      description: 'Race to clear the board first! Same mines, fastest wins.',
      icon: Icons.timer,
      color: Color(0xFF4CAF50),
      defaultTimeLimit: 300,
    ),
    MultiplayerModeConfig(
      mode: MultiplayerMode.versus,
      name: 'Versus',
      description: 'Battle head-to-head! Use spells to sabotage your opponent.',
      icon: Icons.flash_on,
      color: Color(0xFFFF5722),
      defaultTimeLimit: 300,
    ),
    MultiplayerModeConfig(
      mode: MultiplayerMode.coop,
      name: 'Co-op',
      description: 'Work together to clear a larger board!',
      icon: Icons.people,
      color: Color(0xFF2196F3),
      minPlayers: 2,
      maxPlayers: 4,
      defaultTimeLimit: 600,
    ),
  ];

  static MultiplayerModeConfig getConfig(MultiplayerMode mode) {
    return modes.firstWhere((m) => m.mode == mode);
  }
}
