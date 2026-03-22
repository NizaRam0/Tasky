import 'package:flutter/material.dart';
import '../widgets/due_date_cal.dart';
import '../models/task.dart';
//import 'package:hive/hive.dart';
import '../utils/tid_gen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../notifiers/task_notifier.dart';
import '../widgets/priority_widget.dart';
import '../widgets/category_widget.dart';
import '../widgets/due_date_selector.dart';

// ignore: camel_case_types
class addTask extends ConsumerStatefulWidget {
  const addTask({super.key});

  @override
  ConsumerState<addTask> createState() => _addTaskState();
}

// ignore: camel_case_types
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
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFF121212), // dark background
      resizeToAvoidBottomInset: true,

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
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
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
                        color: Color.from(
                          alpha: 0.541,
                          red: 1,
                          green: 1,
                          blue: 1,
                        ),
                        width: 2,
                      ),
                    ),

                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide(
                        color: Color(0xFFFF5252),
                        width: 2,
                      ),
                    ),
                  ),
                ),
                ///////////////////////////// TASK DESC /////////////////////////////////////////////
                const SizedBox(height: 20),

                /// DATE PICKER BUTTON
                DueDateSelector(selectedDay: selectedDay, onPressed: _pickDate),

                /////////////////////////////Priority///////////////////////////////////////////
                const SizedBox(height: 20),
                PrioritySelector(
                  selected: priority,
                  onChanged: (value) {
                    setState(() {
                      priority = value;
                    });
                  },
                ),
                const SizedBox(height: 20),
                CategoryDropdown(
                  selectedValue: category,
                  onChanged: (value) {
                    setState(() {
                      category = value;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
