part of 'pomodoro_bloc.dart';

sealed class PomodoroEvent extends Equatable {
  const PomodoroEvent();

  @override
  List<Object?> get props => [];
}

final class PomodoroStartEvent extends PomodoroEvent {}

final class PomodoroPauseEvent extends PomodoroEvent {}

final class PomodoroResumeEvent extends PomodoroEvent {}

final class PomodoroResetEvent extends PomodoroEvent {}

final class PomodoroTickEvent extends PomodoroEvent {}

final class PomodoroSkipEvent extends PomodoroEvent {}

final class PomodoroSwitchModeEvent extends PomodoroEvent {
  final PomodoroMode mode;

  const PomodoroSwitchModeEvent(this.mode);

  @override
  List<Object?> get props => [mode];
}

final class PomodoroSelectTaskEvent extends PomodoroEvent {
  final Task? task;

  const PomodoroSelectTaskEvent(this.task);

  @override
  List<Object?> get props => [task];
}

final class PomodoroFinishSessionEvent extends PomodoroEvent {}

final class PomodoroSyncSettingsEvent extends PomodoroEvent {}
