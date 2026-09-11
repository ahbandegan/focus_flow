import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focus_flow/core/database/app_database.dart';
import 'package:focus_flow/features/tasks/domain/repositories/task_repository.dart';

part 'tasks_event.dart';
part 'tasks_state.dart';

class TasksBloc extends Bloc<TasksEvent, TasksState> {
  final TaskRepository taskRepository;

  TasksBloc({
    required this.taskRepository,
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
      final result =
          await taskRepository.incrementCompletedPomodoros(event.id);
      if (result < 0) {
        emit(
          TasksErrorState(
            error: Exception("Can't increment pomodoros. Please try again!"),
          ),
        );
        return;
      }

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
    final tasks = await taskRepository.featchAll();
    emit(
      TasksSuccessState(
        data: List<Task>.unmodifiable(tasks),
      ),
    );
  }
}
