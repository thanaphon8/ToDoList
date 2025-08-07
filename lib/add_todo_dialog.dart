import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'todo_model.dart';
import 'todo_manager.dart';
import 'notification_controller.dart';

class AddTodoDialog extends StatefulWidget {
  final DateTime selectedDate;

  const AddTodoDialog({Key? key, required this.selectedDate}) : super(key: key);

  @override
  State<AddTodoDialog> createState() => _AddTodoDialogState();
}

class _AddTodoDialogState extends State<AddTodoDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TodoManager _todoManager = TodoManager();

  late DateTime _selectedScheduleDate;
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    _selectedScheduleDate = widget.selectedDate;
    _selectedTime = TimeOfDay.now();
  }

  void _addTodo() {
    if (_titleController.text.trim().isEmpty) {
      NotificationController.showError(
        context: context,
        message: 'Please enter a task title',
      );
      return;
    }

    final newTodo = TodoItem(
      id: 0,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      scheduledDate: _selectedScheduleDate,
      scheduledTime: _selectedTime,
      createdAt: DateTime.now(),
    );

    _todoManager.addTodo(newTodo);
    Navigator.pop(context, true); // Return true to indicate success
    NotificationController.showSuccess(
      context: context,
      message: 'Task added successfully',
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Task'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.task),
              ),
              maxLength: 50,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
              maxLength: 200,
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today, color: Colors.blue),
                title: const Text('Date'),
                subtitle: Text(
                  DateFormat('dd/MM/yyyy').format(_selectedScheduleDate),
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedScheduleDate,
                    firstDate: DateTime.now().subtract(
                      const Duration(days: 365),
                    ),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() {
                      _selectedScheduleDate = date;
                    });
                  }
                },
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.access_time, color: Colors.orange),
                title: const Text('Time'),
                subtitle: Text(_selectedTime.format(context)),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: _selectedTime,
                  );
                  if (time != null) {
                    setState(() {
                      _selectedTime = time;
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: _addTodo,
          icon: const Icon(Icons.add),
          label: const Text('Add'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
