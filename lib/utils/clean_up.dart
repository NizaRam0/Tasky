import 'package:hive/hive.dart';
import '../models/task.dart';
/// this file is used to clean up deleted tasks from the Hive database. 
/// It defines a function cleanupDeletedTasks that takes a Box Task as a parameter. 
/// The function iterates through all the tasks in the box and checks if they are marked as deleted and if their deletedAt timestamp is not null. 
/// If both conditions are met, it calculates the difference in days between the current date and the deletedAt timestamp.
///  If the difference is greater than or equal to 14 days, it deletes the task from the box. 
/// This helps to keep the database clean by removing tasks that have been marked as deleted for a long time.

void cleanupDeletedTasks(Box<Task> box) {
  final now = DateTime.now();
  

  for (var task in box.values) {
    if (task.isDeleted && task.deletedAt != null) {
      final difference = now.difference(task.deletedAt!).inDays;

      if (difference >= 14) {
        task.delete();
      }
    }
  }
}