import 'package:hive/hive.dart';
import '../models/task.dart';

class TaskRepository {

  final Box<Task> box = Hive.box<Task>('TasksBox');

  List<Task> getTasks() {
    return box.values.where((task) => !task.isDeleted).toList();
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

}