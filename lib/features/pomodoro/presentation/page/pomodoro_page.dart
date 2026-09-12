import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focus_flow/core/database/app_database.dart';
import 'package:focus_flow/core/utils/show_snackbar.dart';
import 'package:focus_flow/features/pomodoro/presentation/bloc/pomodoro_bloc.dart';
import 'package:focus_flow/features/settings/domin/repositories/settings_repository.dart';

class PomodoroPage extends StatefulWidget {
  final SettingsRepository _settingsRepository;
  final Task? task;
  final void Function() unLinckTask;

  const PomodoroPage({
    super.key,
    required this._settingsRepository,
    this.task,
    required this.unLinckTask,
  });

  @override
  State<PomodoroPage> createState() => _PomodoroPageState();
}

class _PomodoroPageState extends State<PomodoroPage> {
  @override
  void initState() {
    super.initState();
    if (widget.task != null){
      context.read<PomodoroBloc>().add(PomodoroSelectTaskEvent(widget.task));
    }
  }

  @override
  void didUpdateWidget(covariant PomodoroPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.task?.id != oldWidget.task?.id) {
      context.read<PomodoroBloc>().add(PomodoroSelectTaskEvent(widget.task));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    final isDesktop = size.width >= 600;
    final bloc = context.read<PomodoroBloc>();

    return BlocConsumer<PomodoroBloc, PomodoroState>(
      listener: (BuildContext context, PomodoroState state) {
        if (state is PomodoroSuccessMessageState) {
          if (widget._settingsRepository.soundEnabled) {
            bloc.audioPlayer.play(AssetSource('audio/success.mp3'));
          }
          showSnackbar(context: context, msg: state.data, isError: false);
        }
      },
      builder: (context, state) {
        return Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 24.0 : 16.0,
              vertical: isDesktop ? 24.0 : 16.0,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 550),
              child: Container(
                width: isDesktop ? size.width * 0.6 : double.infinity,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: theme.colorScheme.surfaceBright,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                      color: Colors.black.withValues(alpha: 0.08),
                    ),
                  ],
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final contentWidth = constraints.maxWidth;
                    final progressSize =
                        (contentWidth * 0.68).clamp(200.0, 260.0);
                    final titleSize = (contentWidth * 0.06).clamp(18.0, 26.0);

                    return Padding(
                      padding: EdgeInsets.all(isDesktop ? 28.0 : 20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            state.mode == PomodoroMode.shortBreak
                                ? "Short Break"
                                : (state.mode == PomodoroMode.longBreak
                                      ? "Long Break"
                                      : 'Focus Session'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: state.mode == PomodoroMode.focus
                                  ? Colors.red
                                  : Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: titleSize,
                            ),
                          ),
                          if (state.selectedTask != null) ...[
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer
                                    .withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: theme.colorScheme.primary.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    state.isTaskFinished
                                        ? Icons.check_circle
                                        : Icons.task_alt,
                                    size: 16,
                                    color: theme.colorScheme.primary,
                                  ),
                                  const SizedBox(width: 6),
                                  ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxWidth: (contentWidth * 0.6)
                                          .clamp(140.0, 260.0),
                                    ),
                                    child: Text(
                                      state.selectedTask!.title,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: theme.colorScheme.primary,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  InkWell(
                                    onTap: () {
                                      widget.unLinckTask();
                                      context.read<PomodoroBloc>().add(
                                        const PomodoroSelectTaskEvent(null),
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(12),
                                    child: Padding(
                                      padding: const EdgeInsets.all(2),
                                      child: Icon(
                                        Icons.close,
                                        size: 14,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          SizedBox(height: isDesktop ? 28 : 20),

                          Center(
                            child: SizedBox(
                              width: progressSize,
                              height: progressSize,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox.expand(
                                    child: CircularProgressIndicator(
                                      value: 1,
                                      strokeWidth: 10,
                                      color: theme
                                          .colorScheme
                                          .surfaceContainerHighest,
                                    ),
                                  ),

                                  SizedBox.expand(
                                    child: CircularProgressIndicator(
                                      value: state.progress,
                                      strokeWidth: 10,
                                      strokeCap: StrokeCap.round,
                                      color: state.isCompleted
                                          ? Colors.green
                                          : (state.mode ==
                                                  PomodoroMode.shortBreak
                                              ? Colors.green
                                              : Colors.red),
                                    ),
                                  ),

                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        state.formattedTime,
                                        style: TextStyle(
                                          fontSize: progressSize * 0.22,
                                          fontWeight: FontWeight.w300,
                                          letterSpacing: -1,
                                        ),
                                      ),
                                      if (state.isCompleted) ...[
                                        const SizedBox(height: 6),
                                        Container(
                                          padding:
                                              const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.green
                                                .withValues(alpha: 0.15),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.check_circle,
                                                size: 14,
                                                color: Colors.green,
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                "Completed",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight:
                                                      FontWeight.bold,
                                                  color: Colors.green,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(height: isDesktop ? 28 : 20),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                onPressed: () {
                                  context.read<PomodoroBloc>().add(
                                    PomodoroResetEvent(),
                                  );
                                },
                                icon: const Icon(Icons.refresh),
                              ),

                              const SizedBox(width: 16),

                              SizedBox(
                                width: 64,
                                height: 64,
                                child: FloatingActionButton(
                                  onPressed: state.isCompleted
                                      ? null
                                      : () {
                                          if (state.status ==
                                              PomodoroStatus.initial) {
                                            context.read<PomodoroBloc>().add(
                                              PomodoroStartEvent(),
                                            );
                                          } else if (state.status ==
                                              PomodoroStatus.paused) {
                                            context.read<PomodoroBloc>().add(
                                              PomodoroResumeEvent(),
                                            );
                                          } else if (state.status ==
                                              PomodoroStatus.running) {
                                            context.read<PomodoroBloc>().add(
                                              PomodoroPauseEvent(),
                                            );
                                          }
                                        },
                                  elevation: state.isCompleted ? 0 : 4,
                                  backgroundColor: state.isCompleted
                                      ? theme.colorScheme
                                          .surfaceContainerHighest
                                      : (state.mode == PomodoroMode.shortBreak
                                          ? Colors.green
                                          : Colors.red),
                                  child: Icon(
                                    state.isCompleted
                                        ? Icons.check
                                        : (state.status ==
                                                PomodoroStatus.running
                                            ? Icons.pause
                                            : Icons.play_arrow),
                                    size: 32,
                                    color: state.isCompleted
                                        ? theme.colorScheme.outline
                                        : Colors.white,
                                  ),
                                ),
                              ),

                              const SizedBox(width: 16),

                              IconButton(
                                onPressed: state.canSkip
                                    ? () {
                                        context.read<PomodoroBloc>().add(
                                          PomodoroSkipEvent(),
                                        );
                                      }
                                    : null,
                                icon: const Icon(Icons.skip_next),
                              ),
                            ],
                          ),

                          SizedBox(height: isDesktop ? 24 : 18),

                          Builder(
                            builder: (context) {
                              final isDone = state.isCompleted;
                              final total = state.targetCycles;
                              final completed = (state.selectedTask != null
                                      ? state.selectedTask!.completedPomodoros
                                      : state.completedCycles)
                                  .clamp(0, total);
                              final remaining = (total - completed).clamp(
                                0,
                                total,
                              );

                              return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  for (int i = 0; i < completed; i++)
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isDone
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ),
                                  for (int i = 0; i < remaining; i++)
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: theme
                                            .colorScheme
                                            .surfaceContainerHighest,
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
