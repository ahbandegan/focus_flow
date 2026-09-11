part of 'tasks_bloc.dart';

sealed class TasksState extends Equatable {
  const TasksState();

  @override
  List<Object?> get props => [];
}

final class TasksInitialState extends TasksState {}

final class TasksLoadingState extends TasksState {}

final class TasksErrorState extends TasksState {
  final Exception error;
  const TasksErrorState({required this.error});

  @override
  List<Object?> get props => [error];
}

final class TasksSuccessState extends TasksState {
  final List<Task> data;

  const TasksSuccessState({
    required this.data,
  });

  TasksSuccessState copyWith({
    List<Task>? data,
  }) {
    return TasksSuccessState(
      data: data ?? this.data,
    );
  }

  @override
  List<Object?> get props => [data];
}

final class TasksStreamSuccessState extends TasksState {
  final Stream<List<Task>> data;
  const TasksStreamSuccessState({required this.data});

  @override
  List<Object?> get props => [data];
}

final class TasksSuccessMessageState extends TasksState {
  final String data;
  String get message => data;

  const TasksSuccessMessageState({required this.data});

  @override
  List<Object?> get props => [data];
}
