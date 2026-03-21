import 'package:app6/models/task.dart';
import 'package:app6/screens/add_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hive_test/hive_test.dart';

void main() {
// Runs once before all tests.
// Sets up an isolated Hive test environment (separate from real app storage).
setUpAll(() async {
TestWidgetsFlutterBinding.ensureInitialized();
await setUpTestHive();



    // Register adapter once so Hive can serialize Task objects in tests.
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(TaskAdapter());
        }

    // Open the same box name used by the app.
      await Hive.openBox<Task>('TasksBox');
  });

// Runs after each test.
// Clears data so tests stay independent and reproducible.
     tearDown(() async {
      final box = Hive.box<Task>('TasksBox');
      await box.clear();
      });

// Runs once after all tests.
// Closes box and removes temporary Hive test files.
    tearDownAll(() async {
      await Hive.box<Task>('TasksBox').close();
      await tearDownTestHive();
      });
      
    testWidgets('Add task saves to Hive', (WidgetTester tester) async {
// Build only the Add Task screen.
// ProviderScope is required because addTask uses Riverpod providers.
     await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: addTask(),
          ),
        ),
      );

    // Fill required text fields.
// TextField(0) -> title, TextField(1) -> description.
await tester.enterText(find.byType(TextField).at(0), 'Buy groceries');
await tester.enterText(find.byType(TextField).at(1), 'Milk and bread');

// Pick due date by opening date picker and confirming default selected date.
await tester.tap(find.text('Set due date'));
await tester.pumpAndSettle();
await tester.tap(find.text('OK'));
await tester.pumpAndSettle();

// Select priority from dropdown.
await tester.tap(find.text('Select priority').first);
await tester.pumpAndSettle();
await tester.tap(find.text('High').last);
await tester.pumpAndSettle();

// Select category from second dropdown.
// Your UI uses the same hint text, so we tap by visible option text.
await tester.tap(find.text('Select priority').first);
await tester.pumpAndSettle();
await tester.tap(find.text('Personal').last);
await tester.pumpAndSettle();

// Save task from AppBar save icon.
await tester.tap(find.byIcon(Icons.save));
await tester.pumpAndSettle();

// Verify one task was persisted to Hive.
final box = Hive.box<Task>('TasksBox');
expect(box.values.length, 1);

// Verify task fields match user input.
final task = box.values.first;
expect(task.title, 'Buy groceries');
expect(task.description, 'Milk and bread');
expect(task.priority, 'High');
expect(task.category, 'Personal');
});
}