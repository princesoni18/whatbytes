import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:whatbytes_assignment/core/logger.dart';
import '../model/task.dart';
import '../model/task_filter.dart';
import '../repo/task_service.dart';

// Events
abstract class TaskEvent extends Equatable {
  const TaskEvent();
  @override
  List<Object> get props => [];
}

class LoadTasks extends TaskEvent {}

class CreateTask extends TaskEvent {
  final Task task;
  const CreateTask(this.task);
  @override
  List<Object> get props => [task];
}

class UpdateTask extends TaskEvent {
  final Task task;
  const UpdateTask(this.task);
  @override
  List<Object> get props => [task];
}

class ToggleTask extends TaskEvent {
  final String taskId;
  const ToggleTask(this.taskId);
  @override
  List<Object> get props => [taskId];
}

class DeleteTask extends TaskEvent {
  final String taskId;
  const DeleteTask(this.taskId);
  @override
  List<Object> get props => [taskId];
}

class FilterTasks extends TaskEvent {
  final TaskFilterCriteria filterCriteria;
  const FilterTasks(this.filterCriteria);
  @override
  List<Object> get props => [filterCriteria];
}

class ClearFilters extends TaskEvent {}

// States
abstract class TaskState extends Equatable {
  const TaskState();
  @override
  List<Object> get props => [];
}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TasksLoaded extends TaskState {
  final List<Task> tasks;
  final TaskFilterCriteria filterCriteria;

  const TasksLoaded({
    required this.tasks,
    required this.filterCriteria,
  });

  @override
  List<Object> get props => [tasks, filterCriteria];
}

class TaskError extends TaskState {
  final String message;

  const TaskError(this.message);

  @override
  List<Object> get props => [message];
}

// BLoC
class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskService _taskService;
  List<Task> _localTasks = [];
  TaskFilterCriteria _currentFilter = const TaskFilterCriteria();

  TaskBloc(this._taskService) : super(TaskInitial()) {
    on<LoadTasks>(_onLoadTasks);
    on<CreateTask>(_onCreateTask);
    on<UpdateTask>(_onUpdateTask);
    on<ToggleTask>(_onToggleTask);
    on<DeleteTask>(_onDeleteTask);
    on<FilterTasks>(_onFilterTasks);
    on<ClearFilters>(_onClearFilters);
  }

  Future<void> _onLoadTasks(LoadTasks event, Emitter<TaskState> emit) async {
    try {
      AppLogger.info('TaskBloc: Loading tasks');
      emit(TaskLoading());
      
      final tasks = await _taskService.getAllTasks();
      _localTasks = List.from(tasks);

      AppLogger.info('TaskBloc: Loaded ${tasks.length} tasks');
      emit(_buildTasksLoadedState());
    } catch (e) {
      AppLogger.error('TaskBloc: Failed to load tasks - $e');
      emit(TaskError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onCreateTask(CreateTask event, Emitter<TaskState> emit) async {
    try {
      AppLogger.info('TaskBloc: Creating task ${event.task.title}');

      // Optimistically add to local list
      _localTasks.insert(0, event.task);
      emit(_buildTasksLoadedState());
      
      // Sync to Firebase
      final createdTask = await _taskService.createTask(event.task);
      
      // Update local list with the created task (with proper ID)
      _localTasks[0] = createdTask;
      emit(_buildTasksLoadedState());

      AppLogger.info('TaskBloc: Task created successfully');
    } catch (e) {
      AppLogger.error('TaskBloc: Failed to create task - $e');
      // Remove from local list on error
      _localTasks.removeWhere((task) => task.title == event.task.title && task.id == event.task.id);
      emit(TaskError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onUpdateTask(UpdateTask event, Emitter<TaskState> emit) async {
    try {
      AppLogger.info('TaskBloc: Updating task ${event.task.title}');

      // Find and update in local list
      final taskIndex = _localTasks.indexWhere((task) => task.id == event.task.id);
      if (taskIndex == -1) {
        AppLogger.error('TaskBloc: Task not found in local list');
        emit(const TaskError('Task not found'));
        return;
      }
      
      // Optimistically update local list
      _localTasks[taskIndex] = event.task;
      emit(_buildTasksLoadedState());
      
      // Sync to Firebase
      await _taskService.updateTask(event.task);

      AppLogger.info('TaskBloc: Task updated successfully');
    } catch (e) {
      AppLogger.error('TaskBloc: Failed to update task - $e');
      // Revert local change on error
      final taskIndex = _localTasks.indexWhere((task) => task.id == event.task.id);
      if (taskIndex != -1) {
        // We would need to store the old task to revert, for now just reload
        add(LoadTasks());
      }
      emit(TaskError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onToggleTask(ToggleTask event, Emitter<TaskState> emit) async {
    try {
      AppLogger.info('TaskBloc: Toggling task ${event.taskId}');

      // Find the task in local list
      final taskIndex = _localTasks.indexWhere((task) => task.id == event.taskId);
      if (taskIndex == -1) {
        AppLogger.error('TaskBloc: Task not found in local list');
        return;
      }
      
      final task = _localTasks[taskIndex];
      final newStatus = !task.isCompleted;
      
      // Optimistically update local list
      _localTasks[taskIndex] = task.copyWith(
        isCompleted: newStatus,
        completedAt: newStatus ? DateTime.now() : null,
      );
      emit(_buildTasksLoadedState());
      
      // Sync to Firebase
      await _taskService.toggleTaskCompletionSync(event.taskId, newStatus);

      AppLogger.info('TaskBloc: Task toggled successfully');
    } catch (e) {
      AppLogger.error('TaskBloc: Failed to toggle task - $e');
      // Revert local change on error
      final taskIndex = _localTasks.indexWhere((task) => task.id == event.taskId);
      if (taskIndex != -1) {
        final task = _localTasks[taskIndex];
        _localTasks[taskIndex] = task.copyWith(
          isCompleted: !task.isCompleted,
          completedAt: task.isCompleted ? null : DateTime.now(),
        );
        emit(_buildTasksLoadedState());
      }
      emit(TaskError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onDeleteTask(DeleteTask event, Emitter<TaskState> emit) async {
    Task? removedTask;
    try {
      AppLogger.info('TaskBloc: Deleting task ${event.taskId}');

      // Find and remove from local list
      final taskIndex = _localTasks.indexWhere((task) => task.id == event.taskId);
      if (taskIndex == -1) {
        AppLogger.error('TaskBloc: Task not found in local list');
        return;
      }
      
      removedTask = _localTasks.removeAt(taskIndex);
      emit(_buildTasksLoadedState());
      
      // Sync to Firebase
      await _taskService.deleteTask(event.taskId);

      AppLogger.info('TaskBloc: Task deleted successfully');
    } catch (e) {
      AppLogger.error('TaskBloc: Failed to delete task - $e');
      // Restore task on error
      if (removedTask != null) {
        _localTasks.insert(0, removedTask);
        emit(_buildTasksLoadedState());
      }
      emit(TaskError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onFilterTasks(FilterTasks event, Emitter<TaskState> emit) async {
    AppLogger.info('TaskBloc: Applying filter - ${event.filterCriteria}');
    _currentFilter = event.filterCriteria;
    emit(_buildTasksLoadedState());
  }

  Future<void> _onClearFilters(ClearFilters event, Emitter<TaskState> emit) async {
    AppLogger.info('TaskBloc: Clearing filters');
    _currentFilter = const TaskFilterCriteria();
    emit(_buildTasksLoadedState());
  }

  TasksLoaded _buildTasksLoadedState() {
    // Apply filters to the task list
    final filteredTasks = _localTasks.where((task) => _currentFilter.matchesTask(task)).toList();

    // Sort tasks by due date (earliest to latest)
    filteredTasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));

    return TasksLoaded(
      tasks: filteredTasks,
      filterCriteria: _currentFilter,
    );
  }
}
