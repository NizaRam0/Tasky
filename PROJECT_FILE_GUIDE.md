# Project File Guide

This document is the developer reference for this project.
It explains what each file does, what each important method does, and where to make changes safely.

============================================================

## 1) Architecture Overview

The app is a local-first task manager.

Layered flow:

UI (screens/widgets)
-> Riverpod state (TaskNotifier)
-> Repository (TaskRepository)
-> Local DB (Hive TasksBox)

Single source of truth for task state is TaskNotifier state from taskProvider.

============================================================

## 2) Root Files

### pubspec.yaml

Purpose:

- Declares runtime and dev dependencies.

Used by:

- flutter pub get
- build/test/analyze tools

Important deps currently:

- flutter_riverpod
- hive + hive_flutter
- table_calendar
- uuid
- hive_test (dev)

### analysis_options.yaml

Purpose:

- Defines static analysis and lint behavior.

### README.md

Purpose:

- Product-facing project overview (setup, architecture summary, screenshots).

### PROJECT_FILE_GUIDE.md

Purpose:

- Internal engineering documentation for onboarding and maintenance.

============================================================

## 3) App Entry

### lib/main.dart

Purpose:

- App bootstrapping and app-level dependency setup.

Key methods/classes:

- main()
  - Calls WidgetsFlutterBinding.ensureInitialized()
  - Calls Hive.initFlutter()
  - Registers TaskAdapter
  - Opens Hive box: TasksBox
  - Runs cleanupDeletedTasks(box)
  - Wraps app in ProviderScope and runs MyApp

- class MyApp extends StatelessWidget
  - build()
  - Returns MaterialApp(home: HomeScreen)

Change here when:

- App startup sequence changes
- Global providers/theme/router are introduced

============================================================

## 4) Data Model

### lib/models/task.dart

Purpose:

- Defines Task entity persisted in Hive and used throughout UI/state.

Class:

- Task extends HiveObject
  Fields:
  - title: String
  - description: String
  - dueDate: DateTime
  - priority: String
  - isCompleted: bool
  - category: String
  - isDeleted: bool
  - deletedAt: DateTime?
  - tid: String
  - createdAt: DateTime?

Constructor behavior:

- Requires core fields for a valid task
- Defaults:
  - isCompleted = false
  - isDeleted = false
  - tid = ""

Important note:

- Field order via @HiveField must stay stable after release unless migration is handled.

### lib/models/task.g.dart

Purpose:

- Generated adapter code for Hive serialization.

Rule:

- Do not manually edit.

============================================================

## 5) State and Repository

### lib/notifiers/task_Notifier.dart

Purpose:

- Riverpod state management for tasks.

Providers:

- taskRepositoryProvider
  - Returns TaskRepository instance.

- taskProvider (StateNotifierProvider<TaskNotifier, List<Task>>)
  - Exposes current visible task list state.

Class and methods:

- class TaskNotifier extends StateNotifier<List<Task>>

- TaskNotifier(this.repo)
  - Initializes state as []
  - Immediately calls loadTasks()

- loadTasks()
  - Pulls active tasks from repository and replaces state

- addTask(Task task)
  - Delegates insert to repository
  - Refreshes state via loadTasks()

- updateTask(Task task)
  - Delegates save/update to repository
  - Refreshes state

- deleteTask(Task task)
  - Delegates soft delete to repository
  - Refreshes state

- restoreTask(Task task)
  - Delegates restore to repository
  - Refreshes state

### lib/repositories/task_repository.dart

Purpose:

- Encapsulates direct Hive operations.

Fields:

- box
  - Hive.box<Task>('TasksBox')

Methods:

- getTasks()
  - Returns only tasks where isDeleted == false

- addTask(Task task)
  - box.add(task)

- updateTask(Task task)
  - task.save()

- deleteTask(Task task)
  - Marks task.isDeleted = true
  - Sets task.deletedAt = DateTime.now()
  - Saves task

- restoreTask(Task task)
  - Marks task.isDeleted = false
  - Clears task.deletedAt
  - Saves task

Change here when:

- Persistence strategy changes (Hive -> API/SQLite)
- Filtering or soft-delete policy changes

============================================================

## 6) Screens

### lib/screens/home_screen.dart

Purpose:

- Main dashboard screen.

Class:

- HomeScreen (ConsumerStatefulWidget)

State fields:

- selectedDay

Main behavior in build():

- Watches taskProvider for live tasks
- Renders app bar (add/profile buttons)
- Renders CalendarWidget
- Renders TaskSectionWidget with selectedDay + tasks

Key interactions:

- Add button opens addTask screen
- Calendar day selection updates selectedDay

### lib/screens/add_screen.dart

Purpose:

- Form to create a new task.

Class:

- addTask (ConsumerStatefulWidget)

State fields:

- titleController
- descController
- priority
- selectedDay
- category

Methods:

- dispose()
  - Disposes text controllers

- \_pickDate()
  - Opens shared date picker
  - Stores selected date in selectedDay

- saveTask()
  - Validates required fields
  - Shows snackbar on missing input
  - Builds Task with generated tid and createdAt
  - Calls taskProvider.notifier.addTask(newTask)
  - Pops screen on success

### lib/screens/task_details_screen.dart

Purpose:

- View and edit one existing task.

Class:

- TaskDetailsScreen (ConsumerStatefulWidget)

State fields:

- isEditing
- initialized
- isCompleted
- selectedDay
- titleController
- descriptionController

Methods:

- \_getTask()
  - Finds task in provider state by tid
  - Returns null if missing (safe against deletion race)

- \_pickDate()
  - Opens date picker
  - Updates selectedDay local UI state
  - Persists dueDate through notifier if task exists

- dispose()
  - Disposes controllers

- build()
  - Handles "Task not found" fallback
  - Initializes local fields once from task
  - Supports edit/save/delete actions
  - Persists all updates through notifier

Important behavior:

- Deletion can remove the task before rebuild completes, so null handling is required.

============================================================

## 7) Widgets

### lib/widgets/calTable.dart

Purpose:

- Reusable calendar widget wrapper.

Class:

- CalendarWidget (StatelessWidget)

Inputs:

- selectedDay
- onDaySelected callback

Behavior:

- Uses TableCalendar
- Applies custom dark theme styles
- Calls onDaySelected(selectedDay) when user picks a day

### lib/widgets/todo_title.dart

Purpose:

- Renders selected-day task list and task-level gestures.

Class:

- TaskSectionWidget (ConsumerStatefulWidget)

Inputs:

- selectedDay
- tasks (already provided by parent)

Behavior in build():

- Filters tasks for selectedDay
- Shows empty state if no tasks
- Shows list with Dismissible cards

Swipe behavior (confirmDismiss):

- Start-to-end:
  - Toggles task completion
  - Persists via notifier.updateTask(task)
  - Returns false (item stays in list)
- End-to-start:
  - Calls deleteTask utility (soft delete + undo snackbar)

Tap behavior:

- Opens TaskDetailsScreen(taskId: task.tid)

### lib/widgets/dueDate_cal.dart

Purpose:

- Shared date picker function with app theme styling.

Function:

- showDueDatePicker(BuildContext context, DateTime selectedDay)

Behavior:

- Opens showDatePicker
- Uses selectedDay as initialDate
- Restricts range from current year to current year + 20
- Applies dark themed colors

============================================================

## 8) Utility Files

### lib/utils/DeleteTask.dart

Purpose:

- Centralized delete + undo flow used by multiple screens/widgets.

Function:

- deleteTask({context, task, ref})

Behavior:

- Captures notifier from ref once
- Performs soft delete through notifier
- Shows snackbar with UNDO action
- UNDO calls notifier.restoreTask(task)

Why this design:

- Avoids using ref after widget disposal in snackbar callback.

### lib/utils/cleanUp.dart

Purpose:

- Purges old soft-deleted tasks on app startup.

Function:

- cleanupDeletedTasks(Box<Task> box)

Behavior:

- Iterates all tasks
- If isDeleted and deletedAt exists:
  - Computes days since deletion
  - Permanently deletes task when difference >= 14

### lib/utils/TidGen.dart

Purpose:

- Creates unique task ids.

Class/method:

- TidGen.generateTid()
  - Returns uuid.v4()

### lib/utils/priority_colors.dart

Purpose:

- Maps priority/completion to card border color.

Class/method:

- PriorityColors.getColor(priority, isCompleted)
  - Completed tasks always return completed color
  - Else maps High/Medium/Low/default

### lib/utils/category_icons.dart

Purpose:

- Maps category label to icon.

Class/method:

- CategoryIcons.getIcon(category)
  - Switch mapping with default fallback icon

============================================================

## 9) Tests

### test/widget_test.dart

Purpose:

- Widget test for add-task workflow and persistence.

Setup lifecycle:

- setUpAll:
  - Initializes test Hive
  - Registers adapter
  - Opens TasksBox
- tearDown:
  - Clears TasksBox after each test
- tearDownAll:
  - Closes box and tears down Hive test environment

Current test:

- Add task saves to Hive
  - Pumps addTask screen under ProviderScope
  - Enters form fields
  - Picks date
  - Selects priority/category
  - Saves
  - Asserts task persisted with expected values

Next recommended tests:

- Validation snackbar appears on empty required fields
- Edit task from details and verify persistence
- Delete + undo flow restores task
- Calendar day filtering behavior

============================================================

## 10) Platform Folders

Folders:

- android
- ios
- macos
- linux
- windows
- web

Notes:

- Mostly generated and platform configuration files.
- Edit only when changing platform-specific build or permissions.

============================================================

## 11) Data and Event Flows

Add flow:

1. add_screen.dart saveTask()
2. task_Notifier.dart addTask()
3. task_repository.dart addTask()
4. Hive write
5. notifier reloads state
6. UI rebuilds from provider

Update flow:

1. details/list UI mutates task fields
2. notifier updateTask()
3. repository updateTask() -> task.save()
4. state reload + UI refresh

Delete flow:

1. UI calls utils/DeleteTask.dart
2. notifier deleteTask() marks soft delete
3. snackbar appears with UNDO
4. UNDO calls notifier restoreTask()

Startup cleanup flow:

1. main.dart opens box
2. cleanupDeletedTasks(box)
3. Tasks deleted >=14 days are permanently removed

============================================================

## 12) Rules for New Developers

1. Keep business logic out of UI when possible.
2. Route persistence through TaskRepository.
3. Refresh provider state after each repository write.
4. Prefer extending existing utilities (DeleteTask, TidGen, picker helpers) before duplicating logic.
5. Keep task model backward-compatible with Hive field ordering.
6. Add or update tests when behavior changes.
7. Update this document whenever a new file, method, or major flow is added/changed.

============================================================

## 13) Documentation Update Checklist

When you add or change code, update these sections:

- Architecture Overview (if flow changed)
- Relevant file section (purpose, methods, behavior)
- Data and Event Flows (if runtime flow changed)
- Tests section (if new tests added)
- Rules/Checklist (if team conventions changed)
