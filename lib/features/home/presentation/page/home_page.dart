import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focus_flow/core/utils/format_minutes.dart';
import 'package:focus_flow/features/home/presentation/bloc/home_bloc.dart';
import 'package:focus_flow/features/home/presentation/widget/task_card.dart';
import 'package:focus_flow/features/settings/domin/repositories/settings_repository.dart';
import 'package:focus_flow/features/tasks/presentation/bloc/tasks_bloc.dart';
import 'package:intl/intl.dart';

import '../widget/stat_card.dart';

class HomePage extends StatelessWidget {
  final AudioPlayer player = AudioPlayer();
  final SettingsRepository _settingsRepository;

  HomePage({super.key, required this._settingsRepository});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return "Good Morning";
    } else if (hour >= 12 && hour < 20) {
      return "Good Evening";
    } else {
      return "Good Night";
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TasksBloc, TasksState>(
      builder: (context, state) {
        if (state is TasksSuccessState) {
          final now = DateTime.now();
          final todayTask = state.data.where((element) {
            if (element.isDeleted) return false;
            final targetDate = element.dueDate ?? element.createdAt;
            return targetDate.year == now.year &&
                targetDate.month == now.month &&
                targetDate.day == now.day;
          }).toList();
          final taskComplited = todayTask
              .where((element) => element.isCompleted)
              .toList();
          final pomodorosCount = todayTask
              .where((e) => !e.isDeleted)
              .fold(
                0,
                (previousValue, element) =>
                    previousValue + element.estimatedPomodoros,
              );
          final pomodorosCompliteCount = todayTask
              .where((e) => !e.isDeleted)
              .fold(
                0,
                (previousValue, element) =>
                    previousValue + element.completedPomodoros,
              );
          final focusTime = pomodorosCount * _settingsRepository.focusDuration;

          return ListView(
            padding: const EdgeInsets.all(30.0),
            physics: BouncingScrollPhysics(),
            scrollDirection: Axis.vertical,
            children: [
              Text(
                DateFormat('EEEE, MMMM d').format(DateTime.now()),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.outline,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                _getGreeting(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
              ),
              SizedBox(height: 20),

              GridView.extent(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                maxCrossAxisExtent: 250,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                mainAxisExtent: 130,
                children: [
                  StatCard(
                    icon: Icons.task_alt,
                    color: Colors.blueAccent,
                    value: "${taskComplited.length}/${todayTask.length}",
                    title: "Tasks Completed",
                  ),
                  StatCard(
                    icon: Icons.timer,
                    color: Colors.redAccent,
                    iconColor: Colors.red,
                    value: "$pomodorosCompliteCount/$pomodorosCount",
                    title: "Pomodoros",
                  ),
                  StatCard(
                    icon: Icons.timer,
                    color: Colors.greenAccent,
                    iconColor: Colors.green,
                    value: formatMinutes(focusTime),
                    title: "Focus Time",
                  ),
                ],
              ),

              SizedBox(height: 30),

              Text(
                "Today's Tasks",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 10),
              if (todayTask.isEmpty)
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: BoxBorder.all(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(25.0),
                            child: Text(
                              "No tasks for today!",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.outline,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              else
                ...todayTask.map(
                  (e) => Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                    child: TaskCard(
                      task: e,
                      onCheck: (value) {
                        context.read<TasksBloc>().add(
                          OnUpdateTaskEvent(
                            task: e.copyWith(isCompleted: value),
                          ),
                        );
                      },
                      onStart: (id) {},
                      onDelete: (id) {
                        context.read<TasksBloc>().add(
                          OnDeleteTaskEvent(id: id),
                        );
                      },
                    ),
                  ),
                ),
              SizedBox(height: 10),
            ],
          );
        }
        if (state is TasksErrorState) {
          return Center(
            child: Text(
              state.error.toString(),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          );
        }

        return Center(child: CircularProgressIndicator());
      },
    );
  }
}
