import 'package:focus_flow/core/database/app_database.dart';

abstract class PomodoroRepository {
  Future<int> insertSession(PomodoroSessionsCompanion session);
  Stream<List<PomodoroSession>> watchTodaySessions();
  Stream<int> watchTodayCompletedPomodoros();
  Stream<int> watchTodayFocusSeconds();
  Future<List<PomodoroSession>> getSessionsBetween(
    DateTime start,
    DateTime end,
  );
  Future<int> getTotalFocusSecondsBetween(DateTime start, DateTime end);
}
