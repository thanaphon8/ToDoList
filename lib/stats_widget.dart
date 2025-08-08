import 'package:flutter/material.dart';

class StatsWidget extends StatelessWidget {
  final Map<String, int> stats;

  const StatsWidget({Key? key, required this.stats}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (stats['total']! == 0) return const SizedBox.shrink();

    return Container(
      color: isDark ? const Color(0xFF21262D) : Colors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatChip('All', stats['total']!, Colors.blue, isDark),
          _buildStatChip(
            'Completed',
            stats['completed']!,
            Colors.green,
            isDark,
          ),
          _buildStatChip('Pending', stats['pending']!, Colors.orange, isDark),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, int value, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(isDark ? 0.4 : 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? color.withOpacity(0.8) : color,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? color.withOpacity(0.8) : color,
            ),
          ),
        ],
      ),
    );
  }
}
