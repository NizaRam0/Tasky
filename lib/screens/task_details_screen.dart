import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'add_screen.dart';
import '../utils/DeleteTask.dart';
import '../models/task.dart';
import '../widgets/dueDate_cal.dart';

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
  DateTime? selectedDay;
  String? priority;
  String? category;

  late Task task;
 // TODO: load from task

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  void _pickDate() async {
  final pickedDate = await showDueDatePicker(context, selectedDay ?? DateTime.now());

  if (pickedDate != null) {
    setState(() {
      selectedDay = pickedDate;
      task.dueDate = selectedDay!;
    });
  }
}
 @override 
void initState() {
  super.initState();

  /// LOAD TASK FROM HIVE
  final box = Hive.box<Task>('TasksBox');
  task = box.values.firstWhere((t) => t.tid == widget.taskId);

  titleController.text = task.title;
  descriptionController.text = task.description;

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
  padding: const EdgeInsets.only(bottom:16, left: 16, right: 16, top: 60),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

  /////////////////////////////////////////////////// TITLE FIELD////////////////////////
      
      TextField(
        controller: titleController, 
        readOnly: !isEditing,
        style:  TextStyle(color: Colors.white54,
        fontSize: 20,),

        decoration: const InputDecoration(
          hintText: 'Enter a title for your task ',
          hintStyle: TextStyle(color: Colors.white54),
                    labelText: "Title",
                    labelStyle: TextStyle(color: Colors.white54,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: Colors.white54, width: 2),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: Colors.redAccent, width: 2),
          ),
        ),
        // load task title into controller
      ),

      const SizedBox(height: 25),

  ///////////////////////////// DESCRIPTION FIELD/////////////////////////////////////////
      TextField(
        controller: descriptionController,
        readOnly: !isEditing,
        maxLines: 4,
        style:  TextStyle(color: Colors.white54,
        fontSize: 20,),
        decoration: const InputDecoration(

          hintText: 'Enter a description for your task ',
          hintStyle: TextStyle(color: Colors.white54),
          labelText: "Description",
                    labelStyle: TextStyle(color: Colors.white54,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: Colors.white54, width: 2),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: Colors.redAccent, width: 2),
          ),
          
        ),

        // TODO:
        // load description from task

      ),

      const SizedBox(height: 25),

      // =========================
      // COMPLETED CHECKBOX
      // =========================
      Row(
        children: [

          Checkbox(
            value: isCompleted,
            

            

            onChanged: isEditing?(value) {

              // TODO:
              // update task completed state
              // call util function if needed
              // save change to database

              setState(() {
                isCompleted = value!;
                task.isCompleted = isCompleted;
              });

              //task.save();

            }:null
          ),

          const Text(
            "Completed",
            style:  TextStyle(color: Colors.white54,
        fontSize: 20,),

          ),
        ],
      ),
      /////////////////////////////////////////////
                      //=========================
                     //////////CATEGORY/////////
                    //=========================
            ElevatedButton(
              onPressed: isEditing ? _pickDate : null,
              

              style: ElevatedButton.styleFrom(
                backgroundColor: selectedDay == null
                 ? Colors.white54 : Colors.redAccent,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  Text("Due: ${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year}"
                    ,style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                    ),
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
//=========================
//////////PRIORITY/////////
//=========================
DropdownButtonFormField<String>(
  dropdownColor: const Color(0xFFFF5252),
// The dropdownColor property is used to set the background color of the dropdown menu when it is opened. In this case, it is set to a shade of red (0xFFFF5252).
  value: task.priority,
  hint: const Text("Select priority", style: TextStyle(color: Colors.white54),),

  items: ["Low", "Medium", "High"].map((String value) {
    return DropdownMenuItem(
      value: value,
      child: Text(value, style: TextStyle(color: Colors.white54)),
    );
  }).toList(),

  onChanged: isEditing ? (value) {
    setState(() {
      task.priority = value!;
    });
  } : null,

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

//=========================
//////////CATEGORY/////////
//=========================

DropdownButtonFormField<String>(
  dropdownColor: const Color(0xFFFF5252),
// The dropdownColor property is used to set the background color of the dropdown menu when it is opened. In this case, it is set to a shade of red (0xFFFF5252).
  value: task.category,
  hint: const Text("Select priority", style: TextStyle(color: Colors.white54),),

   items: ["Personal", "Work", "Learning", "Sport/Activity", "Errands"]
      .map((String value) {
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
          Text(value, style: const TextStyle(color: Colors.white54)),
          Icon(icon, color: Colors.white54),
        ],
      ),
    );
  }).toList(),

  onChanged: isEditing ? (value) {
    setState(() {
      task.category = value!;
    });
  }: null,

  decoration: const InputDecoration(
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: Colors.white54),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: Color(0xFFFF5252)),
    ),
  )
),

      const SizedBox(height: 25),

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
                   style: ElevatedButton.styleFrom(
                  backgroundColor: isEditing ? Colors.redAccent : Colors.white54,

                ),
                onPressed: isEditing
                    ? null
                    : () {

                        // TODO:
                        // enable editing
                        // setState(() => isEditing = true);

                        setState(() => isEditing = true);

                      },
                     ////////////////////////////////////// fixxx

                child:  Text("Edit", style: isEditing ? TextStyle(color: Colors.white54) : TextStyle(color: Colors.black),),
              ),

              const SizedBox(width: 16),

              // SAVE BUTTON
              ElevatedButton(
                ////////////////////////////////////////fix save button color when disabled and enabled
                style: ElevatedButton.styleFrom(
                  backgroundColor: isEditing ? Colors.redAccent : Colors.white54,

                ),
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

                child:  Text("Save", style: isEditing ? TextStyle(color: Colors.white54) : TextStyle(color: Colors.black),),
              ),
            ],
          ),
        ],
      ),

      const SizedBox(height: 20),

      Text(
        "Created: ${task.createdAt?.day}/${task.createdAt?.month}/${task.createdAt?.year}",
        style: const TextStyle(
          color: Colors.white54,
          fontSize: 26,
        ),
      ),

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