import 'package:flutter/material.dart';
import '../widgets/dueDate_cal.dart';
import '../models/task.dart';
//import 'package:hive/hive.dart';
import '../utils/TidGen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../notifiers/task_Notifier.dart';

class addTask extends ConsumerStatefulWidget {
  const addTask({super.key});

  @override
  ConsumerState<addTask> createState() => _addTaskState();
}

class _addTaskState extends ConsumerState<addTask> {
  //final taskDB = Hive.box<Task>('TasksBox');

  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();

  String? priority;
  DateTime? selectedDay;
  String? category;

  @override
  void dispose() {
    titleController
        .dispose(); // The dispose method is overridden to clean up the resources used by the TextEditingController instances when the widget is removed from the widget tree. This is important to prevent memory leaks and ensure that the controllers are properly disposed of when they are no longer needed.
    descController
        .dispose(); // The dispose method is overridden to clean up the resources used by the TextEditingController instances when the widget is removed from the widget tree. This is important to prevent memory leaks and ensure that the controllers are properly disposed of when they are no longer needed.
    super
        .dispose(); // The super.dispose() call ensures that any additional cleanup logic defined in the parent class (ConsumerState) is also executed.
  } //better to dispose of the controllers when the widget is removed from the widget tree to free up resources and prevent memory leaks.

  // The _pickDate function is an asynchronous function that allows the user to select a due date for the task.
  //It uses the showDueDatePicker function (presumably defined in the dueDate_cal.dart file) to display a date picker dialog.
  //The selected date is then stored in the selectedDay variable, and the UI is updated using setState to reflect the chosen date.

  void _pickDate() async {
    final pickedDate = await showDueDatePicker(
      context,
      selectedDay ?? DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        //no need to use setState to update selectedDay because the CalendarWidget will call the onDaySelected callback with the new selected day, and the TaskSectionWidget will automatically rebuild and display tasks for the new selected day based on the updated state provided by the taskProvider.
        selectedDay = pickedDate;
      });
    }
  }

  /// The saveTask function is responsible for creating a new Task object with the provided title, description, due date, and priority. It first checks if the title is empty or if the due date is not selected. If either of these conditions is true, it shows a SnackBar message indicating that the title and due date are required. If both fields are valid, it creates a new Task object and adds it to the taskDB Hive box. Finally, it navigates back to the previous screen using Navigator.pop(context).
  void saveTask() {
    if (titleController.text.trim().isEmpty ||
        selectedDay == null ||
        priority == null ||
        category == null ||
        descController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("!!ALL FIELDS ARE REQUIRED!!")),
      );

      return;
    }
    final newTask = Task(
      title: titleController.text,
      description: descController.text,
      dueDate: selectedDay!,
      priority: priority!,
      category: category!,
      //the ! makes the variable non-nullable,
      // which is necessary because the Task constructor requires non-null values for these fields.
      tid: TidGen.generateTid(),
      createdAt: DateTime.now(),
    );
    ref.read(taskProvider.notifier).addTask(newTask);
    Navigator.pop(context);
  }

  /////////////////////////////////////////////////////////////Eend functions///////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // dark background

      appBar: AppBar(
        leading: const BackButton(color: Colors.redAccent),
        elevation: 0,
        centerTitle: true,

        title: Text(
          "Add Task",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF121212),
          ),
        ),

        actions: [
          IconButton(
            onPressed: saveTask,
            // when the save button is pressed, it calls the saveTask function to save the task and then navigates back to the previous screen.
            icon: Icon(Icons.save, size: 40),
            color: Colors.redAccent,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ///////////////////////////// TASK TITLE /////////////////////////////////////////////
            const Text(
              "Task title:",
              style: TextStyle(fontSize: 21, color: Colors.white54),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: titleController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Enter a title for your task ',
                hintStyle: TextStyle(color: Colors.white54),

                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: Colors.white54, width: 2),
                ),

                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: Colors.redAccent, width: 2),
                ),
              ),
            ),
            ///////////////////////////// TASK DESC /////////////////////////////////////////////
            const SizedBox(height: 20),

            const Text(
              "Task descreption:",
              style: TextStyle(fontSize: 21, color: Colors.white54),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: descController,
              maxLines: 4,

              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Enter a descreption for your task',
                hintStyle: TextStyle(color: Colors.white54),

                ///enabledBorder and focusedBorder are properties of the InputDecoration class in Flutter that define the appearance of the border around a TextField when it is enabled and focused, respectively.
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(
                    color: Color.from(alpha: 0.541, red: 1, green: 1, blue: 1),
                    width: 2,
                  ),
                ),

                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: Color(0xFFFF5252), width: 2),
                ),
              ),
            ),
            ///////////////////////////// TASK DESC /////////////////////////////////////////////
            const SizedBox(height: 20),

            /// DATE PICKER BUTTON
            ElevatedButton(
              onPressed: _pickDate,

              style: ElevatedButton.styleFrom(
                backgroundColor: selectedDay == null
                    ? Colors.white54
                    : Colors.redAccent,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    selectedDay == null
                        ? "Set due date"
                        : "Due: ${selectedDay!.day}/${selectedDay!.month}/${selectedDay!.year}",
                    style: const TextStyle(color: Colors.black, fontSize: 20),
                  ),

                  const Icon(
                    Icons.calendar_month,
                    color: Colors.black,
                    size: 30,
                  ),
                ],
              ),
            ),

            /////////////////////////////Priority///////////////////////////////////////////
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              dropdownColor: const Color(0xFFFF5252),
              // The dropdownColor property is used to set the background color of the dropdown menu when it is opened. In this case, it is set to a shade of red (0xFFFF5252).
              initialValue: priority,
              hint: const Text(
                "Select priority",
                style: TextStyle(color: Colors.white54),
              ),

              items: ["Low", "Medium", "High"].map((String value) {
                return DropdownMenuItem(
                  value: value,
                  child: Text(value, style: TextStyle(color: Colors.white54)),
                );
              }).toList(),

              onChanged: (value) {
                setState(() {
                  //no need to use setState to update priority because the DropdownButtonFormField will call the onChanged callback with the new selected value, and the TaskSectionWidget will automatically rebuild and display tasks for the new selected day based on the updated state provided by the taskProvider.
                  priority = value;
                });
              },

              decoration: const InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: Colors.white54),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: Color(0xFFFF5252)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              dropdownColor: const Color(0xFFFF5252),
              // The dropdownColor property is used to set the background color of the dropdown menu when it is opened. In this case, it is set to a shade of red (0xFFFF5252).
              initialValue: category,
              hint: const Text(
                "Select priority",
                style: TextStyle(color: Colors.white54),
              ),

              items: ["Personal", "Work", "Learning", "Sport/Activity", "Errands"].map((
                String value,
              ) {
                IconData icon;

                switch (value) {
                  case "Personal":
                    icon = Icons.person_outline;
                    break;
                  case "Work":
                    icon = Icons.work_outline;
                    break;
                  case "Learning":
                    icon = Icons.menu_book_outlined;
                    break;
                  case "Sport/Activity":
                    icon = Icons.fitness_center_outlined;
                    break;
                  case "Errands":
                    icon = Icons.shopping_cart_outlined;
                    break;
                  default:
                    icon = Icons.circle_outlined;
                }

                /// Each DropdownMenuItem in the category dropdown includes an icon that visually represents the category.
                /// The icons are determined based on the category name, providing a more intuitive
                /// and visually appealing user interface for selecting task categories.

                return DropdownMenuItem(
                  value: value,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        value,
                        style: const TextStyle(color: Colors.white54),
                      ),
                      Icon(icon, color: Colors.white54),
                    ],
                  ),
                );
              }).toList(),

              onChanged: (value) {
                setState(() {
                  //no need to use setState to update category because the DropdownButtonFormField will call the onChanged callback with the new selected value, and the TaskSectionWidget will automatically rebuild and display tasks for the new selected day based on the updated state provided by the taskProvider.
                  category = value;
                });
              },

              decoration: const InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: Colors.white54),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: Color(0xFFFF5252)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
