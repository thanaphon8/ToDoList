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
      createdAt: todo.createdAt,
      isCompleted: todo.isCompleted,
    );
    _todos.add(newTodo);
  }

  List<TodoItem> getTodosByDate(DateTime date) {
    final now = DateTime.now();
    return _todos.where((todo) => todo.isSameDate(date)).toList()..sort((a, b) {
      // ถ้า a เสร็จแล้วแต่ b ยังไม่เสร็จ ให้ a ไปล่าง (return 1)
      if (a.isCompleted && !b.isCompleted) return 1;
      // ถ้า b เสร็จแล้วแต่ a ยังไม่เสร็จ ให้ b ไปล่าง (return -1)
      if (b.isCompleted && !a.isCompleted) return -1;

      // ถ้าทั้งคู่เสร็จแล้วหรือทั้งคู่ยังไม่เสร็จ เรียงตามเวลา
      final aScheduled = a.fullScheduledDateTime;
      final bScheduled = b.fullScheduledDateTime;

      // สำหรับรายการที่ยังไม่เสร็จ ให้ priority กับรายการที่ใกล้เวลาที่กำหนดมากที่สุด
      if (!a.isCompleted && !b.isCompleted) {
        final aDiff = aScheduled.difference(now).abs();
        final bDiff = bScheduled.difference(now).abs();
        return aDiff.compareTo(bDiff);
      }

      // สำหรับรายการที่เสร็จแล้ว เรียงตามเวลาปกติ
      return aScheduled.compareTo(bScheduled);
    });
  }

  void updateTodoStatus(int id, bool isCompleted) {
    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index != -1) {
      _todos[index].isCompleted = isCompleted;
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
