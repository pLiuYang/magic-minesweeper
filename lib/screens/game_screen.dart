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
            backgroundColor: AppColors.backgroundLight,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.menu, color: Colors.black87),
                onPressed: () => _showGameMenu(context),
              ),
              title: const Text(
                'Magic MineSweeper',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.auto_stories, color: AppColors.primaryPurple),
                  tooltip: 'Spell Book',
                  onPressed: () => _showSpellBook(context),
                ),
              ],
            ),
            body: SafeArea(
              child: Column(
                children: [
                  // Status bar
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: StatusBarWidget(),
                  ),
                  // Game board
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GameBoardWidget(),
                    ),
                  ),
                  // Spell bar
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: SpellBarWidget(),
                  ),
                ],
              ),
            ),
          );
        },
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            _buildMenuItem(
              icon: Icons.refresh,
              label: 'New Game',
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _hasShownResult = false;
                  _gameProvider.newGame();
                });
              },
            ),
            _buildMenuItem(
              icon: Icons.auto_stories,
              label: 'Spell Book',
              color: AppColors.primaryPurple,
              onTap: () {
                Navigator.pop(context);
                _showSpellBook(context);
              },
            ),
            _buildMenuItem(
              icon: Icons.grid_view,
              label: 'Change Difficulty',
              onTap: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
            _buildMenuItem(
              icon: Icons.home,
              label: 'Main Menu',
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
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.primaryBlue),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
