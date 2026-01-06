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
              child: Stack(
                children: [
                  // Background decorations
                  _buildBackgroundDecorations(),
                  // Main content
                  SafeArea(
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
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBackgroundDecorations() {
    return Stack(
      children: [
        // Decorative circles
        Positioned(
          top: -30,
          right: -30,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.candyPink.withOpacity(0.2),
                  AppColors.candyPink.withOpacity(0.0),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 100,
          left: -40,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.candyPurple.withOpacity(0.15),
                  AppColors.candyPurple.withOpacity(0.0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          // Menu button - Candy style
          _buildIconButton(
            icon: Icons.menu_rounded,
            color: AppColors.candyPurple,
            onPressed: () => _showGameMenu(context),
          ),
          const Spacer(),
          // Title - Candy Crush style
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFFFB6C1),
                  Color(0xFFFF69B4),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.candyPink.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome, color: AppColors.sparkleGold, size: 16),
                    const SizedBox(width: 6),
                    const Text(
                      'Magic Sweeper',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        shadows: [
                          Shadow(
                            color: Color(0x60000000),
                            offset: Offset(1, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(Icons.auto_awesome, color: AppColors.sparkleGold, size: 16),
                  ],
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.difficulty.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          // Spell book button - Candy style
          _buildIconButton(
            icon: Icons.auto_stories_rounded,
            color: AppColors.candyPink,
            onPressed: () => _showSpellBook(context),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    final lightColor = Color.lerp(color, Colors.white, 0.3)!;
    final darkColor = Color.lerp(color, Colors.black, 0.2)!;
    
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [lightColor, color, darkColor],
            stops: const [0.0, 0.5, 1.0],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white.withOpacity(0.4),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Glossy highlight
            Positioned(
              top: 2,
              left: 4,
              right: 4,
              height: 12,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.4),
                      Colors.white.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
            Center(
              child: Icon(
                icon,
                color: Colors.white,
                size: 22,
                shadows: const [
                  Shadow(
                    color: Color(0x60000000),
                    offset: Offset(1, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
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
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFF0F5),
              Colors.white,
            ],
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(
            color: AppColors.sparkleGold.withOpacity(0.5),
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.candyPurple.withOpacity(0.2),
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
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.candyPurple, AppColors.candyPink],
                ),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 24),
            _buildMenuItem(
              icon: Icons.refresh_rounded,
              label: 'New Game',
              color: AppColors.candyPurple,
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
              color: AppColors.candyPink,
              onTap: () {
                Navigator.pop(context);
                _showSpellBook(context);
              },
            ),
            _buildMenuItem(
              icon: Icons.grid_view_rounded,
              label: 'Change Difficulty',
              color: AppColors.candyBlue,
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
    final itemColor = color ?? AppColors.candyPurple;
    final lightColor = Color.lerp(itemColor, Colors.white, 0.3)!;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: itemColor.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [lightColor, itemColor],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: itemColor.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 22,
                    shadows: const [
                      Shadow(
                        color: Color(0x60000000),
                        offset: Offset(1, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.chevron_right_rounded,
                  color: itemColor.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
