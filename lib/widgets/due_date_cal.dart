import 'package:flutter/material.dart';
import 'dart:core';
/// THIS FUNCTION SHOWS A DATE PICKER DIALOG TO THE USER WHEN THEY WANT TO SET A DUE DATE FOR A TASK.
/// IT USES THE SHOWDATEPICKER FUNCTION FROM THE FLUTTER MATERIAL PACKAGE TO DISPLAY THE DATE PICKER AND ALLOWS THE USER TO SELECT A DATE.
/// THE DATE PICKER IS STYLED TO MATCH THE DARK THEME OF THE APP, WITH A RED ACCENT COLOR FOR THE PRIMARY COLOR AND WHITE TEXT FOR THE ONPRIMARY AND ONSURFACE COLORS.
Future<DateTime?> showDueDatePicker(
  BuildContext context,
  DateTime selectedDay,
) {
  return showDatePicker(
    context: context,
    initialDate: selectedDay,
    firstDate: DateTime(DateTime.now().year ),// the first date shown in the date picker is set to the current year, allowing users to select dates starting from January 1 of the current year. This ensures that users cannot select past dates for task due dates, which is a common requirement for task management applications.
    lastDate: DateTime(DateTime.now().year + 20 ),

    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Colors.redAccent,
            onPrimary: Colors.white,
            surface: Color(0xFF1E1E1E),
            onSurface: Colors.white,
          ),
          

          dialogBackgroundColor: const Color(0xFF1E1E1E),


        inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.white54),
        labelStyle: TextStyle(color: Colors.white),
                          ),
        textTheme: const TextTheme(
        bodyMedium: TextStyle(color: Colors.white),
                          ),

          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: Colors.redAccent,
            ),
          ),
        ),
        child: child!,
      );
    },
  );
}