import 'package:flutter/material.dart';

import '../models/task.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final ValueChanged<bool?>? onToggle;
  final VoidCallback? onEdit;

  const TaskTile({super.key, required this.task, this.onToggle, this.onEdit});

  @override
  Widget build(BuildContext context) {
    final titleStyle = task.done
        ? const TextStyle(
            decoration: TextDecoration.lineThrough,
            color: Colors.grey,
          )
        : const TextStyle(fontWeight: FontWeight.w600);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Checkbox(value: task.done, onChanged: onToggle),
        title: Text(task.title, style: titleStyle),
        subtitle: task.note == null || task.note!.isEmpty
            ? null
            : Text(task.note!),
        trailing: IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
      ),
    );
  }
}
