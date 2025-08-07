import 'package:flutter/material.dart';

class TodoItem {
  final int id;
  final String title;
  final String description;
  final DateTime scheduledDate;
  final TimeOfDay scheduledTime;
  final DateTime createdAt;
  bool isCompleted;

  TodoItem({
    required this.id,
    required this.title,
    required this.description,
    required this.scheduledDate,
    required this.scheduledTime,
    required this.createdAt,
    this.isCompleted = false,
  });

  DateTime get fullScheduledDateTime {
    return DateTime(
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
      scheduledTime.hour,
      scheduledTime.minute,
    );
  }

  bool isSameDate(DateTime date) {
    return scheduledDate.year == date.year &&
        scheduledDate.month == date.month &&
        scheduledDate.day == date.day;
  }
}
