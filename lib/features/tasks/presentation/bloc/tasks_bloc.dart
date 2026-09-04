import 'package:equatable/equatable.dart';
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

        if (tasks.isNotEmpty || tasks.isEmpty) {
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
        } else if (result > 0) {
          emit(TasksSuccessState(data: "change task to complite successfuly"));
        } else {
          emit(TasksLoadingState());
        }
      } on Exception catch (e) {
        emit(TasksErrorState(error: e));
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
        } else if (result > 0) {
          emit(TasksSuccessState(data: "restore task successfuly"));
        } else {
          emit(TasksLoadingState());
        }
      } on Exception catch (e) {
        emit(TasksErrorState(error: e));
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
        } else if (result > 0) {
          emit(TasksSuccessState(data: "delete task successfuly"));
        } else {
          emit(TasksLoadingState());
        }
      } on Exception catch (e) {
        emit(TasksErrorState(error: e));
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
        } else if (result > 0) {
          emit(
            TasksSuccessState(
              data: "incriment complited promodoros successfuly",
            ),
          );
        } else {
          emit(TasksLoadingState());
        }
      } on Exception catch (e) {
        emit(TasksErrorState(error: e));
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
          emit(TasksSuccessState(data: result));
        } else {
          emit(TasksLoadingState());
        }
      } on Exception catch (e) {
        emit(TasksErrorState(error: e));
      }
    });
  }
}
