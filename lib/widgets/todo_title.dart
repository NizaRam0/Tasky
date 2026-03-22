import 'package:app6/models/task.dart';
import 'package:flutter/material.dart';
//import '../models/task.dart';
import '../utils/priority_colors.dart';
import '../utils/category_icons.dart';
import '../screens/task_details_screen.dart';
import '../utils/delete_task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../notifiers/task_notifier.dart';

class TaskSectionWidget extends ConsumerStatefulWidget {
  final DateTime selectedDay;
  final List<Task> tasks; // ✅ FIX: add field

  const TaskSectionWidget({
    super.key,
    required this.selectedDay,
    required this.tasks, // ✅ FIX: properly assign
  });

  @override
  ConsumerState<TaskSectionWidget> createState() => _TaskSectionWidgetState();
}

class _TaskSectionWidgetState extends ConsumerState<TaskSectionWidget> {
  @override
  Widget build(BuildContext context) {
    final tasks = widget.tasks; // ✅ FIX: use passed tasks instead of provider

    /// FILTER TASKS FOR SELECTED DAY
    final tasksForDay = tasks.where((task) {
      return !task.isDeleted &&
          task.dueDate.year == widget.selectedDay.year &&
          task.dueDate.month == widget.selectedDay.month &&
          task.dueDate.day == widget.selectedDay.day;
    }).toList();

    //filters the list of tasks passed to the TaskSectionWidget based on their due dates.
    //It checks if each task has a non-null due date and if that due date matches the currently selected day (year, month, and day).
    //The resulting list, tasksForDay, contains only the tasks that are due on the selected day and is used to display the relevant tasks in the UI.

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 30),

        /// HEADER
        Text(
          "Tasks for ${widget.selectedDay.year}-${widget.selectedDay.month}-${widget.selectedDay.day}",
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 20),

        /// EMPTY STATE
        /// //// If there are no tasks for the selected day, it displays a message "No tasks yet" in grey color.
        if (tasksForDay.isEmpty)
          const Text(
            "No tasks yet",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          )
        else
          Expanded(
            child: ListView.builder(
              itemCount: tasksForDay.length,
              itemBuilder: (context, index) {
                final task = tasksForDay[index];

                return Dismissible(
                  key: ValueKey(task.key),

                  background: Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 20),
                    color: Colors.green,
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),

                  secondaryBackground: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: Colors.red,
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),

                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.startToEnd) {
                      /// SWIPE RIGHT → MARK DONE

                      /*setState(() {
                        //toggle the completion status of the task when the user swipes right. If the task is not completed, it marks it as completed; if it is already completed, it marks it as not completed. This allows users to easily update the completion status of their tasks with a simple swipe gesture.
                        if (!task.isCompleted) {
                          task.isCompleted = true;
                        } else {
                          task.isCompleted = false;
                        }
                      });*/

                      task.isCompleted = !task.isCompleted;

                      //task.save(); used to save task directly but now using provider to update task and save to hive in the repository function

                      ref
                          .read(taskProvider.notifier)
                          .updateTask(task); // update through provider

                      return false; // don't remove from list
                    }

                    if (direction == DismissDirection.endToStart) {
                      /// SWIPE LEFT → DELETE
                      deleteTask(context: context, task: task, ref: ref);
                    }

                    return null;
                  },

                  child: Card(
                    ///ON tap navigate to task details screen (not implemented yet)
                    color: const Color(0xFF1E1E1E),
                    margin: const EdgeInsets.symmetric(vertical: 8),

                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: PriorityColors.getColor(
                          task.priority,
                          task.isCompleted,
                        ),

                        // The border color of the card is determined by the getColor method from the PriorityColors class, which takes the task's priority and completion status as parameters. This allows the card to visually indicate the priority level of the task, with different colors for high, medium, low, and completed tasks.
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),

                    child: ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                TaskDetailsScreen(taskId: task.tid),
                          ),
                        );
                      },

                      title: Text(
                        task.title,
                        style: const TextStyle(color: Colors.white),
                      ),

                      leading: Icon(
                        CategoryIcons.getIcon(task.category),
                        color: Colors.white70,
                      ),

                      subtitle: Text(
                        task.description,
                        // If the description is null, it will display an empty string instead.
                        style: const TextStyle(color: Colors.white54),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
