import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focus_flow/features/tasks/domain/repositories/task_repository.dart';

part 'tasks_event.dart';
part 'tasks_state.dart';

class TasksBloc extends Bloc<TasksEvent, TasksState> {
  final TaskRepository _taskRepository;

  TasksBloc(this._taskRepository) : super(TasksInitialState()) {
    on<OnLoadTasksEvent>((event, emit) {});
    on<OnAddTaskEvent>((event, emit) {});
    on<OnUpdateTaskEvent>((event, emit) {});
    on<OnDeleteTaskEvent>((event, emit) {});
    on<OnCompleteTaskEvent>((event, emit) {});
    on<OnRestoreTaskEvent>((event, emit) {});
    on<OnFilterTasksEvent>((event, emit) {});
  }
}
