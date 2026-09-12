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
  }) : audioPlayer = audioPlayer ?? AudioPlayer(),
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
    on<PomodoroSyncSettingsEvent>(_onSyncSettings);
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
    if (state.isCompleted) {
      return;
    }
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
    if (state.isCompleted) {
      return;
    }
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      add(PomodoroTickEvent());
    });

    emit(state.copyWith(status: PomodoroStatus.running));
  }

  void _onReset(PomodoroResetEvent event, Emitter<PomodoroState> emit) {
    _timer?.cancel();
    final duration = _getDurationForMode(state.mode);
    final cycles = state.selectedTask != null
        ? state.selectedTask!.completedPomodoros
        : 0;
    final isFinished = state.isTaskFinished;
    final newState = state.copyWith(
      currentSeconds: isFinished ? 0 : duration,
      totalSeconds: duration,
      status: isFinished ? PomodoroStatus.completed : PomodoroStatus.initial,
      completedCycles: cycles,
      selectedTask: state.selectedTask,
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
      emit(state.copyWith(currentSeconds: 0, status: PomodoroStatus.completed));
      add(PomodoroFinishSessionEvent());
    }
  }

  Future<void> _onFinishSession(
    PomodoroFinishSessionEvent event,
    Emitter<PomodoroState> emit,
  ) async {
    final now = DateTime.now();
    final start =
        _sessionStartTime ??
        now.subtract(Duration(seconds: state.totalSeconds));
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

    // 2. Save session to local database
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

    // 3. Handle task progress and auto-completion if a task is attached
    Task? updatedTask = state.selectedTask;
    bool taskJustCompleted = false;

    if (isFocus && state.selectedTask != null) {
      final taskId = state.selectedTask!.id;
      try {
        await taskRepository.incrementCompletedPomodoros(taskId);
        updatedTask = await taskRepository.getTaskById(taskId) ?? state.selectedTask;

        if (updatedTask != null) {
          if (updatedTask.completedPomodoros >= updatedTask.estimatedPomodoros &&
              !updatedTask.isCompleted) {
            await taskRepository.compliteTask(taskId);
            updatedTask = await taskRepository.getTaskById(taskId) ??
                updatedTask.copyWith(isCompleted: true);
            taskJustCompleted = true;
          }
        }
      } catch (_) {}
    }

    // 4. Local notification (tailored based on task status)
    try {
      final String notificationTitle;
      final String notificationBody;

      if (isFocus) {
        if (updatedTask != null) {
          if (taskJustCompleted) {
            notificationTitle = 'Task Completed! 🎉';
            notificationBody =
                'Great job! You finished all pomodoros for "${updatedTask.title}". Time for a well-deserved break.';
          } else {
            notificationTitle = 'Pomodoro Completed!';
            notificationBody =
                'Progress on "${updatedTask.title}": ${updatedTask.completedPomodoros}/${updatedTask.estimatedPomodoros} pomodoros done. Take a break!';
          }
        } else {
          notificationTitle = 'Pomodoro Completed!';
          notificationBody = 'Great job! Time for a well-deserved break.';
        }
      } else {
        if (state.selectedTask != null) {
          notificationTitle = 'Break Over!';
          notificationBody =
              'Break is over. Ready to focus again on "${state.selectedTask!.title}"?';
        } else {
          notificationTitle = 'Break Over!';
          notificationBody = 'Break is over. Ready to focus again?';
        }
      }

      await notificationService.showNotification(
        id: 1,
        title: notificationTitle,
        body: notificationBody,
      );
    } catch (_) {}

    // 5. Transition to next cycle / mode
    final nextCycles = isFocus
        ? (updatedTask?.completedPomodoros ?? (state.completedCycles + 1))
        : (updatedTask?.completedPomodoros ?? state.completedCycles);

    final isTaskFinished = updatedTask != null &&
        (taskJustCompleted ||
            updatedTask.isCompleted ||
            updatedTask.completedPomodoros >= updatedTask.estimatedPomodoros);

    final isAllCyclesFinished = state.selectedTask == null &&
        isFocus &&
        nextCycles >= state.targetCycles;

    if (isTaskFinished || isAllCyclesFinished) {
      _timer?.cancel();
      final effectiveCycles = nextCycles.clamp(0, state.targetCycles);
      final completionMessage = isTaskFinished
          ? "🎉 Task '${updatedTask.title}' completed! (${updatedTask.completedPomodoros}/${updatedTask.estimatedPomodoros} pomodoros)"
          : "🎉 Pomodoro round completed! ($effectiveCycles/${state.targetCycles} pomodoros)";

      final completedState = state.copyWith(
        currentSeconds: 0,
        status: PomodoroStatus.completed,
        completedCycles: effectiveCycles,
        selectedTask: updatedTask,
      );

      emit(
        PomodoroSuccessMessageState(
          message: completionMessage,
          currentSeconds: 0,
          totalSeconds: state.totalSeconds,
          mode: state.mode,
          status: PomodoroStatus.completed,
          completedCycles: effectiveCycles,
          selectedTask: updatedTask,
        ),
      );

      emit(completedState);
      return;
    }

    // 5. Transition to next cycle / mode
    final nextMode = isFocus
        ? (nextCycles % settingsRepository.longBreakInterval == 0
              ? PomodoroMode.longBreak
              : PomodoroMode.shortBreak)
        : PomodoroMode.focus;

    final nextDuration = _getDurationForMode(nextMode);

    final String completionMessage;
    if (isFocus) {
      if (updatedTask != null) {
        completionMessage =
            "Focus session completed for '${updatedTask.title}' (${updatedTask.completedPomodoros}/${updatedTask.estimatedPomodoros})";
      } else {
        completionMessage = "Focus session completed! Great job.";
      }
    } else {
      if (state.selectedTask != null) {
        completionMessage =
            "Break session completed! Ready to focus on '${state.selectedTask!.title}'.";
      } else {
        completionMessage = "Break session completed! Ready to focus.";
      }
    }

    emit(
      PomodoroSuccessMessageState(
        message: completionMessage,
        currentSeconds: nextDuration,
        totalSeconds: nextDuration,
        mode: nextMode,
        status: PomodoroStatus.initial,
        completedCycles: nextCycles,
        selectedTask: updatedTask,
      ),
    );

    emit(
      state.copyWith(
        currentSeconds: nextDuration,
        totalSeconds: nextDuration,
        mode: nextMode,
        status: PomodoroStatus.initial,
        completedCycles: nextCycles,
        selectedTask: updatedTask,
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

  Future<void> _onSkip(
    PomodoroSkipEvent event,
    Emitter<PomodoroState> emit,
  ) async {
    _timer?.cancel();

    if (state.isCompleted) {
      emit(
        PomodoroSuccessMessageState(
          message: state.selectedTask != null
              ? "Task '${state.selectedTask!.title}' is already completed!"
              : "Pomodoro session is completed!",
          currentSeconds: 0,
          totalSeconds: state.totalSeconds,
          mode: state.mode,
          status: PomodoroStatus.completed,
          completedCycles: state.completedCycles,
          selectedTask: state.selectedTask,
        ),
      );
      return;
    }

    final isFocus = state.mode == PomodoroMode.focus;

    Task? updatedTask = state.selectedTask;
    bool taskJustCompleted = false;

    if (isFocus && state.selectedTask != null) {
      final taskId = state.selectedTask!.id;
      try {
        await taskRepository.incrementCompletedPomodoros(taskId);
        updatedTask = await taskRepository.getTaskById(taskId) ?? state.selectedTask;

        if (updatedTask != null) {
          if (updatedTask.completedPomodoros >= updatedTask.estimatedPomodoros &&
              !updatedTask.isCompleted) {
            await taskRepository.compliteTask(taskId);
            updatedTask = await taskRepository.getTaskById(taskId) ??
                updatedTask.copyWith(isCompleted: true);
            taskJustCompleted = true;
          }
        }
      } catch (_) {}
    }

    final nextCycles = isFocus
        ? (updatedTask?.completedPomodoros ?? (state.completedCycles + 1))
        : (updatedTask?.completedPomodoros ?? state.completedCycles);

    final isTaskFinished = updatedTask != null &&
        (taskJustCompleted ||
            updatedTask.isCompleted ||
            updatedTask.completedPomodoros >= updatedTask.estimatedPomodoros);

    final isAllCyclesFinished = state.selectedTask == null &&
        isFocus &&
        nextCycles >= state.targetCycles;

    if (isTaskFinished || isAllCyclesFinished) {
      final effectiveCycles = nextCycles.clamp(0, state.targetCycles);
      final completedState = state.copyWith(
        currentSeconds: 0,
        status: PomodoroStatus.completed,
        completedCycles: effectiveCycles,
        selectedTask: updatedTask,
      );

      final message = isTaskFinished
          ? "Focus session skipped. 🎉 Task '${updatedTask.title}' completed! (${updatedTask.completedPomodoros}/${updatedTask.estimatedPomodoros} pomodoros)"
          : "Focus session skipped. 🎉 Pomodoro round completed! ($effectiveCycles/${state.targetCycles} pomodoros)";

      emit(
        PomodoroSuccessMessageState(
          message: message,
          currentSeconds: 0,
          totalSeconds: state.totalSeconds,
          mode: state.mode,
          status: PomodoroStatus.completed,
          completedCycles: effectiveCycles,
          selectedTask: updatedTask,
        ),
      );
      emit(completedState);
      return;
    }

    final nextMode = isFocus
        ? (nextCycles % settingsRepository.longBreakInterval == 0
              ? PomodoroMode.longBreak
              : PomodoroMode.shortBreak)
        : PomodoroMode.focus;

    final nextDuration = _getDurationForMode(nextMode);

    final String message;
    if (isFocus) {
      if (updatedTask != null) {
        message = "Focus session skipped (${updatedTask.completedPomodoros}/${updatedTask.estimatedPomodoros})";
      } else {
        message = "Focus session skipped";
      }
    } else {
      message = "Break skipped. Ready to focus.";
    }

    final newState = state.copyWith(
      currentSeconds: nextDuration,
      totalSeconds: nextDuration,
      mode: nextMode,
      status: PomodoroStatus.initial,
      completedCycles: nextCycles,
      selectedTask: updatedTask,
    );
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
      selectedTask: state.selectedTask,
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

  Future<void> _onSelectTask(
    PomodoroSelectTaskEvent event,
    Emitter<PomodoroState> emit,
  ) async {
    Task? task = event.task;
    if (task != null) {
      try {
        final fetched = await taskRepository.getTaskById(task.id);
        if (fetched != null) {
          task = fetched;
        }
      } catch (_) {}
    }

    final isTaskAlreadyFinished = task != null &&
        (task.isCompleted || task.completedPomodoros >= task.estimatedPomodoros);

    final mode = (task != null && state.status == PomodoroStatus.initial)
        ? PomodoroMode.focus
        : state.mode;
    final duration = _getDurationForMode(mode);

    final status = isTaskAlreadyFinished
        ? PomodoroStatus.completed
        : (event.task == null ? PomodoroStatus.initial : state.status);

    final newState = state.copyWith(
      currentSeconds: isTaskAlreadyFinished
          ? 0
          : (state.status == PomodoroStatus.initial ? duration : state.currentSeconds),
      totalSeconds: state.status == PomodoroStatus.initial ? duration : state.totalSeconds,
      mode: mode,
      status: status,
      selectedTask: task,
      clearSelectedTask: task == null,
      completedCycles: task != null ? task.completedPomodoros : (event.task == null ? 0 : state.completedCycles),
    );
    final message = task != null
        ? "Task '${task.title}' linked to session"
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

  void _onSyncSettings(
    PomodoroSyncSettingsEvent event,
    Emitter<PomodoroState> emit,
  ) {
    if (state.status == PomodoroStatus.initial && !state.isCompleted) {
      final newDuration = _getDurationForMode(state.mode);
      emit(
        state.copyWith(
          currentSeconds: newDuration,
          totalSeconds: newDuration,
        ),
      );
    }
  }
}
