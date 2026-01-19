// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../widgets/task_tile.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _showAddEditSheet(BuildContext context, {Task? existing}) {
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final noteCtrl = TextEditingController(text: existing?.note ?? '');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'What do you want to do?',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: noteCtrl,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      final title = titleCtrl.text.trim();
                      if (title.isEmpty) return;
                      final model = Provider.of<TaskModel>(
                        context,
                        listen: false,
                      );
                      if (existing != null) {
                        final updated = Task(
                          id: existing.id,
                          title: title,
                          note: noteCtrl.text.trim(),
                          done: existing.done,
                          createdAt: existing.createdAt,
                        );
                        await model.updateTask(updated);
                      } else {
                        final t = Task(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          title: title,
                          note: noteCtrl.text.trim(),
                        );
                        await model.addTask(t);
                      }
                      Navigator.of(ctx).pop();
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Todos'), elevation: 0),
      body: Consumer<TaskModel>(
        builder: (context, model, _) {
          final tasks = model.tasks;
          if (tasks.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.task_alt,
                      size: 88,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No tasks yet',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('Tap the + button to add your first todo.'),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: tasks.length,
            itemBuilder: (ctx, i) {
              final t = tasks[i];
              return Dismissible(
                key: ValueKey(t.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) async {
                  // Keep a backup so the user can undo the deletion
                  final removed = t;
                  await model.removeTask(t.id);
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Task deleted'),
                      action: SnackBarAction(
                        label: 'Undo',
                        onPressed: () async {
                          await model.addTask(removed);
                        },
                      ),
                    ),
                  );
                },
                child: TaskTile(
                  task: t,
                  onToggle: (_) async => await model.toggleDone(t.id),
                  onEdit: () => _showAddEditSheet(context, existing: t),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
