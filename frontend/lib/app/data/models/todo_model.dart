class TodoState {
  static const String todo = 'todo';
  static const String inProgress = 'in progress';
  static const String done = 'done';

  static const List<String> values = [todo, inProgress, done];

  static String label(String value) {
    switch (value) {
      case todo:
        return 'Todo';
      case inProgress:
        return 'In Progress';
      case done:
        return 'Done';
      default:
        return value;
    }
  }
}

class TodoCategory {
  static const String company = 'company';
  static const String personal = 'personal';
  static const String other = 'other';

  static const List<String> values = [company, personal, other];

  static String label(String value) {
    switch (value) {
      case company:
        return 'Company';
      case personal:
        return 'Personal';
      case other:
        return 'Other';
      default:
        return value;
    }
  }
}

class TodoModel {
  final String id;
  final String title;
  final String dueDate; // 格式: yyyy-mm-dd
  final String state; // 'todo' | 'in progress' | 'done'
  final String category; // 'company' | 'personal' | 'other'
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TodoModel({
    required this.id,
    required this.title,
    required this.dueDate,
    required this.state,
    required this.category,
    this.createdAt,
    this.updatedAt,
  });

  factory TodoModel.fromJson(Map<String, dynamic> json) {
    return TodoModel(
      id: (json['id'] ?? '') as String,
      title: (json['title'] ?? '') as String,
      dueDate: (json['dueDate'] ?? '') as String,
      state: (json['state'] ?? TodoState.todo) as String,
      category: (json['category'] ?? TodoCategory.personal) as String,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toRequestJson() {
    return {
      'title': title,
      'dueDate': dueDate,
      'state': state,
      'category': category,
    };
  }

  TodoModel copyWith({
    String? id,
    String? title,
    String? dueDate,
    String? state,
    String? category,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TodoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      dueDate: dueDate ?? this.dueDate,
      state: state ?? this.state,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
