import 'package:flutter/material.dart';

class SpellBarWidget extends StatelessWidget {
  const SpellBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildSpellButton(
            icon: Icons.visibility,
            name: 'Reveal',
            cost: '10',
          ),
          _buildSpellButton(
            icon: Icons.search,
            name: 'Scan',
            cost: '15',
          ),
          _buildSpellButton(
            icon: Icons.shield,
            name: 'Shield',
            cost: '20',
          ),
          _buildSpellButton(
            icon: Icons.auto_fix_high,
            name: 'Purify',
            cost: '25',
          ),
        ],
      ),
    );
  }

  Widget _buildSpellButton({
    required IconData icon,
    required String name,
    required String cost,
  }) {
    return Opacity(
      opacity: 0.4,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.grey.shade300,
                width: 2,
              ),
            ),
            child: Icon(
              icon,
              color: Colors.grey.shade400,
              size: 28,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade500,
            ),
          ),
          Text(
            cost,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}
