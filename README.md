# TASKY / FLUTTER TODO APP

Simple local-first task manager built with Flutter + Riverpod + Hive.

---

## QUICK LOOK

- Create tasks (title / description / due date / priority / category)
- Browse tasks by selected day (calendar view)
- Edit from details screen
- Swipe right = toggle complete
- Swipe left = soft delete + undo snackbar
- Auto cleanup for old deleted tasks (14+ days)

---

## STACK

- Flutter
- Riverpod
- Hive + hive_flutter
- table_calendar
- uuid

---

## ARCHITECTURE FLOW

UI Screens/Widgets
-> TaskNotifier (Riverpod state)
-> TaskRepository (data access)
-> Hive box (TasksBox)

---

## PROJECT MAP

- lib/main.dart
  - app startup + Hive setup + adapter registration + cleanup + ProviderScope
- lib/models/task.dart
  - Task model + fields persisted to Hive
- lib/notifiers/task_Notifier.dart
  - Riverpod provider and task state actions
- lib/repositories/task_repository.dart
  - CRUD and soft-delete/restore persistence logic
- lib/screens/home_screen.dart
  - main page (calendar + task list)
- lib/screens/add_screen.dart
  - create task form + validation
- lib/screens/task_details_screen.dart
  - view/edit one task
- lib/widgets/calTable.dart
  - calendar component
- lib/widgets/todo_title.dart
  - selected-day task list + swipe actions
- lib/widgets/dueDate_cal.dart
  - date picker helper
- lib/utils/DeleteTask.dart
  - shared delete + undo flow
- lib/utils/cleanUp.dart
  - removes old soft-deleted tasks
- test/widget_test.dart
  - widget tests for core flows

---

## SCREENSHOTS

Yes, add screenshots. They make your README much stronger.

Recommended captures:

- Home screen with calendar + populated tasks
- Add task form filled in
- Task details in edit mode
- Swipe-to-delete with undo snackbar visible

Example layout (after adding image files):

```md
![Home](assets/screenshots/home.png)
![Add Task](assets/screenshots/add_task.png)
![Task Details](assets/screenshots/task_details.png)
![Delete Undo](assets/screenshots/delete_undo.png)
```

Tip:

- Keep image width consistent
- Use clean sample data
- Avoid blurry emulator captures

---

## LOCAL RUN

1. flutter pub get
2. flutter run

---

## TEST

1. flutter test

---

## ROADMAP

- More widget/integration tests
- Search / sort / filters
- Profile/settings page
- Notifications and reminders
