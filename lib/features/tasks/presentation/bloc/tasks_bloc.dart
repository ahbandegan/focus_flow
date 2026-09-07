import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focus_flow/core/database/app_database.dart';
import 'package:focus_flow/core/services/connectivity_service.dart';
import 'package:focus_flow/core/services/sync_queue_service.dart';
import 'package:focus_flow/core/supabase/supabase_database_repository.dart';
import 'package:focus_flow/features/settings/domin/repositories/settings_repository.dart';
import 'package:focus_flow/features/tasks/domain/repositories/task_repository.dart';

part 'tasks_event.dart';
part 'tasks_state.dart';

class TasksBloc extends Bloc<TasksEvent, TasksState> {
  final TaskRepository _taskRepository;
  final SettingsRepository _settingsRepository;
  final SupabaseDatabaseRepository _supabaseDatabaseRepository;
  final ConnectivityService _connectivityService;
  final SyncQueueService _syncQueueService;

  StreamSubscription<bool>? _connectivitySubscription;
  bool _isSyncing = false;

  TasksBloc({
    required this._taskRepository,
    required this._settingsRepository,
    required this._supabaseDatabaseRepository,
    required this._connectivityService,
    required this._syncQueueService,
  })  : super(TasksInitialState()) {
    // 1. Listen for network connectivity changes
    _connectivitySubscription =
        _connectivityService.onConnectivityChanged.listen((isConnected) {
      add(OnConnectivityChangedEvent(isConnected: isConnected));
    });

    // 2. Register event handlers
    on<OnConnectivityChangedEvent>(_onConnectivityChanged);
    on<OnLoadTasksEvent>(_onLoadTasks);
    on<OnSyncTasksEvent>(_onSyncTasks);
    on<OnAddTaskEvent>(_onAddTask);
    on<OnUpdateTaskEvent>(_onUpdateTask);
    on<OnDeleteTaskEvent>(_onDeleteTask);
    on<OnSoftDeleteTaskEvent>(_onSoftDeleteTask);
    on<OnCompleteTaskEvent>(_onCompleteTask);
    on<OnRestoreTaskEvent>(_onRestoreTask);
    on<OnIincrementCompletedPomodorosEvent>(_onIncrementCompletedPomodoros);
    on<OnFilterTasksEvent>(_onFilterTasks);
  }

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    return super.close();
  }

  // ===========================================================================
  // CONNECTIVITY CHANGE & AUTO-SYNC
  // ===========================================================================
  Future<void> _onConnectivityChanged(
    OnConnectivityChangedEvent event,
    Emitter<TasksState> emit,
  ) async {
    if (state is TasksSuccessState) {
      final current = state as TasksSuccessState;
      emit(current.copyWith(
        isOnline: event.isConnected,
        pendingSyncCount: _syncQueueService.getPendingItems().length,
      ));
    }

    // When connection is restored and user is logged in, auto-sync pending items to Supabase!
    if (event.isConnected && _settingsRepository.isLoggedIn) {
      add(OnSyncTasksEvent());
    }
  }

  // ===========================================================================
  // LOAD TASKS (OFFLINE-FIRST)
  // ===========================================================================
  Future<void> _onLoadTasks(
    OnLoadTasksEvent event,
    Emitter<TasksState> emit,
  ) async {
    try {
      await _loadAndEmitTasks(emit);

      // If connected and logged in, trigger background sync
      final online = await _connectivityService.isConnected;
      if (online && _settingsRepository.isLoggedIn) {
        add(OnSyncTasksEvent());
      }
    } catch (e) {
      emit(TasksErrorState(error: Exception(e.toString())));
    }
  }

  // ===========================================================================
  // SYNC WITH SUPABASE (PUSH PENDING & PULL REMOTE)
  // ===========================================================================
  Future<void> _onSyncTasks(
    OnSyncTasksEvent event,
    Emitter<TasksState> emit,
  ) async {
    if (_isSyncing || !_settingsRepository.isLoggedIn) return;

    final isOnline = await _connectivityService.isConnected;
    if (!isOnline) return;

    _isSyncing = true;
    if (state is TasksSuccessState) {
      emit((state as TasksSuccessState).copyWith(isSyncing: true));
    }

    try {
      final currentUserId =
          _supabaseDatabaseRepository.client.auth.currentUser?.id;

      // 1. Process local pending sync queue to Supabase
      final pendingItems = _syncQueueService.getPendingItems();
      for (final item in pendingItems) {
        try {
          final payload = Map<String, dynamic>.from(item.payload);
          if (currentUserId != null) {
            payload['user_id'] = currentUserId;
          }

          switch (item.action) {
            case SyncAction.create:
            case SyncAction.update:
              await _supabaseDatabaseRepository.upsert('tasks', payload);
              await _syncQueueService.remove(item.id);
              break;
            case SyncAction.delete:
              await _supabaseDatabaseRepository.update(
                'tasks',
                {
                  'is_deleted': true,
                  'updated_at': DateTime.now().toUtc().toIso8601String(),
                },
                filters: {'id': item.taskId},
              );
              await _syncQueueService.remove(item.id);
              break;
          }
        } catch (_) {
          // If a single item fails, leave in queue to retry next time
        }
      }

      // 2. Fetch remote tasks from Supabase and upsert locally
      try {
        final remoteRows = await _supabaseDatabaseRepository.getAll('tasks');
        for (final row in remoteRows) {
          final companion = TaskSupabaseMapper.toCompanion(row);
          await _taskRepository.upsertTask(companion);
        }
      } catch (_) {
        // If pull fails, continue with local data
      }

      // 3. Emit updated local state
      await _loadAndEmitTasks(emit, isSyncing: false);
    } catch (e) {
      if (state is TasksSuccessState) {
        emit((state as TasksSuccessState).copyWith(isSyncing: false));
      }
    } finally {
      _isSyncing = false;
    }
  }

  // ===========================================================================
  // ADD TASK
  // ===========================================================================
  Future<void> _onAddTask(
    OnAddTaskEvent event,
    Emitter<TasksState> emit,
  ) async {
    try {
      // 1. Always save to local database immediately
      final localId = await _taskRepository.insertTask(
        title: event.title,
        description: event.description,
        dueDate: event.dueDate,
        priority: event.priority,
        isCompleted: event.isCompleted,
        estimatedPomodoros: event.estimatedPomodoros,
        completedPomodoros: event.completedPomodoros,
        orderIndex: event.orderIndex,
        isDeleted: event.isDeleted,
      );

      if (localId <= 0) {
        emit(
          TasksErrorState(
            error: Exception("Can't insert task. Please try again!"),
          ),
        );
        return;
      }

      // 2. Immediately refresh local UI
      await _loadAndEmitTasks(emit);

      // 3. If logged in, push to Supabase or queue if offline
      if (_settingsRepository.isLoggedIn) {
        final task = await _taskRepository.getTaskById(localId);
        final payload = task?.toSupabaseJson(includeId: true) ??
            {
              'id': localId,
              'title': event.title,
              'description': event.description,
              'priority': event.priority,
              'due_date': event.dueDate?.toUtc().toIso8601String(),
              'is_completed': event.isCompleted,
              'estimated_pomodoros': event.estimatedPomodoros,
              'completed_pomodoros': event.completedPomodoros,
              'order_index': event.orderIndex,
              'is_deleted': event.isDeleted,
              'created_at': DateTime.now().toUtc().toIso8601String(),
              'updated_at': DateTime.now().toUtc().toIso8601String(),
            };

        final userId =
            _supabaseDatabaseRepository.client.auth.currentUser?.id;
        if (userId != null) payload['user_id'] = userId;

        final isOnline = await _connectivityService.isConnected;
        if (isOnline) {
          try {
            await _supabaseDatabaseRepository.upsert('tasks', payload);
          } catch (_) {
            // Failed network call -> queue for auto-sync
            await _syncQueueService.enqueue(
              action: SyncAction.create,
              taskId: localId,
              payload: payload,
            );
          }
        } else {
          // Offline -> save to queue
          await _syncQueueService.enqueue(
            action: SyncAction.create,
            taskId: localId,
            payload: payload,
          );
        }
      }
    } catch (e) {
      emit(TasksErrorState(error: Exception(e.toString())));
    }
  }

  // ===========================================================================
  // UPDATE TASK
  // ===========================================================================
  Future<void> _onUpdateTask(
    OnUpdateTaskEvent event,
    Emitter<TasksState> emit,
  ) async {
    try {
      // 1. Update local database
      final success = await _taskRepository.updateTask(event.task);
      if (!success) {
        emit(
          TasksErrorState(
            error: Exception("Can't update task. Please try again!"),
          ),
        );
        return;
      }

      // 2. Immediately update UI
      await _loadAndEmitTasks(emit);

      // 3. Sync to Supabase or queue
      if (_settingsRepository.isLoggedIn) {
        final payload = event.task.toSupabaseJson(includeId: true);
        final userId =
            _supabaseDatabaseRepository.client.auth.currentUser?.id;
        if (userId != null) payload['user_id'] = userId;

        final isOnline = await _connectivityService.isConnected;
        if (isOnline) {
          try {
            await _supabaseDatabaseRepository.upsert('tasks', payload);
          } catch (_) {
            await _syncQueueService.enqueue(
              action: SyncAction.update,
              taskId: event.task.id,
              payload: payload,
            );
          }
        } else {
          await _syncQueueService.enqueue(
            action: SyncAction.update,
            taskId: event.task.id,
            payload: payload,
          );
        }
      }
    } catch (e) {
      emit(TasksErrorState(error: Exception(e.toString())));
    }
  }

  // ===========================================================================
  // DELETE TASK (SOFT DELETE)
  // ===========================================================================
  Future<void> _onDeleteTask(
    OnDeleteTaskEvent event,
    Emitter<TasksState> emit,
  ) async {
    await _handleDelete(event.id, emit);
  }

  Future<void> _onSoftDeleteTask(
    OnSoftDeleteTaskEvent event,
    Emitter<TasksState> emit,
  ) async {
    await _handleDelete(event.id, emit);
  }

  Future<void> _handleDelete(int id, Emitter<TasksState> emit) async {
    try {
      final result = await _taskRepository.softDeleteTask(id);
      if (result < 0) {
        emit(
          TasksErrorState(
            error: Exception("Can't delete task. Please try again!"),
          ),
        );
        return;
      }

      await _loadAndEmitTasks(emit);

      if (_settingsRepository.isLoggedIn) {
        final payload = {
          'id': id,
          'is_deleted': true,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        };
        final userId =
            _supabaseDatabaseRepository.client.auth.currentUser?.id;
        if (userId != null) payload['user_id'] = userId;

        final isOnline = await _connectivityService.isConnected;
        if (isOnline) {
          try {
            await _supabaseDatabaseRepository.update(
              'tasks',
              payload,
              filters: {'id': id},
            );
          } catch (_) {
            await _syncQueueService.enqueue(
              action: SyncAction.delete,
              taskId: id,
              payload: payload,
            );
          }
        } else {
          await _syncQueueService.enqueue(
            action: SyncAction.delete,
            taskId: id,
            payload: payload,
          );
        }
      }
    } catch (e) {
      emit(TasksErrorState(error: Exception(e.toString())));
    }
  }

  // ===========================================================================
  // COMPLETE TASK
  // ===========================================================================
  Future<void> _onCompleteTask(
    OnCompleteTaskEvent event,
    Emitter<TasksState> emit,
  ) async {
    try {
      final result = await _taskRepository.compliteTask(event.id);
      if (result < 0) {
        emit(
          TasksErrorState(
            error: Exception("Can't complete task. Please try again!"),
          ),
        );
        return;
      }

      await _loadAndEmitTasks(emit);
      await _syncTaskById(event.id);
    } catch (e) {
      emit(TasksErrorState(error: Exception(e.toString())));
    }
  }

  // ===========================================================================
  // RESTORE TASK
  // ===========================================================================
  Future<void> _onRestoreTask(
    OnRestoreTaskEvent event,
    Emitter<TasksState> emit,
  ) async {
    try {
      final result = await _taskRepository.restoreTask(event.id);
      if (result < 0) {
        emit(
          TasksErrorState(
            error: Exception("Can't restore task. Please try again!"),
          ),
        );
        return;
      }

      await _loadAndEmitTasks(emit);
      await _syncTaskById(event.id);
    } catch (e) {
      emit(TasksErrorState(error: Exception(e.toString())));
    }
  }

  // ===========================================================================
  // INCREMENT COMPLETED POMODOROS
  // ===========================================================================
  Future<void> _onIncrementCompletedPomodoros(
    OnIincrementCompletedPomodorosEvent event,
    Emitter<TasksState> emit,
  ) async {
    try {
      final result =
          await _taskRepository.incrementCompletedPomodoros(event.id);
      if (result < 0) {
        emit(
          TasksErrorState(
            error: Exception("Can't increment pomodoros. Please try again!"),
          ),
        );
        return;
      }

      await _loadAndEmitTasks(emit);
      await _syncTaskById(event.id);
    } catch (e) {
      emit(TasksErrorState(error: Exception(e.toString())));
    }
  }

  // ===========================================================================
  // FILTER TASKS
  // ===========================================================================
  Future<void> _onFilterTasks(
    OnFilterTasksEvent event,
    Emitter<TasksState> emit,
  ) async {
    try {
      final stream = _taskRepository.filterTask(
        isCompleted: event.isCompleted,
        priority: event.priority,
        searchQuery: event.searchQuery,
      );
      emit(TasksStreamSuccessState(data: stream));
    } catch (e) {
      emit(TasksErrorState(error: Exception(e.toString())));
    }
  }

  // ===========================================================================
  // HELPER METHODS
  // ===========================================================================
  Future<void> _syncTaskById(int id) async {
    if (!_settingsRepository.isLoggedIn) return;
    final task = await _taskRepository.getTaskById(id);
    if (task == null) return;

    final payload = task.toSupabaseJson(includeId: true);
    final userId = _supabaseDatabaseRepository.client.auth.currentUser?.id;
    if (userId != null) payload['user_id'] = userId;

    final isOnline = await _connectivityService.isConnected;
    if (isOnline) {
      try {
        await _supabaseDatabaseRepository.upsert('tasks', payload);
      } catch (_) {
        await _syncQueueService.enqueue(
          action: SyncAction.update,
          taskId: id,
          payload: payload,
        );
      }
    } else {
      await _syncQueueService.enqueue(
        action: SyncAction.update,
        taskId: id,
        payload: payload,
      );
    }
  }

  Future<void> _loadAndEmitTasks(
    Emitter<TasksState> emit, {
    bool isSyncing = false,
  }) async {
    final tasks = await _taskRepository.featchAll();
    final isOnline = await _connectivityService.isConnected;
    final pendingCount = _syncQueueService.getPendingItems().length;

    emit(
      TasksSuccessState(
        data: List<Task>.unmodifiable(tasks),
        isSyncing: isSyncing,
        isOnline: isOnline,
        pendingSyncCount: pendingCount,
      ),
    );
  }
}
