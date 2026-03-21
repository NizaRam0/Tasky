import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task.dart';
import '../repositories/task_repository.dart';

final taskRepositoryProvider = Provider((ref) {
  return TaskRepository();
});

final taskProvider =
    StateNotifierProvider<TaskNotifier, List<Task>>((ref) {
  final repo = ref.watch(taskRepositoryProvider);
  return TaskNotifier(repo);
});

class TaskNotifier extends StateNotifier<List<Task>> {

  final TaskRepository repo;

  TaskNotifier(this.repo) : super([]) {
    loadTasks();
  }

  void loadTasks() {
    state = repo.getTasks();
  }

  void addTask(Task task) {
    repo.addTask(task);
    loadTasks();
  }

  void updateTask(Task task) {
    repo.updateTask(task);
    loadTasks();
  }

  void deleteTask(Task task) {
    repo.deleteTask(task);
    loadTasks();
  }
  void restoreTask(Task task) {
  repo.restoreTask(task); // let repository handle it
  loadTasks();
}
}