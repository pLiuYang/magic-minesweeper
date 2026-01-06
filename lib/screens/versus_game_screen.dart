import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/multiplayer_match.dart';
import '../models/competitive_spell.dart';
import '../models/game_board.dart';
import '../providers/multiplayer_provider.dart';
import '../providers/game_provider.dart';
import '../utils/constants.dart';
import '../widgets/versus_board_widget.dart';
import '../widgets/competitive_spell_bar.dart';
import 'multiplayer_result_screen.dart';

class VersusGameScreen extends StatefulWidget {
  final MultiplayerModeConfig modeConfig;
  final String difficulty;

  const VersusGameScreen({
    super.key,
    required this.modeConfig,
    required this.difficulty,
  });

  @override
  State<VersusGameScreen> createState() => _VersusGameScreenState();
}

class _VersusGameScreenState extends State<VersusGameScreen>
    with TickerProviderStateMixin {
  late AnimationController _vsAnimationController;
  late Animation<double> _vsScaleAnimation;
  late AnimationController _timerPulseController;
  bool _showCountdown = true;
  int _countdown = 3;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    
    _vsAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    
    _vsScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _vsAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _timerPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 1) {
        setState(() => _countdown--);
      } else {
        timer.cancel();
        setState(() => _showCountdown = false);
        _vsAnimationController.forward();
        _startMatch();
      }
    });
  }

  void _startMatch() {
    final provider = Provider.of<MultiplayerProvider>(context, listen: false);
    provider.startMatch();
  }

  @override
  void dispose() {
    _vsAnimationController.dispose();
    _timerPulseController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1a1a2e),
              Color(0xFF16213e),
              Color(0xFF0f3460),
            ],
          ),
        ),
        child: SafeArea(
          child: _showCountdown ? _buildCountdownView() : _buildGameView(),
        ),
      ),
    );
  }

  Widget _buildCountdownView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.modeConfig.name.toUpperCase(),
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: widget.modeConfig.color,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 40),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 1.5, end: 1.0),
            duration: const Duration(milliseconds: 800),
            key: ValueKey(_countdown),
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        widget.modeConfig.color,
                        widget.modeConfig.color.withOpacity(0.3),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.modeConfig.color.withOpacity(0.5),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      _countdown.toString(),
                      style: const TextStyle(
                        fontSize: 72,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 40),
          Text(
            'Get Ready!',
            style: TextStyle(
              fontSize: 24,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameView() {
    return Consumer<MultiplayerProvider>(
      builder: (context, provider, child) {
        final match = provider.currentMatch;
        if (match == null) return const SizedBox();

        return Column(
          children: [
            // Top bar with timer and scores
            _buildTopBar(match, provider),
            
            // VS indicator
            _buildVSIndicator(),
            
            // Game boards
            Expanded(
              child: _buildGameBoards(match, provider),
            ),
            
            // Spell bar (for versus mode)
            if (widget.modeConfig.mode == MultiplayerMode.versus)
              CompetitiveSpellBar(
                onSpellCast: (spell) => _castSpell(provider, spell),
              ),
            
            // Bottom controls
            _buildBottomControls(match),
          ],
        );
      },
    );
  }

  Widget _buildTopBar(MultiplayerMatch match, MultiplayerProvider provider) {
    final player1 = match.players[0];
    final player2 = match.players[1];
    final isLowTime = match.remainingTime <= 30;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          // Player 1 info
          Expanded(
            child: _buildPlayerInfo(
              player1.name,
              match.getPlayerScore(player1.id),
              player1.mana,
              player1.maxMana,
              Colors.blue,
              isLeft: true,
            ),
          ),
          
          // Timer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isLowTime
                    ? [Colors.red.shade700, Colors.red.shade900]
                    : [const Color(0xFF2d2d44), const Color(0xFF1a1a2e)],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isLowTime ? Colors.red : Colors.white.withOpacity(0.2),
                width: 2,
              ),
              boxShadow: isLowTime
                  ? [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.5),
                        blurRadius: 10,
                      ),
                    ]
                  : null,
            ),
            child: Text(
              match.formattedTimeRemaining,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isLowTime ? Colors.white : Colors.white,
                fontFamily: 'monospace',
              ),
            ),
          ),
          
          // Player 2 info
          Expanded(
            child: _buildPlayerInfo(
              player2.name,
              match.getPlayerScore(player2.id),
              player2.mana,
              player2.maxMana,
              Colors.red,
              isLeft: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerInfo(
    String name,
    int score,
    int mana,
    int maxMana,
    Color color, {
    required bool isLeft,
  }) {
    final children = [
      // Avatar
      Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.7)],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 8,
            ),
          ],
        ),
        child: const Icon(Icons.person, color: Colors.white, size: 24),
      ),
      const SizedBox(width: 10),
      // Info
      Expanded(
        child: Column(
          crossAxisAlignment: isLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          children: [
            Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              score.toString(),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 4),
            // Mana bar
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.water_drop, size: 12, color: Colors.blue.shade300),
                const SizedBox(width: 4),
                SizedBox(
                  width: 60,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: mana / maxMana,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation(Colors.blue.shade400),
                      minHeight: 6,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ];

    return Row(
      children: isLeft ? children : children.reversed.toList(),
    );
  }

  Widget _buildVSIndicator() {
    return AnimatedBuilder(
      animation: _vsScaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _vsScaleAnimation.value,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.blue.withOpacity(0.5),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        widget.modeConfig.color.withOpacity(0.3),
                        widget.modeConfig.color.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: widget.modeConfig.color.withOpacity(0.5),
                    ),
                  ),
                  child: Text(
                    'VS',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: widget.modeConfig.color,
                      shadows: [
                        Shadow(
                          color: widget.modeConfig.color.withOpacity(0.5),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: 80,
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.red.withOpacity(0.5),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGameBoards(MultiplayerMatch match, MultiplayerProvider provider) {
    return Row(
      children: [
        // Player 1 board (interactive)
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.blue.withOpacity(0.5),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.2),
                  blurRadius: 10,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: VersusBoardWidget(
                playerId: match.players[0].id,
                isInteractive: true,
                difficulty: widget.difficulty,
                onScoreUpdate: (score) {
                  provider.updatePlayerScore(match.players[0].id, score);
                  _checkWinCondition(provider);
                },
                onGameComplete: () => _handleGameComplete(provider, match.players[0].id),
                activeEffects: provider.activeEffects
                    .where((e) => e.targetId == match.players[0].id)
                    .toList(),
              ),
            ),
          ),
        ),
        
        // Player 2 board (AI controlled, view only)
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.red.withOpacity(0.5),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.2),
                  blurRadius: 10,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: VersusBoardWidget(
                playerId: match.players[1].id,
                isInteractive: false,
                difficulty: widget.difficulty,
                onScoreUpdate: (score) {
                  provider.updatePlayerScore(match.players[1].id, score);
                },
                onGameComplete: () => _handleGameComplete(provider, match.players[1].id),
                activeEffects: provider.activeEffects
                    .where((e) => e.targetId == match.players[1].id)
                    .toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomControls(MultiplayerMatch match) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Pause/Menu button
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.pause, color: Colors.white),
              onPressed: _showPauseMenu,
            ),
          ),
          const SizedBox(width: 16),
          // Surrender button
          OutlinedButton.icon(
            onPressed: _confirmSurrender,
            icon: const Icon(Icons.flag, size: 18),
            label: const Text('Surrender'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red.shade300,
              side: BorderSide(color: Colors.red.shade300.withOpacity(0.5)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _castSpell(MultiplayerProvider provider, CompetitiveSpell spell) {
    final match = provider.currentMatch;
    if (match == null) return;

    // Target opponent
    final opponentId = match.players[1].id;
    final success = provider.castCompetitiveSpell(spell, opponentId);

    if (success) {
      // Show spell cast animation/feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(spell.icon, color: spell.color),
              const SizedBox(width: 8),
              Text('${spell.name} cast on opponent!'),
            ],
          ),
          backgroundColor: const Color(0xFF2d2d44),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Cannot cast spell - not enough mana or on cooldown'),
          backgroundColor: Colors.red.shade700,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _checkWinCondition(MultiplayerProvider provider) {
    // Check if either player has completed their board
    // This is handled by onGameComplete callback
  }

  void _handleGameComplete(MultiplayerProvider provider, String winnerId) {
    provider.endMatch(winnerId: winnerId, completed: true);
    _navigateToResults();
  }

  void _navigateToResults() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MultiplayerResultScreen(
          modeConfig: widget.modeConfig,
        ),
      ),
    );
  }

  void _showPauseMenu() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Game Paused',
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPauseMenuItem(
              icon: Icons.play_arrow,
              label: 'Resume',
              onTap: () => Navigator.pop(context),
            ),
            _buildPauseMenuItem(
              icon: Icons.exit_to_app,
              label: 'Quit Match',
              onTap: () {
                Navigator.pop(context);
                _confirmSurrender();
              },
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPauseMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : Colors.white,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isDestructive ? Colors.red : Colors.white,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  void _confirmSurrender() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Surrender?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to surrender? This will count as a loss.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              final provider = Provider.of<MultiplayerProvider>(context, listen: false);
              final match = provider.currentMatch;
              if (match != null) {
                // Opponent wins
                provider.endMatch(winnerId: match.players[1].id);
                _navigateToResults();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Surrender'),
          ),
        ],
      ),
    );
  }
}
