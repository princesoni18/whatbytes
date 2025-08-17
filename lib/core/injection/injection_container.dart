import 'package:get_it/get_it.dart';
import 'package:whatbytes_assignment/features/tasks/bloc/simple_task_bloc.dart';
import '../../features/tasks/repo/task_service.dart';

import '../../features/auth/auth_service.dart';
import '../../features/auth/simple_auth_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Simple approach - just register the services and blocs
  sl.registerLazySingleton<AuthService>(() => AuthService());
  sl.registerLazySingleton<TaskService>(() => TaskService());
  sl.registerFactory<AuthBloc>(() => AuthBloc(sl()));
  sl.registerFactory<TaskBloc>(() => TaskBloc(sl()));
}

// Helper method to reset dependencies (useful for testing)
Future<void> reset() async {
  await sl.reset();
}
