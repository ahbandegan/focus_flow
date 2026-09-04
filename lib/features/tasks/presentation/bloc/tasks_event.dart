part of 'tasks_bloc.dart';

sealed class TasksEvent extends Equatable {
  const TasksEvent();

  @override
  List<Object> get props => [];
}

final class OnLoadTasksEvent extends TasksEvent {}

final class OnAddTaskEvent extends TasksEvent {
  final String title;
  final int priority;
  final bool isCompleted;
  final int estimatedPomodoros;
  final int completedPomodoros;
  final int orderIndex;
  final bool isDeleted;

  const OnAddTaskEvent({
    required this.title,
    required this.priority,
    required this.isCompleted,
    required this.estimatedPomodoros,
    required this.completedPomodoros,
    required this.orderIndex,
    required this.isDeleted,
  });

  @override
  List<Object> get props => [
    title,
    priority,
    isCompleted,
    estimatedPomodoros,
    completedPomodoros,
    orderIndex,
    isDeleted,
  ];
}

// ignore: must_be_immutable
final class OnUpdateTaskEvent extends TasksEvent {
  final Task task;

  const OnUpdateTaskEvent({required this.task});

  @override
  List<Object> get props => [task];
}

final class OnDeleteTaskEvent extends TasksEvent {
  final int id;

  const OnDeleteTaskEvent({required this.id});

  @override
  List<Object> get props => [id];
}

final class OnCompleteTaskEvent extends TasksEvent {
  final int id;

  const OnCompleteTaskEvent({required this.id});

  @override
  List<Object> get props => [id];
}

final class OnRestoreTaskEvent extends TasksEvent {
  final int id;

  const OnRestoreTaskEvent({required this.id});

  @override
  List<Object> get props => [id];
}

final class OnSoftDeleteTaskEvent extends TasksEvent {
  final int id;

  const OnSoftDeleteTaskEvent({required this.id});

  @override
  List<Object> get props => [id];
}

final class OnIincrementCompletedPomodorosEvent extends TasksEvent {
  final int id;

  const OnIincrementCompletedPomodorosEvent({required this.id});

  @override
  List<Object> get props => [id];
}

final class OnFilterTasksEvent extends TasksEvent {}
