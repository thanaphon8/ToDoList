import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'todo_model.dart';
import 'todo_manager.dart';
import 'todo_item_widget.dart';
import 'add_todo_dialog.dart';
import 'stats_widget.dart';
import 'notification_controller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calendar Todo App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TodoManager _todoManager = TodoManager();
  List<TodoItem> _todos = [];
  DateTime _selectedDate = DateTime.now();
  Map<String, int> _stats = {'total': 0, 'completed': 0, 'pending': 0};

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  void _loadTodos() {
    setState(() {
      _todos = _todoManager.getTodosByDate(_selectedDate);
      _stats = _todoManager.getStatsByDate(_selectedDate);
    });
  }

  Future<void> _selectDate(DateTime? date) async {
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
      _loadTodos();
    }
  }

  void _toggleTodoStatus(TodoItem todo) {
    _todoManager.updateTodoStatus(todo.id, !todo.isCompleted);
    _loadTodos();
    NotificationController.showSuccess(
      context: context,
      message: todo.isCompleted
          ? 'Task marked as incomplete'
          : 'Task completed!',
    );
  }

  Future<void> _deleteTodo(TodoItem todo) async {
    _todoManager.deleteTodo(todo.id);
    _loadTodos();
    NotificationController.showSuccess(
      context: context,
      message: 'Task deleted successfully',
    );
  }

  Future<void> _showAddTodoDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AddTodoDialog(selectedDate: _selectedDate);
      },
    );

    if (result == true) {
      _loadTodos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Todo Calendar'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () => _selectDate(DateTime.now()),
            tooltip: 'Today',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTodos,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Date Selector Header
          Container(
            color: Colors.blue,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => _selectDate(
                      _selectedDate.subtract(const Duration(days: 1)),
                    ),
                    icon: const Icon(
                      Icons.chevron_left,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime.now().subtract(
                          const Duration(days: 365),
                        ),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      _selectDate(date);
                    },
                    child: Column(
                      children: [
                        Text(
                          _selectedDate.day.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          DateFormat('MMMM yyyy').format(_selectedDate),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          DateFormat('EEEE').format(_selectedDate),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () =>
                        _selectDate(_selectedDate.add(const Duration(days: 1))),
                    icon: const Icon(
                      Icons.chevron_right,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Stats Widget
          StatsWidget(stats: _stats),

          // Todo List
          Expanded(
            child: Container(
              color: Colors.grey[200],
              child: _todos.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_note,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No tasks for today',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap + to add a new task',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _todos.length,
                      itemBuilder: (context, index) {
                        final todo = _todos[index];
                        return TodoItemWidget(
                          todo: todo,
                          onTap: () => _toggleTodoStatus(todo),
                          onDismissed: () => _deleteTodo(todo),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTodoDialog,
        tooltip: 'Add new task',
        shape: const CircleBorder(),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
