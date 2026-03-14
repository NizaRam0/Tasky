import 'package:flutter/material.dart';
///// The PriorityColors class defines a set of static constants representing 
///different colors for task priorities (high, medium, low) and completed tasks. It also includes a static method getColor that takes a priority string and a boolean indicating whether the task is completed. The method returns the appropriate color based on the priority level or the completed status of the task. If the task is completed, it returns the completed color; otherwise, it checks the priority and returns the corresponding color. If the priority is not recognized, it defaults to returning grey.
class PriorityColors {

  static const Color high = Color.fromARGB(255, 255, 145, 0); // amber
  static const Color medium = Color(0xFFFFD700); // yellow
  static const Color low = Color(0xFF4CAF50); // green
  static const Color completed = Color(0xFFBDBDBD); // gray
  static const Color defaultColor = Color(0xFF1E1E1E); // default color for unrecognized priorities

  static Color getColor(String? priority, bool isCompleted) {

    if (isCompleted) {
      return completed;
    }

    switch (priority) {
      case "High":
        return high;

      case "Medium":
        return medium;

      case "Low":
        return low;

      default:
        return defaultColor;
    }
  }
}
