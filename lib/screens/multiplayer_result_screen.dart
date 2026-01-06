import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/multiplayer_match.dart';
import '../providers/multiplayer_provider.dart';
import 'multiplayer_menu_screen.dart';
import 'multiplayer_lobby_screen.dart';

class MultiplayerResultScreen extends StatefulWidget {
  final MultiplayerModeConfig modeConfig;

  const MultiplayerResultScreen({
    super.key,
    required this.modeConfig,
  });

  @override
  State<MultiplayerResultScreen> createState() => _MultiplayerResultScreenState();
}

class _MultiplayerResultScreenState extends State<MultiplayerResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
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
          child: Consumer<MultiplayerProvider>(
            builder: (context, provider, child) {
              final match = provider.currentMatch;
              if (match == null) {
                return const Center(
                  child: Text(
                    'No match data',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              final isWinner = match.winnerId == provider.currentPlayer.id;
              final player1 = match.players[0];
              final player2 = match.players[1];

              return Column(
                children: [
                  const SizedBox(height: 40),
                  
                  // Result header
                  _buildResultHeader(isWinner),
                  
                  const SizedBox(height: 40),
                  
                  // Score comparison
                  _buildScoreComparison(match, player1, player2, provider),
                  
                  const SizedBox(height: 30),
                  
                  // Match stats
                  _buildMatchStats(match),
                  
                  const Spacer(),
                  
                  // Action buttons
                  _buildActionButtons(context),
                  
                  const SizedBox(height: 30),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildResultHeader(bool isWinner) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Column(
            children: [
              // Trophy/Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: isWinner
                        ? [
                            const Color(0xFFFFD700),
                            const Color(0xFFFF8C00),
                          ]
                        : [
                            Colors.grey.shade600,
                            Colors.grey.shade800,
                          ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isWinner
                          ? const Color(0xFFFFD700).withOpacity(0.5)
                          : Colors.grey.withOpacity(0.3),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Icon(
                  isWinner ? Icons.emoji_events : Icons.sentiment_dissatisfied,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              
              // Result text
              Text(
                isWinner ? 'VICTORY!' : 'DEFEAT',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: isWinner ? const Color(0xFFFFD700) : Colors.grey,
                  letterSpacing: 4,
                  shadows: [
                    Shadow(
                      color: isWinner
                          ? const Color(0xFFFFD700).withOpacity(0.5)
                          : Colors.grey.withOpacity(0.3),
                      blurRadius: 20,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildScoreComparison(
    MultiplayerMatch match,
    player1,
    player2,
    MultiplayerProvider provider,
  ) {
    final score1 = match.getPlayerScore(player1.id);
    final score2 = match.getPlayerScore(player2.id);
    final isPlayer1Winner = match.winnerId == player1.id;
    final isPlayer2Winner = match.winnerId == player2.id;

    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            child: Row(
              children: [
                // Player 1
                Expanded(
                  child: _buildPlayerResult(
                    player1.name,
                    score1,
                    Colors.blue,
                    isPlayer1Winner,
                    player1.id == provider.currentPlayer.id,
                  ),
                ),
                
                // VS
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'VS',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: widget.modeConfig.color,
                    ),
                  ),
                ),
                
                // Player 2
                Expanded(
                  child: _buildPlayerResult(
                    player2.name,
                    score2,
                    Colors.red,
                    isPlayer2Winner,
                    player2.id == provider.currentPlayer.id,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlayerResult(
    String name,
    int score,
    Color color,
    bool isWinner,
    bool isCurrentPlayer,
  ) {
    return Column(
      children: [
        // Avatar with crown if winner
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.7)],
                ),
                borderRadius: BorderRadius.circular(16),
                border: isWinner
                    ? Border.all(color: const Color(0xFFFFD700), width: 3)
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 32),
            ),
            if (isWinner)
              Positioned(
                top: -15,
                left: 0,
                right: 0,
                child: Center(
                  child: Icon(
                    Icons.emoji_events,
                    color: const Color(0xFFFFD700),
                    size: 24,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Name
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            if (isCurrentPlayer)
              Container(
                margin: const EdgeInsets.only(left: 4),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'YOU',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        
        // Score
        Text(
          score.toString(),
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: isWinner ? const Color(0xFFFFD700) : Colors.white,
          ),
        ),
        Text(
          'points',
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildMatchStats(MultiplayerMatch match) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  Icons.timer,
                  'Duration',
                  _formatDuration(match.duration),
                ),
                _buildStatItem(
                  Icons.sports_esports,
                  'Mode',
                  widget.modeConfig.name,
                ),
                _buildStatItem(
                  Icons.trending_up,
                  'Difficulty',
                  match.difficulty.toUpperCase(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.6), size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                // Play Again button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () => _playAgain(context),
                    icon: const Icon(Icons.replay),
                    label: const Text(
                      'Play Again',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.modeConfig.color,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Back to menu button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () => _backToMenu(context),
                    icon: const Icon(Icons.home),
                    label: const Text('Back to Menu'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.white.withOpacity(0.3)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
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

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _playAgain(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MultiplayerLobbyScreen(
          modeConfig: widget.modeConfig,
        ),
      ),
    );
  }

  void _backToMenu(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const MultiplayerMenuScreen(),
      ),
      (route) => route.isFirst,
    );
  }
}
