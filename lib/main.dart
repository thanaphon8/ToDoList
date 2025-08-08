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

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark
          ? ThemeMode.light
          : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calendar Todo App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.grey[100],
        cardColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: const Color(0xFF2196F3),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0A0A), // เกือบดำ แต่อ่านง่าย
        cardColor: const Color(0xFF1E1E1E), // สี card ที่อ่านง่าย
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A1A1A), // สีแถบบน สุขุม
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF2196F3), // น้ำเงินอ่อน
          foregroundColor: Colors.white,
        ),
      ),
      themeMode: _themeMode,
      home: HomePage(onToggleTheme: _toggleTheme),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const HomePage({Key? key, required this.onToggleTheme}) : super(key: key);

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF0A0A0A) : Colors.grey[200];
    final headerColor = isDark ? const Color(0xFF1A1A1A) : Colors.blue;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Todo Calendar'),
        backgroundColor: headerColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () => _selectDate(DateTime.now()),
            tooltip: 'Today',
          ),
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onToggleTheme,
            tooltip: 'Toggle Theme',
          ),
        ],
      ),
      body: Column(
        children: [
          // Date Selector Header
          Container(
            color: headerColor,
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
              color: backgroundColor,
              child: _todos.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_note,
                            size: 80,
                            color: isDark
                                ? const Color(0xFF404040)
                                : Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No tasks for today',
                            style: TextStyle(
                              fontSize: 18,
                              color: isDark
                                  ? const Color(0xFFB0B0B0)
                                  : Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap + to add a new task',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark
                                  ? const Color(0xFF808080)
                                  : Colors.grey[500],
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
