import 'package:flutter/material.dart';
/// The CategoryIcons class provides a static method getIcon that takes a category string as input and returns the corresponding IconData based on predefined categories. 
/// It uses a switch statement to match the category with specific icons for 
/// "Personal", "Work", "Learning", "Sport/Activity", and "Errands". 
/// If the category does not match any of the predefined cases, it returns a default icon (circle_outlined). 
/// This utility class is likely used in the app to display appropriate icons for tasks based on their assigned categories.

class CategoryIcons {

  static IconData getIcon(String? category) {

    switch (category) {
      case "Personal":
        return Icons.person_outline;

      case "Work":
        return Icons.work_outline;

      case "Learning":
        return Icons.menu_book_outlined;

      case "Sport/Activity":
        return Icons.fitness_center_outlined;

      case "Errands":
        return Icons.shopping_cart_outlined;

      default:
        return Icons.circle_outlined;
    }
  }
}