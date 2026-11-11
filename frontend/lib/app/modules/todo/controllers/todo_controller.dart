import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../../data/dtos/todo_dto.dart';
import '../../../data/entities/todo_entity.dart';
import '../../../data/services/todo_api_service.dart';

/// MVC Controller：負責協調 Retrofit TodoApiService (DTO <-> Entity 轉換) 與響應式 UI 狀態
class TodoController extends GetxController {
  final TodoApiService _apiService = Get.find<TodoApiService>();

  /// 領域實體 (Entity) 列表
  final RxList<TodoEntity> todos = <TodoEntity>[].obs;

  /// 是否依 dueDate 由新到舊排序 (true = 由新到舊 Descending, false = 由舊到新 Ascending)
  final RxBool isSortDescending = false.obs;

  /// 載入與送出狀態
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;

  /// 依 dueDate 排序後的響應式 Entity 列表
  List<TodoEntity> get sortedTodos {
    final list = List<TodoEntity>.from(todos);
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

  /// 透過 Retrofit TodoApiService 讀取所有 Todo 並將 DTO 轉為 Entity
  Future<void> loadTodos() async {
    try {
      isLoading.value = true;
      final responseDto = await _apiService.getTodos();
      final entities = responseDto.data.map((dto) => dto.toEntity()).toList();
      todos.assignAll(entities);
    } catch (e) {
      Get.snackbar(
        '載入失敗',
        _formatError(e),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// 新增 Todo (Entity -> UpsertTodoRequestDto -> Retrofit -> TodoDto -> Entity)
  Future<bool> addTodo({
    required String title,
    required String dueDate,
    required String state,
    required String category,
  }) async {
    try {
      isSubmitting.value = true;
      final draftEntity = TodoEntity(
        id: '',
        title: title.trim(),
        dueDate: dueDate,
        state: state,
        category: category,
      );
      final reqDto = UpsertTodoRequestDto.fromEntity(draftEntity);
      final resDto = await _apiService.createTodo(reqDto);
      todos.add(resDto.data.toEntity());
      return true;
    } catch (e) {
      Get.snackbar(
        '新增失敗',
        _formatError(e),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// 更新既有 TodoEntity
  Future<bool> editTodo(TodoEntity updated) async {
    try {
      isSubmitting.value = true;
      final reqDto = UpsertTodoRequestDto.fromEntity(updated);
      final resDto = await _apiService.updateTodo(updated.id, reqDto);
      final savedEntity = resDto.data.toEntity();
      final idx = todos.indexWhere((item) => item.id == savedEntity.id);
      if (idx != -1) {
        todos[idx] = savedEntity;
      }
      return true;
    } catch (e) {
      Get.snackbar(
        '更新失敗',
        _formatError(e),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// 使用 TodoEntity.nextState 領域邏輯快速循環切換狀態
  Future<void> cycleTodoState(TodoEntity todo) async {
    await editTodo(todo.copyWith(state: todo.nextState));
  }

  /// 刪除 Todo
  Future<void> removeTodo(String id) async {
    final backupIndex = todos.indexWhere((item) => item.id == id);
    TodoEntity? backupItem;
    if (backupIndex != -1) {
      backupItem = todos.removeAt(backupIndex);
    }
    try {
      await _apiService.deleteTodo(id);
    } catch (e) {
      if (backupItem != null && backupIndex != -1) {
        todos.insert(backupIndex, backupItem);
      }
      Get.snackbar(
        '刪除失敗',
        _formatError(e),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  String _formatError(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map && data['error'] != null) {
        return data['error'].toString();
      }
      return error.message ?? '網路連線異常';
    }
    return error.toString();
  }
}
