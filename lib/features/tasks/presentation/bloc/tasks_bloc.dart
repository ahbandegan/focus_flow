import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focus_flow/core/database/app_database.dart';
import 'package:focus_flow/core/services/notification_service.dart';
import 'package:focus_flow/features/tasks/domain/repositories/task_repository.dart';

part 'tasks_event.dart';
part 'tasks_state.dart';

class TasksBloc extends Bloc<TasksEvent, TasksState> {
  final TaskRepository taskRepository;
  final NotificationService? notificationService;

  TasksBloc({
    required this.taskRepository,
    this.notificationService,
  }) : super(TasksInitialState()) {
    on<OnLoadTasksEvent>(_onLoadTasks);
    on<OnAddTaskEvent>(_onAddTask);
    on<OnUpdateTaskEvent>(_onUpdateTask);
    on<OnDeleteTaskEvent>(_onDeleteTask);
    on<OnSoftDeleteTaskEvent>(_onSoftDeleteTask);
    on<OnCompleteTaskEvent>(_onCompleteTask);
    on<OnRestoreTaskEvent>(_onRestoreTask);
    on<OnIincrementCompletedPomodorosEvent>(_onIncrementCompletedPomodoros);
    on<OnFilterTasksEvent>(_onFilterTasks);
  }

  // ===========================================================================
  // LOAD TASKS (LOCAL DATABASE)
  // ===========================================================================
  Future<void> _onLoadTasks(
    OnLoadTasksEvent event,
    Emitter<TasksState> emit,
  ) async {
    try {
      if (!event.silent) {
        emit(const TasksSuccessMessageState(data: "Tasks loaded successfully"));
      }
      await _loadAndEmitTasks(emit);
    } catch (e) {
      emit(TasksErrorState(error: Exception(e.toString())));
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
      final localId = await taskRepository.insertTask(
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

      // Schedule notification if due date is in the future
      if (event.dueDate != null && event.dueDate!.isAfter(DateTime.now())) {
        try {
          await notificationService?.scheduleNotification(
            id: localId,
            title: 'Task Reminder: ${event.title}',
            body: event.description?.isNotEmpty == true
                ? event.description!
                : 'It is time to work on "${event.title}".',
            scheduledDate: event.dueDate!,
          );
        } catch (_) {}
      }

      emit(const TasksSuccessMessageState(data: "Task added successfully"));
      await _loadAndEmitTasks(emit);
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
      final success = await taskRepository.updateTask(event.task);
      if (!success) {
        emit(
          TasksErrorState(
            error: Exception("Can't update task. Please try again!"),
          ),
        );
        return;
      }

      final task = event.task;
      if (task.dueDate != null &&
          task.dueDate!.isAfter(DateTime.now()) &&
          !task.isCompleted &&
          !task.isDeleted) {
        try {
          await notificationService?.scheduleNotification(
            id: task.id,
            title: 'Task Reminder: ${task.title}',
            body: task.description?.isNotEmpty == true
                ? task.description!
                : 'It is time to work on "${task.title}".',
            scheduledDate: task.dueDate!,
          );
        } catch (_) {}
      } else {
        try {
          await notificationService?.cancelNotification(task.id);
        } catch (_) {}
      }

      emit(const TasksSuccessMessageState(data: "Task updated successfully"));
      await _loadAndEmitTasks(emit);
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
      final result = await taskRepository.softDeleteTask(id);
      if (result < 0) {
        emit(
          TasksErrorState(
            error: Exception("Can't delete task. Please try again!"),
          ),
        );
        return;
      }

      try {
        await notificationService?.cancelNotification(id);
      } catch (_) {}

      emit(const TasksSuccessMessageState(data: "Task deleted successfully"));
      await _loadAndEmitTasks(emit);
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
      final result = await taskRepository.compliteTask(event.id);
      if (result < 0) {
        emit(
          TasksErrorState(
            error: Exception("Can't complete task. Please try again!"),
          ),
        );
        return;
      }

      try {
        await notificationService?.cancelNotification(event.id);
      } catch (_) {}

      emit(const TasksSuccessMessageState(data: "Task completed successfully"));
      await _loadAndEmitTasks(emit);
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
      final result = await taskRepository.restoreTask(event.id);
      if (result < 0) {
        emit(
          TasksErrorState(
            error: Exception("Can't restore task. Please try again!"),
          ),
        );
        return;
      }

      try {
        final task = await taskRepository.getTaskById(event.id);
        if (task != null &&
            task.dueDate != null &&
            task.dueDate!.isAfter(DateTime.now()) &&
            !task.isCompleted &&
            !task.isDeleted) {
          await notificationService?.scheduleNotification(
            id: task.id,
            title: 'Task Reminder: ${task.title}',
            body: task.description?.isNotEmpty == true
                ? task.description!
                : 'It is time to work on "${task.title}".',
            scheduledDate: task.dueDate!,
          );
        }
      } catch (_) {}

      emit(const TasksSuccessMessageState(data: "Task restored successfully"));
      await _loadAndEmitTasks(emit);
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
      final result = await taskRepository.incrementCompletedPomodoros(event.id);
      if (result < 0) {
        emit(
          TasksErrorState(
            error: Exception("Can't increment pomodoros. Please try again!"),
          ),
        );
        return;
      }

      emit(const TasksSuccessMessageState(data: "Pomodoro session recorded successfully"));
      await _loadAndEmitTasks(emit);
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
      final stream = taskRepository.filterTask(
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
  Future<void> _loadAndEmitTasks(Emitter<TasksState> emit) async {
    final tasks = List<Task>.from(await taskRepository.featchAll());
    tasks
      ..sort((a, b) => b.priority.compareTo(a.priority))
      ..sort(
        (a, b) => (a.isCompleted ? 1 : 0).compareTo(b.isCompleted ? 1 : 0),
      );
    emit(TasksSuccessState(data: List<Task>.unmodifiable(tasks)));
  }
}
