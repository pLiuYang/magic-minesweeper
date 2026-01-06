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
            // Candy Crush style pink panel
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFFB6C1),  // Light pink
                Color(0xFFFF69B4),  // Hot pink
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.5),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.candyPink.withOpacity(0.4),
                blurRadius: 15,
                offset: const Offset(0, -4),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
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
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: spell.color.withOpacity(0.5),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: spell.color.withOpacity(0.3),
              blurRadius: 8,
            ),
          ],
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
                fontWeight: FontWeight.bold,
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
              AppColors.candyPurple.withOpacity(0.9),
              AppColors.candyPink.withOpacity(0.9),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white.withOpacity(0.5),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.candyPurple.withOpacity(0.4),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.shield_rounded,
              size: 14,
              color: Colors.white,
            ),
            const SizedBox(width: 6),
            const Text(
              'Shield Active',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.white,
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
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.auto_awesome_rounded,
            size: 14,
            color: AppColors.candyPurple.withOpacity(0.7),
          ),
          const SizedBox(width: 6),
          Text(
            'Select a spell to cast',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.candyPurple.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpellButton extends StatefulWidget {
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
  State<_SpellButton> createState() => _SpellButtonState();
}

class _SpellButtonState extends State<_SpellButton> with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(_SpellButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !oldWidget.isSelected) {
      _glowController.repeat(reverse: true);
    } else if (!widget.isSelected && oldWidget.isSelected) {
      _glowController.stop();
      _glowController.reset();
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = !widget.canCast;
    final buttonColor = widget.spell.color;
    final lightColor = Color.lerp(buttonColor, Colors.white, 0.3)!;
    final darkColor = Color.lerp(buttonColor, Colors.black, 0.2)!;
    
    return GestureDetector(
      onTap: isDisabled ? null : widget.onTap,
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, child) {
          return Container(
            width: 74,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            decoration: BoxDecoration(
              // Candy-style gradient button
              gradient: isDisabled
                  ? null
                  : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: widget.isSelected
                          ? [lightColor, buttonColor, darkColor]
                          : [Colors.white, Colors.white.withOpacity(0.9)],
                      stops: widget.isSelected ? const [0.0, 0.5, 1.0] : null,
                    ),
              color: isDisabled ? Colors.grey.shade300 : null,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: widget.isSelected
                    ? Colors.white.withOpacity(0.5)
                    : isDisabled
                        ? Colors.grey.shade400
                        : buttonColor.withOpacity(0.3),
                width: widget.isSelected ? 2 : 1,
              ),
              boxShadow: widget.isSelected
                  ? [
                      BoxShadow(
                        color: buttonColor.withOpacity(0.5 * _glowAnimation.value),
                        blurRadius: 12 * _glowAnimation.value,
                        spreadRadius: 2 * _glowAnimation.value,
                      ),
                      BoxShadow(
                        color: darkColor.withOpacity(0.4),
                        blurRadius: 4,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon with candy-style circular background
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: isDisabled
                        ? null
                        : LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: widget.isSelected
                                ? [Colors.white.withOpacity(0.4), Colors.white.withOpacity(0.2)]
                                : [lightColor, buttonColor],
                          ),
                    color: isDisabled ? Colors.grey.shade400 : null,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDisabled
                          ? Colors.grey.shade500
                          : widget.isSelected
                              ? Colors.white.withOpacity(0.6)
                              : Colors.white.withOpacity(0.5),
                      width: 2,
                    ),
                    boxShadow: isDisabled
                        ? []
                        : [
                            BoxShadow(
                              color: buttonColor.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                  ),
                  child: Icon(
                    widget.spell.icon,
                    size: 18,
                    color: isDisabled
                        ? Colors.grey.shade600
                        : widget.isSelected
                            ? Colors.white
                            : Colors.white,
                    shadows: isDisabled
                        ? []
                        : const [
                            Shadow(
                              color: Color(0x60000000),
                              offset: Offset(1, 1),
                              blurRadius: 2,
                            ),
                          ],
                  ),
                ),
                const SizedBox(height: 5),
                // Name
                Text(
                  widget.spell.name,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isDisabled
                        ? Colors.grey.shade600
                        : widget.isSelected
                            ? Colors.white
                            : AppColors.candyPurple,
                    shadows: widget.isSelected
                        ? const [
                            Shadow(
                              color: Color(0x60000000),
                              offset: Offset(0.5, 0.5),
                              blurRadius: 1,
                            ),
                          ]
                        : [],
                  ),
                ),
                const SizedBox(height: 2),
                // Mana cost
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: widget.isSelected
                        ? Colors.white.withOpacity(0.3)
                        : isDisabled
                            ? Colors.grey.shade400
                            : AppColors.manaBlue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        size: 10,
                        color: isDisabled
                            ? Colors.grey.shade600
                            : widget.isSelected
                                ? Colors.white
                                : AppColors.manaBlue,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${widget.spell.manaCost}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isDisabled
                              ? Colors.grey.shade600
                              : widget.isSelected
                                  ? Colors.white
                                  : AppColors.manaBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
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
        borderRadius: BorderRadius.circular(28),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFF0F5),  // Lavender blush
              Colors.white,
            ],
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: AppColors.sparkleGold.withOpacity(0.5),
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.candyPurple.withOpacity(0.3),
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
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.candyPurple, AppColors.candyPink],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.auto_stories_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 10),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [AppColors.candyPurple, AppColors.candyPink],
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
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.close_rounded, color: Colors.grey.shade600),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.candyPurple.withOpacity(0.15),
                    AppColors.candyPink.withOpacity(0.15),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.candyPurple.withOpacity(0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.info_outline, size: 16, color: AppColors.candyPurple),
                  const SizedBox(width: 8),
                  Text(
                    'Select up to 4 spells (${_selected.length}/4)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.candyPurple,
                    ),
                  ),
                ],
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
                final lightColor = Color.lerp(spell.color, Colors.white, 0.3)!;
                final darkColor = Color.lerp(spell.color, Colors.black, 0.2)!;
                
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
                              colors: [lightColor, spell.color, darkColor],
                              stops: const [0.0, 0.5, 1.0],
                            )
                          : null,
                      color: isSelected ? null : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isSelected ? Colors.white.withOpacity(0.5) : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: spell.color.withOpacity(0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
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
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.check,
                                size: 12,
                                color: spell.color,
                              ),
                            ),
                          ),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? null
                                : LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [lightColor, spell.color],
                                  ),
                            color: isSelected ? Colors.white.withOpacity(0.3) : null,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? Colors.white.withOpacity(0.5) : Colors.white.withOpacity(0.8),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            spell.icon,
                            size: 22,
                            color: isSelected ? Colors.white : Colors.white,
                            shadows: const [
                              Shadow(
                                color: Color(0x60000000),
                                offset: Offset(1, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          spell.name,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : AppColors.candyPurple,
                            shadows: isSelected
                                ? const [
                                    Shadow(
                                      color: Color(0x60000000),
                                      offset: Offset(0.5, 0.5),
                                      blurRadius: 1,
                                    ),
                                  ]
                                : [],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white.withOpacity(0.3)
                                : AppColors.manaBlue.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.auto_awesome,
                                size: 10,
                                color: isSelected ? Colors.white : AppColors.manaBlue,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '${spell.manaCost}',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.white : AppColors.manaBlue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 20),
            
            // Save button - Candy style
            SizedBox(
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                  gradient: _selected.isNotEmpty
                      ? const LinearGradient(
                          colors: [AppColors.candyPurple, AppColors.candyPink],
                        )
                      : null,
                  color: _selected.isEmpty ? Colors.grey.shade300 : null,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: _selected.isNotEmpty
                      ? [
                          BoxShadow(
                            color: AppColors.candyPurple.withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [],
                ),
                child: ElevatedButton(
                  onPressed: _selected.isNotEmpty
                      ? () {
                          widget.onSave(_selected);
                          Navigator.pop(context);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    'Save Selection',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Color(0x60000000),
                          offset: Offset(1, 1),
                          blurRadius: 2,
                        ),
                      ],
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
