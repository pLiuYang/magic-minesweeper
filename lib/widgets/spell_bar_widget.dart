import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/spell.dart';
import '../providers/game_provider.dart';

class SpellBarWidget extends StatelessWidget {
  const SpellBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1F2937),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFFBBF24), // Gold border for magic feel
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Fixed-height status area
              SizedBox(
                height: 32,
                child: _buildStatusIndicator(gameProvider),
              ),
              const SizedBox(height: 12),
              // Spell buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: gameProvider.equippedSpells.map((spellType) {
                  return _SpellButton(
                    spell: Spell.getSpell(spellType),
                    isSelected: gameProvider.selectedSpell == spellType,
                    canCast: gameProvider.canCastSpell(spellType),
                    currentMana: gameProvider.mana,
                    onTap: () => gameProvider.selectSpell(spellType),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusIndicator(GameProvider gameProvider) {
    // Show spell mode indicator
    if (gameProvider.isSpellMode && gameProvider.selectedSpell != null) {
      final spell = Spell.getSpell(gameProvider.selectedSpell!);
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: spell.color,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.white.withOpacity(0.5),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.touch_app,
              size: 16,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              'TAP TO CAST ${spell.name.toUpperCase()}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => gameProvider.cancelSpellMode(),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Show shield indicator
    if (gameProvider.hasShield) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF8B5CF6), // Purple
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.white.withOpacity(0.5),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.shield,
              size: 16,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            const Text(
              'SHIELD ACTIVE',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      );
    }

    // Default: show hint text
    return Center(
      child: Text(
        'SELECT A SPELL TO CAST',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white.withOpacity(0.5),
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _SpellButton extends StatelessWidget {
  final Spell spell;
  final bool isSelected;
  final bool canCast;
  final int currentMana;
  final VoidCallback onTap;

  const _SpellButton({
    required this.spell,
    required this.isSelected,
    required this.canCast,
    required this.currentMana,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = !canCast;
    final buttonColor = isDisabled ? const Color(0xFF374151) : spell.color;

    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Container(
        width: 72,
        height: 72, // Square buttons
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : buttonColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? buttonColor : Colors.black.withOpacity(0.3),
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? buttonColor.withOpacity(0.6)
                  : Colors.black.withOpacity(0.4),
              offset: isSelected ? const Offset(0, 0) : const Offset(0, 4),
              blurRadius: isSelected ? 12 : 0,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              spell.icon,
              size: 28,
              color: isSelected
                  ? buttonColor
                  : (isDisabled ? Colors.grey.shade600 : Colors.white),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.auto_awesome,
                  size: 10,
                  color: isSelected
                      ? buttonColor
                      : (isDisabled ? Colors.grey.shade600 : Colors.white70),
                ),
                const SizedBox(width: 2),
                Text(
                  '${spell.manaCost}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: isSelected
                        ? buttonColor
                        : (isDisabled ? Colors.grey.shade600 : Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Dialog to show all spells and allow selection
class SpellBookDialog extends StatefulWidget {
  final List<SpellType> currentEquipped;
  final Function(List<SpellType>) onSave;

  const SpellBookDialog({
    super.key,
    required this.currentEquipped,
    required this.onSave,
  });

  @override
  State<SpellBookDialog> createState() => _SpellBookDialogState();
}

class _SpellBookDialogState extends State<SpellBookDialog> {
  late List<SpellType> _selected;

  @override
  void initState() {
    super.initState();
    _selected = List.from(widget.currentEquipped);
  }

  void _toggleSpell(SpellType type) {
    setState(() {
      if (_selected.contains(type)) {
        _selected.remove(type);
      } else if (_selected.length < 4) {
        _selected.add(type);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: const Color(0xFF1F2937),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFFFBBF24), // Gold
            width: 4,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 0,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'SPELL BOOK',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444), // Red
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: Colors.black.withOpacity(0.3), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          offset: const Offset(0, 2),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child:
                        const Icon(Icons.close, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF374151),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.info_outline,
                      size: 16, color: Color(0xFFFBBF24)),
                  const SizedBox(width: 8),
                  Text(
                    'SELECT UP TO 4 SPELLS (${_selected.length}/4)',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFBBF24),
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Spell grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.9,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: Spell.allSpells.length,
              itemBuilder: (context, index) {
                final spell = Spell.allSpells[index];
                final isSelected = _selected.contains(spell.type);

                return GestureDetector(
                  onTap: () => _toggleSpell(spell.type),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected ? spell.color : const Color(0xFF374151),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? Colors.white
                            : Colors.black.withOpacity(0.3),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          offset: isSelected
                              ? const Offset(0, 0)
                              : const Offset(0, 4),
                          blurRadius: isSelected ? 8 : 0,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          spell.icon,
                          size: 24,
                          color:
                              isSelected ? Colors.white : Colors.grey.shade400,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          spell.name.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            color: isSelected
                                ? Colors.white
                                : Colors.grey.shade400,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              size: 8,
                              color: isSelected
                                  ? Colors.white70
                                  : Colors.grey.shade500,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${spell.manaCost}',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Save button
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: _selected.isNotEmpty
                    ? () {
                        widget.onSave(_selected);
                        Navigator.pop(context);
                      }
                    : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: _selected.isNotEmpty
                        ? const Color(0xFF4ADE80)
                        : const Color(0xFF374151),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.black.withOpacity(0.2),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        offset: const Offset(0, 4),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'EQUIP SPELLS',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: _selected.isNotEmpty
                            ? const Color(0xFF064E3B)
                            : Colors.grey.shade600,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
