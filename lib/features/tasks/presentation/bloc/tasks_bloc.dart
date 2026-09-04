import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focus_flow/core/database/app_database.dart';
import 'package:focus_flow/features/tasks/domain/repositories/task_repository.dart';

part 'tasks_event.dart';
part 'tasks_state.dart';

class TasksBloc extends Bloc<TasksEvent, TasksState> {
  final TaskRepository _taskRepository;

  TasksBloc(this._taskRepository) : super(TasksInitialState()) {
    on<OnLoadTasksEvent>((event, emit) async {
      try {
        final tasks = await _taskRepository.featchAll();

        if (tasks.isEmpty) {
          emit(TasksErrorState(error: Exception("the list is empity !")));
        } else if (tasks.isNotEmpty) {
          emit(TasksSuccessState(data: tasks));
        } else {
          emit(TasksLoadingState());
        }
      } on Exception catch (e) {
        emit(TasksErrorState(error: e));
      }
    });
    on<OnAddTaskEvent>((event, emit) async {
      try {
        final result = await _taskRepository.insertTask(
          title: event.title,
          priority: event.priority,
          isCompleted: event.isCompleted,
          estimatedPomodoros: event.estimatedPomodoros,
          completedPomodoros: event.completedPomodoros,
          orderIndex: event.orderIndex,
          isDeleted: event.isDeleted,
        );

        if (result < 0) {
          emit(
            TasksErrorState(
              error: Exception("cant insert task. please try agein !"),
            ),
          );
        } else if (result > 0) {
          emit(TasksSuccessState(data: "task insert successfuly"));
        } else {
          emit(TasksLoadingState());
        }
      } on Exception catch (e) {
        emit(TasksErrorState(error: e));
      }
    });
    on<OnUpdateTaskEvent>((event, emit) async {
      try {
        final result = await _taskRepository.updateTask(event.task);

        if (result) {
          emit(TasksSuccessState(data: "task update successfuly"));
        } else {
          emit(
            TasksErrorState(
              error: Exception("cant update task. please try agein !"),
            ),
          );
        }
      } on Exception catch (e) {
        emit(TasksErrorState(error: e));
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
        } else if (result > 0) {
          emit(TasksSuccessState(data: "task delete successfuly"));
        } else {
          emit(TasksLoadingState());
        }
      } on Exception catch (e) {
        emit(TasksErrorState(error: e));
      }
    });
    on<OnCompleteTaskEvent>((event, emit) {});
    on<OnRestoreTaskEvent>((event, emit) {});
    on<OnSoftDeleteTaskEvent>((event, emit) {});
    on<OnIincrementCompletedPomodorosEvent>((event, emit) {});
    on<OnFilterTasksEvent>((event, emit) {});
  }
}
