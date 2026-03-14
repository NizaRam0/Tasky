import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'add_screen.dart';
import '../utils/DeleteTask.dart';
import '../models/task.dart';

class TaskDetailsScreen extends StatefulWidget {

  final String taskId;

  const TaskDetailsScreen({
    super.key,
    required this.taskId,
  });

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  bool isEditing = false;
  bool isCompleted = false;
  late Task task;
 // TODO: load from task

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  
 @override 
void initState() {
  super.initState();

  /// LOAD TASK FROM HIVE
  final box = Hive.box<Task>('TasksBox');
  task = box.values.firstWhere((t) => t.tid == widget.taskId);

  titleController.text = task.title;
  descriptionController.text = task.description ?? "";

  isCompleted = task.isCompleted;

}
  @override
  Widget build(BuildContext context) {
 return Scaffold(
      backgroundColor: const Color(0xFF121212),
     ////////////////////////////////////////NAVBAR///////////////////////////////////////////////////////////////
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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const addTask()),
                );
              },
              icon: const Icon(Icons.add, size: 40),
              color: Colors.redAccent,
            ),
        ],
      ),
////////////////////////////////////////////////////////////END OF NAVBAR/////////////////////////////////////////////

//////////////////////////////////////////////////////////////BODY///////////////////////////////////////////////////////////////
    body: Padding(
  padding: const EdgeInsets.all(16),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

  /////////////////////////////////////////////////// TITLE FIELD////////////////////////
      
      TextField(
        controller: titleController, 
        readOnly: !isEditing,

        decoration: const InputDecoration(
          labelText: "Title",
          border: OutlineInputBorder(),
        ),
        // load task title into controller
      ),

      const SizedBox(height: 16),

  ///////////////////////////// DESCRIPTION FIELD/////////////////////////////////////////
      TextField(
        controller: descriptionController,
        readOnly: !isEditing,
        maxLines: 4,

        decoration: const InputDecoration(
          labelText: "Description",
          border: OutlineInputBorder(),
        ),

        // TODO:
        // load description from task

      ),

      const SizedBox(height: 20),

      // =========================
      // COMPLETED CHECKBOX
      // =========================
      Row(
        children: [

          Checkbox(
            value: isCompleted,

            onChanged: (value) {

              // TODO:
              // update task completed state
              // call util function if needed
              // save change to database

              setState(() {
                isCompleted = value!;
                task.isCompleted = isCompleted;
              });

              task.save();

            },
          ),

          const Text(
            "Completed",
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),

      const SizedBox(height: 20),

      // =========================
      // ACTION BUTTONS
      // =========================
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          // DELETE BUTTON
          IconButton(
            icon: const Icon(
              Icons.delete,
              color: Colors.red,
              size: 30,
            ),

            onPressed: () {

              // TODO:
              // call delete function from utils
              // example:
              // deleteTask(taskId);

              deleteTask(
                context: context,
                task: task,
                refreshUI: (fn) {
                   if (mounted) {
                     setState(fn);
                     }
                     });

              // TODO:
              // navigate back after delete

              Navigator.pop(context);

            },
          ),

          Row(
            children: [

              // EDIT BUTTON
              ElevatedButton(
                onPressed: isEditing
                    ? null
                    : () {

                        // TODO:
                        // enable editing
                        // setState(() => isEditing = true);

                        setState(() => isEditing = true);

                      },

                child: const Text("Edit"),
              ),

              const SizedBox(width: 10),

              // SAVE BUTTON
              ElevatedButton(
                onPressed: !isEditing
                    ? null
                    : () {

                        // TODO:
                        // save updated title & description
                        // call util function

                        task.title = titleController.text;
                        task.description = descriptionController.text;

                        task.save();

                        // TODO:
                        // disable editing after save
                        // setState(() => isEditing = false);

                        setState(() => isEditing = false);

                      },

                child: const Text("Save"),
              ),
            ],
          ),
        ],
      ),

      const SizedBox(height: 20),

      // =========================
      // OPTIONAL EXTRA INFO
      // =========================
      // You can show extra task info here
      // example:
      // created date
      // priority
      // category

      // TODO:
      // add additional task info widgets here

    ],
  ),
)
 );
     /* body: Center(
        child: Text("Task ID: $taskId", style: const TextStyle(color: Colors.white, fontSize: 24),
      ),
      )
    );*/
  }
}