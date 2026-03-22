import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

/// THIS PAGE IS A CUSTOM CALENDAR WIDGET THAT IS USED IN THE HOME SCREEN                                                             ///////
/// TO DISPLAY THE CALENDAR AND ALLOW THE USER TO SELECT A DATE.                                                                     ///////
/// IT USES THE TABLE_CALENDAR PACKAGE TO DISPLAY THE CALENDAR AND PROVIDES CUSTOM STYLES TO MATCH THE DARK THEME OF THE APP.       ///////
/// ITS PROPS INCLUDE THE SELECTED DAY AND A CALLBACK FUNCTION THAT IS CALLED WHEN A DAY IS SELECTED.                              ///////
/// ITS IMPLEMENTED IN THE HOME SCREEN AND PASSES THE SELECTED DAY TO THE TASK LIST TO FILTER TASKS BASED ON THE DUE DATE.        ///////
///)                                     NIZARINSKY                                                                              ///////
/// ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

class CalendarWidget extends StatelessWidget {
  final DateTime selectedDay;
  // takes the currently selected day as a parameter and highlights it on the calendar. It is of type DateTime and is required to be passed when creating an instance of the CalendarWidget.
  final Function(DateTime) onDaySelected; 
  // takes a callback function that is called when a day is selected on the calendar. The function takes a DateTime parameter, which represents the selected day. 
  //This allows the parent widget (in this case, the home screen) to update its state and filter tasks based on the selected date.

  const CalendarWidget({
    super.key, 
    // The super.key is used to pass the key parameter to the parent class (StatelessWidget) constructor. This allows the widget to be properly identified and managed in the widget tree, especially when it comes to rebuilding and optimizing performance.
    required this.selectedDay,
    required this.onDaySelected,
    // The required keyword is used to indicate that the selectedDay and onDaySelected parameters must be provided when creating an instance of the CalendarWidget. This ensures that the widget has the necessary information to function correctly and prevents potential errors from missing parameters.
  });

  @override
  Widget build(BuildContext context) {
    /// The build method is responsible for building the UI of the CalendarWidget. It returns a Card widget that contains the TableCalendar widget. The Card provides a styled container for the calendar, while the TableCalendar displays the calendar interface and handles user interactions for selecting dates.
    return Card(
      color: const Color(0xFF1E1E1E),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: TableCalendar( //the imported calendar widget from the table_calendar package that provides a customizable calendar interface.
          focusedDay: selectedDay,
          firstDay: DateTime(2020), 
          lastDay: DateTime(2030),
          // the firstDay shown and lastDay shown parameters define the range of the calendar,
          // allowing users to navigate between years and months within that range. 
          //In this case, the calendar will display dates from January 1, 2020, to December 31, 2030.

          selectedDayPredicate: (day) => isSameDay(day, selectedDay), 
          // the day selected predicate is a function that checks if a given day is the same as the currently selected day. 
          //This is used to highlight the selected day on the calendar.

          onDaySelected: (selectedDay, focusedDay) {
            // the onDaySelected callback is triggered when a user selects a day on the calendar. It takes the selected day and the focused day as parameters.
            onDaySelected(selectedDay);
          },
/////////////////////////////////////////////STYLES////////////////////////////////////////////////////////////////////////////////////
          headerStyle: const HeaderStyle(
            titleCentered: true,
            formatButtonVisible: false,
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
            rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
          ),

          daysOfWeekStyle: const DaysOfWeekStyle(
            weekdayStyle: TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
            weekendStyle: TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.bold,
            ),
          ),

          calendarStyle: const CalendarStyle(
            defaultTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
            weekendTextStyle: TextStyle(
              color: Colors.redAccent,
              fontSize: 16,
            ),
            todayDecoration: BoxDecoration(
              color: Colors.orange,
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            selectedTextStyle: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            outsideDaysVisible: false,
          ),
          ////////////////////////////////////////////////////END OF STYLES////////////////////////////////////////////////////////////////////////////////////
        ),
      ),
    );
  }
}