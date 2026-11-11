import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:cullio_todo_app/app/data/entities/todo_entity.dart';
import 'package:cullio_todo_app/app/data/dtos/todo_dto.dart';
import 'package:cullio_todo_app/app/data/services/todo_api_service.dart';
import 'package:cullio_todo_app/app/modules/todo/controllers/todo_controller.dart';

/// 測試用假 Retrofit TodoApiService (In-Memory Stub)
class FakeTodoApiService implements TodoApiService {
  final List<TodoDto> memory = [];
  int _seq = 1;

  @override
  Future<TodoListResponseDto> getTodos() async {
    return TodoListResponseDto(data: List<TodoDto>.from(memory));
  }

  @override
  Future<TodoSingleResponseDto> createTodo(UpsertTodoRequestDto body) async {
    final now = DateTime.now().toUtc().toIso8601String();
    final created = TodoDto(
      id: 'todo-${_seq++}',
      title: body.title,
      dueDate: body.dueDate,
      state: body.state,
      category: body.category,
      createdAt: now,
      updatedAt: now,
    );
    memory.add(created);
    return TodoSingleResponseDto(data: created);
  }

  @override
  Future<TodoSingleResponseDto> updateTodo(
    String id,
    UpsertTodoRequestDto body,
  ) async {
    final idx = memory.indexWhere((e) => e.id == id);
    final now = DateTime.now().toUtc().toIso8601String();
    final updated = TodoDto(
      id: id,
      title: body.title,
      dueDate: body.dueDate,
      state: body.state,
      category: body.category,
      createdAt: idx != -1 ? memory[idx].createdAt : now,
      updatedAt: now,
    );
    if (idx != -1) {
      memory[idx] = updated;
    }
    return TodoSingleResponseDto(data: updated);
  }

  @override
  Future<void> deleteTodo(String id) async {
    memory.removeWhere((e) => e.id == id);
  }
}

void main() {
  late FakeTodoApiService fakeApiService;
  late TodoController controller;

  setUp(() {
    Get.testMode = true;
    Get.reset();
    fakeApiService =
        Get.put<TodoApiService>(FakeTodoApiService()) as FakeTodoApiService;
    controller = Get.put<TodoController>(TodoController());
  });

  tearDown(() {
    Get.reset();
  });

  group('Entity & DTO Mapping TDD Tests', () {
    test('TodoDto 反序列化並正確轉換為 TodoEntity 與 UpsertTodoRequestDto', () {
      final json = {
        'id': 't1',
        'title': '架構重構為 MVC',
        'dueDate': '2026-11-15',
        'state': 'in progress',
        'category': 'company',
        'createdAt': '2026-11-11T10:00:00Z',
        'updatedAt': '2026-11-11T10:00:00Z',
      };

      final dto = TodoDto.fromJson(json);
      final entity = dto.toEntity();

      expect(entity.id, 't1');
      expect(entity.title, '架構重構為 MVC');
      expect(entity.dueDate, '2026-11-15');
      expect(entity.state, TodoState.inProgress);
      expect(entity.category, TodoCategory.company);

      final reqDto = UpsertTodoRequestDto.fromEntity(entity);
      expect(reqDto.toJson(), {
        'title': '架構重構為 MVC',
        'dueDate': '2026-11-15',
        'state': 'in progress',
        'category': 'company',
      });
    });

    test('TodoEntity.nextState 領域邏輯正確循環切換狀態', () {
      final entity = TodoEntity(
        id: '1',
        title: '測試',
        dueDate: '2026-11-15',
        state: TodoState.todo,
        category: TodoCategory.personal,
      );
      expect(entity.nextState, TodoState.inProgress);
      expect(
        entity.copyWith(state: TodoState.inProgress).nextState,
        TodoState.done,
      );
      expect(entity.copyWith(state: TodoState.done).nextState, TodoState.todo);
    });
  });

  group('TodoController (MVC + Retrofit Service) TDD Tests', () {
    test('新增多筆 TodoEntity 後，支援依 dueDate 由舊到新與由新到舊切換排序', () async {
      await controller.addTodo(
        title: '中程任務',
        dueDate: '2026-11-20',
        state: TodoState.todo,
        category: TodoCategory.company,
      );
      await controller.addTodo(
        title: '近期任務',
        dueDate: '2026-11-12',
        state: TodoState.inProgress,
        category: TodoCategory.personal,
      );
      await controller.addTodo(
        title: '遠期任務',
        dueDate: '2026-12-01',
        state: TodoState.done,
        category: TodoCategory.other,
      );

      // 預設 isSortDescending = false (由舊到新 Ascending)
      expect(controller.isSortDescending.value, isFalse);
      expect(
        controller.sortedTodos.map((e) => e.dueDate).toList(),
        ['2026-11-12', '2026-11-20', '2026-12-01'],
      );

      // 切換為由新到舊 (Descending)
      controller.toggleSortOrder();
      expect(controller.isSortDescending.value, isTrue);
      expect(
        controller.sortedTodos.map((e) => e.dueDate).toList(),
        ['2026-12-01', '2026-11-20', '2026-11-12'],
      );
    });

    test('透過 Controller 快速循環切換 TodoEntity 的 state', () async {
      await controller.addTodo(
        title: '測試狀態切換',
        dueDate: '2026-11-15',
        state: TodoState.todo,
        category: TodoCategory.personal,
      );

      await controller.cycleTodoState(controller.todos.first);
      expect(controller.todos.first.state, TodoState.inProgress);

      await controller.cycleTodoState(controller.todos.first);
      expect(controller.todos.first.state, TodoState.done);

      await controller.cycleTodoState(controller.todos.first);
      expect(controller.todos.first.state, TodoState.todo);
    });

    test('透過 Controller 刪除 TodoEntity 後從列表中移除', () async {
      await controller.addTodo(
        title: '待刪除項目',
        dueDate: '2026-11-15',
        state: TodoState.todo,
        category: TodoCategory.other,
      );
      expect(controller.todos.length, 1);

      final id = controller.todos.first.id;
      await controller.removeTodo(id);
      expect(controller.todos, isEmpty);
    });
  });
}
