import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/entities/todo_entity.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/todo_controller.dart';
import '../widgets/todo_bottom_sheet.dart';
import '../widgets/todo_card_widget.dart';

/// MVC View：待辦事項列表主畫面
class TodoListView extends GetView<TodoController> {
  const TodoListView({super.key});

  void _openBottomSheet({TodoEntity? todo}) {
    Get.bottomSheet(
      TodoBottomSheet(existingTodo: todo),
      isScrollControlled: true,
    );
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
              return TodoCardWidget(
                todo: todo,
                onTap: () => _openBottomSheet(todo: todo),
                onCycleState: () => controller.cycleTodoState(todo),
                onDelete: () => controller.removeTodo(todo.id),
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
