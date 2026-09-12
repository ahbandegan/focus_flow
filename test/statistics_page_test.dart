import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:focus_flow/features/pomodoro/domain/repositories/pomodoro_repository.dart';
import 'package:focus_flow/features/statistics/presentation/bloc/statistics_bloc.dart';
import 'package:focus_flow/features/statistics/presentation/pages/statistics_page.dart';
import 'package:focus_flow/features/tasks/domain/repositories/task_repository.dart';

class FakeStatisticsBloc extends Bloc<StatisticsEvent, StatisticsState>
    implements StatisticsBloc {
  FakeStatisticsBloc(super.initialState) {
    on<StatisticsEvent>((event, emit) {});
  }

  @override
  PomodoroRepository get pomodoroRepository => throw UnimplementedError();

  @override
  TaskRepository get taskRepository => throw UnimplementedError();
}

void main() {
  testWidgets('StatisticsPage renders loading indicator on StatisticsLoadingState',
      (tester) async {
    final bloc = FakeStatisticsBloc(StatisticsLoadingState());

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<StatisticsBloc>.value(
          value: bloc,
          child: const StatisticsPage(),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('StatisticsPage renders statistics data on StatisticsLoadedState',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    const loadedState = StatisticsLoadedState(
      todayFocusMinutes: 75,
      todayCompletedPomodoros: 3,
      weekFocusMinutes: 320,
      weekDailyMinutes: [30, 45, 60, 25, 50, 40, 70],
      totalCompletedTasks: 8,
      totalActiveTasks: 2,
      completionRate: 80.0,
      streakDays: 4,
    );

    final bloc = FakeStatisticsBloc(loadedState);

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<StatisticsBloc>.value(
          value: bloc,
          child: const StatisticsPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Title & streak
    expect(find.text('Statistics'), findsOneWidget);
    expect(find.text('4 Day Streak!'), findsOneWidget);

    // Verify Metric cards
    expect(find.text("Today's Focus"), findsOneWidget);
    expect(find.text('Completed Pomodoros'), findsOneWidget);
    expect(find.text('Weekly Focus'), findsOneWidget);
    expect(find.text('Task Completion'), findsOneWidget);
    expect(find.text('80%'), findsOneWidget);

    // Verify Section Headers
    expect(find.text('Weekly Focus Activity'), findsOneWidget);
    expect(find.text('Task Efficiency'), findsOneWidget);
    expect(find.text('Completed: '), findsOneWidget);
    expect(find.text('Pending: '), findsOneWidget);
  });

  testWidgets('StatisticsPage renders error view on StatisticsErrorState',
      (tester) async {
    final bloc = FakeStatisticsBloc(
      const StatisticsErrorState(message: 'Database connection failed'),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<StatisticsBloc>.value(
          value: bloc,
          child: const StatisticsPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Failed to load statistics'), findsOneWidget);
    expect(find.text('Database connection failed'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });
}
