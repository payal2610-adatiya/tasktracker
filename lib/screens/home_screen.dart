import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/task_database.dart';
import '../model/task_model.dart';
import '../task_color/app_color.dart';
import 'add_edit_task_screen.dart';
import 'login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  final int userId;
  const HomeScreen({super.key, required this.userId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final db = MyDatabase();
  List<Task> tasks = [];
  String filter = 'all';

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final maps = await db.getTasks(
      userId: widget.userId,
      status: filter == 'all' ? null : filter,
    );
    setState(() => tasks = maps.map((m) => Task.fromMap(m)).toList());
  }

  Future<void> _deleteTask(Task t) async {
    if (t.id != null) await db.deleteTask(t.id!);
    await _loadTasks();
  }

  Future<void> _toggleComplete(Task t) async {
    t.status = t.status == 'pending' ? 'completed' : 'pending';
    await db.updateTask(t.toMap());
    await _loadTasks();
  }

  Future<void> _openAddEdit([Task? task]) async {
    final changed = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditTaskScreen(task: task, userId: widget.userId),
      ),
    );
    if (changed == true) await _loadTasks();
  }

  void _confirmDelete(Task t) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(' Do you want to delete a task?'),
        content: Text('Delete task "${t.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _deleteTask(t);
              },
              child: const Text('Delete')),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('logged_user_id');

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }

  Color _priorityColor(String p) {
    switch (p) {
      case 'high':
        return AppColors.terracotta;
      case 'medium':
        return AppColors.caramel;
      default:
        return AppColors.tan;
    }
  }

  Widget _taskCard(Task t) {
    final due = DateTime.tryParse(t.dueDate);
    final dueText = due != null ? DateFormat.yMMMd().format(due) : '';
    final titleStyle =
    t.status == 'completed' ? const TextStyle(decoration: TextDecoration.lineThrough) : null;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: Checkbox(
          value: t.status == 'completed',
          onChanged: (_) => _toggleComplete(t),
          activeColor: AppColors.caramel,
        ),
        title: Text(t.title, style: titleStyle),
        subtitle: Row(
          children: [
            Text(dueText),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _priorityColor(t.priority),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                  t.priority[0].toUpperCase() + t.priority.substring(1),
                  style: const TextStyle(fontSize: 12)),
            ),
          ],
        ),
        onTap: () => _openAddEdit(t),
        onLongPress: () => _confirmDelete(t),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // disables back button
      child: Scaffold(
        backgroundColor: AppColors.latte,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('TaskTrack'),
          backgroundColor: AppColors.caramel,
          actions: [
            IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
          ],
        ),
        body: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: filter == 'all',
                  onSelected: (_) {
                    filter = 'all';
                    _loadTasks();
                  },
                ),
                ChoiceChip(
                  label: const Text('Pending'),
                  selected: filter == 'pending',
                  onSelected: (_) {
                    filter = 'pending';
                    _loadTasks();
                  },
                ),
                ChoiceChip(
                  label: const Text('Completed'),
                  selected: filter == 'completed',
                  onSelected: (_) {
                    filter = 'completed';
                    _loadTasks();
                  },
                ),
              ],
            ),
            Expanded(
              child: tasks.isEmpty
                  ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.inbox, size: 64, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('No tasks yet'),
                  ],
                ),
              )
                  : ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (_, i) => _taskCard(tasks[i]),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _openAddEdit(),
          backgroundColor: AppColors.caramel,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
