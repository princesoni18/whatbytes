import 'package:flutter/material.dart';

enum TaskCategory {
  personal('Personal', Color(0xFF10B981)),
  work('Work', Color(0xFF3B82F6)),
  app('App', Color(0xFF8B5CF6)),
  cf('CF', Color(0xFFF59E0B)),
  study('Study', Color(0xFFEF4444));

  const TaskCategory(this.displayName, this.color);
  final String displayName;
  final Color color;
}

enum TaskPriority {
  low('Low'),
  medium('Medium'),
  high('High');

  const TaskPriority(this.displayName);
  final String displayName;
}

enum TaskStatus {
  incomplete('Incomplete'),
  completed('Completed');

  const TaskStatus(this.displayName);
  final String displayName;
}

class Task {
  final String id;
  final String title;
  final String? description;
  final DateTime dueDate;
  final TaskCategory category;
  final TaskPriority priority;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? completedAt;

  const Task({
    required this.id,
    required this.title,
    this.description,
    required this.dueDate,
    required this.category,
    required this.priority,
    required this.isCompleted,
    required this.createdAt,
    this.completedAt,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    TaskCategory? category,
    TaskPriority? priority,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  // Helper method to determine if task is overdue
  bool get isOverdue {
    if (isCompleted) return false;
    return DateTime.now().isAfter(dueDate);
  }

  // Helper method to determine if task is due today
  bool get isDueToday {
    final now = DateTime.now();
    return dueDate.year == now.year &&
        dueDate.month == now.month &&
        dueDate.day == now.day;
  }

  // Helper method to determine if task is due tomorrow
  bool get isDueTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return dueDate.year == tomorrow.year &&
        dueDate.month == tomorrow.month &&
        dueDate.day == tomorrow.day;
  }

  // Helper method to determine if task is due this week
  bool get isDueThisWeek {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    return dueDate.isAfter(weekStart) && dueDate.isBefore(weekEnd);
  }

  // Status getter for easier access
  TaskStatus get status => isCompleted ? TaskStatus.completed : TaskStatus.incomplete;

  // Validation methods
  bool get isValid {
    return id.isNotEmpty && 
           title.trim().isNotEmpty && 
           createdAt.isBefore(DateTime.now().add(const Duration(minutes: 1)));
  }

  String? get validationError {
    if (id.isEmpty) return 'Task ID cannot be empty';
    if (title.trim().isEmpty) return 'Task title cannot be empty';
    if (createdAt.isAfter(DateTime.now().add(const Duration(minutes: 1)))) {
      return 'Created date cannot be in the future';
    }
    if (isCompleted && completedAt == null) {
      return 'Completed tasks must have a completion date';
    }
    return null;
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'category': category.name,
      'priority': priority.name,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  // JSON deserialization
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      dueDate: DateTime.parse(json['dueDate'] as String),
      category: TaskCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => TaskCategory.personal,
      ),
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => TaskPriority.medium,
      ),
      isCompleted: json['isCompleted'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }

  // Equality and hashCode
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Task && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Task(id: $id, title: $title, priority: ${priority.displayName}, '
           'status: ${status.displayName}, dueDate: $dueDate)';
  }
}
