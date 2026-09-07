part of 'home_bloc.dart';

sealed class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

final class HomeInitialState extends HomeState {}

final class HomeLoadingState extends HomeState {}

final class HomeLoadedState extends HomeState {
  final List<Task> todayTasks;
  final int completedTasksCount;
  final int totalTasksCount;
  final int completedPomodorosCount;
  final int estimatedPomodorosCount;
  final int focusTimeMinutes;
  final String greeting;

  const HomeLoadedState({
    required this.todayTasks,
    required this.completedTasksCount,
    required this.totalTasksCount,
    required this.completedPomodorosCount,
    required this.estimatedPomodorosCount,
    required this.focusTimeMinutes,
    required this.greeting,
  });

  @override
  List<Object?> get props => [
        todayTasks,
        completedTasksCount,
        totalTasksCount,
        completedPomodorosCount,
        estimatedPomodorosCount,
        focusTimeMinutes,
        greeting,
      ];
}

final class HomeErrorState extends HomeState {
  final String message;

  const HomeErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}
