import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/task_database.dart';
import '../model/task_model.dart';
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
  DateTime? _dueDate;
  String _priority = 'low';
  final db = MyDatabase();

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleCtrl.text = widget.task!.title;
      _descCtrl.text = widget.task!.description;
      _dueDate = DateTime.tryParse(widget.task!.dueDate);
      _priority = widget.task!.priority;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.caramel,
              onPrimary: AppColors.latte,
              onSurface: AppColors.saddle,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final isoDate = (_dueDate ?? DateTime.now()).toIso8601String();
    final map = {
      if (widget.task?.id != null) 'id': widget.task!.id,
      'title': _titleCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'due_date': isoDate,
      'status': widget.task?.status ?? 'pending',
      'priority': _priority,
      'user_id': widget.userId,
    };

    if (widget.task == null) {
      await db.insertTask(map);
    } else {
      await db.updateTask(map);
    }

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final dateText =
    _dueDate == null ? 'Pick due date' : DateFormat.yMMMd().format(_dueDate!);

    return Scaffold(
      backgroundColor: AppColors.latte,
      appBar: AppBar(title: Text(widget.task == null ? 'Add Task' : 'Edit Task')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: InputDecoration(
                  labelText: 'Title',
                  filled: true,
                  fillColor: AppColors.toast,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (s) =>
                s == null || s.trim().isEmpty ? 'Enter title' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtrl,
                decoration: InputDecoration(
                  labelText: 'Description',
                  filled: true,
                  fillColor: AppColors.toast,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                minLines: 3,
                maxLines: 6,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: Text(dateText)),
                  ElevatedButton(
                    onPressed: _pickDate,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.caramel),
                    child: const Text('Select'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _priority,
                items: ['low', 'medium', 'high']
                    .map((p) => DropdownMenuItem(
                    value: p,
                    child: Text(p[0].toUpperCase() + p.substring(1))))
                    .toList(),
                onChanged: (v) => setState(() => _priority = v ?? 'low'),
                decoration: InputDecoration(
                  labelText: 'Priority',
                  filled: true,
                  fillColor: AppColors.toast,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: AppColors.caramel,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
