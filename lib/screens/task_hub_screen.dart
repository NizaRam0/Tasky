import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task.dart';
import '../notifiers/task_notifier.dart';
import 'task_details_screen.dart';

class TaskHubScreen extends ConsumerStatefulWidget {
  const TaskHubScreen({super.key});

  @override
  ConsumerState<TaskHubScreen> createState() => _TaskHubScreenState();
}

class _TaskHubScreenState extends ConsumerState<TaskHubScreen> {
  final TextEditingController _searchController = TextEditingController();
  static const List<String> _baseCategories = [
    'Personal',
    'Work',
    'Learning',
    'Sport/Activity',
    'Errands',
  ];

  String _query = '';
  String _priorityFilter = 'All';
  String _categoryFilter = 'All';
  String _dateFilter = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    final allTasks = ref.watch(taskProvider);
    final notifier = ref.read(taskProvider.notifier);

    final allCategories = <String>[
      'All',
      ..._baseCategories,
      ...allTasks.map((task) => task.category),
    ].toSet().toList();

    final todayTasks = notifier.filterTasks(
      tasks: notifier.getTodayTasks(),
      query: _query,
      priority: _priorityFilter,
      category: _categoryFilter,
      dateFilter: _dateFilter,
    );

    final overdueTasks = notifier.filterTasks(
      tasks: notifier.getOverdueTasks(),
      query: _query,
      priority: _priorityFilter,
      category: _categoryFilter,
      dateFilter: _dateFilter,
    );

    final upcomingTasks = notifier.filterTasks(
      tasks: notifier.getUpcomingTasks(),
      query: _query,
      priority: _priorityFilter,
      category: _categoryFilter,
      dateFilter: _dateFilter,
    );

    final deletedTasks = notifier.filterTasks(
      tasks: notifier.getDeletedTasks(),
      query: _query,
      priority: _priorityFilter,
      category: _categoryFilter,
      dateFilter: _dateFilter,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
                leading: const BackButton(color: Colors.redAccent),
        elevation: 0,
        centerTitle: true,

        title: Text(
          "Tasks Hub",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF121212),
          ),
        ),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  onChanged: (value) {
                    setState(() {
                      _query = value;
                    });
                  },
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, color: Colors.white54),
                    hintText: 'Search by task title',
                    hintStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: const Color(0xFF1E1E1E),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.white54,
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.white54,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.redAccent,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _buildDropdown(
                      label: 'Priority',
                      value: _priorityFilter,
                      items: const ['All', 'Low', 'Medium', 'High'],
                      onChanged: (value) {
                        setState(() {
                          _priorityFilter = value;
                        });
                      },
                    ),
                    _buildDropdown(
                      label: 'Category',
                      value: _categoryFilter,
                      items: allCategories,
                      onChanged: (value) {
                        setState(() {
                          _categoryFilter = value;
                        });
                      },
                    ),
                    _buildDropdown(
                      label: 'Date',
                      value: _dateFilter,
                      items: const ['All', 'Today', 'Overdue', 'Upcoming'],
                      onChanged: (value) {
                        setState(() {
                          _dateFilter = value;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildSection(
                  icon: Icons.push_pin,
                  title: 'Today',
                  tasks: todayTasks,
                  emptyText: 'No tasks due today',
                ),
                _buildSection(
                  icon: Icons.warning_amber,
                  title: 'Overdue',
                  tasks: overdueTasks,
                  emptyText: 'No overdue tasks',
                ),
                _buildSection(
                  icon: Icons.upcoming,
                  title: 'Upcoming',
                  tasks: upcomingTasks,
                  emptyText: 'No upcoming tasks',
                ),
                _buildDeletedSection(deletedTasks),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String> onChanged,
  }) {
    final selectedValue = items.contains(value) ? value : items.first;

    return SizedBox(
      width: 170,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xFF1E1E1E),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: DropdownButtonFormField<String>(
          initialValue: selectedValue,
          isExpanded: true,
          dropdownColor: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(16),
          icon: const Icon(Icons.expand_more, color: Colors.white),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: Colors.white54),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFFFF5252),
                width: 1.5,
              ),
            ),
          ),
          items: items
              .map(
                (item) =>
                    DropdownMenuItem<String>(value: item, child: Text(item)),
              )
              .toList(),
          onChanged: (selected) {
            if (selected == null) {
              return;
            }
            onChanged(selected);
          },
        ),
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required List<Task> tasks,
    required String emptyText,
  }) {
    return Card(
      color: const Color(0xFF1E1E1E),
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.white12, width: 1),
      ),
      child: ExpansionTile(
        leading: Icon(icon, color: Colors.redAccent, size: 24),
        title: Text(
          '$title (${tasks.length})',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        iconColor: Colors.redAccent,
        collapsedIconColor: Colors.redAccent,
        textColor: Colors.white,
        children: [
          if (tasks.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                emptyText,
                style: const TextStyle(color: Colors.white54),
              ),
            )
          else
            ...tasks.map(_buildTaskTile),
        ],
      ),
    );
  }

  Widget _buildDeletedSection(List<Task> tasks) {
    final notifier = ref.read(taskProvider.notifier);

    return Card(
      color: const Color(0xFF1E1E1E),
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.white12, width: 1),
      ),
      child: ExpansionTile(
        leading: const Icon(
          Icons.delete_outline,
          color: Colors.redAccent,
          size: 24,
        ),
        title: Text(
          'Recently Deleted (${tasks.length})',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        iconColor: Colors.redAccent,
        collapsedIconColor: Colors.redAccent,
        textColor: Colors.white,
        children: [
          if (tasks.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'No recently deleted tasks',
                style: TextStyle(color: Colors.white54),
              ),
            )
          else
            ...tasks.map(
              (task) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  title: Text(
                    task.title,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    task.description,
                    style: const TextStyle(color: Colors.white54),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Restore',
                        icon: const Icon(Icons.restore, color: Colors.green),
                        onPressed: () {
                          notifier.restoreTask(task);
                        },
                      ),
                      IconButton(
                        tooltip: 'Delete permanently',
                        icon: const Icon(
                          Icons.delete_forever,
                          color: Colors.redAccent,
                        ),
                        onPressed: () {
                          notifier.permanentlyDeleteTask(task);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTaskTile(Task task) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        title: Text(
          task.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          '${task.category} • ${task.priority} • ${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year}',
          style: const TextStyle(color: Colors.white54),
        ),
        trailing: task.isCompleted
            ? const Icon(Icons.check_circle, color: Colors.green, size: 20)
            : null,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TaskDetailsScreen(taskId: task.tid),
            ),
          );
        },
      ),
    );
  }
}
