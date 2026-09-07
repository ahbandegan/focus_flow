import 'package:focus_flow/core/database/app_database.dart';
import 'package:focus_flow/core/database/daos/pomodoro_dao.dart';
import 'package:focus_flow/features/pomodoro/domain/repositories/pomodoro_repository.dart';

class PomodoroRepositoryImpl implements PomodoroRepository {
  final PomodoroDao pomodoroDao;

  PomodoroRepositoryImpl({required this.pomodoroDao});

  @override
  Future<int> insertSession(PomodoroSessionsCompanion session) =>
      pomodoroDao.insertSession(session);

  @override
  Stream<List<PomodoroSession>> watchTodaySessions() =>
      pomodoroDao.watchTodaySessions();

  @override
  Stream<int> watchTodayCompletedPomodoros() =>
      pomodoroDao.watchTodayCompletedPomodoros();

  @override
  Stream<int> watchTodayFocusSeconds() => pomodoroDao.watchTodayFocusSeconds();

  @override
  Future<List<PomodoroSession>> getSessionsBetween(
    DateTime start,
    DateTime end,
  ) =>
      pomodoroDao.getSessionsBetween(start, end);

  @override
  Future<int> getTotalFocusSecondsBetween(DateTime start, DateTime end) =>
      pomodoroDao.getTotalFocusSecondsBetween(start, end);
}
