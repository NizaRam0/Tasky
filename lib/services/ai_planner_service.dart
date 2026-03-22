import 'dart:convert';

import 'package:http/http.dart' as http;

class AiPlanSubtask {
  final String title;
  final String description;
  final DateTime dueDate;
  final String priority;
  final String category;

  const AiPlanSubtask({
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    required this.category,
  });

  factory AiPlanSubtask.fromJson(Map<String, dynamic> json) {
    final rawPriority = (json['priority'] as String? ?? 'Medium').trim();
    final safePriority = ['Low', 'Medium', 'High'].contains(rawPriority)
        ? rawPriority
        : 'Medium';

    final rawCategory = (json['category'] as String? ?? 'Work').trim();

    return AiPlanSubtask(
      title: (json['title'] as String? ?? 'Untitled task').trim(),
      description: (json['description'] as String? ?? '').trim(),
      dueDate:
          DateTime.tryParse(json['dueDateIso'] as String? ?? '') ??
          DateTime.now(),
      priority: safePriority,
      category: rawCategory.isEmpty ? 'Work' : rawCategory,
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'dueDateIso': dueDate.toIso8601String(),
    'priority': priority,
    'category': category,
  };
}

class AiPlanResponse {
  final String planTitle;
  final List<AiPlanSubtask> subtasks;

  const AiPlanResponse({required this.planTitle, required this.subtasks});

  factory AiPlanResponse.fromJson(Map<String, dynamic> json) {
    final rawSubtasks = json['subtasks'] as List<dynamic>? ?? const [];

    return AiPlanResponse(
      planTitle: (json['planTitle'] as String? ?? 'Generated Plan').trim(),
      subtasks: rawSubtasks
          .whereType<Map<String, dynamic>>()
          .map(AiPlanSubtask.fromJson)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'planTitle': planTitle,
    'subtasks': subtasks.map((e) => e.toJson()).toList(),
  };
}

class AiPlannerService {
  final String baseUrl;
  final http.Client _client;

  AiPlannerService({
    this.baseUrl = const String.fromEnvironment(
      'AI_BACKEND_URL',
      defaultValue: 'https://taskyai-backend.onrender.com',
    ),
    http.Client? client,
  }) : _client = client ?? http.Client();

  Future<AiPlanResponse> generatePlan({
    required String prompt,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final normalizedBaseUrl = baseUrl.endsWith('/')
      ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final cleaned = prompt.trim();
    if (cleaned.isEmpty) {
      return const AiPlanResponse(planTitle: 'Generated Plan', subtasks: []);
    }

    try {
      final response = await _client
          .post(
            Uri.parse('$normalizedBaseUrl/ai/planner'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'prompt': cleaned,
              'startDate': startDate.toUtc().toIso8601String(),
              'endDate': endDate.toUtc().toIso8601String(),
            }),
          )
          .timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          final parsed = AiPlanResponse.fromJson(decoded);
          if (parsed.subtasks.isNotEmpty || parsed.planTitle.isNotEmpty) {
            return parsed;
          }
        }
      }
    } catch (_) {
      // Fallback to local mock generation if backend is unavailable.
    }

    return _generateMockPlan(
      prompt: cleaned,
      startDate: startDate,
      endDate: endDate,
    );
  }

  AiPlanResponse _generateMockPlan({
    required String prompt,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final daySpan = endDate.difference(startDate).inDays;
    final totalTasks = (daySpan + 1).clamp(3, 8);
    final baseDate = DateTime(startDate.year, startDate.month, startDate.day);

    final subtasks = <AiPlanSubtask>[];

    for (var i = 0; i < totalTasks; i++) {
      final due = baseDate.add(Duration(days: i));
      final progress = i + 1;

      String priority;
      if (i == 0 || i == totalTasks - 1) {
        priority = 'High';
      } else if (i <= 2) {
        priority = 'Medium';
      } else {
        priority = 'Low';
      }

      subtasks.add(
        AiPlanSubtask(
          title: '$prompt - Step $progress',
          description:
              'Complete step $progress of "$prompt" and prepare for the next step.',
          dueDate: due,
          priority: priority,
          category: 'Work',
        ),
      );
    }

    return AiPlanResponse(planTitle: '$prompt plan', subtasks: subtasks);
  }
}
