// ignore: file_names
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task.dart';
import '../repositories/task_repository.dart';

final taskRepositoryProvider = Provider((ref) {
  return TaskRepository();
});

final taskProvider = StateNotifierProvider<TaskNotifier, List<Task>>((ref) {
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

  void permanentlyDeleteTask(Task task) {
    repo.permanentlyDeleteTask(task);
    loadTasks();
  }

  void markTasksCompleted(List<Task> tasks) {
    repo.markTasksCompleted(tasks);
    loadTasks();
  }

  void deleteTasks(List<Task> tasks) {
    repo.softDeleteTasks(tasks);
    loadTasks();
  }

  List<Task> getDeletedTasks() {
    return repo.getDeletedTasks();
  }

  List<Task> getTodayTasks() {
    final now = DateTime.now();
    return state.where((task) => _isSameDay(task.dueDate, now)).toList();
  }

  List<Task> getOverdueTasks() {
    final today = _dateOnly(DateTime.now());
    return state
        .where(
          (task) =>
              _dateOnly(task.dueDate).isBefore(today) && !task.isCompleted,
        )
        .toList();
  }

  List<Task> getUpcomingTasks() {
    final today = _dateOnly(DateTime.now());
    return state
        .where((task) => _dateOnly(task.dueDate).isAfter(today))
        .toList();
  }

  List<Task> filterTasks({
    required List<Task> tasks,
    String query = '',
    String? priority,
    String? category,
    String dateFilter = 'All',
  }) {
    var filtered = tasks;

    final trimmedQuery = query.trim().toLowerCase();
    if (trimmedQuery.isNotEmpty) {
      filtered = filtered
          .where((task) => task.title.toLowerCase().contains(trimmedQuery))
          .toList();
    }

    if (priority != null && priority != 'All') {
      filtered = filtered.where((task) => task.priority == priority).toList();
    }

    if (category != null && category != 'All') {
      filtered = filtered.where((task) => task.category == category).toList();
    }

    filtered = _applyDateFilter(filtered, dateFilter);
    return filtered;
  }

  List<Task> _applyDateFilter(List<Task> tasks, String dateFilter) {
    final today = DateTime.now();
    final todayDate = _dateOnly(today);

    switch (dateFilter) {
      case 'Today':
        return tasks.where((task) => _isSameDay(task.dueDate, today)).toList();
      case 'Overdue':
        return tasks
            .where(
              (task) =>
                  _dateOnly(task.dueDate).isBefore(todayDate) &&
                  !task.isCompleted,
            )
            .toList();
      case 'Upcoming':
        return tasks
            .where((task) => _dateOnly(task.dueDate).isAfter(todayDate))
            .toList();
      default:
        return tasks;
    }
  }

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
//////////////
//////// This file defines the TaskNotifier class, which extends StateNotifier from the Riverpod package. It manages the state of a list of Task objects and interacts with the TaskRepository to perform CRUD operations. The notifier provides methods to load tasks, add, update, delete, restore, and filter tasks based on various criteria such as priority, category, and due date. 
///The state is updated whenever changes are made to ensure that the UI reflects the current state of tasks.
///The TaskNotifier is provided to the app using a StateNotifierProvider, allowing widgets to listen for changes and rebuild accordingly when the task list is updated.
///This separation of concerns allows for a clean architecture where the UI can focus on presentation while the notifier handles business logic and state management.