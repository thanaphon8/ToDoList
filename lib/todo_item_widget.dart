import 'package:flutter/material.dart';
import 'todo_model.dart';

class TodoItemWidget extends StatelessWidget {
  final TodoItem todo;
  final VoidCallback onTap;
  final VoidCallback onDismissed;

  const TodoItemWidget({
    Key? key,
    required this.todo,
    required this.onTap,
    required this.onDismissed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final scheduledTime = todo.fullScheduledDateTime;

    // คำนวณสถานะต่างๆ
    final isOverdue = scheduledTime.isBefore(now) && !todo.isCompleted;
    final isApproaching =
        !todo.isCompleted &&
        scheduledTime.isAfter(now) &&
        scheduledTime.difference(now).inMinutes <= 30; // ใกล้ถึงเวลา 30 นาที

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Dismissible(
        key: Key(todo.id.toString()),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.delete, color: Colors.white, size: 30),
        ),
        onDismissed: (direction) => onDismissed(),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
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
                    : isApproaching
                    ? Colors.red.withOpacity(0.15)
                    : Colors.blue.withOpacity(0.15),
              ),
              child: Icon(
                todo.isCompleted
                    ? Icons.check_circle
                    : isOverdue
                    ? Icons.schedule_outlined
                    : isApproaching
                    ? Icons.alarm
                    : Icons.schedule,
                color: todo.isCompleted
                    ? Colors.green
                    : isOverdue || isApproaching
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
                    ? (isDark ? const Color(0xFF606060) : Colors.grey)
                    : (isOverdue || isApproaching)
                    ? Colors.red.shade400
                    : (isDark ? const Color(0xFFE0E0E0) : Colors.black87),
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
                      color: todo.isCompleted
                          ? (isDark ? const Color(0xFF606060) : Colors.grey)
                          : (isDark ? const Color(0xFFB0B0B0) : Colors.black54),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: (isOverdue || isApproaching)
                          ? Colors.red.shade400
                          : (isDark ? const Color(0xFF909090) : Colors.grey),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      todo.scheduledTime.format(context),
                      style: TextStyle(
                        fontSize: 13,
                        color: (isOverdue || isApproaching)
                            ? Colors.red.shade400
                            : (isDark
                                  ? const Color(0xFF909090)
                                  : Colors.grey[600]),
                        fontWeight: (isOverdue || isApproaching)
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // แสดง tags ต่างๆ
                    if (isOverdue) ...[
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
                          'โดยด่วน',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ] else if (isApproaching) ...[
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
                          'เตรียมพร้อม',
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
      ),
    );
  }
}
