import 'package:json_annotation/json_annotation.dart';
import '../entities/todo_entity.dart';

part 'todo_dto.g.dart';

/// 單筆 Todo 資料傳輸物件 (DTO)
@JsonSerializable()
class TodoDto {
  final String id;
  final String title;
  final String dueDate;
  final String state;
  final String category;
  final String? createdAt;
  final String? updatedAt;

  const TodoDto({
    required this.id,
    required this.title,
    required this.dueDate,
    required this.state,
    required this.category,
    this.createdAt,
    this.updatedAt,
  });

  factory TodoDto.fromJson(Map<String, dynamic> json) =>
      _$TodoDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TodoDtoToJson(this);

  /// 將 DTO 轉換為領域實體 (Entity)
  TodoEntity toEntity() {
    return TodoEntity(
      id: id,
      title: title,
      dueDate: dueDate,
      state: state,
      category: category,
      createdAt: createdAt != null ? DateTime.tryParse(createdAt!) : null,
      updatedAt: updatedAt != null ? DateTime.tryParse(updatedAt!) : null,
    );
  }

  /// 由領域實體 (Entity) 建立 DTO
  factory TodoDto.fromEntity(TodoEntity entity) {
    return TodoDto(
      id: entity.id,
      title: entity.title,
      dueDate: entity.dueDate,
      state: entity.state,
      category: entity.category,
      createdAt: entity.createdAt?.toUtc().toIso8601String(),
      updatedAt: entity.updatedAt?.toUtc().toIso8601String(),
    );
  }
}

/// 新增或更新 Todo 的 Request Body DTO
@JsonSerializable()
class UpsertTodoRequestDto {
  final String title;
  final String dueDate;
  final String state;
  final String category;

  const UpsertTodoRequestDto({
    required this.title,
    required this.dueDate,
    required this.state,
    required this.category,
  });

  factory UpsertTodoRequestDto.fromJson(Map<String, dynamic> json) =>
      _$UpsertTodoRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UpsertTodoRequestDtoToJson(this);

  factory UpsertTodoRequestDto.fromEntity(TodoEntity entity) {
    return UpsertTodoRequestDto(
      title: entity.title,
      dueDate: entity.dueDate,
      state: entity.state,
      category: entity.category,
    );
  }
}

/// GET /api/v1/todos 回應外層包裝 DTO ({"data": [TodoDto, ...]})
@JsonSerializable()
class TodoListResponseDto {
  final List<TodoDto> data;

  const TodoListResponseDto({required this.data});

  factory TodoListResponseDto.fromJson(Map<String, dynamic> json) =>
      _$TodoListResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TodoListResponseDtoToJson(this);
}

/// POST / PUT /api/v1/todos 回應外層包裝 DTO ({"data": TodoDto})
@JsonSerializable()
class TodoSingleResponseDto {
  final TodoDto data;

  const TodoSingleResponseDto({required this.data});

  factory TodoSingleResponseDto.fromJson(Map<String, dynamic> json) =>
      _$TodoSingleResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TodoSingleResponseDtoToJson(this);
}
