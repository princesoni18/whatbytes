import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:whatbytes_assignment/core/logger.dart';
import '../model/task.dart';

class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference get _tasksCollection {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      // For development/testing - use a default collection
      return _firestore.collection('public_tasks');
    }
    return _firestore.collection('users').doc(userId).collection('tasks');
  }

  // Create Task
  Future<Task> createTask(Task task) async {
    try {
  AppLogger.info('TaskService: Creating task ${task.title}');
      final docRef = await _tasksCollection.add(_taskToFirestore(task));
      final doc = await docRef.get();
      return _taskFromFirestore(doc);
    } catch (e) {
  AppLogger.error('TaskService: Failed to create task', e);
      throw Exception('Failed to create task: $e');
    }
  }

  // Get All Tasks (one-time fetch)
  Future<List<Task>> getAllTasks() async {
    try {
  AppLogger.info('TaskService: Fetching all tasks');
      final snapshot = await _tasksCollection
          .orderBy('createdAt', descending: true)
          .get();
      
      final tasks = snapshot.docs.map((doc) => _taskFromFirestore(doc)).toList();
  AppLogger.info('TaskService: Fetched ${tasks.length} tasks');
      return tasks;
    } catch (e) {
  AppLogger.error('TaskService: Failed to fetch tasks', e);
      throw Exception('Failed to fetch tasks: $e');
    }
  }

  // Watch Tasks Stream (keeping for backward compatibility if needed)
  Stream<List<Task>> watchTasks() {
    try {
  AppLogger.info('TaskService: Starting to watch tasks');
      return _tasksCollection
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
  AppLogger.debug('TaskService: Received ${snapshot.docs.length} tasks from Firestore');
        return snapshot.docs.map((doc) => _taskFromFirestore(doc)).toList();
      });
    } catch (e) {
  AppLogger.error('TaskService: Error watching tasks', e);
      throw Exception('Failed to watch tasks: $e');
    }
  }

  // Toggle Task Completion (no return, just update)
  Future<void> toggleTaskCompletionSync(String taskId, bool newStatus) async {
    try {
  AppLogger.info('TaskService: Syncing task $taskId completion to $newStatus');
      
      final updateData = {
        'isCompleted': newStatus,
        'completedAt': newStatus ? Timestamp.now() : null,
      };
      
      await _tasksCollection.doc(taskId).update(updateData);
  AppLogger.info('TaskService: Task $taskId synced successfully');
    } catch (e) {
  AppLogger.error('TaskService: Failed to sync task toggle', e);
      throw Exception('Failed to sync task: $e');
    }
  }

  // Toggle Task Completion
  Future<Task> toggleTaskCompletion(String taskId, bool currentStatus) async {
    try {
      final newStatus = !currentStatus;
  AppLogger.info('TaskService: Toggling task $taskId from $currentStatus to $newStatus');
      
      final updateData = {
        'isCompleted': newStatus,
        'completedAt': newStatus ? Timestamp.now() : null,
      };
      
      await _tasksCollection.doc(taskId).update(updateData);
      final doc = await _tasksCollection.doc(taskId).get();
      
  AppLogger.info('TaskService: Task $taskId toggled successfully');
      return _taskFromFirestore(doc);
    } catch (e) {
  AppLogger.error('TaskService: Failed to toggle task', e);
      throw Exception('Failed to toggle task: $e');
    }
  }

  // Delete Task
  Future<void> deleteTask(String taskId) async {
    try {
  AppLogger.info('TaskService: Deleting task $taskId');
      await _tasksCollection.doc(taskId).delete();
  AppLogger.info('TaskService: Task $taskId deleted successfully');
    } catch (e) {
  AppLogger.error('TaskService: Failed to delete task', e);
      throw Exception('Failed to delete task: $e');
    }
  }

  // Update Task
  Future<Task> updateTask(Task task) async {
    try {
  AppLogger.info('TaskService: Updating task ${task.id}');
      await _tasksCollection.doc(task.id).update(_taskToFirestore(task));
      final doc = await _tasksCollection.doc(task.id).get();
  AppLogger.info('TaskService: Task ${task.id} updated successfully');
      return _taskFromFirestore(doc);
    } catch (e) {
  AppLogger.error('TaskService: Failed to update task', e);
      throw Exception('Failed to update task: $e');
    }
  }

  // Convert Task to Firestore format
  Map<String, dynamic> _taskToFirestore(Task task) {
    return {
      'title': task.title,
      'description': task.description,
      'dueDate': Timestamp.fromDate(task.dueDate),
      'category': task.category.name,
      'priority': task.priority.name,
      'isCompleted': task.isCompleted,
      'createdAt': Timestamp.fromDate(task.createdAt),
      'completedAt': task.completedAt != null ? Timestamp.fromDate(task.completedAt!) : null,
    };
  }

  // Convert Firestore document to Task
  Task _taskFromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Task(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'],
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      category: TaskCategory.values.firstWhere(
        (e) => e.name == data['category'],
        orElse: () => TaskCategory.personal,
      ),
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == data['priority'],
        orElse: () => TaskPriority.medium,
      ),
      isCompleted: data['isCompleted'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      completedAt: data['completedAt'] != null 
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
    );
  }
}
