import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/leaderboard_entry.dart';
import '../providers/multiplayer_provider.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  LeaderboardCategory _selectedCategory = LeaderboardCategory.allTime;
  LeaderboardGameMode _selectedGameMode = LeaderboardGameMode.all;
  String _selectedDifficulty = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedCategory = LeaderboardCategory.values[_tabController.index];
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
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
          child: Column(
            children: [
              // Header
              _buildHeader(),
              
              // Tab bar
              _buildTabBar(),
              
              // Filters
              _buildFilters(),
              
              // Leaderboard list
              Expanded(
                child: _buildLeaderboardList(),
              ),
            ],
          ),
        ),
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
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Leaderboard',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Color(0xFFFFD700),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
                Text(
                  'Global Rankings',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          // Trophy icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.emoji_events,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white60,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        tabs: const [
          Tab(text: 'All Time'),
          Tab(text: 'Weekly'),
          Tab(text: 'Daily'),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Game mode filter
          Expanded(
            child: _buildFilterDropdown(
              value: _selectedGameMode.name,
              items: LeaderboardGameMode.values.map((m) => m.name).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedGameMode = LeaderboardGameMode.values
                      .firstWhere((m) => m.name == value);
                });
              },
              icon: Icons.sports_esports,
            ),
          ),
          const SizedBox(width: 12),
          // Difficulty filter
          Expanded(
            child: _buildFilterDropdown(
              value: _selectedDifficulty,
              items: ['all', 'easy', 'medium', 'hard'],
              onChanged: (value) {
                setState(() {
                  _selectedDifficulty = value!;
                });
              },
              icon: Icons.trending_up,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: const Color(0xFF2d2d44),
          icon: Icon(Icons.arrow_drop_down, color: Colors.white.withOpacity(0.7)),
          style: const TextStyle(color: Colors.white),
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Row(
                children: [
                  Icon(icon, size: 16, color: Colors.white70),
                  const SizedBox(width: 8),
                  Text(
                    item.toUpperCase(),
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildLeaderboardList() {
    return Consumer<MultiplayerProvider>(
      builder: (context, provider, child) {
        final entries = provider.getFilteredLeaderboard(
          category: _selectedCategory,
          gameMode: _selectedGameMode,
          difficulty: _selectedDifficulty,
        );

        if (entries.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.leaderboard,
                  size: 64,
                  color: Colors.white.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'No entries yet',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Be the first to make the leaderboard!',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.3),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index];
            final isCurrentPlayer = entry.oderId == provider.currentPlayer.id;
            return _buildLeaderboardEntry(entry, isCurrentPlayer);
          },
        );
      },
    );
  }

  Widget _buildLeaderboardEntry(LeaderboardEntry entry, bool isCurrentPlayer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        gradient: isCurrentPlayer
            ? LinearGradient(
                colors: [
                  Colors.blue.withOpacity(0.3),
                  Colors.blue.withOpacity(0.1),
                ],
              )
            : null,
        color: isCurrentPlayer ? null : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentPlayer
              ? Colors.blue.withOpacity(0.5)
              : Colors.white.withOpacity(0.1),
          width: isCurrentPlayer ? 2 : 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: _buildRankBadge(entry.rank),
        title: Row(
          children: [
            Text(
              entry.playerName,
              style: TextStyle(
                color: Colors.white,
                fontWeight: isCurrentPlayer ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (isCurrentPlayer)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'YOU',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Row(
          children: [
            _buildStatChip(Icons.timer, entry.formattedTime),
            const SizedBox(width: 8),
            _buildStatChip(Icons.trending_up, entry.difficulty),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              entry.score.toString(),
              style: TextStyle(
                color: entry.rank <= 3 ? entry.rankColor : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              'points',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankBadge(int rank) {
    Color badgeColor;
    IconData? icon;
    
    switch (rank) {
      case 1:
        badgeColor = const Color(0xFFFFD700);
        icon = Icons.emoji_events;
        break;
      case 2:
        badgeColor = const Color(0xFFC0C0C0);
        icon = Icons.workspace_premium;
        break;
      case 3:
        badgeColor = const Color(0xFFCD7F32);
        icon = Icons.military_tech;
        break;
      default:
        badgeColor = Colors.white.withOpacity(0.3);
        icon = null;
    }

    return Container(
      width: 45,
      height: 45,
      decoration: BoxDecoration(
        gradient: rank <= 3
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  badgeColor,
                  badgeColor.withOpacity(0.7),
                ],
              )
            : null,
        color: rank > 3 ? badgeColor : null,
        borderRadius: BorderRadius.circular(12),
        boxShadow: rank <= 3
            ? [
                BoxShadow(
                  color: badgeColor.withOpacity(0.4),
                  blurRadius: 8,
                ),
              ]
            : null,
      ),
      child: Center(
        child: icon != null
            ? Icon(icon, color: Colors.white, size: 24)
            : Text(
                '#$rank',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white60),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
