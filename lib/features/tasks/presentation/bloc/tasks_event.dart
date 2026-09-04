part of 'tasks_bloc.dart';

sealed class TasksEvent extends Equatable {
  const TasksEvent();

  @override
  List<Object> get props => [];
}

final class OnLoadTasksEvent extends TasksEvent {}

final class OnAddTaskEvent extends TasksEvent {}

final class OnUpdateTaskEvent extends TasksEvent {}

final class OnDeleteTaskEvent extends TasksEvent {}

final class OnCompleteTaskEvent extends TasksEvent {}

final class OnRestoreTaskEvent extends TasksEvent {}

final class OnFilterTasksEvent extends TasksEvent {}
