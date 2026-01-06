import 'api_service.dart';

/// Service for managing multiplayer matches
class MatchService {
  static final MatchService _instance = MatchService._internal();
  factory MatchService() => _instance;
  MatchService._internal();

  final ApiService _api = ApiService();

  /// Create a new match
  Future<ApiResponse<MatchData>> createMatch({
    required String mode,
    required String difficulty,
    int maxPlayers = 2,
    int? timeLimit,
  }) async {
    return await _api.mutation<MatchData>(
      'match.create',
      input: {
        'mode': mode,
        'difficulty': difficulty,
        'maxPlayers': maxPlayers,
        if (timeLimit != null) 'timeLimit': timeLimit,
      },
      fromJson: (data) => MatchData.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Join an existing match
  Future<ApiResponse<MatchData>> joinMatch(int matchId) async {
    return await _api.mutation<MatchData>(
      'match.join',
      input: {'matchId': matchId},
      fromJson: (data) => MatchData.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Set ready status
  Future<ApiResponse<bool>> setReady(int matchId, bool ready) async {
    return await _api.mutation<bool>(
      'match.setReady',
      input: {'matchId': matchId, 'ready': ready},
      fromJson: (data) => data as bool,
    );
  }

  /// Get match details
  Future<ApiResponse<MatchDetails>> getMatch(int matchId) async {
    return await _api.query<MatchDetails>(
      'match.get',
      input: {'matchId': matchId},
      fromJson: (data) => MatchDetails.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Get available matches
  Future<ApiResponse<List<AvailableMatch>>> getAvailableMatches({
    String? mode,
    String? difficulty,
  }) async {
    return await _api.query<List<AvailableMatch>>(
      'match.available',
      input: {
        if (mode != null) 'mode': mode,
        if (difficulty != null) 'difficulty': difficulty,
      },
      fromJson: (data) => (data as List)
          .map((e) => AvailableMatch.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Leave a match
  Future<ApiResponse<bool>> leaveMatch(int matchId) async {
    return await _api.mutation<bool>(
      'match.leave',
      input: {'matchId': matchId},
      fromJson: (data) => data as bool,
    );
  }

  /// Complete a match
  Future<ApiResponse<MatchData>> completeMatch({
    required int matchId,
    int? winnerId,
    required int duration,
    required List<ParticipantResult> participantResults,
  }) async {
    return await _api.mutation<MatchData>(
      'match.complete',
      input: {
        'matchId': matchId,
        if (winnerId != null) 'winnerId': winnerId,
        'duration': duration,
        'participantResults': participantResults.map((p) => p.toJson()).toList(),
      },
      fromJson: (data) => MatchData.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Get match history
  Future<ApiResponse<List<MatchHistory>>> getHistory({int limit = 20}) async {
    return await _api.query<List<MatchHistory>>(
      'match.history',
      input: {'limit': limit},
      fromJson: (data) => (data as List)
          .map((e) => MatchHistory.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Match data model
class MatchData {
  final int id;
  final String mode;
  final String difficulty;
  final int maxPlayers;
  final int? timeLimit;
  final String status;
  final int hostUserId;
  final int boardWidth;
  final int boardHeight;
  final int mineCount;
  final String boardSeed;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final int? duration;
  final int? winnerId;

  MatchData({
    required this.id,
    required this.mode,
    required this.difficulty,
    required this.maxPlayers,
    this.timeLimit,
    required this.status,
    required this.hostUserId,
    required this.boardWidth,
    required this.boardHeight,
    required this.mineCount,
    required this.boardSeed,
    this.startedAt,
    this.completedAt,
    this.duration,
    this.winnerId,
  });

  factory MatchData.fromJson(Map<String, dynamic> json) {
    return MatchData(
      id: json['id'] as int,
      mode: json['mode'] as String,
      difficulty: json['difficulty'] as String,
      maxPlayers: json['maxPlayers'] as int? ?? 2,
      timeLimit: json['timeLimit'] as int?,
      status: json['status'] as String,
      hostUserId: json['hostUserId'] as int,
      boardWidth: json['boardWidth'] as int? ?? 16,
      boardHeight: json['boardHeight'] as int? ?? 16,
      mineCount: json['mineCount'] as int? ?? 40,
      boardSeed: json['boardSeed'] as String? ?? '',
      startedAt: json['startedAt'] != null
          ? DateTime.parse(json['startedAt'] as String)
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      duration: json['duration'] as int?,
      winnerId: json['winnerId'] as int?,
    );
  }
}

/// Match details with participants
class MatchDetails {
  final int id;
  final String mode;
  final String difficulty;
  final String status;
  final int maxPlayers;
  final int? timeLimit;
  final String boardSeed;
  final int boardWidth;
  final int boardHeight;
  final int mineCount;
  final List<MatchParticipant> participants;

  MatchDetails({
    required this.id,
    required this.mode,
    required this.difficulty,
    required this.status,
    required this.maxPlayers,
    this.timeLimit,
    required this.boardSeed,
    required this.boardWidth,
    required this.boardHeight,
    required this.mineCount,
    required this.participants,
  });

  factory MatchDetails.fromJson(Map<String, dynamic> json) {
    return MatchDetails(
      id: json['id'] as int,
      mode: json['mode'] as String,
      difficulty: json['difficulty'] as String,
      status: json['status'] as String,
      maxPlayers: json['maxPlayers'] as int? ?? 2,
      timeLimit: json['timeLimit'] as int?,
      boardSeed: json['boardSeed'] as String? ?? '',
      boardWidth: json['boardWidth'] as int? ?? 16,
      boardHeight: json['boardHeight'] as int? ?? 16,
      mineCount: json['mineCount'] as int? ?? 40,
      participants: (json['participants'] as List?)
              ?.map((e) => MatchParticipant.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// Match participant
class MatchParticipant {
  final int id;
  final int userId;
  final String displayName;
  final String? avatarAsset;
  final int rankPoints;
  final bool isReady;
  final bool isConnected;
  final int score;
  final int tilesRevealed;
  final int? completionTime;
  final bool isWinner;
  final bool hitMine;

  MatchParticipant({
    required this.id,
    required this.userId,
    required this.displayName,
    this.avatarAsset,
    required this.rankPoints,
    required this.isReady,
    required this.isConnected,
    required this.score,
    required this.tilesRevealed,
    this.completionTime,
    required this.isWinner,
    required this.hitMine,
  });

  factory MatchParticipant.fromJson(Map<String, dynamic> json) {
    return MatchParticipant(
      id: json['id'] as int,
      userId: json['userId'] as int,
      displayName: json['displayName'] as String? ?? 'Player',
      avatarAsset: json['avatarAsset'] as String?,
      rankPoints: json['rankPoints'] as int? ?? 1000,
      isReady: json['isReady'] as bool? ?? false,
      isConnected: json['isConnected'] as bool? ?? false,
      score: json['score'] as int? ?? 0,
      tilesRevealed: json['tilesRevealed'] as int? ?? 0,
      completionTime: json['completionTime'] as int?,
      isWinner: json['isWinner'] as bool? ?? false,
      hitMine: json['hitMine'] as bool? ?? false,
    );
  }
}

/// Available match for lobby
class AvailableMatch {
  final int id;
  final String mode;
  final String difficulty;
  final int maxPlayers;
  final int currentPlayers;
  final String hostName;
  final int hostRankPoints;
  final DateTime createdAt;

  AvailableMatch({
    required this.id,
    required this.mode,
    required this.difficulty,
    required this.maxPlayers,
    required this.currentPlayers,
    required this.hostName,
    required this.hostRankPoints,
    required this.createdAt,
  });

  factory AvailableMatch.fromJson(Map<String, dynamic> json) {
    return AvailableMatch(
      id: json['id'] as int,
      mode: json['mode'] as String,
      difficulty: json['difficulty'] as String,
      maxPlayers: json['maxPlayers'] as int? ?? 2,
      currentPlayers: json['currentPlayers'] as int? ?? 1,
      hostName: json['hostName'] as String? ?? 'Unknown',
      hostRankPoints: json['hostRankPoints'] as int? ?? 1000,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }
}

/// Match history entry
class MatchHistory {
  final int id;
  final String mode;
  final String difficulty;
  final String status;
  final DateTime? completedAt;
  final int? duration;
  final bool isWinner;
  final int score;
  final int playerCount;

  MatchHistory({
    required this.id,
    required this.mode,
    required this.difficulty,
    required this.status,
    this.completedAt,
    this.duration,
    required this.isWinner,
    required this.score,
    required this.playerCount,
  });

  factory MatchHistory.fromJson(Map<String, dynamic> json) {
    return MatchHistory(
      id: json['id'] as int,
      mode: json['mode'] as String,
      difficulty: json['difficulty'] as String,
      status: json['status'] as String,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      duration: json['duration'] as int?,
      isWinner: json['isWinner'] as bool? ?? false,
      score: json['score'] as int? ?? 0,
      playerCount: json['playerCount'] as int? ?? 2,
    );
  }
}

/// Participant result for match completion
class ParticipantResult {
  final int userId;
  final int score;
  final int tilesRevealed;
  final int flagsPlaced;
  final int manaUsed;
  final int spellsCast;
  final int? completionTime;
  final bool isWinner;
  final bool hitMine;

  ParticipantResult({
    required this.userId,
    required this.score,
    required this.tilesRevealed,
    required this.flagsPlaced,
    required this.manaUsed,
    required this.spellsCast,
    this.completionTime,
    required this.isWinner,
    required this.hitMine,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'score': score,
      'tilesRevealed': tilesRevealed,
      'flagsPlaced': flagsPlaced,
      'manaUsed': manaUsed,
      'spellsCast': spellsCast,
      if (completionTime != null) 'completionTime': completionTime,
      'isWinner': isWinner,
      'hitMine': hitMine,
    };
  }
}
