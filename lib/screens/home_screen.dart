import 'package:app6/screens/add_screen.dart';
import 'package:flutter/material.dart';
//import 'package:hive_flutter/hive_flutter.dart';
import '../widgets/calTable.dart';
import '../widgets/todo_title.dart';
//import '../models/task.dart';
//import 'package:hive/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../notifiers/task_Notifier.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>{


///for hive no need now while using provider, the provider will handle all interactions with hive and provide the necessary data to the UI
            //final box = Hive.box<Task>('TasksBox');// This line initializes a Hive box for storing Task objects. 
            //The box is named 'TasksBox' and is used to read and write tasks in the Hive database.

  
  DateTime selectedDay = DateTime.now(); 
  //selectedDay is a DateTime variable that holds the currently selected date in the calendar.
  // It is initialized to the current date using DateTime.now().
  // used in the CalendarWidget to highlight the selected date and to filter tasks based on their due dates.

  

  @override
  Widget build(BuildContext context) {
      
      final tasks = ref.watch(taskProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
     ////////////////////////////////////////NAVBAR///////////////////////////////////////////////////////////////
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            //ADD TASK BUTTON ICON NAVIGATES TO ADD TASK SCREEN
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const addTask()),
                );
              },
              icon: const Icon(Icons.add, size: 40),
              color: Colors.redAccent,
            ),

            //END OF ADD TASK BUTTON

            // APP TITLE "Tasky"

            const Text(
              "Tasky",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF121212),
              ),
            ),
            //END OF APP TITLE

            /// PROFILE BUTTON TAKES USER TO PROFILE SCREEN *(NOT IMPLEMENTED YET)* OR SHOWS ALL USERS TASKS WITH SPECIFIED DATE AND STATUS AND DETAILS
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.person, size: 40),
              color: Colors.redAccent,
            ),
            //END OF PROFILE BUTTON
          ],
        ),
        elevation: 0,
      ),
////////////////////////////////////////////////////////////END OF NAVBAR/////////////////////////////////////////////

////////////////////////////////////////////////////////////PAGE BODY/////////////////////////////////////////////////
    
      body: Padding(
        // The body of the Scaffold is wrapped in a Padding widget to provide consistent spacing around the content.
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            /// CALENDAR WIDGET DISPLAYS CALENDAR AND ALLOWS USER TO SELECT A DATE TO VIEW TASKS DUE ON THAT DATE
            CalendarWidget(
              selectedDay: selectedDay,
              onDaySelected: (day) {
                setState(() { 
                  selectedDay = day;
                });
              },
            ),
            /// END OF CALENDAR WIDGET
            
            const SizedBox(height: 30),// A SizedBox is used to add vertical spacing between the CalendarWidget and the TaskSectionWidget.

            /// TASK LIST
            Expanded( //USE EXPANDED TO TAKE UP REMAINING SPACE IN THE COLUMN 
                     // AND ALLOW THE TASK LIST TO SCROLL IF IT EXCEEDS THE AVAILABLE SPACE
              
              child: TaskSectionWidget(
                selectedDay: selectedDay,
                tasks: tasks, // Pass the list of tasks from the provider to the TaskSectionWidget
                ),
              
              
              
              /*ValueListenableBuilder(
                // The ValueListenableBuilder listens to changes in the Hive box and rebuilds the TaskSectionWidget whenever there is a change in the tasks stored in the box.
                valueListenable: box.listenable(), //listenable to changes in the box 
                
                builder: (context, Box<Task> box, _) {
      //runs whenever there is a change in the box, providing the updated box as a parameter to the builder function.

                  final tasks = box.values.toList();

                  //Task widget 
                  return TaskSectionWidget(
                    // The TaskSectionWidget is a custom widget that displays the list of tasks. It takes the selectedDay and the list of tasks as parameters to filter and display the tasks based on their due dates.
                    selectedDay: selectedDay,
                    tasks: tasks,
                  );
                  //End of Task widget
                },
              ),*/
            ),
          ],
        ),
      ),
    );
    //////////////////////////////////////////////END OF PAGE BODY////////////////////////////////////////////////
  }
}