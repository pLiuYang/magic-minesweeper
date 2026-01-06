import 'package:flutter/material.dart';

/// Leaderboard category types
enum LeaderboardCategory {
  allTime,
  weekly,
  daily,
}

/// Leaderboard game mode filter
enum LeaderboardGameMode {
  all,
  singlePlayer,
  race,
  versus,
  coop,
}

/// Represents a single leaderboard entry
class LeaderboardEntry {
  final String id;
  final String oderId;
  final String playerName;
  final String? avatarAsset;
  final int score;
  final int rank;
  final String difficulty;
  final String gameMode;
  final int timeSeconds;
  final DateTime timestamp;
  final int gamesPlayed;
  final int gamesWon;

  const LeaderboardEntry({
    required this.id,
    required this.oderId,
    required this.playerName,
    this.avatarAsset,
    required this.score,
    required this.rank,
    required this.difficulty,
    required this.gameMode,
    required this.timeSeconds,
    required this.timestamp,
    this.gamesPlayed = 0,
    this.gamesWon = 0,
  });

  /// Get formatted time string
  String get formattedTime {
    final minutes = timeSeconds ~/ 60;
    final seconds = timeSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Get win rate percentage
  double get winRate {
    if (gamesPlayed == 0) return 0.0;
    return (gamesWon / gamesPlayed) * 100;
  }

  /// Get rank badge color
  Color get rankColor {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return Colors.grey;
    }
  }

  /// Get rank badge icon
  IconData get rankIcon {
    switch (rank) {
      case 1:
        return Icons.emoji_events;
      case 2:
        return Icons.workspace_premium;
      case 3:
        return Icons.military_tech;
      default:
        return Icons.tag;
    }
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'oderId': oderId,
      'playerName': playerName,
      'avatarAsset': avatarAsset,
      'score': score,
      'rank': rank,
      'difficulty': difficulty,
      'gameMode': gameMode,
      'timeSeconds': timeSeconds,
      'timestamp': timestamp.toIso8601String(),
      'gamesPlayed': gamesPlayed,
      'gamesWon': gamesWon,
    };
  }

  /// Create from JSON
  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      id: json['id'] as String,
      oderId: json['oderId'] as String,
      playerName: json['playerName'] as String,
      avatarAsset: json['avatarAsset'] as String?,
      score: json['score'] as int,
      rank: json['rank'] as int,
      difficulty: json['difficulty'] as String,
      gameMode: json['gameMode'] as String,
      timeSeconds: json['timeSeconds'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
      gamesPlayed: json['gamesPlayed'] as int? ?? 0,
      gamesWon: json['gamesWon'] as int? ?? 0,
    );
  }

  /// Create a copy with updated rank
  LeaderboardEntry copyWithRank(int newRank) {
    return LeaderboardEntry(
      id: id,
      oderId: oderId,
      playerName: playerName,
      avatarAsset: avatarAsset,
      score: score,
      rank: newRank,
      difficulty: difficulty,
      gameMode: gameMode,
      timeSeconds: timeSeconds,
      timestamp: timestamp,
      gamesPlayed: gamesPlayed,
      gamesWon: gamesWon,
    );
  }
}

/// Leaderboard data container
class Leaderboard {
  final LeaderboardCategory category;
  final LeaderboardGameMode gameMode;
  final String difficulty;
  final List<LeaderboardEntry> entries;
  final DateTime lastUpdated;

  const Leaderboard({
    required this.category,
    required this.gameMode,
    required this.difficulty,
    required this.entries,
    required this.lastUpdated,
  });

  /// Get top N entries
  List<LeaderboardEntry> getTopEntries(int count) {
    return entries.take(count).toList();
  }

  /// Find player's entry
  LeaderboardEntry? findPlayer(String oderId) {
    try {
      return entries.firstWhere((e) => e.oderId == oderId);
    } catch (_) {
      return null;
    }
  }

  /// Get player's rank
  int? getPlayerRank(String oderId) {
    final entry = findPlayer(oderId);
    return entry?.rank;
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'category': category.index,
      'gameMode': gameMode.index,
      'difficulty': difficulty,
      'entries': entries.map((e) => e.toJson()).toList(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  /// Create from JSON
  factory Leaderboard.fromJson(Map<String, dynamic> json) {
    return Leaderboard(
      category: LeaderboardCategory.values[json['category'] as int],
      gameMode: LeaderboardGameMode.values[json['gameMode'] as int],
      difficulty: json['difficulty'] as String,
      entries: (json['entries'] as List)
          .map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }

  /// Create empty leaderboard
  factory Leaderboard.empty({
    LeaderboardCategory category = LeaderboardCategory.allTime,
    LeaderboardGameMode gameMode = LeaderboardGameMode.all,
    String difficulty = 'all',
  }) {
    return Leaderboard(
      category: category,
      gameMode: gameMode,
      difficulty: difficulty,
      entries: [],
      lastUpdated: DateTime.now(),
    );
  }
}

/// Sample leaderboard data for testing
class SampleLeaderboardData {
  static List<LeaderboardEntry> generateSampleEntries() {
    final names = [
      'MineHunter', 'BombDefuser', 'SafeClicker', 'FlagMaster',
      'SpeedRunner', 'CautionKing', 'LuckyGuess', 'ProSweeper',
      'MineWhisperer', 'GridMaster', 'TileBreaker', 'BoomAvoider',
      'PatternPro', 'NumberNinja', 'ClickChamp', 'SweepLord',
      'MineEvader', 'SafeZone', 'FlagPlacer', 'QuickSolver',
    ];

    final entries = <LeaderboardEntry>[];
    final random = DateTime.now().millisecondsSinceEpoch;

    for (int i = 0; i < names.length; i++) {
      final baseScore = 10000 - (i * 400) + ((random + i * 17) % 200);
      final timeBase = 60 + (i * 15) + ((random + i * 13) % 30);
      
      entries.add(LeaderboardEntry(
        id: 'entry_$i',
        oderId: 'player_$i',
        playerName: names[i],
        score: baseScore,
        rank: i + 1,
        difficulty: i % 3 == 0 ? 'hard' : (i % 2 == 0 ? 'medium' : 'easy'),
        gameMode: i % 4 == 0 ? 'versus' : (i % 3 == 0 ? 'race' : 'single'),
        timeSeconds: timeBase,
        timestamp: DateTime.now().subtract(Duration(hours: i * 2)),
        gamesPlayed: 50 + (i * 3),
        gamesWon: 30 + (i * 2),
      ));
    }

    return entries;
  }
}
