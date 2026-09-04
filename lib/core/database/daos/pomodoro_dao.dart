import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/pomodoro_sessions_table.dart';

part 'pomodoro_dao.g.dart';

@DriftAccessor(tables: [PomodoroSessions])
class PomodoroDao extends DatabaseAccessor<AppDatabase>
    with _$PomodoroDaoMixin {
  PomodoroDao(super.db);

  // 1. Insert & Update
  Future<int> insertSession(PomodoroSessionsCompanion session) =>
      into(pomodoroSessions).insert(session);

  Future<bool> updateSession(PomodoroSession session) =>
      update(pomodoroSessions).replace(session);

  Future<int> deleteSession(int id) {
    return (delete(pomodoroSessions)..where((s) => s.id.equals(id))).go();
  }

  // 2. Streams / Watches
  Stream<List<PomodoroSession>> watchRecentSessions({int limit = 30}) {
    return (select(pomodoroSessions)
          ..orderBy([(s) => OrderingTerm.desc(s.startTime)])
          ..limit(limit))
        .watch();
  }

  Stream<List<PomodoroSession>> watchSessionsForTask(int taskId) {
    return (select(pomodoroSessions)
          ..where((s) => s.taskId.equals(taskId))
          ..orderBy([(s) => OrderingTerm.desc(s.startTime)]))
        .watch();
  }

  Stream<List<PomodoroSession>> watchTodaySessions() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return (select(pomodoroSessions)
          ..where((s) =>
              s.startTime.isBiggerOrEqualValue(startOfDay) &
              s.startTime.isSmallerOrEqualValue(endOfDay))
          ..orderBy([(s) => OrderingTerm.desc(s.startTime)]))
        .watch();
  }

  Stream<int> watchTodayCompletedPomodoros() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    final query = select(pomodoroSessions)
      ..where((s) =>
          s.sessionType.equals('focus') &
          s.isCompleted.equals(true) &
          s.startTime.isBiggerOrEqualValue(startOfDay) &
          s.startTime.isSmallerOrEqualValue(endOfDay));

    return query.watch().map((list) => list.length);
  }

  Stream<int> watchTodayFocusSeconds() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    final query = select(pomodoroSessions)
      ..where((s) =>
          s.sessionType.equals('focus') &
          s.startTime.isBiggerOrEqualValue(startOfDay) &
          s.startTime.isSmallerOrEqualValue(endOfDay));

    return query.watch().map((list) {
      return list.fold<int>(0, (sum, s) => sum + s.actualDurationSeconds);
    });
  }

  // 3. Analytics & Statistics Range Queries
  Future<List<PomodoroSession>> getSessionsBetween(
    DateTime start,
    DateTime end,
  ) {
    return (select(pomodoroSessions)
          ..where((s) =>
              s.startTime.isBiggerOrEqualValue(start) &
              s.startTime.isSmallerThanValue(end))
          ..orderBy([(s) => OrderingTerm.asc(s.startTime)]))
        .get();
  }

  Future<int> getTotalFocusSecondsBetween(DateTime start, DateTime end) async {
    final sessions = await (select(pomodoroSessions)
          ..where((s) =>
              s.sessionType.equals('focus') &
              s.startTime.isBiggerOrEqualValue(start) &
              s.startTime.isSmallerThanValue(end)))
        .get();

    return sessions.fold<int>(0, (sum, s) => sum + s.actualDurationSeconds);
  }
}
