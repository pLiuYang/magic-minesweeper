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

class _MenuButtonState extends State<MenuButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.enabled) {
      setState(() => _isPressed = true);
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.enabled) {
      setState(() => _isPressed = false);
      _controller.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.enabled) {
      setState(() => _isPressed = false);
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = !widget.enabled;
    // Use the exact color provided, or gray if disabled
    final baseColor = isDisabled ? Colors.grey.shade600 : widget.color;

    // Calculate highlight (top) and shadow (bottom/border) colors for pseudo-3D look
    final highlightColor = Color.lerp(baseColor, Colors.white, 0.4)!;
    final shadowColor = Color.lerp(baseColor, Colors.black, 0.4)!;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.enabled ? widget.onPressed : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Drop shadow block (drawn behind everything)
                Positioned(
                  top: 6,
                  left: 0,
                  right: 0,
                  bottom: -6,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF111827)
                          .withOpacity(0.6), // Dark shadow
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),

                // Main Button Body
                Container(
                  width: double.infinity,
                  height: 68,
                  decoration: BoxDecoration(
                    color: baseColor,
                    borderRadius: BorderRadius.circular(16),
                    // Hard border
                    border: Border.all(
                      color: shadowColor,
                      width: 3,
                    ),
                    // Inner bevel effect
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        highlightColor,
                        baseColor,
                        baseColor,
                      ],
                      stops: const [0.0, 0.1, 1.0],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Inner highlight line at top
                      Positioned(
                        top: 2,
                        left: 4,
                        right: 4,
                        height: 4,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),

                      // Label & Icon
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Text
                            Text(
                              widget.text.toUpperCase(),
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight
                                    .w900, // Extra bold for blocky look
                                color: const Color(0xFF111827), // Dark text
                                letterSpacing: 1.2,
                                shadows: [
                                  Shadow(
                                    color: Colors.white.withOpacity(0.3),
                                    offset: const Offset(0, 1),
                                    blurRadius: 0,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Icon on RIGHT side now, as per mockup
                            Icon(
                              widget.icon,
                              color: const Color(0xFF111827),
                              size: 26,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Badge (if applicable)
                if (widget.badge != null)
                  Positioned(
                    top: -12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF111827), // Dark bg
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: AppColors.retroGold,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.badge!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
