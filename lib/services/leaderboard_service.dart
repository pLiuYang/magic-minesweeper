import 'api_service.dart';

/// Service for leaderboard operations
class LeaderboardService {
  static final LeaderboardService _instance = LeaderboardService._internal();
  factory LeaderboardService() => _instance;
  LeaderboardService._internal();

  final ApiService _api = ApiService();

  /// Get leaderboard entries
  Future<ApiResponse<List<LeaderboardEntry>>> getLeaderboard({
    String? gameMode,
    String? difficulty,
    String category = 'allTime',
    int limit = 50,
  }) async {
    return await _api.query<List<LeaderboardEntry>>(
      'leaderboard.get',
      input: {
        if (gameMode != null) 'gameMode': gameMode,
        if (difficulty != null) 'difficulty': difficulty,
        'category': category,
        'limit': limit,
      },
      fromJson: (data) => (data as List)
          .map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Get player's rank
  Future<ApiResponse<PlayerRank>> getMyRank({
    String? gameMode,
    String category = 'allTime',
  }) async {
    return await _api.query<PlayerRank>(
      'leaderboard.myRank',
      input: {
        if (gameMode != null) 'gameMode': gameMode,
        'category': category,
      },
      fromJson: (data) => PlayerRank.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Submit a single-player score
  Future<ApiResponse<LeaderboardEntry>> submitScore({
    required int score,
    required int completionTime,
    required String difficulty,
    required int tilesRevealed,
    required int flagsPlaced,
    required int spellsCast,
  }) async {
    return await _api.mutation<LeaderboardEntry>(
      'leaderboard.submitScore',
      input: {
        'score': score,
        'completionTime': completionTime,
        'difficulty': difficulty,
        'tilesRevealed': tilesRevealed,
        'flagsPlaced': flagsPlaced,
        'spellsCast': spellsCast,
      },
      fromJson: (data) => LeaderboardEntry.fromJson(data as Map<String, dynamic>),
    );
  }
}

/// Leaderboard entry model
class LeaderboardEntry {
  final int id;
  final int userId;
  final String playerName;
  final int rank;
  final int score;
  final int? completionTime;
  final String gameMode;
  final String difficulty;
  final DateTime createdAt;

  LeaderboardEntry({
    required this.id,
    required this.userId,
    required this.playerName,
    required this.rank,
    required this.score,
    this.completionTime,
    required this.gameMode,
    required this.difficulty,
    required this.createdAt,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      id: json['id'] as int,
      userId: json['userId'] as int,
      playerName: json['playerName'] as String? ?? 'Unknown',
      rank: json['rank'] as int? ?? 0,
      score: json['score'] as int? ?? 0,
      completionTime: json['completionTime'] as int?,
      gameMode: json['gameMode'] as String? ?? 'single',
      difficulty: json['difficulty'] as String? ?? 'medium',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  /// Format completion time as mm:ss
  String get formattedTime {
    if (completionTime == null) return '--:--';
    final minutes = completionTime! ~/ 60;
    final seconds = completionTime! % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

/// Player rank model
class PlayerRank {
  final int rank;
  final int totalPlayers;
  final int score;
  final double percentile;

  PlayerRank({
    required this.rank,
    required this.totalPlayers,
    required this.score,
    required this.percentile,
  });

  factory PlayerRank.fromJson(Map<String, dynamic> json) {
    return PlayerRank(
      rank: json['rank'] as int? ?? 0,
      totalPlayers: json['totalPlayers'] as int? ?? 0,
      score: json['score'] as int? ?? 0,
      percentile: (json['percentile'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
