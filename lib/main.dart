import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/home_screen.dart';
import 'models/task.dart'; // <-- IMPORTANT
import 'utils/clean_up.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  /// REGISTER ADAPTER
  Hive.registerAdapter(TaskAdapter());

  /// OPEN DATABASE BOX
  final box = await Hive.openBox<Task>('TasksBox');
  //defined in cleanUp.dart, is called to remove tasks that have been marked as deleted for more than 14 days.
  cleanupDeletedTasks(box);

  runApp(
    const ProviderScope(
      // provides Riverpod state management to the entire app
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}
