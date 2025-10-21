import 'package:flutter/material.dart';
import 'database/models/item.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDarkMode = false; // Track current theme

  void _toggleTheme(bool value) {
    setState(() {
      isDarkMode = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task List with Priority & Dark/Light Mode',
      theme: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: TaskListScreen(
        isDarkMode: isDarkMode,
        onThemeChanged: _toggleTheme,
      ),
    );
  }
}

class TaskListScreen extends StatefulWidget {
  final bool isDarkMode;
  final Function(bool) onThemeChanged;

  const TaskListScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TextEditingController nameController = TextEditingController();

  // Priority options
  final List<String> priorities = ['Low', 'Medium', 'High'];
  String selectedPriority = 'Low';

  List<Map<String, dynamic>> items = [];

  void _addItem() {
    final taskName = nameController.text.trim();
    if (taskName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a task')),
      );
      return;
    }

    setState(() {
      items.insert(0, {
        'item': Item(id: null, name: taskName),
        'completed': false,
        'priority': selectedPriority,
      });
      _sortByPriority();
    });

    nameController.clear();
    selectedPriority = 'Low'; // Reset dropdown
  }

  void _toggleComplete(int index, bool value) {
    setState(() {
      items[index]['completed'] = value;
    });
  }

  void _removeItem(int index) {
    setState(() {
      items.removeAt(index);
    });
  }

  void _sortByPriority() {
    const order = {'High': 3, 'Medium': 2, 'Low': 1};
    items.sort((a, b) =>
        order[b['priority']]!.compareTo(order[a['priority']]!)); // High first
  }

  void _changePriority(int index, String newPriority) {
    setState(() {
      items[index]['priority'] = newPriority;
      _sortByPriority();
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return Colors.redAccent;
      case 'Medium':
        return Colors.orangeAccent;
      case 'Low':
      default:
        return Colors.greenAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Task List with Priority'),
        actions: [
          Row(
            children: [
              const Icon(Icons.light_mode),
              Switch(
                value: widget.isDarkMode,
                onChanged: widget.onThemeChanged,
                activeColor: Colors.greenAccent,
              ),
              const Icon(Icons.dark_mode),
              const SizedBox(width: 8),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Task name input
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                hintText: 'Enter a task',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _addItem(),
            ),
            const SizedBox(height: 12),

            // Priority dropdown
            Row(
              children: [
                const Text('Priority:'),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: selectedPriority,
                  items: priorities.map((String priority) {
                    return DropdownMenuItem<String>(
                      value: priority,
                      child: Text(priority),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedPriority = value!;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Add + Refresh buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _addItem,
                    child: const Text('Add Task'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => setState(() => _sortByPriority()),
                    child: const Text('Refresh & Sort'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Text(
              'Tasks:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Task List
            Expanded(
              child: items.isEmpty
                  ? const Center(child: Text('No tasks yet'))
                  : ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final item = items[index]['item'] as Item;
                        final completed = items[index]['completed'] as bool;
                        final priority = items[index]['priority'] as String;

                        return ListTile(
                          leading: Switch(
                            value: completed,
                            onChanged: (value) =>
                                _toggleComplete(index, value),
                            activeColor: Colors.green,
                          ),
                          title: Text(
                            item.name,
                            style: TextStyle(
                              decoration: completed
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                              color: completed ? Colors.grey : null,
                            ),
                          ),
                          subtitle: Row(
                            children: [
                              Text(
                                'Priority: ',
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.secondary),
                              ),
                              DropdownButton<String>(
                                value: priority,
                                underline: Container(),
                                items: priorities.map((String p) {
                                  return DropdownMenuItem<String>(
                                    value: p,
                                    child: Text(
                                      p,
                                      style: TextStyle(
                                        color: _getPriorityColor(p),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) =>
                                    _changePriority(index, value!),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete,
                                color: Colors.redAccent),
                            onPressed: () => _removeItem(index),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}