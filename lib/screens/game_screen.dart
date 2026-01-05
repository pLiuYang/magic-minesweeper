import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/constants.dart';
import '../widgets/game_board_widget.dart';
import '../widgets/status_bar_widget.dart';
import '../widgets/spell_bar_widget.dart';
import 'victory_screen.dart';
import 'main_menu_screen.dart';

class GameScreen extends StatefulWidget {
  final DifficultyConfig difficulty;

  const GameScreen({
    super.key,
    required this.difficulty,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameProvider _gameProvider;
  bool _hasShownResult = false;

  @override
  void initState() {
    super.initState();
    _gameProvider = GameProvider(difficulty: widget.difficulty);
  }

  @override
  void dispose() {
    _gameProvider.dispose();
    super.dispose();
  }

  void _checkGameEnd() {
    if (_hasShownResult) return;

    if (_gameProvider.isGameOver) {
      _hasShownResult = true;

      // Record game stats
      final settingsProvider = context.read<SettingsProvider>();
      settingsProvider.recordGame(
        _gameProvider.isWon,
        _gameProvider.elapsedSeconds,
      );

      // Update best time if won
      if (_gameProvider.isWon) {
        final currentBest = settingsProvider.getBestTime(widget.difficulty.name);
        if (currentBest == null || _gameProvider.elapsedSeconds < currentBest) {
          settingsProvider.updateBestTime(
            widget.difficulty.name,
            _gameProvider.elapsedSeconds,
          );
        }
      }

      // Show result screen after a short delay
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => VictoryScreen(
                isWon: _gameProvider.isWon,
                time: _gameProvider.elapsedSeconds,
                tilesCleared: _gameProvider.board.revealedCount,
                totalTiles: _gameProvider.board.safeCells,
                score: _gameProvider.calculateScore(),
                stars: _gameProvider.calculateStars(),
                difficulty: widget.difficulty,
                isNewBestTime: _gameProvider.isWon &&
                    (context.read<SettingsProvider>().getBestTime(widget.difficulty.name) ==
                        _gameProvider.elapsedSeconds),
                spellsUsed: _gameProvider.spellsUsed,
                manaRemaining: _gameProvider.mana,
              ),
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _gameProvider,
      child: Consumer<GameProvider>(
        builder: (context, gameProvider, child) {
          // Check for game end
          WidgetsBinding.instance.addPostFrameCallback((_) => _checkGameEnd());

          return Scaffold(
            body: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.gameGradient,
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    // Custom app bar
                    _buildAppBar(context),
                    // Status bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: StatusBarWidget(),
                    ),
                    // Game board
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: GameBoardWidget(),
                      ),
                    ),
                    // Spell bar
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: SpellBarWidget(),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          // Menu button
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryPurple.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(Icons.menu_rounded, color: AppColors.magicPurple),
              onPressed: () => _showGameMenu(context),
            ),
          ),
          const Spacer(),
          // Title
          Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_awesome, color: AppColors.sparkleGold, size: 18),
                  const SizedBox(width: 6),
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [AppColors.magicPurple, AppColors.primaryPink],
                    ).createShader(bounds),
                    child: const Text(
                      'Magic Sweeper',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(Icons.auto_awesome, color: AppColors.sparkleGold, size: 18),
                ],
              ),
              Text(
                widget.difficulty.name,
                style: TextStyle(
                  color: AppColors.magicPurple.withOpacity(0.6),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Spell book button
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryPurple.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(Icons.auto_stories_rounded, color: AppColors.magicPurple),
              tooltip: 'Spell Book',
              onPressed: () => _showSpellBook(context),
            ),
          ),
        ],
      ),
    );
  }

  void _showSpellBook(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => SpellBookDialog(
        currentEquipped: _gameProvider.equippedSpells,
        onSave: (spells) {
          _gameProvider.updateEquippedSpells(spells);
        },
      ),
    );
  }

  void _showGameMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryPurple.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.primaryPurple.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            _buildMenuItem(
              icon: Icons.refresh_rounded,
              label: 'New Game',
              color: AppColors.magicPurple,
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _hasShownResult = false;
                  _gameProvider.newGame();
                });
              },
            ),
            _buildMenuItem(
              icon: Icons.auto_stories_rounded,
              label: 'Spell Book',
              color: AppColors.primaryPink,
              onTap: () {
                Navigator.pop(context);
                _showSpellBook(context);
              },
            ),
            _buildMenuItem(
              icon: Icons.grid_view_rounded,
              label: 'Change Difficulty',
              color: AppColors.crystalBlue,
              onTap: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
            _buildMenuItem(
              icon: Icons.home_rounded,
              label: 'Main Menu',
              color: AppColors.buttonGray,
              onTap: () {
                Navigator.pop(context);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const MainMenuScreen()),
                  (route) => false,
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: (color ?? AppColors.magicPurple).withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color ?? AppColors.magicPurple, size: 22),
        ),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.magicPurple,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: (color ?? AppColors.magicPurple).withOpacity(0.5),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        tileColor: Colors.transparent,
        hoverColor: (color ?? AppColors.magicPurple).withOpacity(0.05),
      ),
    );
  }
}
