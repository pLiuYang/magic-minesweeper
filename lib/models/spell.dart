import 'package:flutter/material.dart';

/// Enum representing all available spell types
enum SpellType {
  reveal,
  scan,
  disarm,
  shield,
  teleport,
  purify,
}

/// Model class representing a spell
class Spell {
  final SpellType type;
  final String name;
  final String description;
  final int manaCost;
  final IconData icon;
  final Color color;
  final bool requiresTarget;
  final int? areaSize; // For area-effect spells

  const Spell({
    required this.type,
    required this.name,
    required this.description,
    required this.manaCost,
    required this.icon,
    required this.color,
    this.requiresTarget = true,
    this.areaSize,
  });

  /// All available spells in the game
  static const List<Spell> allSpells = [
    Spell(
      type: SpellType.reveal,
      name: 'Reveal',
      description: 'Safely reveal one tile without triggering mines',
      manaCost: 10,
      icon: Icons.visibility,
      color: Color(0xFF3B82F6), // Blue
      requiresTarget: true,
    ),
    Spell(
      type: SpellType.scan,
      name: 'Scan',
      description: 'Highlight all mines in a 3×3 area temporarily',
      manaCost: 20,
      icon: Icons.radar,
      color: Color(0xFF22C55E), // Green
      requiresTarget: true,
      areaSize: 3,
    ),
    Spell(
      type: SpellType.disarm,
      name: 'Disarm',
      description: 'Permanently remove a flagged mine from the board',
      manaCost: 30,
      icon: Icons.construction,
      color: Color(0xFFF59E0B), // Amber
      requiresTarget: true,
    ),
    Spell(
      type: SpellType.shield,
      name: 'Shield',
      description: 'Protect yourself from the next mine you reveal',
      manaCost: 40,
      icon: Icons.shield,
      color: Color(0xFF8B5CF6), // Purple
      requiresTarget: false,
    ),
    Spell(
      type: SpellType.teleport,
      name: 'Teleport',
      description: 'Move a mine to a random safe location',
      manaCost: 50,
      icon: Icons.swap_horiz,
      color: Color(0xFFEC4899), // Pink
      requiresTarget: true,
    ),
    Spell(
      type: SpellType.purify,
      name: 'Purify',
      description: 'Safely clear all tiles in a 3×3 area',
      manaCost: 80,
      icon: Icons.auto_fix_high,
      color: Color(0xFFEF4444), // Red
      requiresTarget: true,
      areaSize: 3,
    ),
  ];

  /// Get a spell by its type
  static Spell getSpell(SpellType type) {
    return allSpells.firstWhere((spell) => spell.type == type);
  }

  /// Default spells equipped in the spell bar (4 slots)
  static List<SpellType> get defaultEquippedSpells => [
    SpellType.reveal,
    SpellType.scan,
    SpellType.shield,
    SpellType.purify,
  ];
}

/// Model for tracking spell usage during a game
class SpellUsage {
  final SpellType type;
  final int row;
  final int col;
  final int timestamp;

  const SpellUsage({
    required this.type,
    required this.row,
    required this.col,
    required this.timestamp,
  });
}
