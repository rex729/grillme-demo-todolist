import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:cullio_todo_app/app/data/models/todo_model.dart';
import 'package:cullio_todo_app/app/data/providers/api_provider.dart';
import 'package:cullio_todo_app/app/modules/todo/todo_controller.dart';
import 'package:cullio_todo_app/app/modules/todo/todo_list_view.dart';
import 'package:cullio_todo_app/app/modules/todo/widgets/todo_bottom_sheet.dart';

class FakeApiProvider extends ApiProvider {
  final List<TodoModel> memory = [];
  int _seq = 1;

  @override
  void onInit() {
    // 測試環境不註冊 Firebase HttpClient 攔截器
  }

  @override
  Future<List<TodoModel>> fetchTodos() async {
    return List<TodoModel>.from(memory);
  }

  @override
  Future<TodoModel> createTodo(TodoModel todo) async {
    final created = todo.copyWith(id: 'todo-${_seq++}');
    memory.add(created);
    return created;
  }

  @override
  Future<TodoModel> updateTodo(TodoModel todo) async {
    final idx = memory.indexWhere((e) => e.id == todo.id);
    if (idx != -1) {
      memory[idx] = todo;
    }
    return todo;
  }

  @override
  Future<void> deleteTodo(String id) async {
    memory.removeWhere((e) => e.id == id);
  }
}

void main() {
  late FakeApiProvider fakeApi;
  late TodoController controller;

  setUp(() {
    Get.testMode = true;
    Get.reset();
    fakeApi = Get.put<ApiProvider>(FakeApiProvider()) as FakeApiProvider;
    controller = Get.put<TodoController>(TodoController());
  });

  tearDown(() {
    Get.reset();
  });

  group('TodoModel TDD Tests', () {
    test('正確反序列化與序列化 TodoModel 欄位', () {
      final json = {
        'id': 't1',
        'title': '開會準備',
        'dueDate': '2026-11-15',
        'state': 'in progress',
        'category': 'company',
      };
      final model = TodoModel.fromJson(json);
      expect(model.id, 't1');
      expect(model.title, '開會準備');
      expect(model.dueDate, '2026-11-15');
      expect(model.state, TodoState.inProgress);
      expect(model.category, TodoCategory.company);

      expect(model.toRequestJson(), {
        'title': '開會準備',
        'dueDate': '2026-11-15',
        'state': 'in progress',
        'category': 'company',
      });
    });
  });

  group('TodoController TDD Tests (Sorting & CRUD)', () {
    test('新增多筆 Todo 後，支援依 dueDate 由舊到新與由新到舊切換排序', () async {
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

    test('快速循環切換狀態 (todo -> in progress -> done -> todo)', () async {
      await controller.addTodo(
        title: '測試狀態切換',
        dueDate: '2026-11-15',
        state: TodoState.todo,
        category: TodoCategory.personal,
      );

      final item = controller.todos.first;
      await controller.cycleTodoState(item);
      expect(controller.todos.first.state, TodoState.inProgress);

      await controller.cycleTodoState(controller.todos.first);
      expect(controller.todos.first.state, TodoState.done);

      await controller.cycleTodoState(controller.todos.first);
      expect(controller.todos.first.state, TodoState.todo);
    });

    test('刪除 Todo 後從列表中移除', () async {
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
