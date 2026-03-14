import 'package:flutter/material.dart';
import '../models/task.dart';

Future<bool> deleteTask({
  required BuildContext context,
  required Task task,
  required Function(VoidCallback) refreshUI,
}) async {

  final messenger = ScaffoldMessenger.of(context); // capture early

  refreshUI(() {
    task.isDeleted = true;
    task.deletedAt = DateTime.now();
  });

  await task.save();

  messenger.showSnackBar(
    SnackBar(
      content: Text("${task.title} deleted"),
      duration: const Duration(seconds: 6),
      action: SnackBarAction(
        label: "UNDO",
        onPressed: () {
          refreshUI(() {
            task.isDeleted = false;
            task.deletedAt = null;
          });

          task.save();
        },
      ),
    ),
  );

  return false;
}