import '../utils/constants.dart';

class GameSettings {
  bool soundEnabled;
  bool vibrationEnabled;
  DifficultyConfig currentDifficulty;
  Map<String, int> bestTimes; // difficulty name -> best time in seconds

  GameSettings({
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    DifficultyConfig? currentDifficulty,
    Map<String, int>? bestTimes,
  })  : currentDifficulty = currentDifficulty ?? GameConstants.beginner,
        bestTimes = bestTimes ?? {};

  int? getBestTime(String difficulty) {
    return bestTimes[difficulty];
  }

  void updateBestTime(String difficulty, int time) {
    final current = bestTimes[difficulty];
    if (current == null || time < current) {
      bestTimes[difficulty] = time;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'currentDifficulty': currentDifficulty.name,
      'bestTimes': bestTimes,
    };
  }

  factory GameSettings.fromJson(Map<String, dynamic> json) {
    final difficultyName = json['currentDifficulty'] as String?;
    DifficultyConfig difficulty = GameConstants.beginner;

    if (difficultyName != null) {
      difficulty = GameConstants.difficulties.firstWhere(
        (d) => d.name == difficultyName,
        orElse: () => GameConstants.beginner,
      );
    }

    return GameSettings(
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
      currentDifficulty: difficulty,
      bestTimes: Map<String, int>.from(json['bestTimes'] as Map? ?? {}),
    );
  }

  GameSettings copyWith({
    bool? soundEnabled,
    bool? vibrationEnabled,
    DifficultyConfig? currentDifficulty,
    Map<String, int>? bestTimes,
  }) {
    return GameSettings(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      currentDifficulty: currentDifficulty ?? this.currentDifficulty,
      bestTimes: bestTimes ?? Map.from(this.bestTimes),
    );
  }
}

class GameStats {
  int gamesPlayed;
  int gamesWon;
  int totalTimePlayed; // in seconds
  int currentStreak;
  int bestStreak;

  GameStats({
    this.gamesPlayed = 0,
    this.gamesWon = 0,
    this.totalTimePlayed = 0,
    this.currentStreak = 0,
    this.bestStreak = 0,
  });

  double get winRate => gamesPlayed > 0 ? gamesWon / gamesPlayed : 0;

  void recordGame(bool won, int timePlayed) {
    gamesPlayed++;
    totalTimePlayed += timePlayed;

    if (won) {
      gamesWon++;
      currentStreak++;
      if (currentStreak > bestStreak) {
        bestStreak = currentStreak;
      }
    } else {
      currentStreak = 0;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'gamesPlayed': gamesPlayed,
      'gamesWon': gamesWon,
      'totalTimePlayed': totalTimePlayed,
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
    };
  }

  factory GameStats.fromJson(Map<String, dynamic> json) {
    return GameStats(
      gamesPlayed: json['gamesPlayed'] as int? ?? 0,
      gamesWon: json['gamesWon'] as int? ?? 0,
      totalTimePlayed: json['totalTimePlayed'] as int? ?? 0,
      currentStreak: json['currentStreak'] as int? ?? 0,
      bestStreak: json['bestStreak'] as int? ?? 0,
    );
  }
}
