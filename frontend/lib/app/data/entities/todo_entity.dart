/// 待辦事項狀態列舉值 (Domain Value Constants)
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

/// 待辦事項分類列舉值 (Domain Value Constants)
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

/// 領域實體 (Domain Entity)：與網路 JSON / DTO 解耦，專注於業務屬性與領域行為
class TodoEntity {
  final String id;
  final String title;
  final String dueDate; // 格式: yyyy-mm-dd
  final String state; // 'todo' | 'in progress' | 'done'
  final String category; // 'company' | 'personal' | 'other'
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const TodoEntity({
    required this.id,
    required this.title,
    required this.dueDate,
    required this.state,
    required this.category,
    this.createdAt,
    this.updatedAt,
  });

  /// 領域邏輯：計算下一個循環狀態 (todo -> in progress -> done -> todo)
  String get nextState {
    if (state == TodoState.todo) return TodoState.inProgress;
    if (state == TodoState.inProgress) return TodoState.done;
    return TodoState.todo;
  }

  TodoEntity copyWith({
    String? id,
    String? title,
    String? dueDate,
    String? state,
    String? category,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TodoEntity(
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
