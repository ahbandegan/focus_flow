import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focus_flow/core/database/app_database.dart';
import 'package:focus_flow/features/tasks/domain/repositories/task_repository.dart';
import 'package:focus_flow/features/tasks/presentation/bloc/tasks_bloc.dart';
import 'package:focus_flow/initialize_dependensies.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final AudioPlayer player = AudioPlayer();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          TasksBloc(di<TaskRepository>())..add(OnLoadTasksEvent()),
      child: BlocBuilder<TasksBloc, TasksState>(
        builder: (context, state) {
          if (state is TasksSuccessState<List<Task>>) {
            return Column(
              children: [
                /* TODO Parse date to wakeday, month day */
                Text("Today : "),
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
      ),
    );
  }
}
