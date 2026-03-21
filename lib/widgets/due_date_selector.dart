import 'package:flutter/material.dart';

class DueDateSelector extends StatelessWidget {
  final DateTime? selectedDay;
  final VoidCallback? onPressed;
  final bool enabled;
  final String emptyLabel;
  final String prefixLabel;

  const DueDateSelector({
    super.key,
    required this.selectedDay,
    required this.onPressed,
    this.enabled = true,
    this.emptyLabel = 'Set due date',
    this.prefixLabel = 'Due:',
  });

  @override
  Widget build(BuildContext context) {
    final label = selectedDay == null
        ? emptyLabel
        : '$prefixLabel ${selectedDay!.day}/${selectedDay!.month}/${selectedDay!.year}';

    return ElevatedButton(
      onPressed: enabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: selectedDay == null
            ? Colors.white54
            : Colors.redAccent,
        minimumSize: const Size(double.infinity, 55),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.black, fontSize: 20),
          ),
          const Icon(Icons.calendar_month, color: Colors.black, size: 30),
        ],
      ),
    );
  }
}
