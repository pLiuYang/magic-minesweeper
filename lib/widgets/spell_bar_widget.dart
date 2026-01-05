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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primaryPurple.withOpacity(0.15),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryPurple.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Fixed-height status area to prevent layout shifts
              SizedBox(
                height: 28,
                child: _buildStatusIndicator(gameProvider),
              ),
              const SizedBox(height: 8),
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              spell.color.withOpacity(0.15),
              AppColors.primaryPurple.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: spell.color.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.touch_app_rounded,
              size: 14,
              color: spell.color,
            ),
            const SizedBox(width: 6),
            Text(
              'Tap to cast ${spell.name}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: spell.color,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => gameProvider.cancelSpellMode(),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: spell.color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close_rounded,
                  size: 12,
                  color: spell.color,
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.magicPurple.withOpacity(0.15),
              AppColors.primaryPink.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.magicPurple.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shield_rounded,
              size: 14,
              color: AppColors.magicPurple,
            ),
            const SizedBox(width: 6),
            Text(
              'Shield Active',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.magicPurple,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.auto_awesome,
              size: 12,
              color: AppColors.sparkleGold,
            ),
          ],
        ),
      );
    }
    
    // Default: show hint text
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryPurple.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.auto_awesome_rounded,
            size: 14,
            color: AppColors.primaryPurple.withOpacity(0.5),
          ),
          const SizedBox(width: 6),
          Text(
            'Select a spell to cast',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryPurple.withOpacity(0.5),
            ),
          ),
        ],
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
    
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 74,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    spell.color.withOpacity(0.2),
                    spell.color.withOpacity(0.1),
                  ],
                )
              : null,
          color: isSelected
              ? null
              : isDisabled
                  ? Colors.grey.shade50
                  : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? spell.color
                : isDisabled
                    ? Colors.grey.shade200
                    : AppColors.primaryPurple.withOpacity(0.15),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: spell.color.withOpacity(0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: isDisabled
                    ? null
                    : LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          spell.color.withOpacity(0.2),
                          spell.color.withOpacity(0.1),
                        ],
                      ),
                color: isDisabled ? Colors.grey.shade200 : null,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDisabled
                      ? Colors.grey.shade300
                      : spell.color.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                spell.icon,
                size: 18,
                color: isDisabled ? Colors.grey.shade400 : spell.color,
              ),
            ),
            const SizedBox(height: 5),
            // Name
            Text(
              spell.name,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isDisabled
                    ? Colors.grey.shade400
                    : AppColors.magicPurple,
              ),
            ),
            const SizedBox(height: 2),
            // Mana cost
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.auto_awesome,
                  size: 10,
                  color: isDisabled
                      ? Colors.grey.shade300
                      : canCast
                          ? AppColors.magicPurple
                          : AppColors.primaryPink,
                ),
                const SizedBox(width: 2),
                Text(
                  '${spell.manaCost}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: isDisabled
                        ? Colors.grey.shade300
                        : canCast
                            ? AppColors.magicPurple
                            : AppColors.primaryPink,
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
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryPurple.withOpacity(0.2),
              blurRadius: 30,
              offset: const Offset(0, 10),
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
                Row(
                  children: [
                    Icon(
                      Icons.auto_stories_rounded,
                      color: AppColors.magicPurple,
                      size: 28,
                    ),
                    const SizedBox(width: 10),
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [AppColors.magicPurple, AppColors.primaryPink],
                      ).createShader(bounds),
                      child: const Text(
                        'Spell Book',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, color: AppColors.magicPurple),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Select up to 4 spells (${_selected.length}/4)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.magicPurple,
                ),
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
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: Spell.allSpells.length,
              itemBuilder: (context, index) {
                final spell = Spell.allSpells[index];
                final isSelected = _selected.contains(spell.type);
                
                return GestureDetector(
                  onTap: () => _toggleSpell(spell.type),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                spell.color.withOpacity(0.2),
                                spell.color.withOpacity(0.1),
                              ],
                            )
                          : null,
                      color: isSelected ? null : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? spell.color : Colors.grey.shade200,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: spell.color.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Checkmark for selected
                        if (isSelected)
                          Align(
                            alignment: Alignment.topRight,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: spell.color,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
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
                        const SizedBox(height: 6),
                        Text(
                          spell.name,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.magicPurple,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              size: 10,
                              color: AppColors.magicPurple.withOpacity(0.6),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${spell.manaCost}',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.magicPurple.withOpacity(0.6),
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
                  backgroundColor: AppColors.magicPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
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
