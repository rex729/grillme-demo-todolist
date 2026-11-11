import 'package:flutter/material.dart';
import '../../../data/entities/todo_entity.dart';

/// 單一待辦事項卡片元件 (Widget)
class TodoCardWidget extends StatelessWidget {
  final TodoEntity todo;
  final VoidCallback onTap;
  final VoidCallback onCycleState;
  final VoidCallback onDelete;

  const TodoCardWidget({
    super.key,
    required this.todo,
    required this.onTap,
    required this.onCycleState,
    required this.onDelete,
  });

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
      onDismissed: (_) => onDelete(),
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
          onTap: onTap,
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
                    color: _categoryColor(todo.category).withValues(alpha: 0.12),
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
                  onTap: onCycleState,
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
            onPressed: onDelete,
          ),
        ),
      ),
    );
  }
}
