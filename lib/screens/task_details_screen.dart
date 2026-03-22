import 'package:flutter/material.dart';
//import 'package:hive/hive.dart';
import 'add_screen.dart';
import '../utils/delete_task.dart';
import '../models/task.dart';
import '../widgets/due_date_cal.dart';
//import '../repositories/task_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../notifiers/task_notifier.dart';
import '../widgets/priority_widget.dart';
import '../widgets/category_widget.dart';
import '../widgets/due_date_selector.dart';

class TaskDetailsScreen extends ConsumerStatefulWidget {
  final String taskId;

  const TaskDetailsScreen({super.key, required this.taskId});

  @override
  ConsumerState<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends ConsumerState<TaskDetailsScreen> {
  bool isEditing = false;
  bool initialized = false; // ✅ FIX

  Task? _getTask() {
    final tasks = ref.watch(taskProvider);
    for (final t in tasks) {
      if (t.tid == widget.taskId) {
        return t;
      }
    }
    return null;
  }

  bool isCompleted = false;
  DateTime? selectedDay;
  String? priority;
  String? category;

  // ❌ REMOVED: late Task task

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  void _pickDate() async {
    final pickedDate = await showDueDatePicker(
      context,
      selectedDay ?? DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDay = pickedDate;
      });

      // ✅ FIX: update through provider
      final task = _getTask();
      if (task == null) {
        return;
      }
      task.dueDate = pickedDate;

      ref.read(taskProvider.notifier).updateTask(task);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final task = _getTask();
    if (task == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF121212),
        body: Center(
          child: Text(
            "Task not found",
            style: TextStyle(color: Colors.white54, fontSize: 20),
          ),
        ),
      );
    }

    // =========================
    // SYNC UI WITH TASK
    // =========================
    if (!initialized) {
      // ✅ FIX (instead of !isEditing)
      titleController.text = task.title;
      descriptionController.text = task.description;
      isCompleted = task.isCompleted;
      selectedDay = task.dueDate;
      initialized = true;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121212),

      ////////////////////////////////////////NAVBAR///////////////////////////////////////////////////////////////
      appBar: AppBar(
        leading: const BackButton(color: Colors.redAccent),
        elevation: 0,
        centerTitle: true,

        title: Text(
          "Task Details",
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

      //////////////////////////////////////////////BODY///////////////////////////////////////////////////////////////
      body: Padding(
        padding: const EdgeInsets.only(
          bottom: 16,
          left: 16,
          right: 16,
          top: 60,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /////////////////////////////////////////////////// TITLE FIELD////////////////////////
            TextField(
              controller: titleController,
              readOnly: !isEditing,
              style: const TextStyle(color: Colors.white54, fontSize: 20),
              decoration: const InputDecoration(
                hintText: 'Enter a title for your task ',
                hintStyle: TextStyle(color: Colors.white54),
                labelText: "Title",
                labelStyle: TextStyle(
                  color: Colors.white54,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
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

            const SizedBox(height: 25),

            ///////////////////////////// DESCRIPTION FIELD/////////////////////////////////////////
            TextField(
              controller: descriptionController,
              readOnly: !isEditing,
              maxLines: 4,
              style: const TextStyle(color: Colors.white54, fontSize: 20),
              decoration: const InputDecoration(
                hintText: 'Enter a description for your task ',
                hintStyle: TextStyle(color: Colors.white54),
                labelText: "Description",
                labelStyle: TextStyle(
                  color: Colors.white54,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
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

            const SizedBox(height: 25),

            // =========================
            // COMPLETED CHECKBOX
            // =========================
            Row(
              children: [
                Checkbox(
                  value: isCompleted,
                  onChanged: isEditing
                      ? (value) {
                          setState(() {
                            isCompleted = value!;
                          });

                          final updated = task;
                          updated.isCompleted = value!;

                          ref.read(taskProvider.notifier).updateTask(updated);
                        }
                      : null,
                ),
                const Text(
                  "Completed",
                  style: TextStyle(color: Colors.white54, fontSize: 20),
                ),
              ],
            ),

            /////////////////////////////////////////////
            DueDateSelector(
              selectedDay: selectedDay,
              enabled: isEditing,
              onPressed: _pickDate,
            ),

            const SizedBox(height: 20),

            ///////////////////////////// PRIORITY ///////////////////////////////////////////
            PrioritySelector(
              selected: task.priority,
              enabled: isEditing,
              onChanged: (value) {
                if (isEditing) {
                  final updated = task;
                  updated.priority = value;
                  ref.read(taskProvider.notifier).updateTask(updated);
                }
              },
            ),

            const SizedBox(height: 20),

            ///////////////////////////// CATEGORY ///////////////////////////////////////////
            CategoryDropdown(
              selectedValue: task.category,
              enabled: isEditing,
              onChanged: isEditing
                  ? (value) {
                      final updated = task;
                      updated.category = value!;
                      ref.read(taskProvider.notifier).updateTask(updated);
                    }
                  : null,
            ),

            const SizedBox(height: 25),

            ///////////////////////////// ACTION BUTTONS ///////////////////////////////////////////
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                /// DELETE
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red, size: 30),
                  onPressed: () {
                    deleteTask(context: context, task: task, ref: ref);
                    Navigator.pop(context);
                  },
                ),

                Row(
                  children: [
                    /// EDIT
                    ElevatedButton(
                      onPressed: isEditing
                          ? null
                          : () {
                              setState(() => isEditing = true);
                            },
                      child: Text("Edit"),
                    ),

                    const SizedBox(width: 16),

                    /// SAVE
                    ElevatedButton(
                      onPressed: !isEditing
                          ? null
                          : () {
                              task.title = titleController.text;
                              task.description = descriptionController.text;

                              ref.read(taskProvider.notifier).updateTask(task);

                              setState(() => isEditing = false);
                            },
                      child: Text("Save"),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            Text(
              "Created: ${task.createdAt?.day}/${task.createdAt?.month}/${task.createdAt?.year}",
              style: const TextStyle(color: Colors.white54, fontSize: 26),
            ),
          ],
        ),
      ),
    );
  }
}
     
  /// =========================
/// FIXES APPLIED
/// =========================
///
/// 1. Controller Reset Issue
/// - Before: Controllers were updated inside build() using `!isEditing`
/// - Problem: Every rebuild overwrote user input while typing
/// - Fix: Introduced `initialized` flag to set controller values only once
///
/// 2. Removed Local Task Instance
/// - Before: Used `late Task task` (local copy)
/// - Problem: Could become out of sync with provider state
/// - Fix: Always fetch task using `_getTask()` from Riverpod
///
/// 3. State Sync with Provider
/// - Before: Direct mutation like `task.save()` or local updates only
/// - Problem: UI and data could desync
/// - Fix: All updates now go through:
///   `ref.read(taskProvider.notifier).updateTask(task)`
///
/// 4. Date Update Fix
/// - Before: Only updated local variable
/// - Problem: Changes not persisted
/// - Fix: Update task + notify provider after picking date
///
/// 5. Checkbox / Dropdown Updates
/// - Before: Only `setState()` used
/// - Problem: Changes not reflected globally
/// - Fix: Update task + call provider notifier
///
/// =========================
/// RESULT
/// =========================
/// - No more controller overwrite on rebuild
/// - Single source of truth (Riverpod)
/// - UI stays consistent with stored data
/// - All edits persist correctly