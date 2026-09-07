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
  final bool isSyncing;
  final bool isOnline;
  final int pendingSyncCount;

  const TasksSuccessState({
    required this.data,
    this.isSyncing = false,
    this.isOnline = true,
    this.pendingSyncCount = 0,
  });

  TasksSuccessState copyWith({
    List<Task>? data,
    bool? isSyncing,
    bool? isOnline,
    int? pendingSyncCount,
  }) {
    return TasksSuccessState(
      data: data ?? this.data,
      isSyncing: isSyncing ?? this.isSyncing,
      isOnline: isOnline ?? this.isOnline,
      pendingSyncCount: pendingSyncCount ?? this.pendingSyncCount,
    );
  }

  @override
  List<Object?> get props => [data, isSyncing, isOnline, pendingSyncCount];
}

final class TasksStreamSuccessState extends TasksState {
  final Stream<List<Task>> data;
  const TasksStreamSuccessState({required this.data});

  @override
  List<Object?> get props => [data];
}

final class TasksSuccessMessageState extends TasksState {
  final String data;
  const TasksSuccessMessageState({required this.data});

  @override
  List<Object?> get props => [data];
}
