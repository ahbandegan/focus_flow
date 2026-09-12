part of 'pomodoro_bloc.dart';

enum PomodoroMode { focus, shortBreak, longBreak }

enum PomodoroStatus { initial, running, paused, completed }

class PomodoroState extends Equatable {
  final int currentSeconds;
  final int totalSeconds;
  final PomodoroMode mode;
  final PomodoroStatus status;
  final int completedCycles;
  final Task? selectedTask;

  const PomodoroState({
    required this.currentSeconds,
    required this.totalSeconds,
    required this.mode,
    required this.status,
    required this.completedCycles,
    this.selectedTask,
  });

  bool get isRunning => status == PomodoroStatus.running;
  bool get isPaused => status == PomodoroStatus.paused;
  bool get isAllCyclesFinished =>
      selectedTask == null &&
      completedCycles >= targetCycles &&
      completedCycles > 0;
  bool get isCompleted =>
      status == PomodoroStatus.completed ||
      isTaskFinished ||
      isAllCyclesFinished;

  double get progress {
    if (isCompleted) return 1.0;
    if (totalSeconds <= 0) return 0.0;
    return (totalSeconds - currentSeconds) / totalSeconds;
  }

  String get formattedTime {
    if (isCompleted) return '00:00';
    final minutes = (currentSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (currentSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  int get targetCycles => selectedTask?.estimatedPomodoros ?? 4;

  bool get isTaskFinished =>
      selectedTask != null &&
      (selectedTask!.isCompleted ||
          selectedTask!.completedPomodoros >= selectedTask!.estimatedPomodoros);

  bool get canStart => !isCompleted;
  bool get canSkip => !isCompleted;

  PomodoroState copyWith({
    int? currentSeconds,
    int? totalSeconds,
    PomodoroMode? mode,
    PomodoroStatus? status,
    int? completedCycles,
    Task? selectedTask,
    bool clearSelectedTask = false,
  }) {
    return PomodoroState(
      currentSeconds: currentSeconds ?? this.currentSeconds,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      mode: mode ?? this.mode,
      status: status ?? this.status,
      completedCycles: completedCycles ?? this.completedCycles,
      selectedTask: clearSelectedTask
          ? null
          : (selectedTask ?? this.selectedTask),
    );
  }

  @override
  List<Object?> get props => [
        currentSeconds,
        totalSeconds,
        mode,
        status,
        completedCycles,
        selectedTask,
      ];
}

final class PomodoroSuccessMessageState extends PomodoroState {
  final String message;
  String get data => message;

  const PomodoroSuccessMessageState({
    required this.message,
    required super.currentSeconds,
    required super.totalSeconds,
    required super.mode,
    required super.status,
    required super.completedCycles,
    super.selectedTask,
  });

  @override
  List<Object?> get props => [...super.props, message];
}

