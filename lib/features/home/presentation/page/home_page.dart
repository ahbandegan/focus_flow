import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focus_flow/core/database/app_database.dart';
import 'package:focus_flow/core/utils/format_minutes.dart';
import 'package:focus_flow/features/settings/domin/repositories/settings_repository.dart';
import 'package:focus_flow/features/tasks/domain/repositories/task_repository.dart';
import 'package:focus_flow/features/tasks/presentation/bloc/tasks_bloc.dart';
import 'package:focus_flow/initialize_dependensies.dart';
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
    return BlocProvider(
      create: (context) =>
          TasksBloc(di<TaskRepository>())..add(OnLoadTasksEvent()),
      child: BlocBuilder<TasksBloc, TasksState>(
        builder: (context, state) {
          if (state is TasksSuccessState<List<Task>>) {
            final todayTask = state.data
                .where((element) => element.dueDate == DateTime.now())
                .toList();
            final taskComplited = todayTask
                .where((element) => element.isCompleted)
                .toList();
            final pomodorosCount = state.data.fold(
              0,
              (previousValue, element) =>
                  previousValue + element.estimatedPomodoros,
            );
            final pomodorosCompliteCount = state.data.fold(
              0,
              (previousValue, element) =>
                  previousValue + element.completedPomodoros,
            );
            final focusTime =
                pomodorosCount * _settingsRepository.focusDuration;

            return SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  spacing: 3,
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                          icon: Icons.task_alt,
                          color: Colors.greenAccent,
                          iconColor: Colors.green,
                          value: formatMinutes(focusTime),
                          title: "Focus Time",
                        ),
                        const StatCard(
                          icon: Icons.fireplace_sharp,
                          color: Colors.deepPurpleAccent,
                          iconColor: Colors.deepPurple,
                          value: "0",
                          title: "Habit Streak",
                        ),
                      ],
                    ),
                  ],
                ),
              ),
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
      ),
    );
  }
}
