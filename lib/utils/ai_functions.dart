import '../models/task.dart';
import '../notifiers/task_notifier.dart';
import '../services/ai_planner_service.dart';
import 'tid_gen.dart';

/// Returns true when the planner prompt has meaningful content.
bool hasValidAiPrompt(String prompt) {
	return prompt.trim().isNotEmpty;
}

/// Calls the AI planner service and returns a generated plan response.
Future<AiPlanResponse> generateAiPlan({
	required String prompt,
	required DateTime startDate,
	required DateTime endDate,
	AiPlannerService? service,
}) {
	final plannerService = service ?? AiPlannerService();
	return plannerService.generatePlan(
		prompt: prompt,
		startDate: startDate,
		endDate: endDate,
	);
}

/// Converts generated AI subtasks into saved app tasks using the notifier.
void createTasksFromAiSubtasks({
	required List<AiPlanSubtask> subtasks,
	required TaskNotifier notifier,
}) {
	for (final subtask in subtasks) {
		notifier.addTask(
			Task(
				title: subtask.title,
				description: subtask.description,
				dueDate: subtask.dueDate,
				priority: subtask.priority,
				category: subtask.category,
				tid: TidGen.generateTid(),
				createdAt: DateTime.now(),
			),
		);
	}
}

/// Builds the date-window label shown in the AI planner summary card.
String buildAiPlanWindowLabel({
	required DateTime startDate,
	required DateTime endDate,
}) {
	return 'From ${startDate.day}/${startDate.month}/${startDate.year} '
			'to ${endDate.day}/${endDate.month}/${endDate.year}';
}
