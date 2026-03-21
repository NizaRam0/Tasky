import 'package:flutter/material.dart';

class PrioritySelector extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onChanged;
  final bool enabled;

  const PrioritySelector({
    super.key,
    required this.selected,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final priorities = [
      {'label': 'Low', 'color': Colors.green},
      {'label': 'Medium', 'color': Colors.orange},
      {'label': 'High', 'color': Colors.red},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: priorities.map((p) {
        final isSelected = selected == p['label'];

        return GestureDetector(
          onTap: enabled ? () => onChanged(p['label'] as String) : null,
          child: Opacity(
            opacity: enabled ? 1.0 : 0.5,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? (p['color'] as Color).withOpacity(0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: p['color'] as Color, width: 1.5),
              ),
              child: Text(
                p['label'] as String,
                style: TextStyle(
                  color: p['color'] as Color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
