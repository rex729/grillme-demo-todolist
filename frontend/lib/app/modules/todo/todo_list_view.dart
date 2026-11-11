import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/todo_model.dart';
import '../auth/auth_controller.dart';
import 'todo_controller.dart';
import 'widgets/todo_bottom_sheet.dart';

class TodoListView extends GetView<TodoController> {
  const TodoListView({super.key});

  void _openBottomSheet({TodoModel? todo}) {
    Get.bottomSheet(
      TodoBottomSheet(existingTodo: todo),
      isScrollControlled: true,
    );
  }

  Color _stateColor(String state) {
    switch (state) {
      case TodoState.done:
        return Colors.green.shade600;
      case TodoState.inProgress:
        return Colors.orange.shade700;
      case TodoState.todo:
      default:
        return Colors.blueGrey.shade600;
    }
  }

  Color _categoryColor(String category) {
    switch (category) {
      case TodoCategory.company:
        return Colors.indigo.shade600;
      case TodoCategory.personal:
        return Colors.teal.shade600;
      case TodoCategory.other:
      default:
        return Colors.purple.shade600;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('我的待辦清單'),
        actions: [
          // 切換 dueDate 排序方向按鈕 (由舊到新 / 由新到舊)
          Obx(() {
            final isDesc = controller.isSortDescending.value;
            return TextButton.icon(
              onPressed: controller.toggleSortOrder,
              icon: Icon(
                isDesc
                    ? Icons.arrow_downward_rounded
                    : Icons.arrow_upward_rounded,
                size: 18,
              ),
              label: Text(isDesc ? '到期日：由新到舊' : '到期日：由舊到新'),
            );
          }),
          IconButton(
            tooltip: '重新整理',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: controller.loadTodos,
          ),
          IconButton(
            tooltip: '登出',
            icon: const Icon(Icons.logout_rounded),
            onPressed: authController.signOut,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.todos.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final items = controller.sortedTodos;
        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 12),
                Text(
                  '目前沒有待辦事項，點擊右下角 + 新增第一筆吧！',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.loadTodos,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final todo = items[index];
              return Dismissible(
                key: ValueKey(todo.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.red.shade600,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.delete_outline, color: Colors.white),
                ),
                onDismissed: (_) => controller.removeTodo(todo.id),
                child: Card(
                  elevation: 1.5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    onTap: () => _openBottomSheet(todo: todo),
                    title: Text(
                      todo.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        decoration: todo.state == TodoState.done
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          // Due Date 顯示
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.event_rounded,
                                size: 15,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                todo.dueDate,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                          // Category 標籤
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _categoryColor(todo.category)
                                  .withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              todo.category,
                              style: TextStyle(
                                fontSize: 12,
                                color: _categoryColor(todo.category),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          // State 標籤（點擊可快速循環切換狀態）
                          InkWell(
                            onTap: () => controller.cycleTodoState(todo),
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _stateColor(todo.state),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                todo.state,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline_rounded),
                      onPressed: () => controller.removeTodo(todo.id),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        onPressed: () => _openBottomSheet(),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}
