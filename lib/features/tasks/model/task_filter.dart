import '../model/task.dart';

enum TaskFilter {
  all('All Tasks'),
  completed('Completed'),
  incomplete('Incomplete');

  const TaskFilter(this.displayName);
  final String displayName;
}

class TaskFilterCriteria {
  final TaskFilter statusFilter;
  final Set<TaskPriority> priorityFilters;
  final Set<TaskCategory> categoryFilters;

  const TaskFilterCriteria({
    this.statusFilter = TaskFilter.all,
    this.priorityFilters = const {},
    this.categoryFilters = const {},
  });

  TaskFilterCriteria copyWith({
    TaskFilter? statusFilter,
    Set<TaskPriority>? priorityFilters,
    Set<TaskCategory>? categoryFilters,
  }) {
    return TaskFilterCriteria(
      statusFilter: statusFilter ?? this.statusFilter,
      priorityFilters: priorityFilters ?? this.priorityFilters,
      categoryFilters: categoryFilters ?? this.categoryFilters,
    );
  }

  bool get hasActiveFilters {
    return statusFilter != TaskFilter.all ||
           priorityFilters.isNotEmpty ||
           categoryFilters.isNotEmpty;
  }

  bool matchesTask(Task task) {
    // Check status filter
    switch (statusFilter) {
      case TaskFilter.completed:
        if (!task.isCompleted) return false;
        break;
      case TaskFilter.incomplete:
        if (task.isCompleted) return false;
        break;
      case TaskFilter.all:
        break;
    }

    // Check priority filter
    if (priorityFilters.isNotEmpty && !priorityFilters.contains(task.priority)) {
      return false;
    }

    // Check category filter
    if (categoryFilters.isNotEmpty && !categoryFilters.contains(task.category)) {
      return false;
    }

    return true;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TaskFilterCriteria &&
           other.statusFilter == statusFilter &&
           other.priorityFilters.length == priorityFilters.length &&
           other.priorityFilters.every(priorityFilters.contains) &&
           other.categoryFilters.length == categoryFilters.length &&
           other.categoryFilters.every(categoryFilters.contains);
  }

  @override
  int get hashCode {
    return Object.hash(
      statusFilter,
      Object.hashAll(priorityFilters.toList()..sort((a, b) => a.name.compareTo(b.name))),
      Object.hashAll(categoryFilters.toList()..sort((a, b) => a.name.compareTo(b.name))),
    );
  }

  @override
  String toString() {
    return 'TaskFilterCriteria(status: ${statusFilter.displayName}, '
           'priorities: ${priorityFilters.map((p) => p.displayName).join(', ')}, '
           'categories: ${categoryFilters.map((c) => c.displayName).join(', ')})';
  }
}
