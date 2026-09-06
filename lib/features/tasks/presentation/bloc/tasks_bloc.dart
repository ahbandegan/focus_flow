import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focus_flow/core/database/app_database.dart';
import 'package:focus_flow/core/supabase/supabase_database_repository.dart';
import 'package:focus_flow/features/settings/domin/repositories/settings_repository.dart';
import 'package:focus_flow/features/tasks/domain/repositories/task_repository.dart';

part 'tasks_event.dart';
part 'tasks_state.dart';

class TasksBloc extends Bloc<TasksEvent, TasksState> {
  final TaskRepository _taskRepository;
  final SettingsRepository _settingsRepository;
  final SupabaseDatabaseRepository _supabaseDatabaseRepository;

  TasksBloc({
    required this._taskRepository,
    required this._settingsRepository,
    required this._supabaseDatabaseRepository,
  }) : super(TasksInitialState()) {
    on<OnLoadTasksEvent>((event, emit) async {
      try {
        await _loadAndEmitTasks(emit);
      } catch (e) {
        emit(TasksErrorState(error: Exception(e.toString())));
      }
    });
    on<OnAddTaskEvent>((event, emit) async {
      try {
        final result = await _taskRepository.insertTask(
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

        if (result <= 0) {
          emit(
            TasksErrorState(
              error: Exception("cant insert task. please try agein !"),
            ),
          );
        } else {
          if (_settingsRepository.isLoggedIn) {
            try {
              await _supabaseDatabaseRepository.insert(
                "tasks",
                {
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
                },
              );
            } catch (_) {}
          }
          await _loadAndEmitTasks(emit);
        }
      } catch (e) {
        emit(TasksErrorState(error: Exception(e.toString())));
      }
    });
    on<OnUpdateTaskEvent>((event, emit) async {
      try {
        final result = await _taskRepository.updateTask(event.task);

        if (result) {
          await _loadAndEmitTasks(emit);
        } else {
          emit(
            TasksErrorState(
              error: Exception("cant update task. please try agein !"),
            ),
          );
        }
      } catch (e) {
        emit(TasksErrorState(error: Exception(e.toString())));
      }
    });
    on<OnDeleteTaskEvent>((event, emit) async {
      try {
        final result = await _taskRepository.deleteTask(event.id);

        if (result < 0) {
          emit(
            TasksErrorState(
              error: Exception("cant delete task. please try agein !"),
            ),
          );
        } else {
          await _loadAndEmitTasks(emit);
        }
      } catch (e) {
        emit(TasksErrorState(error: Exception(e.toString())));
      }
    });
    on<OnCompleteTaskEvent>((event, emit) async {
      try {
        final result = await _taskRepository.compliteTask(event.id);

        if (result < 0) {
          emit(
            TasksErrorState(
              error: Exception(
                "cant change task to complite. please try agein !",
              ),
            ),
          );
        } else {
          await _loadAndEmitTasks(emit);
        }
      } catch (e) {
        emit(TasksErrorState(error: Exception(e.toString())));
      }
    });
    on<OnRestoreTaskEvent>((event, emit) async {
      try {
        final result = await _taskRepository.restoreTask(event.id);

        if (result < 0) {
          emit(
            TasksErrorState(
              error: Exception("cant restore task. please try agein !"),
            ),
          );
        } else {
          await _loadAndEmitTasks(emit);
        }
      } catch (e) {
        emit(TasksErrorState(error: Exception(e.toString())));
      }
    });
    on<OnSoftDeleteTaskEvent>((event, emit) async {
      try {
        final result = await _taskRepository.softDeleteTask(event.id);

        if (result < 0) {
          emit(
            TasksErrorState(
              error: Exception("cant delete task. please try agein !"),
            ),
          );
        } else {
          await _loadAndEmitTasks(emit);
        }
      } catch (e) {
        emit(TasksErrorState(error: Exception(e.toString())));
      }
    });
    on<OnIincrementCompletedPomodorosEvent>((event, emit) async {
      try {
        final result = await _taskRepository.incrementCompletedPomodoros(
          event.id,
        );

        if (result < 0) {
          emit(
            TasksErrorState(
              error: Exception(
                "cant incriment complited promodoros. please try agein !",
              ),
            ),
          );
        } else {
          await _loadAndEmitTasks(emit);
        }
      } catch (e) {
        emit(TasksErrorState(error: Exception(e.toString())));
      }
    });
    on<OnFilterTasksEvent>((event, emit) async {
      try {
        final result = _taskRepository.filterTask(
          isCompleted: event.isCompleted,
          priority: event.priority,
          searchQuery: event.searchQuery,
        );

        if (await result.isEmpty) {
          emit(
            TasksErrorState(
              error: Exception("cant filter tasks. please try agein !"),
            ),
          );
        } else if (!(await result.isEmpty)) {
          emit(TasksStreamSuccessState(data: result));
        } else {
          emit(TasksLoadingState());
        }
      } on Exception catch (e) {
        emit(TasksErrorState(error: e));
      }
    });
  }

  Future<void> _loadAndEmitTasks(Emitter<TasksState> emit) async {
    final tasks = _settingsRepository.isLoggedIn &&
            _supabaseDatabaseRepository.client.auth.currentUser != null
        ? TaskSupabaseMapper.fromSupabaseList(
            await _supabaseDatabaseRepository.getAll("tasks"),
          )
        : await _taskRepository.featchAll();

    emit(TasksSuccessState(data: List<Task>.unmodifiable(tasks)));
  }
}
