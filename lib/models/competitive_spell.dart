import 'package:flutter/material.dart';

/// Competitive spells that can affect opponents in Versus mode
enum CompetitiveSpellType {
  curse,      // Disrupts opponent's next move
  minefield,  // Adds temporary fake mines to opponent's view
  manaDrain,  // Steals mana from opponent
  blind,      // Temporarily hides numbers on opponent's board
  freeze,     // Freezes opponent's timer for a few seconds
  scramble,   // Scrambles revealed numbers temporarily
}

/// Represents a competitive spell for versus mode
class CompetitiveSpell {
  final CompetitiveSpellType type;
  final String name;
  final String description;
  final int manaCost;
  final IconData icon;
  final Color color;
  final int duration; // Effect duration in seconds (0 = instant)
  final int cooldown; // Cooldown in seconds
  final bool targetsSelf;
  final bool targetsOpponent;

  const CompetitiveSpell({
    required this.type,
    required this.name,
    required this.description,
    required this.manaCost,
    required this.icon,
    required this.color,
    this.duration = 0,
    this.cooldown = 10,
    this.targetsSelf = false,
    this.targetsOpponent = true,
  });

  /// All available competitive spells
  static const List<CompetitiveSpell> allSpells = [
    CompetitiveSpell(
      type: CompetitiveSpellType.curse,
      name: 'Curse',
      description: 'Disrupts opponent\'s next move - their next click reveals nothing.',
      manaCost: 50,
      icon: Icons.whatshot,
      color: Color(0xFF9C27B0),
      duration: 0,
      cooldown: 15,
    ),
    CompetitiveSpell(
      type: CompetitiveSpellType.minefield,
      name: 'Minefield',
      description: 'Shows 3 fake mine warnings on opponent\'s board for 10 seconds.',
      manaCost: 75,
      icon: Icons.warning_amber,
      color: Color(0xFFFF5722),
      duration: 10,
      cooldown: 20,
    ),
    CompetitiveSpell(
      type: CompetitiveSpellType.manaDrain,
      name: 'Mana Drain',
      description: 'Steal 30 mana from your opponent.',
      manaCost: 60,
      icon: Icons.water_drop,
      color: Color(0xFF2196F3),
      duration: 0,
      cooldown: 25,
    ),
    CompetitiveSpell(
      type: CompetitiveSpellType.blind,
      name: 'Blind',
      description: 'Hides all numbers on opponent\'s board for 5 seconds.',
      manaCost: 80,
      icon: Icons.visibility_off,
      color: Color(0xFF607D8B),
      duration: 5,
      cooldown: 30,
    ),
    CompetitiveSpell(
      type: CompetitiveSpellType.freeze,
      name: 'Freeze',
      description: 'Freezes opponent\'s controls for 3 seconds.',
      manaCost: 90,
      icon: Icons.ac_unit,
      color: Color(0xFF00BCD4),
      duration: 3,
      cooldown: 35,
    ),
    CompetitiveSpell(
      type: CompetitiveSpellType.scramble,
      name: 'Scramble',
      description: 'Randomizes displayed numbers on opponent\'s revealed tiles for 8 seconds.',
      manaCost: 70,
      icon: Icons.shuffle,
      color: Color(0xFFFF9800),
      duration: 8,
      cooldown: 25,
    ),
  ];

  /// Get spell by type
  static CompetitiveSpell getSpell(CompetitiveSpellType type) {
    return allSpells.firstWhere((s) => s.type == type);
  }

  /// Get default versus mode spells (subset for balanced gameplay)
  static List<CompetitiveSpell> get defaultVersusSpells {
    return [
      getSpell(CompetitiveSpellType.curse),
      getSpell(CompetitiveSpellType.minefield),
      getSpell(CompetitiveSpellType.manaDrain),
    ];
  }
}

/// Active spell effect on a player
class ActiveSpellEffect {
  final CompetitiveSpellType spellType;
  final String casterId;
  final String targetId;
  final DateTime startTime;
  final int duration;
  final Map<String, dynamic> effectData;

  ActiveSpellEffect({
    required this.spellType,
    required this.casterId,
    required this.targetId,
    required this.startTime,
    required this.duration,
    this.effectData = const {},
  });

  /// Check if effect is still active
  bool get isActive {
    if (duration == 0) return false; // Instant effects
    final elapsed = DateTime.now().difference(startTime).inSeconds;
    return elapsed < duration;
  }

  /// Get remaining duration in seconds
  int get remainingDuration {
    if (duration == 0) return 0;
    final elapsed = DateTime.now().difference(startTime).inSeconds;
    return (duration - elapsed).clamp(0, duration);
  }

  /// Get effect progress (0.0 to 1.0)
  double get progress {
    if (duration == 0) return 1.0;
    final elapsed = DateTime.now().difference(startTime).inSeconds;
    return (elapsed / duration).clamp(0.0, 1.0);
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'spellType': spellType.index,
      'casterId': casterId,
      'targetId': targetId,
      'startTime': startTime.toIso8601String(),
      'duration': duration,
      'effectData': effectData,
    };
  }

  /// Create from JSON
  factory ActiveSpellEffect.fromJson(Map<String, dynamic> json) {
    return ActiveSpellEffect(
      spellType: CompetitiveSpellType.values[json['spellType'] as int],
      casterId: json['casterId'] as String,
      targetId: json['targetId'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      duration: json['duration'] as int,
      effectData: json['effectData'] as Map<String, dynamic>? ?? {},
    );
  }
}

/// Spell cooldown tracker
class SpellCooldownTracker {
  final Map<CompetitiveSpellType, DateTime> _lastCastTimes = {};

  /// Record spell cast
  void recordCast(CompetitiveSpellType spellType) {
    _lastCastTimes[spellType] = DateTime.now();
  }

  /// Check if spell is on cooldown
  bool isOnCooldown(CompetitiveSpell spell) {
    final lastCast = _lastCastTimes[spell.type];
    if (lastCast == null) return false;
    
    final elapsed = DateTime.now().difference(lastCast).inSeconds;
    return elapsed < spell.cooldown;
  }

  /// Get remaining cooldown in seconds
  int getRemainingCooldown(CompetitiveSpell spell) {
    final lastCast = _lastCastTimes[spell.type];
    if (lastCast == null) return 0;
    
    final elapsed = DateTime.now().difference(lastCast).inSeconds;
    return (spell.cooldown - elapsed).clamp(0, spell.cooldown);
  }

  /// Get cooldown progress (0.0 = ready, 1.0 = just cast)
  double getCooldownProgress(CompetitiveSpell spell) {
    final remaining = getRemainingCooldown(spell);
    if (remaining == 0) return 0.0;
    return remaining / spell.cooldown;
  }

  /// Reset all cooldowns
  void reset() {
    _lastCastTimes.clear();
  }
}
