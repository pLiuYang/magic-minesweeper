import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/multiplayer_match.dart';
import '../providers/multiplayer_provider.dart';
import '../services/match_service.dart';
import 'versus_game_screen.dart';

class OnlineLobbyScreen extends StatefulWidget {
  final MultiplayerModeConfig modeConfig;

  const OnlineLobbyScreen({super.key, required this.modeConfig});

  @override
  State<OnlineLobbyScreen> createState() => _OnlineLobbyScreenState();
}

class _OnlineLobbyScreenState extends State<OnlineLobbyScreen> {
  String _selectedDifficulty = 'medium';
  int _timeLimit = 300;
  bool _isCreatingMatch = false;
  bool _isSearching = false;
  bool _isLoadingMatches = false;
  List<AvailableMatch> _availableMatches = [];

  @override
  void initState() {
    super.initState();
    _timeLimit = widget.modeConfig.defaultTimeLimit;
    _loadAvailableMatches();
  }

  Future<void> _loadAvailableMatches() async {
    setState(() => _isLoadingMatches = true);
    
    final provider = context.read<MultiplayerProvider>();
    await provider.loadAvailableMatches(
      mode: widget.modeConfig.mode.name,
      difficulty: _selectedDifficulty,
    );
    
    setState(() {
      _availableMatches = provider.availableMatches;
      _isLoadingMatches = false;
    });
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
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Quick Match
                      _buildQuickMatchSection(),
                      
                      const SizedBox(height: 24),
                      
                      // Create Match
                      _buildCreateMatchSection(),
                      
                      const SizedBox(height: 24),
                      
                      // Available Matches
                      _buildAvailableMatchesSection(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.modeConfig.name} - Online',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Find opponents worldwide',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadAvailableMatches,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickMatchSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.flash_on,
                color: widget.modeConfig.color,
                size: 28,
              ),
              const SizedBox(width: 12),
              const Text(
                'Quick Match',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Automatically find an opponent with similar skill level',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),
          
          // Difficulty selector
          Row(
            children: [
              const Text(
                'Difficulty:',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(width: 12),
              ...['easy', 'medium', 'hard'].map((diff) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(diff.toUpperCase()),
                  selected: _selectedDifficulty == diff,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedDifficulty = diff);
                      _loadAvailableMatches();
                    }
                  },
                  selectedColor: widget.modeConfig.color,
                  labelStyle: TextStyle(
                    color: _selectedDifficulty == diff
                        ? Colors.white
                        : Colors.white70,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  backgroundColor: Colors.white.withOpacity(0.1),
                ),
              )),
            ],
          ),
          const SizedBox(height: 16),
          
          // Quick match button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSearching ? _cancelSearch : _startQuickMatch,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isSearching ? Colors.red : widget.modeConfig.color,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSearching
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Searching... Tap to Cancel',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                  : const Text(
                      'Find Match',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateMatchSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.add_circle_outline,
                color: Colors.white,
                size: 28,
              ),
              SizedBox(width: 12),
              Text(
                'Create Match',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Host a game and wait for others to join',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),
          
          // Time limit slider
          Row(
            children: [
              const Text(
                'Time Limit:',
                style: TextStyle(color: Colors.white70),
              ),
              Expanded(
                child: Slider(
                  value: _timeLimit.toDouble(),
                  min: 60,
                  max: 600,
                  divisions: 9,
                  label: '${_timeLimit ~/ 60} min',
                  activeColor: widget.modeConfig.color,
                  onChanged: (value) {
                    setState(() => _timeLimit = value.toInt());
                  },
                ),
              ),
              Text(
                '${_timeLimit ~/ 60} min',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Create button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _isCreatingMatch ? null : _createMatch,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: widget.modeConfig.color),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isCreatingMatch
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      'Create Match',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: widget.modeConfig.color,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableMatchesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.list,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 12),
            const Text(
              'Available Matches',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            if (_isLoadingMatches)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
        const SizedBox(height: 16),
        
        if (_availableMatches.isEmpty && !_isLoadingMatches)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.search_off,
                    size: 48,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No matches available',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create one or use Quick Match',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.3),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ..._availableMatches.map((match) => _buildMatchCard(match)),
      ],
    );
  }

  Widget _buildMatchCard(AvailableMatch match) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          // Host avatar
          CircleAvatar(
            radius: 24,
            backgroundColor: widget.modeConfig.color.withOpacity(0.3),
            child: Text(
              match.hostName.isNotEmpty ? match.hostName[0].toUpperCase() : '?',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Match info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${match.hostName}\'s Game',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildMatchInfoChip(
                      Icons.signal_cellular_alt,
                      match.difficulty.toUpperCase(),
                    ),
                    const SizedBox(width: 8),
                    _buildMatchInfoChip(
                      Icons.people,
                      '${match.currentPlayers}/${match.maxPlayers}',
                    ),
                    const SizedBox(width: 8),
                    _buildMatchInfoChip(
                      Icons.star,
                      '${match.hostRankPoints}',
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Join button
          ElevatedButton(
            onPressed: () => _joinMatch(match),
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.modeConfig.color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Join'),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white70),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _startQuickMatch() async {
    setState(() => _isSearching = true);
    
    final provider = context.read<MultiplayerProvider>();
    await provider.startMatchmaking(
      widget.modeConfig.mode,
      _selectedDifficulty,
    );
    
    if (provider.currentMatch != null && mounted) {
      setState(() => _isSearching = false);
      _navigateToGame();
    }
  }

  void _cancelSearch() {
    final provider = context.read<MultiplayerProvider>();
    provider.cancelMatchmaking();
    setState(() => _isSearching = false);
  }

  Future<void> _createMatch() async {
    setState(() => _isCreatingMatch = true);
    
    try {
      final provider = context.read<MultiplayerProvider>();
      await provider.createMatch(
        mode: widget.modeConfig.mode,
        difficulty: _selectedDifficulty,
        timeLimit: _timeLimit,
        online: true,
      );
      
      if (mounted) {
        setState(() => _isCreatingMatch = false);
        // Navigate to waiting room
        _showWaitingRoom();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCreatingMatch = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create match: $e')),
        );
      }
    }
  }

  Future<void> _joinMatch(AvailableMatch match) async {
    final provider = context.read<MultiplayerProvider>();
    final success = await provider.joinMatch(match.id);
    
    if (success && mounted) {
      _showWaitingRoom();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to join match')),
      );
    }
  }

  void _showWaitingRoom() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _WaitingRoomSheet(
        modeConfig: widget.modeConfig,
        onGameStart: () {
          Navigator.pop(context);
          _navigateToGame();
        },
        onCancel: () {
          Navigator.pop(context);
          final provider = context.read<MultiplayerProvider>();
          provider.cancelMatch();
        },
      ),
    );
  }

  void _navigateToGame() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => VersusGameScreen(
          mode: widget.modeConfig.mode,
          difficulty: _selectedDifficulty,
        ),
      ),
    );
  }
}

class _WaitingRoomSheet extends StatefulWidget {
  final MultiplayerModeConfig modeConfig;
  final VoidCallback onGameStart;
  final VoidCallback onCancel;

  const _WaitingRoomSheet({
    required this.modeConfig,
    required this.onGameStart,
    required this.onCancel,
  });

  @override
  State<_WaitingRoomSheet> createState() => _WaitingRoomSheetState();
}

class _WaitingRoomSheetState extends State<_WaitingRoomSheet> {
  bool _isReady = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<MultiplayerProvider>(
      builder: (context, provider, child) {
        final matchDetails = provider.matchDetails;
        final participants = matchDetails?.participants ?? [];
        final allReady = participants.isNotEmpty && 
            participants.every((p) => p.isReady);

        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF1a1a2e),
                Color(0xFF16213e),
              ],
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const Text(
                      'Waiting Room',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: widget.onCancel,
                    ),
                  ],
                ),
              ),
              
              // Players list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: participants.length,
                  itemBuilder: (context, index) {
                    final participant = participants[index];
                    final isCurrentUser = participant.userId.toString() == 
                        provider.currentPlayer.id;
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isCurrentUser
                              ? widget.modeConfig.color.withOpacity(0.5)
                              : Colors.white.withOpacity(0.1),
                          width: isCurrentUser ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: widget.modeConfig.color.withOpacity(0.3),
                            child: Text(
                              participant.displayName.isNotEmpty
                                  ? participant.displayName[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      participant.displayName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    if (isCurrentUser) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: widget.modeConfig.color.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text(
                                          'YOU',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                Text(
                                  'Rank: ${participant.rankPoints}',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.6),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: participant.isReady
                                  ? Colors.green.withOpacity(0.2)
                                  : Colors.orange.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              participant.isReady ? 'READY' : 'WAITING',
                              style: TextStyle(
                                color: participant.isReady
                                    ? Colors.green
                                    : Colors.orange,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              
              // Ready button
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    if (allReady && participants.length >= 2)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle, color: Colors.green),
                            SizedBox(width: 8),
                            Text(
                              'All players ready! Game starting...',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          setState(() => _isReady = !_isReady);
                          await provider.setReady(_isReady);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isReady
                              ? Colors.orange
                              : widget.modeConfig.color,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          _isReady ? 'Cancel Ready' : 'Ready',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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
}
