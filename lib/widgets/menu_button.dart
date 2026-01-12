import 'package:flutter/material.dart';
import '../utils/constants.dart';

class MenuButton extends StatefulWidget {
  final String text;
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;
  final String? badge;
  final bool enabled;

  const MenuButton({
    super.key,
    required this.text,
    required this.icon,
    required this.color,
    this.onPressed,
    this.badge,
    this.enabled = true,
  });

  @override
  State<MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<MenuButton> with TickerProviderStateMixin {
  late AnimationController _pressController;
  late AnimationController _glowController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  bool _isPressed = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    // Press animation
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 80),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeOut),
    );

    // Subtle idle glow animation
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.6).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.enabled) {
      setState(() => _isPressed = true);
      _pressController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.enabled) {
      setState(() => _isPressed = false);
      _pressController.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.enabled) {
      setState(() => _isPressed = false);
      _pressController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = !widget.enabled;
    final baseColor = isDisabled ? Colors.grey.shade700 : widget.color;

    // Pixel-art color palette
    final highlightColor = Color.lerp(baseColor, Colors.white, 0.5)!;
    final midColor = baseColor;
    final shadowColor = Color.lerp(baseColor, Colors.black, 0.4)!;
    final darkColor = Color.lerp(baseColor, Colors.black, 0.6)!;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: widget.enabled ? widget.onPressed : null,
        child: AnimatedBuilder(
          animation: Listenable.merge([_scaleAnimation, _glowAnimation]),
          builder: (context, child) {
            final glowOpacity = _isHovered ? 0.6 : _glowAnimation.value * 0.4;
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Outer glow effect
                  if (widget.enabled)
                    Positioned(
                      top: -4,
                      left: -4,
                      right: -4,
                      bottom: -4,
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              BoxShadow(
                                color: baseColor.withValues(alpha: glowOpacity),
                                blurRadius: _isHovered ? 20 : 12,
                                spreadRadius: _isHovered ? 2 : 0,
                              ),
                            ],
                          ),
                          child: const SizedBox.expand(),
                        ),
                      ),
                    ),

                  // Main pixel button
                  CustomPaint(
                    painter: PixelButtonPainter(
                      baseColor: midColor,
                      highlightColor: highlightColor,
                      shadowColor: shadowColor,
                      darkColor: darkColor,
                      isPressed: _isPressed,
                      isDisabled: isDisabled,
                    ),
                    child: Container(
                      width: double.infinity,
                      height: 72,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Stack(
                        children: [
                          // Scanline effect overlay
                          if (widget.enabled)
                            Positioned.fill(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: CustomPaint(
                                  painter: ScanlinePainter(),
                                ),
                              ),
                            ),

                          // Content
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Pixel-styled icon container
                                _buildPixelIcon(baseColor, darkColor),
                                const SizedBox(width: 16),
                                // Text with pixel shadow
                                _buildPixelText(shadowColor),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Corner pixel decorations
                  ..._buildCornerPixels(highlightColor, shadowColor),

                  // Badge
                  if (widget.badge != null) _buildPixelBadge(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPixelIcon(Color baseColor, Color darkColor) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: const Color(0xFF1A0A1F),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            offset: const Offset(2, 2),
            blurRadius: 0,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Inner highlight
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 2,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
              ),
            ),
          ),
          Center(
            child: Icon(
              widget.icon,
              color: widget.enabled ? widget.color : Colors.grey,
              size: 22,
              shadows: widget.enabled
                  ? [
                      Shadow(
                        color: widget.color.withValues(alpha: 0.8),
                        blurRadius: 6,
                      ),
                    ]
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPixelText(Color shadowColor) {
    return Stack(
      children: [
        // Shadow layer (offset)
        Transform.translate(
          offset: const Offset(2, 2),
          child: Text(
            widget.text.toUpperCase(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Colors.black.withValues(alpha: 0.6),
              letterSpacing: 2,
            ),
          ),
        ),
        // Main text with gradient
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Colors.white.withValues(alpha: 0.85),
            ],
          ).createShader(bounds),
          child: Text(
            widget.text.toUpperCase(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 2,
              shadows: widget.enabled
                  ? [
                      Shadow(
                        color: widget.color.withValues(alpha: 0.5),
                        blurRadius: 8,
                      ),
                    ]
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildCornerPixels(Color highlight, Color shadow) {
    const pixelSize = 4.0;
    return [
      // Top-left corner pixels
      Positioned(
        top: 0,
        left: 0,
        child: DecoratedBox(
          decoration: BoxDecoration(color: highlight),
          child: const SizedBox(width: pixelSize, height: pixelSize),
        ),
      ),
      Positioned(
        top: pixelSize,
        left: 0,
        child: DecoratedBox(
          decoration: BoxDecoration(color: highlight.withValues(alpha: 0.5)),
          child: const SizedBox(width: pixelSize, height: pixelSize),
        ),
      ),
      Positioned(
        top: 0,
        left: pixelSize,
        child: DecoratedBox(
          decoration: BoxDecoration(color: highlight.withValues(alpha: 0.5)),
          child: const SizedBox(width: pixelSize, height: pixelSize),
        ),
      ),
      // Bottom-right corner pixels
      Positioned(
        bottom: 0,
        right: 0,
        child: DecoratedBox(
          decoration: BoxDecoration(color: shadow),
          child: const SizedBox(width: pixelSize, height: pixelSize),
        ),
      ),
      Positioned(
        bottom: pixelSize,
        right: 0,
        child: DecoratedBox(
          decoration: BoxDecoration(color: shadow.withValues(alpha: 0.5)),
          child: const SizedBox(width: pixelSize, height: pixelSize),
        ),
      ),
      Positioned(
        bottom: 0,
        right: pixelSize,
        child: DecoratedBox(
          decoration: BoxDecoration(color: shadow.withValues(alpha: 0.5)),
          child: const SizedBox(width: pixelSize, height: pixelSize),
        ),
      ),
    ];
  }

  Widget _buildPixelBadge() {
    return Positioned(
      top: -14,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFF1A0A1F),
          border: Border.all(color: AppColors.retroGold, width: 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.retroGold.withValues(alpha: 0.4),
              blurRadius: 8,
              spreadRadius: 1,
            ),
            const BoxShadow(
              color: Colors.black,
              offset: Offset(2, 2),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.star,
              color: AppColors.retroGold,
              size: 12,
              shadows: [
                Shadow(
                  color: AppColors.retroGold.withValues(alpha: 0.8),
                  blurRadius: 4,
                ),
              ],
            ),
            const SizedBox(width: 4),
            Text(
              widget.badge!,
              style: TextStyle(
                color: AppColors.retroGold,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: AppColors.retroGold.withValues(alpha: 0.5),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for the pixel-art button body
class PixelButtonPainter extends CustomPainter {
  final Color baseColor;
  final Color highlightColor;
  final Color shadowColor;
  final Color darkColor;
  final bool isPressed;
  final bool isDisabled;

  PixelButtonPainter({
    required this.baseColor,
    required this.highlightColor,
    required this.shadowColor,
    required this.darkColor,
    required this.isPressed,
    required this.isDisabled,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const borderWidth = 3.0;

    // Draw drop shadow (offset behind button)
    if (!isPressed) {
      final shadowRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(4, 4, size.width, size.height),
        const Radius.circular(4),
      );
      canvas.drawRRect(
        shadowRect,
        Paint()..color = Colors.black.withValues(alpha: 0.5),
      );
    }

    // Main button rect
    final buttonRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
          0, isPressed ? 2 : 0, size.width, size.height - (isPressed ? 2 : 0)),
      const Radius.circular(4),
    );

    // Draw outer dark border
    canvas.drawRRect(
      buttonRect,
      Paint()..color = darkColor,
    );

    // Draw main body with gradient
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        borderWidth,
        borderWidth + (isPressed ? 2 : 0),
        size.width - borderWidth * 2,
        size.height - borderWidth * 2 - (isPressed ? 2 : 0),
      ),
      const Radius.circular(2),
    );

    // Gradient fill
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: isPressed
          ? [baseColor, shadowColor]
          : [highlightColor, baseColor, shadowColor],
      stops: isPressed ? null : const [0.0, 0.3, 1.0],
    );

    final rect = Rect.fromLTWH(
      borderWidth,
      borderWidth + (isPressed ? 2 : 0),
      size.width - borderWidth * 2,
      size.height - borderWidth * 2 - (isPressed ? 2 : 0),
    );

    canvas.drawRRect(
      bodyRect,
      Paint()..shader = gradient.createShader(rect),
    );

    // Top inner highlight (bevel effect)
    if (!isPressed) {
      final highlightPath = Path()
        ..moveTo(borderWidth + 4, borderWidth + 4)
        ..lineTo(size.width - borderWidth - 4, borderWidth + 4)
        ..lineTo(size.width - borderWidth - 8, borderWidth + 10)
        ..lineTo(borderWidth + 8, borderWidth + 10)
        ..close();

      canvas.drawPath(
        highlightPath,
        Paint()..color = Colors.white.withValues(alpha: 0.35),
      );
    }

    // Bottom inner shadow
    final shadowPath = Path()
      ..moveTo(
          borderWidth + 4, size.height - borderWidth - 4 - (isPressed ? 2 : 0))
      ..lineTo(size.width - borderWidth - 4,
          size.height - borderWidth - 4 - (isPressed ? 2 : 0))
      ..lineTo(size.width - borderWidth - 8,
          size.height - borderWidth - 10 - (isPressed ? 2 : 0))
      ..lineTo(
          borderWidth + 8, size.height - borderWidth - 10 - (isPressed ? 2 : 0))
      ..close();

    canvas.drawPath(
      shadowPath,
      Paint()..color = Colors.black.withValues(alpha: 0.2),
    );

    // Pixel detail lines on sides
    final leftLinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(borderWidth + 2, borderWidth + 12 + (isPressed ? 2 : 0)),
      Offset(borderWidth + 2,
          size.height - borderWidth - 12 - (isPressed ? 2 : 0)),
      leftLinePaint,
    );

    final rightLinePaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.15)
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(
          size.width - borderWidth - 2, borderWidth + 12 + (isPressed ? 2 : 0)),
      Offset(size.width - borderWidth - 2,
          size.height - borderWidth - 12 - (isPressed ? 2 : 0)),
      rightLinePaint,
    );
  }

  @override
  bool shouldRepaint(covariant PixelButtonPainter oldDelegate) {
    return oldDelegate.isPressed != isPressed ||
        oldDelegate.baseColor != baseColor;
  }
}

/// Scanline effect painter for CRT look
class ScanlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.08)
      ..strokeWidth = 1;

    // Draw horizontal scanlines
    for (double y = 0; y < size.height; y += 3) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
