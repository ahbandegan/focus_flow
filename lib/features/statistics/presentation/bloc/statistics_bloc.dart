import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focus_flow/features/pomodoro/domain/repositories/pomodoro_repository.dart';
import 'package:focus_flow/features/tasks/domain/repositories/task_repository.dart';

part 'statistics_event.dart';
part 'statistics_state.dart';

class StatisticsBloc extends Bloc<StatisticsEvent, StatisticsState> {
  final PomodoroRepository pomodoroRepository;
  final TaskRepository taskRepository;

  StatisticsBloc({
    required this.pomodoroRepository,
    required this.taskRepository,
  }) : super(StatisticsInitialState()) {
    on<LoadStatisticsEvent>(_onLoadStatistics);
    on<RefreshStatisticsEvent>(_onLoadStatistics);
  }

  Future<void> _onLoadStatistics(
    StatisticsEvent event,
    Emitter<StatisticsState> emit,
  ) async {
    emit(StatisticsLoadingState());
    try {
      if (event is RefreshStatisticsEvent) {
        emit(const StatisticsSuccessMessageState(
          message: "Statistics refreshed successfully",
        ));
      } else {
        emit(const StatisticsSuccessMessageState(
          message: "Statistics loaded successfully",
        ));
      }
      final now = DateTime.now();
      final startOfToday = DateTime(now.year, now.month, now.day);
      final endOfToday = DateTime(now.year, now.month, now.day, 23, 59, 59);

      // 1. Today's Pomodoro stats
      final todaySessions = await pomodoroRepository.getSessionsBetween(
        startOfToday,
        endOfToday,
      );
      final todayFocusSessions = todaySessions
          .where((s) => s.sessionType == 'focus' && s.isCompleted);
      final todayCompletedCount = todayFocusSessions.length;
      final todayFocusSeconds = todaySessions
          .where((s) => s.sessionType == 'focus')
          .fold<int>(0, (sum, s) => sum + s.actualDurationSeconds);
      final todayFocusMinutes = todayFocusSeconds ~/ 60;

      // 2. Past 7 days breakdown for charts
      final List<double> weekDailyMinutes = [];
      int weekTotalSeconds = 0;
      for (int i = 6; i >= 0; i--) {
        final day = now.subtract(Duration(days: i));
        final dayStart = DateTime(day.year, day.month, day.day);
        final dayEnd = DateTime(day.year, day.month, day.day, 23, 59, 59);
        final daySessions = await pomodoroRepository.getSessionsBetween(
          dayStart,
          dayEnd,
        );
        final daySeconds = daySessions
            .where((s) => s.sessionType == 'focus')
            .fold<int>(0, (sum, s) => sum + s.actualDurationSeconds);

        weekTotalSeconds += daySeconds;
        weekDailyMinutes.add((daySeconds / 60.0).roundToDouble());
      }
      final weekFocusMinutes = weekTotalSeconds ~/ 60;

      // 3. Tasks statistics
      final allTasks = await taskRepository.featchAll();
      final completedTasks =
          allTasks.where((t) => t.isCompleted && !t.isDeleted).length;
      final activeTasks =
          allTasks.where((t) => !t.isCompleted && !t.isDeleted).length;
      final totalNonDeleted = completedTasks + activeTasks;
      final completionRate = totalNonDeleted > 0
          ? (completedTasks / totalNonDeleted) * 100.0
          : 0.0;

      // 4. Streak calculation (consecutive days with at least 1 completed focus session)
      int streak = 0;
      for (int i = 0; i < 365; i++) {
        final checkDay = now.subtract(Duration(days: i));
        final checkStart = DateTime(checkDay.year, checkDay.month, checkDay.day);
        final checkEnd =
            DateTime(checkDay.year, checkDay.month, checkDay.day, 23, 59, 59);
        final sessions = await pomodoroRepository.getSessionsBetween(
          checkStart,
          checkEnd,
        );
        final hasCompletedFocus =
            sessions.any((s) => s.sessionType == 'focus' && s.isCompleted);

        if (hasCompletedFocus) {
          streak++;
        } else {
          // If checking today and no session yet, continue checking yesterday before breaking
          if (i == 0) continue;
          break;
        }
      }

      emit(
        StatisticsLoadedState(
          todayFocusMinutes: todayFocusMinutes,
          todayCompletedPomodoros: todayCompletedCount,
          weekFocusMinutes: weekFocusMinutes,
          weekDailyMinutes: weekDailyMinutes,
          totalCompletedTasks: completedTasks,
          totalActiveTasks: activeTasks,
          completionRate: completionRate,
          streakDays: streak,
        ),
      );
    } catch (e) {
      emit(StatisticsErrorState(message: e.toString()));
    }
  }
}
