import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../notifiers/task_notifier.dart';
import '../services/ai_planner_service.dart';
import '../utils/ai_functions.dart';
import '../widgets/due_date_cal.dart';
import '../widgets/due_date_selector.dart';

class AiPlannerScreen extends ConsumerStatefulWidget {
  const AiPlannerScreen({super.key});

  @override
  ConsumerState<AiPlannerScreen> createState() => _AiPlannerScreenState();
}

class _AiPlannerScreenState extends ConsumerState<AiPlannerScreen> {
  final TextEditingController _promptController = TextEditingController();

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 4));
  bool _isGenerating = false;
  String _planTitle = '';
  List<AiPlanSubtask> _generated = const [];

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initial = isStart ? _startDate : _endDate;
    final picked = await showDueDatePicker(context, initial);

    if (picked == null) {
      return;
    }

    setState(() {
      if (isStart) {
        _startDate = picked;
        if (_endDate.isBefore(_startDate)) {
          _endDate = _startDate;
        }
      } else {
        _endDate = picked.isBefore(_startDate) ? _startDate : picked;
      }
    });
  }

  Future<void> _generatePlan() async {
    final prompt = _promptController.text.trim();
    if (!hasValidAiPrompt(prompt)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Describe your day or project first.')),
      );
      return;
    }

    setState(() => _isGenerating = true);
    try {
      final response = await generateAiPlan(
        prompt: prompt,
        startDate: _startDate,
        endDate: _endDate,
      );
      setState(() {
        _planTitle = response.planTitle;
        _generated = response.subtasks;
      });
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  void _createTasks() {
    if (_generated.isEmpty) {
      return;
    }

    final notifier = ref.read(taskProvider.notifier);
    createTasksFromAiSubtasks(subtasks: _generated, notifier: notifier);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_generated.length} tasks created successfully.'),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: const BackButton(color: Colors.redAccent),
        title: const Text(
          'AI Planner',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF121212),
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Project or day goal:',
                  style: TextStyle(color: Colors.white54, fontSize: 21),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _promptController,
                  maxLines: 4,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText:
                        'Example: Plan a 5-day Flutter revision schedule for exams',
                    hintStyle: TextStyle(color: Colors.white54),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide(color: Colors.white54, width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide(color: Colors.redAccent, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Plan window:',
                  style: TextStyle(color: Colors.white54, fontSize: 21),
                ),
                const SizedBox(height: 10),
                DueDateSelector(
                  selectedDay: _startDate,
                  onPressed: () => _pickDate(isStart: true),
                  prefixLabel: 'Start:',
                ),
                const SizedBox(height: 10),
                DueDateSelector(
                  selectedDay: _endDate,
                  onPressed: () => _pickDate(isStart: false),
                  prefixLabel: 'End:',
                ),
                const SizedBox(height: 16),
                Card(
                  color: const Color(0xFF1E1E1E),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.event_note, color: Colors.redAccent),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            buildAiPlanWindowLabel(
                              startDate: _startDate,
                              endDate: _endDate,
                            ),
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isGenerating ? null : _generatePlan,
                    icon: _isGenerating
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.auto_awesome),
                    label: Text(
                      _isGenerating ? 'Generating...' : 'Generate Plan',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (_generated.isNotEmpty) ...[
                  Text(
                    _planTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Generated subtasks',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ..._generated.asMap().entries.map(
                    (entry) => Card(
                      color: const Color(0xFF1E1E1E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          child: Text('${entry.key + 1}'),
                        ),
                        title: Text(
                          entry.value.title,
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          '${entry.value.priority} • ${entry.value.category} • ${entry.value.dueDate.day}/${entry.value.dueDate.month}/${entry.value.dueDate.year}\n${entry.value.description}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        isThreeLine: true,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _createTasks,
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Create Tasks'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
