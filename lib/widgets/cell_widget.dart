import 'package:flutter/material.dart';
import '../models/cell.dart';
import '../utils/constants.dart';

class CellWidget extends StatefulWidget {
  final Cell cell;
  final double cellSize;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final bool gameOver;
  final bool isWon;
  final bool isScanned;
  final bool isSpellTarget;
  final bool isPurified;

  const CellWidget({
    super.key,
    required this.cell,
    required this.onTap,
    required this.onLongPress,
    this.cellSize = 36.0,
    this.gameOver = false,
    this.isWon = false,
    this.isScanned = false,
    this.isSpellTarget = false,
    this.isPurified = false,
  });

  @override
  State<CellWidget> createState() => _CellWidgetState();
}

class _CellWidgetState extends State<CellWidget> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _scanController;
  late AnimationController _purifyController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scanGlowAnimation;
  late Animation<double> _purifyAnimation;

  @override
  void initState() {
    super.initState();

    // Pulse animation for spell target
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Scan glow animation - pulsing effect
    _scanController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scanGlowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _scanController, curve: Curves.easeInOut),
    );

    // Purify sparkle animation
    _purifyController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _purifyAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _purifyController, curve: Curves.easeInOut),
    );

    // Start animations if already in the state
    if (widget.isScanned) {
      _scanController.repeat(reverse: true);
    }
    if (widget.isSpellTarget) {
      _pulseController.repeat(reverse: true);
    }
    if (widget.isPurified) {
      _purifyController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(CellWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle spell target animation
    if (widget.isSpellTarget && !oldWidget.isSpellTarget) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isSpellTarget && oldWidget.isSpellTarget) {
      _pulseController.stop();
      _pulseController.reset();
    }

    // Handle scan animation - FIXED: Start animation when isScanned becomes true
    if (widget.isScanned && !oldWidget.isScanned) {
      _scanController.repeat(reverse: true);
    } else if (!widget.isScanned && oldWidget.isScanned) {
      _scanController.stop();
      _scanController.reset();
    }

    // Handle purify animation
    if (widget.isPurified && !oldWidget.isPurified) {
      _purifyController.repeat(reverse: true);
    } else if (!widget.isPurified && oldWidget.isPurified) {
      _purifyController.stop();
      _purifyController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scanController.dispose();
    _purifyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Scale icon and font sizes based on cell size
    final iconSize = (widget.cellSize * 0.55).clamp(16.0, 24.0);
    final fontSize = (widget.cellSize * 0.5).clamp(14.0, 22.0);
    final borderRadius = (widget.cellSize * 0.22).clamp(6.0, 12.0);
    final margin = (widget.cellSize * 0.04).clamp(1.5, 2.5);

    Widget cellContent = GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.all(margin),
        decoration: BoxDecoration(
          gradient: _getCellGradient(),
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: _getCellShadow(),
          border: _getCellBorder(),
        ),
        child: Stack(
          children: [
            // Glossy highlight overlay for 3D effect
            if (!widget.cell.isRevealed || widget.cell.isMine)
              Positioned(
                top: 2,
                left: 2,
                right: widget.cellSize * 0.4,
                bottom: widget.cellSize * 0.5,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(borderRadius - 2),
                      topRight: Radius.circular(borderRadius * 0.5),
                      bottomLeft: Radius.circular(borderRadius * 0.3),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.4),
                        Colors.white.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),
            // Main content
            Center(
              child: _buildCellContent(iconSize, fontSize),
            ),
            // Scan overlay with animated pulsing glow - FIXED
            if (widget.isScanned)
              AnimatedBuilder(
                animation: _scanGlowAnimation,
                builder: (context, child) {
                  final glowValue = _scanGlowAnimation.value;
                  return Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(borderRadius),
                        gradient: RadialGradient(
                          colors: [
                            AppColors.scanGlow.withOpacity(0.7 * glowValue),
                            AppColors.scanPulse.withOpacity(0.4 * glowValue),
                          ],
                        ),
                        border: Border.all(
                          color: Color.lerp(
                            AppColors.scanGlow,
                            AppColors.scanPulse,
                            glowValue,
                          )!,
                          width: 2 + glowValue,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                AppColors.scanGlow.withOpacity(0.7 * glowValue),
                            blurRadius: 10 + (8 * glowValue),
                            spreadRadius: 2 * glowValue,
                          ),
                          BoxShadow(
                            color: AppColors.scanPulse
                                .withOpacity(0.5 * glowValue),
                            blurRadius: 15,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.white,
                          size: iconSize * (0.8 + 0.2 * glowValue),
                          shadows: [
                            Shadow(
                              color: AppColors.scanGlow,
                              blurRadius: 10 * glowValue,
                            ),
                            Shadow(
                              color: AppColors.scanPulse,
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            // Spell target overlay with pulse animation
            if (widget.isSpellTarget && !widget.cell.isRevealed)
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(borderRadius),
                        color: AppColors.magicPurple.withOpacity(0.15),
                        border: Border.all(
                          color: AppColors.magicPurple.withOpacity(
                              0.6 + 0.4 * (_pulseAnimation.value - 1) * 12.5),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.magicPurple.withOpacity(0.3),
                            blurRadius: 6 * _pulseAnimation.value,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.auto_awesome,
                          color: AppColors.magicPurple.withOpacity(0.6),
                          size: iconSize * 0.7 * _pulseAnimation.value,
                        ),
                      ),
                    ),
                  );
                },
              ),
            // Purify sparkle effect - FIXED with animation
            if (widget.isPurified)
              AnimatedBuilder(
                animation: _purifyAnimation,
                builder: (context, child) {
                  final sparkleValue = _purifyAnimation.value;
                  return Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(borderRadius),
                        gradient: RadialGradient(
                          colors: [
                            AppColors.purifyGlow
                                .withOpacity(0.5 * sparkleValue),
                            AppColors.purifySparkle
                                .withOpacity(0.2 * sparkleValue),
                          ],
                        ),
                        border: Border.all(
                          color: AppColors.purifyGlow
                              .withOpacity(0.6 * sparkleValue),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.purifyGlow
                                .withOpacity(0.5 * sparkleValue),
                            blurRadius: 8 + (6 * sparkleValue),
                            spreadRadius: sparkleValue,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.auto_awesome,
                          color: Colors.white.withOpacity(0.8 * sparkleValue),
                          size: iconSize * 0.6 * (0.8 + 0.2 * sparkleValue),
                          shadows: [
                            Shadow(
                              color: AppColors.purifyGlow,
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );

    // Wrap with scale animation for spell target
    if (widget.isSpellTarget && !widget.cell.isRevealed) {
      return AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: cellContent,
          );
        },
      );
    }

    return cellContent;
  }

  LinearGradient? _getCellGradient() {
    if (widget.cell.isFlagged) {
      // Flagged cell - Gold retro style
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFFDE047), // Light gold
          Color(0xFFFBBF24), // Gold
        ],
        stops: [0.0, 0.6],
      );
    }

    if (widget.cell.isRevealed) {
      if (widget.cell.isMine) {
        if (widget.gameOver && !widget.isWon) {
          // Exploded mine - Coral red
          return const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFCA5A5), // Light red
              Color(0xFFF87171), // Coral red
            ],
            stops: [0.0, 0.6],
          );
        }
        // Safe mine (won) - Mint green
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF6EE7B7), // Light mint
            Color(0xFF34D399), // Mint
          ],
          stops: [0.0, 0.6],
        );
      }
      // Revealed empty cell - Dark surface
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF4B5563), // Lighter surface
          Color(0xFF374151), // Dark surface
        ],
      );
    }

    // Covered cell - Indigo retro style
    return const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFF818CF8), // Light indigo
        Color(0xFF6366F1), // Indigo
      ],
      stops: [0.0, 0.6],
    );
  }

  List<BoxShadow>? _getCellShadow() {
    if (widget.isScanned) {
      return [
        BoxShadow(
          color: AppColors.scanGlow.withOpacity(0.6),
          blurRadius: 12,
          spreadRadius: 2,
        ),
      ];
    }

    if (widget.cell.isCovered || widget.cell.isFlagged) {
      // Chunky retro arcade shadow
      return [
        // Solid drop shadow for 3D effect
        BoxShadow(
          color: Colors.black.withOpacity(0.5),
          blurRadius: 0,
          offset: const Offset(2, 3),
        ),
      ];
    }

    // Revealed cell - subtle inset look
    return [
      BoxShadow(
        color: Colors.black.withOpacity(0.2),
        blurRadius: 2,
        offset: const Offset(1, 1),
      ),
    ];
  }

  Border? _getCellBorder() {
    if (widget.isScanned) {
      return Border.all(color: AppColors.scanGlow, width: 2);
    }

    if (widget.cell.isFlagged) {
      // Gold border for flagged cells
      return Border.all(color: const Color(0xFFD97706), width: 3);
    }

    if (widget.cell.isRevealed) {
      return Border.all(color: const Color(0xFF4B5563), width: 1);
    }

    // Covered cell - chunky border
    return Border.all(
      color: const Color(0xFF4338CA),
      width: 3,
    );
  }

  Widget? _buildCellContent(double iconSize, double fontSize) {
    if (widget.cell.isFlagged) {
      return Icon(
        Icons.flag_rounded,
        color: Colors.white,
        size: iconSize,
        shadows: const [
          Shadow(
            color: Color(0x60000000),
            offset: Offset(1, 1),
            blurRadius: 2,
          ),
        ],
      );
    }

    if (widget.cell.isRevealed) {
      if (widget.cell.isMine) {
        return Icon(
          widget.gameOver && !widget.isWon
              ? Icons.close_rounded
              : Icons.check_circle_rounded,
          color: Colors.white,
          size: iconSize,
          shadows: const [
            Shadow(
              color: Color(0x60000000),
              offset: Offset(1, 1),
              blurRadius: 2,
            ),
          ],
        );
      }

      if (widget.cell.adjacentMines > 0) {
        return Text(
          '${widget.cell.adjacentMines}',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: AppColors.numberColors[widget.cell.adjacentMines - 1],
            shadows: const [
              Shadow(
                color: Color(0x40000000),
                offset: Offset(1, 1),
                blurRadius: 2,
              ),
            ],
          ),
        );
      }
    }

    return null;
  }
}
