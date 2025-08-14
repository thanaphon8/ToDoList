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

      final aScheduled = a.fullScheduledDateTime;
      final bScheduled = b.fullScheduledDateTime;

      if (!a.isCompleted && !b.isCompleted) {
        final aDiff = aScheduled.difference(now).abs();
        final bDiff = bScheduled.difference(now).abs();
        return aDiff.compareTo(bDiff);
      }
      return aScheduled.compareTo(bScheduled);
    });
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
