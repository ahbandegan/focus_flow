import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:drift/drift.dart' as drift;
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focus_flow/core/database/app_database.dart';
import 'package:focus_flow/core/services/notification_service.dart';
import 'package:focus_flow/features/pomodoro/domain/repositories/pomodoro_repository.dart';
import 'package:focus_flow/features/settings/domin/repositories/settings_repository.dart';
import 'package:focus_flow/features/tasks/domain/repositories/task_repository.dart';

part 'pomodoro_event.dart';
part 'pomodoro_state.dart';

class PomodoroBloc extends Bloc<PomodoroEvent, PomodoroState> {
  final PomodoroRepository pomodoroRepository;
  final TaskRepository taskRepository;
  final SettingsRepository settingsRepository;
  final NotificationService notificationService;
  final AudioPlayer audioPlayer;

  Timer? _timer;
  DateTime? _sessionStartTime;

  PomodoroBloc({
    required this.pomodoroRepository,
    required this.taskRepository,
    required this.settingsRepository,
    required this.notificationService,
    AudioPlayer? audioPlayer,
  })  : audioPlayer = audioPlayer ?? AudioPlayer(),
        super(
          PomodoroState(
            currentSeconds: settingsRepository.focusDuration * 60,
            totalSeconds: settingsRepository.focusDuration * 60,
            mode: PomodoroMode.focus,
            status: PomodoroStatus.initial,
            completedCycles: 0,
          ),
        ) {
    on<PomodoroStartEvent>(_onStart);
    on<PomodoroPauseEvent>(_onPause);
    on<PomodoroResumeEvent>(_onResume);
    on<PomodoroResetEvent>(_onReset);
    on<PomodoroTickEvent>(_onTick);
    on<PomodoroSkipEvent>(_onSkip);
    on<PomodoroSwitchModeEvent>(_onSwitchMode);
    on<PomodoroSelectTaskEvent>(_onSelectTask);
    on<PomodoroFinishSessionEvent>(_onFinishSession);
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    audioPlayer.dispose();
    return super.close();
  }

  int _getDurationForMode(PomodoroMode mode) {
    switch (mode) {
      case PomodoroMode.focus:
        return settingsRepository.focusDuration * 60;
      case PomodoroMode.shortBreak:
        return settingsRepository.shortBreak * 60;
      case PomodoroMode.longBreak:
        return settingsRepository.longBreak * 60;
    }
  }

  void _onStart(PomodoroStartEvent event, Emitter<PomodoroState> emit) {
    _timer?.cancel();
    _sessionStartTime = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      add(PomodoroTickEvent());
    });

    emit(state.copyWith(status: PomodoroStatus.running));
  }

  void _onPause(PomodoroPauseEvent event, Emitter<PomodoroState> emit) {
    _timer?.cancel();
    emit(state.copyWith(status: PomodoroStatus.paused));
  }

  void _onResume(PomodoroResumeEvent event, Emitter<PomodoroState> emit) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      add(PomodoroTickEvent());
    });

    emit(state.copyWith(status: PomodoroStatus.running));
  }

  void _onReset(PomodoroResetEvent event, Emitter<PomodoroState> emit) {
    _timer?.cancel();
    final duration = _getDurationForMode(state.mode);
    final newState = state.copyWith(
      currentSeconds: duration,
      totalSeconds: duration,
      status: PomodoroStatus.initial,
    );
    emit(
      PomodoroSuccessMessageState(
        message: "Timer reset successfully",
        currentSeconds: newState.currentSeconds,
        totalSeconds: newState.totalSeconds,
        mode: newState.mode,
        status: newState.status,
        completedCycles: newState.completedCycles,
        selectedTask: newState.selectedTask,
      ),
    );
    emit(newState);
  }

  Future<void> _onTick(
    PomodoroTickEvent event,
    Emitter<PomodoroState> emit,
  ) async {
    if (state.currentSeconds > 1) {
      emit(state.copyWith(currentSeconds: state.currentSeconds - 1));
    } else {
      _timer?.cancel();
      emit(
        state.copyWith(
          currentSeconds: 0,
          status: PomodoroStatus.completed,
        ),
      );
      add(PomodoroFinishSessionEvent());
    }
  }

  Future<void> _onFinishSession(
    PomodoroFinishSessionEvent event,
    Emitter<PomodoroState> emit,
  ) async {
    final now = DateTime.now();
    final start = _sessionStartTime ?? now.subtract(Duration(seconds: state.totalSeconds));
    final durationSeconds = state.totalSeconds;
    final isFocus = state.mode == PomodoroMode.focus;

    // 1. Play sound notification if enabled
    if (settingsRepository.soundEnabled) {
      try {
        final sound = settingsRepository.soundName;
        await audioPlayer.stop();
        await audioPlayer.play(AssetSource('audio/$sound.mp3'));
      } catch (_) {}
    }

    // 2. Local notification
    try {
      await notificationService.showNotification(
        id: 1,
        title: isFocus ? 'Pomodoro Completed!' : 'Break Over!',
        body: isFocus
            ? 'Great job! Time for a well-deserved break.'
            : 'Break is over. Ready to focus again?',
      );
    } catch (_) {}

    // 3. Save session to local database
    final sessionCompanion = PomodoroSessionsCompanion.insert(
      taskId: drift.Value(state.selectedTask?.id),
      sessionType: state.mode.name,
      targetDurationMinutes: drift.Value(state.totalSeconds ~/ 60),
      actualDurationSeconds: drift.Value(durationSeconds),
      startTime: start,
      endTime: drift.Value(now),
      isCompleted: const drift.Value(true),
    );

    await pomodoroRepository.insertSession(sessionCompanion);

    // 4. Increment task completed pomodoros if a task was attached
    if (isFocus && state.selectedTask != null) {
      try {
        await taskRepository.incrementCompletedPomodoros(state.selectedTask!.id);
      } catch (_) {}
    }

    // 6. Transition to next cycle / mode
    final nextCycles = isFocus ? state.completedCycles + 1 : state.completedCycles;
    final nextMode = isFocus
        ? (nextCycles % settingsRepository.longBreakInterval == 0
            ? PomodoroMode.longBreak
            : PomodoroMode.shortBreak)
        : PomodoroMode.focus;

    final nextDuration = _getDurationForMode(nextMode);

    final completionMessage = isFocus
        ? "Focus session completed! Great job."
        : "Break session completed! Ready to focus.";

    emit(
      PomodoroSuccessMessageState(
        message: completionMessage,
        currentSeconds: nextDuration,
        totalSeconds: nextDuration,
        mode: nextMode,
        status: PomodoroStatus.initial,
        completedCycles: nextCycles,
        selectedTask: state.selectedTask,
      ),
    );

    emit(
      state.copyWith(
        currentSeconds: nextDuration,
        totalSeconds: nextDuration,
        mode: nextMode,
        status: PomodoroStatus.initial,
        completedCycles: nextCycles,
      ),
    );

    // Auto-start if configured
    final shouldAutoStart = isFocus
        ? settingsRepository.autoStartBreaks
        : settingsRepository.autoStartPomodoros;

    if (shouldAutoStart) {
      add(PomodoroStartEvent());
    }
  }

  void _onSkip(PomodoroSkipEvent event, Emitter<PomodoroState> emit) {
    _timer?.cancel();
    final isFocus = state.mode == PomodoroMode.focus;
    final nextMode = isFocus ? PomodoroMode.shortBreak : PomodoroMode.focus;
    final nextDuration = _getDurationForMode(nextMode);

    final newState = state.copyWith(
      currentSeconds: nextDuration,
      totalSeconds: nextDuration,
      mode: nextMode,
      status: PomodoroStatus.initial,
    );
    emit(
      PomodoroSuccessMessageState(
        message: "Session skipped successfully",
        currentSeconds: newState.currentSeconds,
        totalSeconds: newState.totalSeconds,
        mode: newState.mode,
        status: newState.status,
        completedCycles: newState.completedCycles,
        selectedTask: newState.selectedTask,
      ),
    );
    emit(newState);
  }

  void _onSwitchMode(
    PomodoroSwitchModeEvent event,
    Emitter<PomodoroState> emit,
  ) {
    _timer?.cancel();
    final duration = _getDurationForMode(event.mode);
    final modeLabel = switch (event.mode) {
      PomodoroMode.focus => "Focus",
      PomodoroMode.shortBreak => "Short Break",
      PomodoroMode.longBreak => "Long Break",
    };
    final newState = state.copyWith(
      currentSeconds: duration,
      totalSeconds: duration,
      mode: event.mode,
      status: PomodoroStatus.initial,
    );
    emit(
      PomodoroSuccessMessageState(
        message: "Switched to $modeLabel mode",
        currentSeconds: newState.currentSeconds,
        totalSeconds: newState.totalSeconds,
        mode: newState.mode,
        status: newState.status,
        completedCycles: newState.completedCycles,
        selectedTask: newState.selectedTask,
      ),
    );
    emit(newState);
  }

  void _onSelectTask(
    PomodoroSelectTaskEvent event,
    Emitter<PomodoroState> emit,
  ) {
    final newState = state.copyWith(
      selectedTask: event.task,
      clearSelectedTask: event.task == null,
    );
    final message = event.task != null
        ? "Task '${event.task!.title}' linked to session"
        : "Task unlinked from session";
    emit(
      PomodoroSuccessMessageState(
        message: message,
        currentSeconds: newState.currentSeconds,
        totalSeconds: newState.totalSeconds,
        mode: newState.mode,
        status: newState.status,
        completedCycles: newState.completedCycles,
        selectedTask: newState.selectedTask,
      ),
    );
    emit(newState);
  }
}
