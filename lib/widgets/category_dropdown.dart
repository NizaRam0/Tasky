import 'package:flutter/material.dart';
import '../utils/category_icons.dart';

class CategoryDropdown extends StatelessWidget {
  final String? selectedValue;
  final ValueChanged<String?>? onChanged;
  final bool enabled;
  final bool showIcons;

  const CategoryDropdown({
    super.key,
    required this.selectedValue,
    required this.onChanged,
    this.enabled = true,
    this.showIcons = true,
  });

  static const List<String> _categories = [
    'Personal',
    'Work',
    'Learning',
    'Sport/Activity',
    'Errands',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF1E1E1E),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        dropdownColor: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
        icon: const Icon(Icons.expand_more, color: Colors.white),

        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),

        hint: const Text(
          "Select category",
          style: TextStyle(color: Colors.white38),
        ),

        items: _categories.map((value) {
          return DropdownMenuItem(
            value: value,
            child: Row(
              children: [
                if (showIcons) ...[
                  Container(
                    padding: const EdgeInsets.only(top:2, bottom: 8, left: 8, right: 8),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      CategoryIcons.getIcon(value),
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Text(value),
              ],
            ),
          );
        }).toList(),

        onChanged: enabled ? onChanged : null,

        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFFFF5252),
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}