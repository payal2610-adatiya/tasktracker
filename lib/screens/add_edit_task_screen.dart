import 'package:flutter/material.dart';
import '../model/task_model.dart';
import '../db/task_database.dart';
import '../task_color/app_color.dart';


class AddEditTaskScreen extends StatefulWidget {
  final Task? task;
  final int userId;

  const AddEditTaskScreen({super.key, this.task, required this.userId});

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  DateTime? _selectedDate;
  bool _loading = false;

  final db = MyDatabase();

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleCtrl.text = widget.task!.title;
      _descCtrl.text = widget.task!.description;
      _selectedDate = DateTime.parse(widget.task!.dueDate);
    }
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final title = _titleCtrl.text.trim();
    final desc = _descCtrl.text.trim();
    final date = _selectedDate?.toIso8601String() ?? DateTime.now().toIso8601String();

    if (widget.task == null) {
      await db.insertTask(Task(
        userId: widget.userId,
        title: title,
        description: desc,
        dueDate: date,
      ) as Map<String, dynamic>);
    } else {
      await db.updateTask(Task(
        id: widget.task!.id,
        userId: widget.userId,
        title: title,
        description: desc,
        dueDate: date,
      ) as Map<String, dynamic>);
    }

    Navigator.pop(context, true);
    setState(() => _loading = false);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.terracotta,
              onPrimary: Colors.white,
              onSurface: AppColors.saddle,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.latte,
      appBar: AppBar(
        backgroundColor: AppColors.terracotta,
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.task == null ? "Add Task" : "Edit Task",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.caramel, AppColors.latte],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Title
                    TextFormField(
                      controller: _titleCtrl,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.title, color: AppColors.terracotta),
                        labelText: "Task Title",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      validator: (v) => v == null || v.isEmpty ? "Enter task title" : null,
                    ),
                    const SizedBox(height: 16),

                    // Description
                    TextFormField(
                      controller: _descCtrl,
                      maxLines: 3,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.notes, color: AppColors.terracotta),
                        labelText: "Description",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Due Date
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _selectedDate == null
                                ? "No date selected"
                                : "Due: ${_selectedDate!.toLocal().toString().split(' ')[0]}",
                            style: const TextStyle(color: AppColors.saddle, fontSize: 16),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.calendar_month, color: AppColors.terracotta),
                          onPressed: _pickDate,
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(
                            colors: [AppColors.terracotta, AppColors.caramel],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                        child: ElevatedButton(
                          onPressed: _loading ? null : _saveTask,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _loading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(
                            widget.task == null ? "Save Task" : "Update Task",
                            style: const TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
