import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../db/task_database.dart';
import '../model/task_model.dart';
import '../task_color/app_color.dart';
import 'add_edit_task_screen.dart';
import 'login.dart';


class HomeScreen extends StatefulWidget {
  final int userId;
  const HomeScreen({Key? key, required this.userId}) : super(key: key);

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
    _load();
  }

  Future<void> _load() async {
    final maps = await db.getTasks(
      userId: widget.userId,
      status: filter == 'all' ? null : filter,
    );
    setState(() => tasks = maps.map((m) => Task.fromMap(m)).toList());
  }

  Future<void> _delete(Task t) async {
    if (t.id != null) await db.deleteTask(t.id!);
    await _load();
  }

  Future<void> _toggleComplete(Task t) async {
    t.status = (t.status == 'pending') ? 'completed' : 'pending';
    await db.updateTask(t.toMap());
    await _load();
  }

  Future<void> _openAddEdit([Task? task]) async {
    final changed = await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => AddEditTaskScreen(task: task, userId: widget.userId),
    ));
    if (changed == true) await _load();
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('logged_user_id');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  Color priorityColor(String p) {
    switch (p) {
      case 'high':
        return AppColors.saddle;
      case 'medium':
        return AppColors.terracotta;
      default:
        return AppColors.grey;
    }
  }

  Widget _buildTaskCard(Task t) {
    final due = DateTime.tryParse(t.dueDate);
    final dueText = due == null ? '' : DateFormat.yMMMd().format(due);
    final isDone = t.status == 'completed';

    return GestureDetector(
      onLongPress: () => _delete(t),
      onTap: () => _openAddEdit(t),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: isDone
                ? [AppColors.grey.withOpacity(0.6), AppColors.grey.withOpacity(0.4)]
                : [AppColors.toast, AppColors.latte],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border(
            left: BorderSide(color: priorityColor(t.priority), width: 6),
          ),
        ),
        child: Row(
          children: [
            Checkbox(
              value: isDone,
              onChanged: (_) => _toggleComplete(t),
              activeColor: AppColors.saddle,
              checkColor: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                      decoration:
                      isDone ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  if (t.description.isNotEmpty)
                    Text(
                      t.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.grey,
                        fontSize: 13,
                      ),
                    ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                          priorityColor(t.priority).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          t.priority.toUpperCase(),
                          style: TextStyle(
                            color: priorityColor(t.priority),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      if (dueText.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.mocha,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            dueText,
                            style: const TextStyle(
                              color: AppColors.saddle,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.latte,
      appBar: AppBar(
        title: const Text("My Tasks"),
        centerTitle: true,
        backgroundColor: AppColors.terracotta,
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout, color: Colors.white),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.terracotta,
        onPressed: () => _openAddEdit(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: tasks.isEmpty
          ? const Center(
        child: Text(
          "No tasks found",
          style: TextStyle(
            color: AppColors.grey,
            fontSize: 16,
          ),
        ),
      )
          : ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (_, i) => _buildTaskCard(tasks[i]),
      ),
    );
  }
}
