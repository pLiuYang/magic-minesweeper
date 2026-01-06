import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/multiplayer_match.dart';
import '../providers/multiplayer_provider.dart';
import '../utils/constants.dart';
import 'versus_game_screen.dart';

class MultiplayerLobbyScreen extends StatefulWidget {
  final MultiplayerModeConfig modeConfig;

  const MultiplayerLobbyScreen({
    super.key,
    required this.modeConfig,
  });

  @override
  State<MultiplayerLobbyScreen> createState() => _MultiplayerLobbyScreenState();
}

class _MultiplayerLobbyScreenState extends State<MultiplayerLobbyScreen>
    with SingleTickerProviderStateMixin {
  String _selectedDifficulty = 'medium';
  int _timeLimit = 300; // 5 minutes default
  bool _isSearching = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _timeLimit = widget.modeConfig.defaultTimeLimit;
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              widget.modeConfig.color.withOpacity(0.3),
              const Color(0xFF1a1a2e),
              const Color(0xFF16213e),
            ],
          ),
        ),
        child: SafeArea(
          child: _isSearching ? _buildSearchingView() : _buildLobbyView(),
        ),
      ),
    );
  }

  Widget _buildLobbyView() {
    return Column(
      children: [
        // Header
        _buildHeader(),
        
        // Settings
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mode info card
                _buildModeInfoCard(),
                
                const SizedBox(height: 24),
                
                // Difficulty selection
                _buildSectionTitle('Difficulty'),
                const SizedBox(height: 12),
                _buildDifficultySelector(),
                
                const SizedBox(height: 24),
                
                // Time limit
                _buildSectionTitle('Time Limit'),
                const SizedBox(height: 12),
                _buildTimeLimitSelector(),
                
                const SizedBox(height: 24),
                
                // Players preview
                _buildSectionTitle('Players'),
                const SizedBox(height: 12),
                _buildPlayersPreview(),
              ],
            ),
          ),
        ),
        
        // Start button
        _buildStartButton(),
      ],
    );
  }

  Widget _buildSearchingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated search indicator
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 120,
                  height: 120,
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
                  child: Icon(
                    widget.modeConfig.icon,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 40),
          
          const Text(
            'Finding Opponent...',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Text(
            'Setting up ${widget.modeConfig.name} match',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Cancel button
          OutlinedButton(
            onPressed: _cancelSearch,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.white.withOpacity(0.5)),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              '${widget.modeConfig.name} Mode',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            widget.modeConfig.color.withOpacity(0.3),
            widget.modeConfig.color.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.modeConfig.color.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: widget.modeConfig.color,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              widget.modeConfig.icon,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.modeConfig.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.modeConfig.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildDifficultySelector() {
    final difficulties = [
      {'id': 'easy', 'name': 'Easy', 'icon': Icons.sentiment_satisfied},
      {'id': 'medium', 'name': 'Medium', 'icon': Icons.sentiment_neutral},
      {'id': 'hard', 'name': 'Hard', 'icon': Icons.sentiment_very_dissatisfied},
    ];

    return Row(
      children: difficulties.map((diff) {
        final isSelected = _selectedDifficulty == diff['id'];
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedDifficulty = diff['id'] as String),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: [
                          widget.modeConfig.color,
                          widget.modeConfig.color.withOpacity(0.7),
                        ],
                      )
                    : null,
                color: isSelected ? null : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? widget.modeConfig.color
                      : Colors.white.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    diff['icon'] as IconData,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    diff['name'] as String,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTimeLimitSelector() {
    final timeLimits = [
      {'seconds': 180, 'label': '3 min'},
      {'seconds': 300, 'label': '5 min'},
      {'seconds': 600, 'label': '10 min'},
      {'seconds': 0, 'label': 'No Limit'},
    ];

    return Row(
      children: timeLimits.map((time) {
        final isSelected = _timeLimit == time['seconds'];
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _timeLimit = time['seconds'] as int),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: [
                          widget.modeConfig.color,
                          widget.modeConfig.color.withOpacity(0.7),
                        ],
                      )
                    : null,
                color: isSelected ? null : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? widget.modeConfig.color
                      : Colors.white.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  time['label'] as String,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPlayersPreview() {
    return Consumer<MultiplayerProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              // Player 1 (You)
              Expanded(
                child: _buildPlayerSlot(
                  name: provider.currentPlayer.name,
                  subtitle: 'You',
                  color: Colors.blue,
                  isReady: true,
                ),
              ),
              
              // VS
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'VS',
                  style: TextStyle(
                    fontSize: 24,
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
              
              // Player 2 (Opponent)
              Expanded(
                child: _buildPlayerSlot(
                  name: 'AI Opponent',
                  subtitle: 'Bot',
                  color: Colors.red,
                  isReady: true,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlayerSlot({
    required String name,
    required String subtitle,
    required Color color,
    required bool isReady,
  }) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withOpacity(0.7)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.person,
            color: Colors.white,
            size: 32,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          subtitle,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: isReady ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            isReady ? 'Ready' : 'Waiting',
            style: TextStyle(
              color: isReady ? Colors.green : Colors.orange,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStartButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _startMatch,
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.modeConfig.color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 8,
            shadowColor: widget.modeConfig.color.withOpacity(0.5),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.play_arrow, size: 28),
              SizedBox(width: 8),
              Text(
                'Start Match',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startMatch() async {
    setState(() => _isSearching = true);

    final provider = Provider.of<MultiplayerProvider>(context, listen: false);
    
    // Create match
    await provider.createMatch(
      mode: widget.modeConfig.mode,
      difficulty: _selectedDifficulty,
      timeLimit: _timeLimit,
    );

    // Simulate matchmaking delay
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() => _isSearching = false);

    // Navigate to game screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => VersusGameScreen(
          modeConfig: widget.modeConfig,
          difficulty: _selectedDifficulty,
        ),
      ),
    );
  }

  void _cancelSearch() {
    setState(() => _isSearching = false);
    Provider.of<MultiplayerProvider>(context, listen: false).cancelMatchmaking();
  }
}
