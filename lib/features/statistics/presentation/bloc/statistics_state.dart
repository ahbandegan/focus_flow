part of 'statistics_bloc.dart';

sealed class StatisticsState extends Equatable {
  const StatisticsState();

  @override
  List<Object?> get props => [];
}

final class StatisticsInitialState extends StatisticsState {}

final class StatisticsLoadingState extends StatisticsState {}

final class StatisticsLoadedState extends StatisticsState {
  final int todayFocusMinutes;
  final int todayCompletedPomodoros;
  final int weekFocusMinutes;
  final List<double> weekDailyMinutes; // 7 days of focus minutes for fl_chart
  final int totalCompletedTasks;
  final int totalActiveTasks;
  final double completionRate;
  final int streakDays;

  const StatisticsLoadedState({
    required this.todayFocusMinutes,
    required this.todayCompletedPomodoros,
    required this.weekFocusMinutes,
    required this.weekDailyMinutes,
    required this.totalCompletedTasks,
    required this.totalActiveTasks,
    required this.completionRate,
    required this.streakDays,
  });

  @override
  List<Object?> get props => [
        todayFocusMinutes,
        todayCompletedPomodoros,
        weekFocusMinutes,
        weekDailyMinutes,
        totalCompletedTasks,
        totalActiveTasks,
        completionRate,
        streakDays,
      ];
}

final class StatisticsErrorState extends StatisticsState {
  final String message;

  const StatisticsErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}

final class StatisticsSuccessMessageState extends StatisticsState {
  final String message;
  String get data => message;

  const StatisticsSuccessMessageState({required this.message});

  @override
  List<Object?> get props => [message];
}

