class Task {
  int? id;
  String name;
  String priority;
  bool completed;

  Task({
    this.id,
    required this.name,
    required this.priority,
    this.completed = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'priority': priority,
      'completed': completed ? 1 : 0,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      name: map['name'],
      priority: map['priority'],
      completed: map['completed'] == 1,
    );
  }
}
