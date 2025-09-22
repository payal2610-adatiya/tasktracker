class Task{
  int? id;
  String title;
  String description;
  String dueDate;
  String status;
  String priority;
  int? userId;
  Task({
   this.id,
   required this.title,
  required this.description,
  required this.dueDate,
  this.status='pending',
  this.priority='low',
  required this.userId
  });
  Map<String,dynamic> toMap()=>
      {
        if(id != null)'id':id,
        'title':title,
        'description':description,
        'due_date':dueDate,
        'status':status,
        'priority':priority,
        'user_id':userId
      };
  factory Task.fromMap(Map<String, dynamic> m) => Task(
    id: m['id'] as int?,
    title: m['title'] ?? '',
    description: m['description'] ?? '',
    dueDate: m['due_date'] ?? '',
    status: m['status'] ?? 'pending',
    priority: m['priority'] ?? 'low',
    userId: m['user_id'] as int?,
  );
}