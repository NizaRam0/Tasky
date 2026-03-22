import 'package:flutter/material.dart';
import '../models/task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../notifiers/task_notifier.dart';


Future<bool> deleteTask({
  required BuildContext context,
  required Task task,
  required WidgetRef ref,
}) async {
  final notifier = ref.read(taskProvider.notifier);

  final messenger = ScaffoldMessenger.of(
    Navigator.of(context, rootNavigator: true).context,
  );

  // ✅ delete via notifier ONLY
  notifier.deleteTask(task);

  messenger.showSnackBar(
    SnackBar(
      content: Text("${task.title} deleted"),
      duration: const Duration(seconds: 6),

      action: SnackBarAction(
        label: "UNDO",
        onPressed: () {
          // Use captured notifier so undo still works after source widget is disposed.
          notifier.restoreTask(task);
        },
      ),
    ),
  );

  return false;
}