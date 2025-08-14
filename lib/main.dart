import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'todo_model.dart';
import 'todo_manager.dart';
import 'todo_item_widget.dart';
import 'add_todo_dialog.dart';

import 'notification_controller.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'auth_controller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AuthController authController = Get.put(AuthController());
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark
          ? ThemeMode.light
          : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Calendar Todo App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.grey[100],
        cardColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2196F3),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        cardColor: const Color(0xFF1E1E1E),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A1A1A),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF2196F3),
          foregroundColor: Colors.white,
        ),
      ),
      themeMode: _themeMode,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const LoginScreen()),
        GetPage(name: '/login', page: () => const LoginScreen()),
        GetPage(name: '/register', page: () => const RegisterScreen()),
        GetPage(
          name: '/home',
          page: () => HomePage(onToggleTheme: _toggleTheme),
        ),
      ],
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

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  void _loadTodos() {
    setState(() {
      _todos = _todoManager.getTodosByDate(_selectedDate);
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
      message: 'Task deleted successfully!',
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

  Future<void> _showEditTodoDialog(TodoItem todo) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AddTodoDialog(
          selectedDate: _selectedDate,
          existingTodo: todo, // ส่ง TodoItem ที่ต้องการแก้ไขเข้าไป
        );
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
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              final AuthController authController = Get.find();
              authController.logout();
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Column(
        children: [
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
                        return Dismissible(
                          key: ValueKey(todo.id),
                          direction: DismissDirection.horizontal,
                          background: Container(
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            color: Colors.blue,
                            child: const Icon(Icons.edit, color: Colors.white),
                          ),
                          secondaryBackground: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            color: Colors.red,
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          confirmDismiss: (direction) async {
                            if (direction == DismissDirection.endToStart) {
                              // ปัดไปทางซ้ายเพื่อลบ
                              return await showDialog<bool>(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('Delete Task'),
                                    content: Text(
                                      'Are you sure you want to delete "${todo.title}"?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(false),
                                        child: const Text('Cancel'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(true),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                        ),
                                        child: const Text(
                                          'Delete',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            } else if (direction ==
                                DismissDirection.startToEnd) {
                              // ปัดไปทางขวาเพื่อแก้ไข
                              _showEditTodoDialog(todo);
                              return false; // ไม่ให้ Dismiss
                            }
                            return null;
                          },
                          onDismissed: (direction) {
                            if (direction == DismissDirection.endToStart) {
                              _deleteTodo(todo);
                            }
                          },
                          child: TodoItemWidget(
                            todo: todo,
                            onTap: () => _toggleTodoStatus(todo),
                          ),
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
