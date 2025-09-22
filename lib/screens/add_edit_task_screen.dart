import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/task_database.dart';
import '../model/task_model.dart';

class AddEditTaskScreen extends StatefulWidget {
  final Task? task;
  final int userId;
  const AddEditTaskScreen({Key? key, this.task, required this.userId}) : super(key: key);

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
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.brown,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
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
    final dateText = _dueDate == null ? 'Pick due date' : DateFormat.yMMMd().format(_dueDate!);

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text(widget.task == null ? 'Add Task' : 'Edit Task'),
        backgroundColor: Colors.brown,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildCard(
                child: TextFormField(
                  controller: _titleCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Title', border: InputBorder.none, labelStyle: TextStyle(color: Colors.white70)),
                  validator: (s) => (s == null || s.trim().isEmpty) ? 'Enter title' : null,
                ),
              ),
              const SizedBox(height: 16),
              _buildCard(
                child: TextFormField(
                  controller: _descCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Description', border: InputBorder.none, labelStyle: TextStyle(color: Colors.white70)),
                  minLines: 3,
                  maxLines: 6,
                ),
              ),
              const SizedBox(height: 16),
              _buildCard(
                child: Row(
                  children: [
                    Expanded(child: Text(dateText, style: const TextStyle(fontSize: 15, color: Colors.white))),
                    ElevatedButton(
                      onPressed: _pickDate,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.brown, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: const Text('Select'),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildCard(
                child: DropdownButtonFormField<String>(
                  value: _priority,
                  items: ['low', 'medium', 'high']
                      .map((p) => DropdownMenuItem(value: p, child: Text(p[0].toUpperCase() + p.substring(1), style: const TextStyle(fontSize: 15, color: Colors.white))))
                      .toList(),
                  onChanged: (v) => setState(() => _priority = v ?? 'low'),
                  decoration: const InputDecoration(labelText: 'Priority', border: InputBorder.none, labelStyle: TextStyle(color: Colors.white70)),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), backgroundColor: Colors.brown),
                  child: const Text('Save Task', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 3))],
      ),
      child: child,
    );
  }
}
