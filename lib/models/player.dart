import 'package:flutter/material.dart';

/// Represents a player in the game
class Player {
  final String id;
  final String name;
  final String avatarAsset;
  final Color primaryColor;
  int score;
  int mana;
  int maxMana;
  int gamesPlayed;
  int gamesWon;
  int totalScore;
  DateTime? lastPlayed;

  Player({
    required this.id,
    required this.name,
    this.avatarAsset = 'assets/images/avatar_default.png',
    this.primaryColor = Colors.blue,
    this.score = 0,
    this.mana = 0,
    this.maxMana = 100,
    this.gamesPlayed = 0,
    this.gamesWon = 0,
    this.totalScore = 0,
    this.lastPlayed,
  });

  /// Create a copy of the player with updated values
  Player copyWith({
    String? id,
    String? name,
    String? avatarAsset,
    Color? primaryColor,
    int? score,
    int? mana,
    int? maxMana,
    int? gamesPlayed,
    int? gamesWon,
    int? totalScore,
    DateTime? lastPlayed,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarAsset: avatarAsset ?? this.avatarAsset,
      primaryColor: primaryColor ?? this.primaryColor,
      score: score ?? this.score,
      mana: mana ?? this.mana,
      maxMana: maxMana ?? this.maxMana,
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      gamesWon: gamesWon ?? this.gamesWon,
      totalScore: totalScore ?? this.totalScore,
      lastPlayed: lastPlayed ?? this.lastPlayed,
    );
  }

  /// Calculate win rate percentage
  double get winRate {
    if (gamesPlayed == 0) return 0.0;
    return (gamesWon / gamesPlayed) * 100;
  }

  /// Calculate mana percentage
  double get manaPercentage => maxMana > 0 ? (mana / maxMana) * 100 : 0;

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatarAsset': avatarAsset,
      'primaryColor': primaryColor.value,
      'score': score,
      'mana': mana,
      'maxMana': maxMana,
      'gamesPlayed': gamesPlayed,
      'gamesWon': gamesWon,
      'totalScore': totalScore,
      'lastPlayed': lastPlayed?.toIso8601String(),
    };
  }

  /// Create from JSON (supports both local and backend format)
  factory Player.fromJson(Map<String, dynamic> json) {
    // Handle backend format (uses 'id' as int and 'openId' as string)
    final idValue = json['openId'] ?? json['id'];
    final id = idValue is int ? idValue.toString() : idValue as String;
    
    return Player(
      id: id,
      name: json['name'] as String? ?? json['displayName'] as String? ?? 'Player',
      avatarAsset: json['avatarAsset'] as String? ?? 'assets/images/avatar_default.png',
      primaryColor: json['primaryColor'] != null 
          ? Color(json['primaryColor'] as int) 
          : Colors.blue,
      score: json['score'] as int? ?? 0,
      mana: json['mana'] as int? ?? 0,
      maxMana: json['maxMana'] as int? ?? 100,
      gamesPlayed: json['gamesPlayed'] as int? ?? 0,
      gamesWon: json['gamesWon'] as int? ?? 0,
      totalScore: json['totalScore'] as int? ?? 0,
      lastPlayed: json['lastPlayed'] != null 
          ? DateTime.parse(json['lastPlayed'] as String) 
          : json['lastSignedIn'] != null
              ? DateTime.parse(json['lastSignedIn'] as String)
              : null,
    );
  }

  /// Create a guest player
  factory Player.guest() {
    return Player(
      id: 'guest_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Guest',
      primaryColor: Colors.blue,
    );
  }

  /// Create Player 1 (default local player)
  factory Player.player1() {
    return Player(
      id: 'player1',
      name: 'Player 1',
      avatarAsset: 'assets/images/avatar_wizard.png',
      primaryColor: Colors.blue,
    );
  }

  /// Create Player 2 (opponent)
  factory Player.player2() {
    return Player(
      id: 'player2',
      name: 'Player 2',
      avatarAsset: 'assets/images/avatar_rogue.png',
      primaryColor: Colors.red,
    );
  }

  /// Create an AI opponent
  factory Player.ai({String difficulty = 'medium'}) {
    return Player(
      id: 'ai_$difficulty',
      name: 'AI ($difficulty)',
      avatarAsset: 'assets/images/avatar_ai.png',
      primaryColor: Colors.purple,
    );
  }
}

/// Player avatar options
class PlayerAvatar {
  final String id;
  final String name;
  final String asset;
  final bool isUnlocked;

  const PlayerAvatar({
    required this.id,
    required this.name,
    required this.asset,
    this.isUnlocked = true,
  });

  static const List<PlayerAvatar> defaultAvatars = [
    PlayerAvatar(
      id: 'wizard',
      name: 'Wizard',
      asset: 'assets/images/avatar_wizard.png',
    ),
    PlayerAvatar(
      id: 'rogue',
      name: 'Rogue',
      asset: 'assets/images/avatar_rogue.png',
    ),
    PlayerAvatar(
      id: 'knight',
      name: 'Knight',
      asset: 'assets/images/avatar_knight.png',
    ),
    PlayerAvatar(
      id: 'mage',
      name: 'Mage',
      asset: 'assets/images/avatar_mage.png',
    ),
  ];
}
