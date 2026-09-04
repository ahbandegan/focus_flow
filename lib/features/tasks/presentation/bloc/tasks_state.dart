part of 'tasks_bloc.dart';

sealed class TasksState extends Equatable {
  const TasksState();

  @override
  List<Object> get props => [];
}

final class TasksInitialState extends TasksState {}

final class TasksLoadingState extends TasksState {}

final class TasksErrorState extends TasksState {
  final Exception error;
  const TasksErrorState({required this.error});
}

final class TasksSuccessState extends TasksState {
  
}
