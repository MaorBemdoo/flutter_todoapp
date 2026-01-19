import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

class Task {
  String id;
  String title;
  String? note;
  bool done;
  DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    this.note,
    this.done = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'note': note,
    'done': done,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Task.fromMap(Map<String, dynamic> m) => Task(
    id: m['id'] as String,
    title: m['title'] as String,
    note: m['note'] as String?,
    done: m['done'] as bool? ?? false,
    createdAt: m['createdAt'] == null
        ? DateTime.now()
        : DateTime.parse(m['createdAt'] as String),
  );
}

class TaskModel extends ChangeNotifier {
  late final Box _box;

  TaskModel() {
    _box = Hive.box('tasks');
  }

  List<Task> get tasks {
    final list = _box.values
        .map((e) => Task.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Future<void> addTask(Task t) async {
    await _box.put(t.id, t.toMap());
    notifyListeners();
  }

  Future<void> updateTask(Task t) async {
    await _box.put(t.id, t.toMap());
    notifyListeners();
  }

  Future<void> removeTask(String id) async {
    await _box.delete(id);
    notifyListeners();
  }

  Future<void> toggleDone(String id) async {
    final raw = _box.get(id);
    if (raw == null) return;
    final t = Task.fromMap(Map<String, dynamic>.from(raw as Map));
    final updated = Task(
      id: t.id,
      title: t.title,
      note: t.note,
      done: !t.done,
      createdAt: t.createdAt,
    );
    await _box.put(id, updated.toMap());
    notifyListeners();
  }
}
