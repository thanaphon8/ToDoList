// add_todo_dialog.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'todo_model.dart';
import 'todo_manager.dart';
import 'notification_controller.dart';

class AddTodoDialog extends StatefulWidget {
  final DateTime selectedDate;
  final TodoItem? existingTodo; // เพิ่ม parameter สำหรับ Todo ที่มีอยู่แล้ว

  const AddTodoDialog({
    Key? key,
    required this.selectedDate,
    this.existingTodo, // ทำให้เป็น optional
  }) : super(key: key);

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
    if (widget.existingTodo != null) {
      _titleController.text = widget.existingTodo!.title;
      _descriptionController.text = widget.existingTodo!.description;
      _selectedScheduleDate = widget.existingTodo!.scheduledDate;
      _selectedTime = widget.existingTodo!.scheduledTime;
    } else {
      _selectedScheduleDate = widget.selectedDate;
      _selectedTime = TimeOfDay.now();
    }
  }

  void _saveTodo() {
    if (_titleController.text.trim().isEmpty) {
      NotificationController.showError(
        context: context,
        message: 'Please enter a task title',
      );
      return;
    }

    if (widget.existingTodo != null) {
      // โหมดแก้ไข: อัปเดตรายการเดิม
      final updatedTodo = widget.existingTodo!.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        scheduledDate: _selectedScheduleDate,
        scheduledTime: _selectedTime,
      );
      _todoManager.updateTodo(updatedTodo);
      NotificationController.showSuccess(
        context: context,
        message: 'Task updated successfully',
      );
    } else {
      // โหมดเพิ่มใหม่: เพิ่มรายการใหม่
      final newTodo = TodoItem(
        id: 0,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        scheduledDate: _selectedScheduleDate,
        scheduledTime: _selectedTime,
        createdAt: DateTime.now(),
      );
      _todoManager.addTodo(newTodo);
      NotificationController.showSuccess(
        context: context,
        message: 'Task added successfully',
      );
    }

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        widget.existingTodo != null ? 'Edit Task' : 'Add New Task',
        style: TextStyle(
          color: isDark ? const Color(0xFFE0E0E0) : null,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              style: TextStyle(color: isDark ? const Color(0xFFE0E0E0) : null),
              decoration: InputDecoration(
                labelText: 'Title *',
                labelStyle: TextStyle(
                  color: isDark ? const Color(0xFF909090) : null,
                ),
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: isDark ? const Color(0xFF404040) : Colors.grey[400]!,
                  ),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
                prefixIcon: Icon(
                  Icons.task,
                  color: isDark ? const Color(0xFF909090) : null,
                ),
              ),
              maxLength: 50,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              style: TextStyle(color: isDark ? const Color(0xFFE0E0E0) : null),
              decoration: InputDecoration(
                labelText: 'Description',
                labelStyle: TextStyle(
                  color: isDark ? const Color(0xFF909090) : null,
                ),
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: isDark ? const Color(0xFF404040) : Colors.grey[400]!,
                  ),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
                prefixIcon: Icon(
                  Icons.description,
                  color: isDark ? const Color(0xFF909090) : null,
                ),
              ),
              maxLines: 3,
              maxLength: 200,
            ),
            const SizedBox(height: 16),
            Card(
              color: isDark ? const Color(0xFF2A2A2A) : null,
              elevation: isDark ? 0 : null,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: isDark
                    ? BorderSide(color: const Color(0xFF404040), width: 1)
                    : BorderSide.none,
              ),
              child: ListTile(
                leading: const Icon(Icons.calendar_today, color: Colors.blue),
                title: Text(
                  'Date',
                  style: TextStyle(
                    color: isDark ? const Color(0xFFE0E0E0) : null,
                  ),
                ),
                subtitle: Text(
                  DateFormat('dd/MM/yyyy').format(_selectedScheduleDate),
                  style: TextStyle(
                    color: isDark ? const Color(0xFFB0B0B0) : null,
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  color: isDark ? const Color(0xFF909090) : null,
                ),
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
              color: isDark ? const Color(0xFF2A2A2A) : null,
              elevation: isDark ? 0 : null,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: isDark
                    ? BorderSide(color: const Color(0xFF404040), width: 1)
                    : BorderSide.none,
              ),
              child: ListTile(
                leading: const Icon(Icons.access_time, color: Colors.orange),
                title: Text(
                  'Time',
                  style: TextStyle(
                    color: isDark ? const Color(0xFFE0E0E0) : null,
                  ),
                ),
                subtitle: Text(
                  _selectedTime.format(context),
                  style: TextStyle(
                    color: isDark ? const Color(0xFFB0B0B0) : null,
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  color: isDark ? const Color(0xFF909090) : null,
                ),
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
          child: Text(
            'Cancel',
            style: TextStyle(color: isDark ? const Color(0xFFB0B0B0) : null),
          ),
        ),
        ElevatedButton.icon(
          onPressed: _saveTodo, // เรียกใช้ method ที่แก้ไขแล้ว
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2196F3),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          icon: Icon(widget.existingTodo != null ? Icons.save : Icons.add),
          label: Text(widget.existingTodo != null ? 'Save' : 'Add'),
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
