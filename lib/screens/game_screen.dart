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
        final currentBest =
            settingsProvider.getBestTime(widget.difficulty.name);
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
                    (context
                            .read<SettingsProvider>()
                            .getBestTime(widget.difficulty.name) ==
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
            backgroundColor: const Color(0xFF2D0A31), // Deep purple
            body: Stack(
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
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
          );
        },
      ),
    );
  }

  Widget _buildBackgroundDecorations() {
    return Stack(
      children: [
        // Grid pattern overlay (subtle)
        Positioned.fill(
          child: Opacity(
            opacity: 0.05,
            child: Image.asset(
              'assets/images/grid_pattern.png',
              repeat: ImageRepeat.repeat,
              errorBuilder: (_, __, ___) =>
                  Container(color: Colors.transparent),
            ),
          ),
        ),
        // Scattered pixel elements
        _buildPixelSquare(
            top: 100, left: 20, color: const Color(0xFFFACC15), size: 16),
        _buildPixelSquare(
            top: 200, right: 30, color: const Color(0xFFF472B6), size: 12),
        _buildPixelSquare(
            bottom: 150, left: 40, color: const Color(0xFF4ADE80), size: 14),
        _buildPixelSquare(
            bottom: 50, right: 60, color: const Color(0xFF2DD4BF), size: 18),
      ],
    );
  }

  Widget _buildPixelSquare(
      {double? top,
      double? bottom,
      double? left,
      double? right,
      required Color color,
      required double size}) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Transform.rotate(
        angle: 0.1,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.5),
                blurRadius: 4,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          // Menu button
          _buildRetroIconButton(
            icon: Icons.menu_rounded,
            color: const Color(0xFFC084FC), // Purple
            onPressed: () => _showGameMenu(context),
          ),
          const Spacer(),
          // Title / Difficulty
          Column(
            children: [
              Text(
                'MAGIC SWEEPER',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  letterSpacing: 1,
                  shadows: [
                    Shadow(color: Color(0xFF4C1D95), offset: Offset(2, 2)),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Text(
                  widget.difficulty.name.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          // Spell book button
          _buildRetroIconButton(
            icon: Icons.auto_stories_rounded,
            color: const Color(0xFFF472B6), // Pink
            onPressed: () => _showSpellBook(context),
          ),
        ],
      ),
    );
  }

  Widget _buildRetroIconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.black.withOpacity(0.2),
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              offset: const Offset(0, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Icon(
          icon,
          color: const Color(0xFF111827),
          size: 24,
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
          color: const Color(0xFF1F2937),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(
            color: const Color(0xFFFBBF24), // Gold border
            width: 4,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
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
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF374151),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            _buildMenuItem(
              icon: Icons.refresh_rounded,
              label: 'NEW GAME',
              color: const Color(0xFFC084FC),
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
              label: 'SPELL BOOK',
              color: const Color(0xFFF472B6),
              onTap: () {
                Navigator.pop(context);
                _showSpellBook(context);
              },
            ),
            _buildMenuItem(
              icon: Icons.grid_view_rounded,
              label: 'CHANGE DIFFICULTY',
              color: const Color(0xFF4ADE80),
              onTap: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
            _buildMenuItem(
              icon: Icons.home_rounded,
              label: 'MAIN MENU',
              color: const Color(0xFF9CA3AF),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const MainMenuScreen()),
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
    final itemColor = color ?? const Color(0xFFC084FC);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: itemColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.black.withOpacity(0.2),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  offset: const Offset(0, 4),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: const Color(0xFF111827),
                  size: 24,
                ),
                const SizedBox(width: 16),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF111827),
                    letterSpacing: 1,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Color(0xFF111827),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
