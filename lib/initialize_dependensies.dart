import 'package:focus_flow/core/database/database_config.dart';
import 'package:focus_flow/core/services/connectivity_service.dart';
import 'package:focus_flow/core/services/notification_service.dart';
import 'package:focus_flow/core/services/settings_preferences_service.dart';
import 'package:focus_flow/core/services/sync_queue_service.dart';
import 'package:focus_flow/core/supabase/supabase_auth_repository.dart';
import 'package:focus_flow/core/supabase/supabase_database_repository.dart';
import 'package:focus_flow/features/pomodoro/data/repositories/pomodoro_repository_impl.dart';
import 'package:focus_flow/features/pomodoro/domain/repositories/pomodoro_repository.dart';
import 'package:focus_flow/features/settings/data/repositories/settings_repository.dart';
import 'package:focus_flow/features/settings/domin/repositories/settings_repository.dart';
import 'package:focus_flow/features/tasks/data/repository/task_repository.dart';
import 'package:focus_flow/features/tasks/domain/repositories/task_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final di = GetIt.instance;

Future<void> initializeDi() async {
  // 1. SharedPreferences & Core Services
  final sharedPreferences = await SharedPreferences.getInstance();
  di.registerSingleton<SharedPreferences>(sharedPreferences);

  di.registerSingleton<NotificationService>(NotificationService());
  di.registerLazySingleton<ConnectivityService>(() => ConnectivityService());
  di.registerLazySingleton<SyncQueueService>(
    () => SyncQueueService(di<SharedPreferences>()),
  );

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
  di.registerLazySingleton<PomodoroRepository>(
    () => PomodoroRepositoryImpl(pomodoroDao: di<PomodoroDao>()),
  );

  di.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);
  di.registerLazySingleton<SupabaseDatabaseRepository>(
    () => SupabaseDatabaseRepository(client: di<SupabaseClient>()),
  );
  di.registerLazySingleton<SupabaseAuthRepository>(
    () => SupabaseAuthRepository(client: di<SupabaseClient>()),
  );
}
