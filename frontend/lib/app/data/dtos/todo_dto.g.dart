// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TodoDto _$TodoDtoFromJson(Map<String, dynamic> json) => TodoDto(
      id: (json['id'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      dueDate: (json['dueDate'] as String?) ?? '',
      state: (json['state'] as String?) ?? 'todo',
      category: (json['category'] as String?) ?? 'personal',
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );

Map<String, dynamic> _$TodoDtoToJson(TodoDto instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'dueDate': instance.dueDate,
      'state': instance.state,
      'category': instance.category,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };

UpsertTodoRequestDto _$UpsertTodoRequestDtoFromJson(
        Map<String, dynamic> json) =>
    UpsertTodoRequestDto(
      title: (json['title'] as String?) ?? '',
      dueDate: (json['dueDate'] as String?) ?? '',
      state: (json['state'] as String?) ?? 'todo',
      category: (json['category'] as String?) ?? 'personal',
    );

Map<String, dynamic> _$UpsertTodoRequestDtoToJson(
        UpsertTodoRequestDto instance) =>
    <String, dynamic>{
      'title': instance.title,
      'dueDate': instance.dueDate,
      'state': instance.state,
      'category': instance.category,
    };

TodoListResponseDto _$TodoListResponseDtoFromJson(Map<String, dynamic> json) =>
    TodoListResponseDto(
      data: (json['data'] as List<dynamic>? ?? const [])
          .map((e) => TodoDto.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );

Map<String, dynamic> _$TodoListResponseDtoToJson(
        TodoListResponseDto instance) =>
    <String, dynamic>{
      'data': instance.data.map((e) => e.toJson()).toList(),
    };

TodoSingleResponseDto _$TodoSingleResponseDtoFromJson(
        Map<String, dynamic> json) =>
    TodoSingleResponseDto(
      data: TodoDto.fromJson(Map<String, dynamic>.from(json['data'] as Map)),
    );

Map<String, dynamic> _$TodoSingleResponseDtoToJson(
        TodoSingleResponseDto instance) =>
    <String, dynamic>{
      'data': instance.data.toJson(),
    };
