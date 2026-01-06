import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/competitive_spell.dart';
import '../providers/multiplayer_provider.dart';

class CompetitiveSpellBar extends StatelessWidget {
  final Function(CompetitiveSpell) onSpellCast;

  const CompetitiveSpellBar({
    super.key,
    required this.onSpellCast,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<MultiplayerProvider>(
      builder: (context, provider, child) {
        final spells = CompetitiveSpell.defaultVersusSpells;
        final player = provider.currentPlayer;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF2d2d44).withOpacity(0.9),
                const Color(0xFF1a1a2e),
              ],
            ),
            border: Border(
              top: BorderSide(
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Mana bar
              Row(
                children: [
                  Icon(
                    Icons.water_drop,
                    color: Colors.blue.shade300,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: player.mana / player.maxMana,
                        backgroundColor: Colors.white.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation(
                          Colors.blue.shade400,
                        ),
                        minHeight: 10,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${player.mana}/${player.maxMana}',
                    style: TextStyle(
                      color: Colors.blue.shade300,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Spell buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: spells.map((spell) {
                  return _SpellButton(
                    spell: spell,
                    currentMana: player.mana,
                    cooldownTracker: provider.cooldownTracker,
                    onTap: () => onSpellCast(spell),
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

class _SpellButton extends StatefulWidget {
  final CompetitiveSpell spell;
  final int currentMana;
  final SpellCooldownTracker cooldownTracker;
  final VoidCallback onTap;

  const _SpellButton({
    required this.spell,
    required this.currentMana,
    required this.cooldownTracker,
    required this.onTap,
  });

  @override
  State<_SpellButton> createState() => _SpellButtonState();
}

class _SpellButtonState extends State<_SpellButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canCast = widget.currentMana >= widget.spell.manaCost &&
        !widget.cooldownTracker.isOnCooldown(widget.spell);
    final isOnCooldown = widget.cooldownTracker.isOnCooldown(widget.spell);
    final cooldownProgress = widget.cooldownTracker.getCooldownProgress(widget.spell);

    return GestureDetector(
      onTap: canCast ? widget.onTap : null,
      onLongPress: () => _showSpellInfo(context),
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, child) {
          return Container(
            width: 80,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: canCast
                    ? [
                        widget.spell.color.withOpacity(0.4),
                        widget.spell.color.withOpacity(0.2),
                      ]
                    : [
                        Colors.grey.withOpacity(0.3),
                        Colors.grey.withOpacity(0.1),
                      ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: canCast
                    ? widget.spell.color.withOpacity(_glowAnimation.value)
                    : Colors.grey.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: canCast
                  ? [
                      BoxShadow(
                        color: widget.spell.color.withOpacity(_glowAnimation.value * 0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: Stack(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon
                    Icon(
                      widget.spell.icon,
                      color: canCast ? widget.spell.color : Colors.grey,
                      size: 28,
                    ),
                    const SizedBox(height: 4),
                    // Name
                    Text(
                      widget.spell.name,
                      style: TextStyle(
                        color: canCast ? Colors.white : Colors.grey,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    // Mana cost
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.water_drop,
                          size: 10,
                          color: widget.currentMana >= widget.spell.manaCost
                              ? Colors.blue.shade300
                              : Colors.red.shade300,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${widget.spell.manaCost}',
                          style: TextStyle(
                            color: widget.currentMana >= widget.spell.manaCost
                                ? Colors.blue.shade300
                                : Colors.red.shade300,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                // Cooldown overlay
                if (isOnCooldown)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          '${widget.cooldownTracker.getRemainingCooldown(widget.spell)}s',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showSpellInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: widget.spell.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                widget.spell.icon,
                color: widget.spell.color,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              widget.spell.name,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.spell.description,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              Icons.water_drop,
              'Mana Cost',
              '${widget.spell.manaCost}',
              Colors.blue,
            ),
            if (widget.spell.duration > 0)
              _buildInfoRow(
                Icons.timer,
                'Duration',
                '${widget.spell.duration}s',
                Colors.orange,
              ),
            _buildInfoRow(
              Icons.refresh,
              'Cooldown',
              '${widget.spell.cooldown}s',
              Colors.purple,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 13,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
