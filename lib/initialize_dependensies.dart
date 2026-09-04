import 'package:focus_flow/core/database/database_config.dart';
import 'package:focus_flow/core/services/notification_service.dart';
import 'package:focus_flow/core/services/settings_preferences_service.dart';
import 'package:focus_flow/features/settings/data/repositories/settings_repository.dart';
import 'package:focus_flow/features/settings/domin/repositories/settings_repository.dart';
import 'package:focus_flow/features/tasks/data/repository/task_repository.dart';
import 'package:focus_flow/features/tasks/domain/repositories/task_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

final di = GetIt.instance;

Future<void> initializeDi() async {
  // 1. SharedPreferences & Settings Service
  final sharedPreferences = await SharedPreferences.getInstance();
  di.registerSingleton<SharedPreferences>(sharedPreferences);

  di.registerSingleton<NotificationService>(NotificationService());

  di.registerLazySingleton<SettingsPreferencesService>(
    () => SettingsPreferencesService(di<SharedPreferences>()),
  );

  // 2. Drift Database & DAOs
  final db = AppDatabase();
  di.registerSingleton<AppDatabase>(db);

  di.registerLazySingleton<TasksDao>(() => db.tasksDao);
  di.registerLazySingleton<SubtasksDao>(() => db.subtasksDao);
  di.registerLazySingleton<TagsDao>(() => db.tagsDao);
  di.registerLazySingleton<PomodoroDao>(() => db.pomodoroDao);

  // 3. Repositories
  di.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(di<SettingsPreferencesService>()),
  );
  di.registerLazySingleton<TaskRepository>(
    () => TaskRepositoryImpl(tasksDao: di<TasksDao>()),
  );
}
