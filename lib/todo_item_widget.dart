// todo_item_widget.dart

import 'package:flutter/material.dart';
import 'todo_model.dart';

class TodoItemWidget extends StatelessWidget {
  final TodoItem todo;
  final VoidCallback onTap;
  // ลบ final VoidCallback onDismissed; ออก

  const TodoItemWidget({
    Key? key,
    required this.todo,
    required this.onTap,
    // ลบ required this.onDismissed, ออก
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isOverdue = todo.fullScheduledDateTime.isBefore(now) && !todo.isCompleted;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Container( // เปลี่ยนจาก Dismissible เป็น Container
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          tileColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: todo.isCompleted
                  ? Colors.green.withOpacity(0.15)
                  : isOverdue
                      ? Colors.red.withOpacity(0.15)
                      : Colors.blue.withOpacity(0.15),
            ),
            child: Icon(
              todo.isCompleted
                  ? Icons.check_circle
                  : isOverdue
                      ? Icons.schedule_outlined
                      : Icons.schedule,
              color: todo.isCompleted
                  ? Colors.green
                  : isOverdue
                      ? Colors.red
                      : Colors.blue,
              size: 20,
            ),
          ),
          title: Text(
            todo.title,
            style: TextStyle(
              decoration: todo.isCompleted
                  ? TextDecoration.lineThrough
                  : null,
              color: todo.isCompleted
                  ? Colors.grey
                  : isOverdue
                      ? Colors.red.shade700
                      : Colors.black87,
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (todo.description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  todo.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: todo.isCompleted ? Colors.grey : Colors.black54,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: isOverdue ? Colors.red : Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    todo.scheduledTime.format(context),
                    style: TextStyle(
                      fontSize: 13,
                      color: isOverdue ? Colors.red : Colors.grey[600],
                      fontWeight: isOverdue ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  if (isOverdue) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'เลยเวลา',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}