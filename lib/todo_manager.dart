// todo_manager.dart

import 'todo_model.dart';

class TodoManager {
  static final TodoManager _instance = TodoManager._internal();
  factory TodoManager() => _instance;
  TodoManager._internal();

  final List<TodoItem> _todos = [];
  int _nextId = 1;

  void addTodo(TodoItem todo) {
    final newTodo = TodoItem(
      id: _nextId++,
      title: todo.title,
      description: todo.description,
      scheduledDate: todo.scheduledDate,
      scheduledTime: todo.scheduledTime,
      createdAt: DateTime.now(), // ใช้ DateTime.now() เพื่อให้ตรงกับโค้ดเดิม
      isCompleted: todo.isCompleted,
    );
    _todos.add(newTodo);
  }

  // เพิ่ม method สำหรับอัปเดต Todo
  void updateTodo(TodoItem updatedTodo) {
    final index = _todos.indexWhere((todo) => todo.id == updatedTodo.id);
    if (index != -1) {
      _todos[index] = updatedTodo;
    }
  }

  List<TodoItem> getTodosByDate(DateTime date) {
    final now = DateTime.now();
    return _todos.where((todo) => todo.isSameDate(date)).toList()..sort((a, b) {
        if (a.isCompleted && !b.isCompleted) return 1;
        if (b.isCompleted && !a.isCompleted) return -1;

<<<<<<< HEAD
      // สำหรับรายการที่ยังไม่เสร็จ
      if (!a.isCompleted && !b.isCompleted) {
        final aScheduled = a.fullScheduledDateTime;
        final bScheduled = b.fullScheduledDateTime;

        // คำนวณสถานะต่างๆ
        final aIsOverdue = aScheduled.isBefore(now);
        final bIsOverdue = bScheduled.isBefore(now);
        final aIsApproaching =
            !aIsOverdue &&
            aScheduled.isAfter(now) &&
            aScheduled.difference(now).inMinutes <= 30;
        final bIsApproaching =
            !bIsOverdue &&
            bScheduled.isAfter(now) &&
            bScheduled.difference(now).inMinutes <= 30;

        // Priority 1: รายการที่ใกล้ถึงเวลา (ต้องทำ) ขึ้นบนสุด
        if (aIsApproaching && !bIsApproaching) return -1;
        if (bIsApproaching && !aIsApproaching) return 1;

        // Priority 2: รายการที่เลยเวลาแล้ว
        if (aIsOverdue && !bIsOverdue) return -1;
        if (bIsOverdue && !aIsOverdue) return 1;

        // ถ้าเป็น category เดียวกัน เรียงตามเวลา
        if (aIsApproaching && bIsApproaching) {
          // ใกล้ถึงเวลา: ใครใกล้กว่าขึ้นก่อน
          final aDiff = aScheduled.difference(now).abs();
          final bDiff = bScheduled.difference(now).abs();
          return aDiff.compareTo(bDiff);
        } else if (aIsOverdue && bIsOverdue) {
          // เลยเวลา: ใครเลยเวลานานกว่าขึ้นก่อน
          return bScheduled.compareTo(aScheduled);
        } else {
          // รายการปกติ: เรียงตามเวลาปกติ
          return aScheduled.compareTo(bScheduled);
        }
      }

      // สำหรับรายการที่เสร็จแล้ว เรียงตามเวลาปกติ
      final aScheduled = a.fullScheduledDateTime;
      final bScheduled = b.fullScheduledDateTime;
      return aScheduled.compareTo(bScheduled);
    });
=======
        final aScheduled = a.fullScheduledDateTime;
        final bScheduled = b.fullScheduledDateTime;

        if (!a.isCompleted && !b.isCompleted) {
          final aDiff = aScheduled.difference(now).abs();
          final bDiff = bScheduled.difference(now).abs();
          return aDiff.compareTo(bDiff);
        }
        return aScheduled.compareTo(bScheduled);
      });
>>>>>>> pathiphat
  }

  void updateTodoStatus(int id, bool isCompleted) {
    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index != -1) {
      // สร้าง TodoItem ใหม่ด้วยค่า isCompleted ที่อัปเดต
      _todos[index] = _todos[index].copyWith(isCompleted: isCompleted);
    }
  }

  void deleteTodo(int id) {
    _todos.removeWhere((todo) => todo.id == id);
  }

  Map<String, int> getStatsByDate(DateTime date) {
    final todosForDate = getTodosByDate(date);
    final total = todosForDate.length;
    final completed = todosForDate.where((todo) => todo.isCompleted).length;

    return {
      'total': total,
      'completed': completed,
      'pending': total - completed,
    };
  }

  List<TodoItem> getAllTodos() {
    return List.from(_todos);
  }
}