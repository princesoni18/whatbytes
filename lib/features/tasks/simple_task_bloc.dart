import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'domain/entities/task.dart';
import 'task_service.dart';

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
  final List<Task> todayTasks;
  final List<Task> tomorrowTasks;
  final List<Task> thisWeekTasks;

  const TasksLoaded({
    required this.tasks,
    required this.todayTasks,
    required this.tomorrowTasks,
    required this.thisWeekTasks,
  });

  @override
  List<Object> get props => [tasks, todayTasks, tomorrowTasks, thisWeekTasks];
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

  TaskBloc(this._taskService) : super(TaskInitial()) {
    on<LoadTasks>(_onLoadTasks);
    on<CreateTask>(_onCreateTask);
    on<ToggleTask>(_onToggleTask);
    on<DeleteTask>(_onDeleteTask);
  }

  Future<void> _onLoadTasks(LoadTasks event, Emitter<TaskState> emit) async {
    try {
      print('TaskBloc: Loading tasks');
      emit(TaskLoading());
      
      final tasks = await _taskService.getAllTasks();
      _localTasks = List.from(tasks);
      
      print('TaskBloc: Loaded ${tasks.length} tasks');
      emit(_buildTasksLoadedState());
    } catch (e) {
      print('TaskBloc: Failed to load tasks - $e');
      emit(TaskError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onCreateTask(CreateTask event, Emitter<TaskState> emit) async {
    try {
      print('TaskBloc: Creating task ${event.task.title}');
      
      // Optimistically add to local list
      _localTasks.insert(0, event.task);
      emit(_buildTasksLoadedState());
      
      // Sync to Firebase
      final createdTask = await _taskService.createTask(event.task);
      
      // Update local list with the created task (with proper ID)
      _localTasks[0] = createdTask;
      emit(_buildTasksLoadedState());
      
      print('TaskBloc: Task created successfully');
    } catch (e) {
      print('TaskBloc: Failed to create task - $e');
      // Remove from local list on error
      _localTasks.removeWhere((task) => task.title == event.task.title && task.id == event.task.id);
      emit(TaskError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onToggleTask(ToggleTask event, Emitter<TaskState> emit) async {
    try {
      print('TaskBloc: Toggling task ${event.taskId}');
      
      // Find the task in local list
      final taskIndex = _localTasks.indexWhere((task) => task.id == event.taskId);
      if (taskIndex == -1) {
        print('TaskBloc: Task not found in local list');
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
      
      print('TaskBloc: Task toggled successfully');
      // Emit state again after successful sync to ensure UI is updated
      emit(_buildTasksLoadedState());
    } catch (e) {
      print('TaskBloc: Failed to toggle task - $e');
      // Revert local change on error
      final taskIndex = _localTasks.indexWhere((task) => task.id == event.taskId);
      if (taskIndex != -1) {
        final task = _localTasks[taskIndex];
        _localTasks[taskIndex] = task.copyWith(
          isCompleted: !task.isCompleted,
          completedAt: task.isCompleted ? null : DateTime.now(),
        );
      }
      emit(_buildTasksLoadedState());
      emit(TaskError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onDeleteTask(DeleteTask event, Emitter<TaskState> emit) async {
    Task? removedTask;
    try {
      print('TaskBloc: Deleting task ${event.taskId}');
      
      // Find and remove from local list
      final taskIndex = _localTasks.indexWhere((task) => task.id == event.taskId);
      if (taskIndex == -1) {
        print('TaskBloc: Task not found in local list');
        return;
      }
      
      removedTask = _localTasks.removeAt(taskIndex);
      emit(_buildTasksLoadedState());
      
      // Sync to Firebase
      await _taskService.deleteTask(event.taskId);
      
      print('TaskBloc: Task deleted successfully');
      // Emit state again after successful sync to ensure UI is updated
      emit(_buildTasksLoadedState());
    } catch (e) {
      print('TaskBloc: Failed to delete task - $e');
      // Restore task on error
      if (removedTask != null) {
        _localTasks.insert(0, removedTask);
      }
      emit(_buildTasksLoadedState());
      emit(TaskError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  TasksLoaded _buildTasksLoadedState() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final nextWeek = today.add(const Duration(days: 7));

    final todayTasks = _localTasks.where((task) {
      final taskDate = DateTime(task.dueDate.year, task.dueDate.month, task.dueDate.day);
      return taskDate.isAtSameMomentAs(today);
    }).toList();

    final tomorrowTasks = _localTasks.where((task) {
      final taskDate = DateTime(task.dueDate.year, task.dueDate.month, task.dueDate.day);
      return taskDate.isAtSameMomentAs(tomorrow);
    }).toList();

    final thisWeekTasks = _localTasks.where((task) {
      final taskDate = DateTime(task.dueDate.year, task.dueDate.month, task.dueDate.day);
      return taskDate.isAfter(tomorrow) && taskDate.isBefore(nextWeek);
    }).toList();

    return TasksLoaded(
      tasks: _localTasks,
      todayTasks: todayTasks,
      tomorrowTasks: tomorrowTasks,
      thisWeekTasks: thisWeekTasks,
    );
  }
}
