import 'package:get/get.dart';
import '../../data/models/todo_model.dart';
import '../../data/providers/api_provider.dart';

class TodoController extends GetxController {
  final ApiProvider _apiProvider = Get.find<ApiProvider>();

  /// 原始 Todo 列表
  final RxList<TodoModel> todos = <TodoModel>[].obs;

  /// 是否依 dueDate 由新到舊排序 (true = 由新到舊 Descending, false = 由舊到新 Ascending)
  final RxBool isSortDescending = false.obs;

  /// 載入與送出狀態
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;

  /// 依 dueDate 排序後的響應式列表（無篩選器，直接呈現全部項目並排序）
  List<TodoModel> get sortedTodos {
    final list = List<TodoModel>.from(todos);
    list.sort((a, b) {
      final cmp = a.dueDate.compareTo(b.dueDate);
      return isSortDescending.value ? -cmp : cmp;
    });
    return list;
  }

  @override
  void onInit() {
    super.onInit();
    loadTodos();
  }

  /// 切換到期日排序方向（由新到舊 <-> 由舊到新）
  void toggleSortOrder() {
    isSortDescending.value = !isSortDescending.value;
  }

  /// 從 Go 後端拉取當前使用者的所有 Todo
  Future<void> loadTodos() async {
    try {
      isLoading.value = true;
      final result = await _apiProvider.fetchTodos();
      todos.assignAll(result);
    } catch (e) {
      Get.snackbar(
        '載入失敗',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// 新增 Todo
  Future<bool> addTodo({
    required String title,
    required String dueDate,
    required String state,
    required String category,
  }) async {
    try {
      isSubmitting.value = true;
      final created = await _apiProvider.createTodo(
        TodoModel(
          id: '',
          title: title.trim(),
          dueDate: dueDate,
          state: state,
          category: category,
        ),
      );
      todos.add(created);
      return true;
    } catch (e) {
      Get.snackbar(
        '新增失敗',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// 更新既有 Todo
  Future<bool> editTodo(TodoModel updated) async {
    try {
      isSubmitting.value = true;
      final saved = await _apiProvider.updateTodo(updated);
      final idx = todos.indexWhere((item) => item.id == saved.id);
      if (idx != -1) {
        todos[idx] = saved;
      }
      return true;
    } catch (e) {
      Get.snackbar(
        '更新失敗',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// 快速循環切換單一 Todo 的 state (todo -> in progress -> done -> todo)
  Future<void> cycleTodoState(TodoModel todo) async {
    final String nextState;
    if (todo.state == TodoState.todo) {
      nextState = TodoState.inProgress;
    } else if (todo.state == TodoState.inProgress) {
      nextState = TodoState.done;
    } else {
      nextState = TodoState.todo;
    }
    await editTodo(todo.copyWith(state: nextState));
  }

  /// 刪除 Todo
  Future<void> removeTodo(String id) async {
    final backupIndex = todos.indexWhere((item) => item.id == id);
    TodoModel? backupItem;
    if (backupIndex != -1) {
      backupItem = todos.removeAt(backupIndex);
    }
    try {
      await _apiProvider.deleteTodo(id);
    } catch (e) {
      if (backupItem != null && backupIndex != -1) {
        todos.insert(backupIndex, backupItem);
      }
      Get.snackbar(
        '刪除失敗',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
