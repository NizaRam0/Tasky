import 'package:hive/hive.dart';
import '../models/task.dart';

class TaskRepository {
  final Box<Task> box = Hive.box<Task>('TasksBox');

  List<Task> getTasks() {
    return box.values.where((task) => !task.isDeleted).toList();
  }

  List<Task> getDeletedTasks() {
    final deleted = box.values.where((task) => task.isDeleted).toList();
    deleted.sort((a, b) {
      final aTime = a.deletedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bTime = b.deletedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bTime.compareTo(aTime);
    });
    return deleted;
  }

  void addTask(Task task) {
    box.add(task);
  }

  void updateTask(Task task) {
    task.save();
  }

  void deleteTask(Task task) {
    task.isDeleted = true;
    task.deletedAt = DateTime.now();
    task.save();
  }

  void restoreTask(Task task) {
    task.isDeleted = false;
    task.deletedAt = null;

    // save to Hive or DB
    task.save(); // or box.put(...)
  }

  void permanentlyDeleteTask(Task task) {
    task.delete();
  }

  void markTasksCompleted(List<Task> tasks) {
    for (final task in tasks) {
      task.isCompleted = true;
      task.save();
    }
  }

  void softDeleteTasks(List<Task> tasks) {
    for (final task in tasks) {
      task.isDeleted = true;
      task.deletedAt = DateTime.now();
      task.save();
    }
  }
}
