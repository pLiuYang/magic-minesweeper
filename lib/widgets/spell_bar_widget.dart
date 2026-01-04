import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/spell.dart';
import '../providers/game_provider.dart';
import '../utils/constants.dart';

class SpellBarWidget extends StatelessWidget {
  const SpellBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Spell mode indicator
              if (gameProvider.isSpellMode)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primaryPurple.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.touch_app,
                        size: 16,
                        color: AppColors.primaryPurple,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Tap a cell to cast ${Spell.getSpell(gameProvider.selectedSpell!).name}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primaryPurple,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => gameProvider.cancelSpellMode(),
                        child: Icon(
                          Icons.close,
                          size: 16,
                          color: AppColors.primaryPurple,
                        ),
                      ),
                    ],
                  ),
                ),
              
              // Shield indicator
              if (gameProvider.hasShield)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.purple.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.shield,
                        size: 16,
                        color: Colors.purple,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Shield Active',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ),
                ),
              
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
    
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 72,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? spell.color.withOpacity(0.2)
              : isDisabled
                  ? Colors.grey.shade100
                  : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? spell.color
                : isDisabled
                    ? Colors.grey.shade300
                    : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: spell.color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isDisabled
                    ? Colors.grey.shade300
                    : spell.color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                spell.icon,
                size: 20,
                color: isDisabled ? Colors.grey.shade500 : spell.color,
              ),
            ),
            const SizedBox(height: 4),
            // Name
            Text(
              spell.name,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isDisabled ? Colors.grey.shade500 : Colors.black87,
              ),
            ),
            const SizedBox(height: 2),
            // Mana cost
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.water_drop,
                  size: 10,
                  color: isDisabled
                      ? Colors.grey.shade400
                      : canCast
                          ? AppColors.primaryBlue
                          : Colors.orange,
                ),
                const SizedBox(width: 2),
                Text(
                  '${spell.manaCost}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: isDisabled
                        ? Colors.grey.shade400
                        : canCast
                            ? AppColors.primaryBlue
                            : Colors.orange,
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Spell Book',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Select up to 4 spells (${_selected.length}/4)',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),
            
            // Spell grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.85,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: Spell.allSpells.length,
              itemBuilder: (context, index) {
                final spell = Spell.allSpells[index];
                final isSelected = _selected.contains(spell.type);
                
                return _SpellBookItem(
                  spell: spell,
                  isSelected: isSelected,
                  onTap: () => _toggleSpell(spell.type),
                );
              },
            ),
            
            const SizedBox(height: 20),
            
            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selected.isNotEmpty
                    ? () {
                        widget.onSave(_selected);
                        Navigator.pop(context);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save Selection',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
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

class _SpellBookItem extends StatelessWidget {
  final Spell spell;
  final bool isSelected;
  final VoidCallback onTap;

  const _SpellBookItem({
    required this.spell,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected
              ? spell.color.withOpacity(0.15)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? spell.color : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with checkmark
            Stack(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: spell.color.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    spell.icon,
                    size: 22,
                    color: spell.color,
                  ),
                ),
                if (isSelected)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: spell.color,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 10,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            // Name
            Text(
              spell.name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? spell.color : Colors.black87,
              ),
            ),
            const SizedBox(height: 2),
            // Mana cost
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.water_drop,
                  size: 10,
                  color: AppColors.primaryBlue,
                ),
                const SizedBox(width: 2),
                Text(
                  '${spell.manaCost} MP',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
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
