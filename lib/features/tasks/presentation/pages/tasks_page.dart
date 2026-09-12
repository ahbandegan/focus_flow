import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focus_flow/core/database/app_database.dart';
import 'package:focus_flow/core/utils/show_snackbar.dart';
import 'package:focus_flow/features/home/presentation/widget/task_card.dart';
import 'package:focus_flow/features/settings/domin/repositories/settings_repository.dart';
import 'package:focus_flow/features/tasks/presentation/bloc/tasks_bloc.dart';

class TasksPage extends StatefulWidget {
  final AudioPlayer player = AudioPlayer();
  final SettingsRepository _settingsRepository;
  final void Function(Task?) onPomodoroNav;

  TasksPage({
    super.key,
    required this._settingsRepository,
    required this.onPomodoroNav,
  });

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  final filters = ["All Status", "Pending", "Complited"];
  String? selectedValue;

  @override
  void initState() {
    super.initState();
    selectedValue = filters[0];
    context.read<TasksBloc>().add(const OnLoadTasksEvent(silent: true));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isDesktop = size.width >= 600;

    return BlocConsumer<TasksBloc, TasksState>(
      buildWhen: (previous, current) => current is! TasksSuccessMessageState,
      builder: (context, state) {
        if (state is TasksSuccessState) {
          final tasks = state.data.where((element) {
            if (element.isDeleted) return false;
            return switch (selectedValue) {
              "Complited" => element.isCompleted,
              "Pending" => !element.isCompleted,
              _ => true,
            };
          }).toList();

          return ListView(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 30.0 : 16.0,
              vertical: isDesktop ? 30.0 : 20.0,
            ),
            physics: const BouncingScrollPhysics(),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "All Tasks (${tasks.length})",
                      style: TextStyle(
                        fontSize: isDesktop ? 30 : 22,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  DropdownMenu<String>(
                    onSelected: (value) => setState(() {
                      selectedValue = value;
                    }),
                    initialSelection: selectedValue,
                    width: isDesktop ? 180 : 135,
                    textStyle: TextStyle(
                      fontSize: isDesktop ? 14 : 13,
                    ),
                    requestFocusOnTap: false,
                    dropdownMenuEntries: [
                      for (String item in filters)
                        DropdownMenuEntry(value: item, label: item),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (tasks.isEmpty)
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
                              "Not have tasks!",
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
                ...tasks.map(
                  (e) => Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                    child: TaskCard(
                      key: ValueKey(e.id),
                      task: e,
                      onCheck: (value) {
                        context.read<TasksBloc>().add(
                          OnUpdateTaskEvent(
                            task: e.copyWith(isCompleted: value),
                          ),
                        );
                      },
                      onStart: () {
                        widget.onPomodoroNav(e);
                      },
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

        return Center(child: CircularProgressIndicator());
      },
      listener: (BuildContext context, TasksState state) {
        if (state is TasksSuccessMessageState) {
          if (widget._settingsRepository.soundEnabled) {
            widget.player.play(AssetSource('audio/success.mp3'));
          }
          showSnackbar(context: context, msg: state.data, isError: false);
        }

        if (state is TasksErrorState) {
          if (widget._settingsRepository.soundEnabled) {
            widget.player.play(AssetSource('audio/error.mp3'));
          }
          showSnackbar(
            context: context,
            msg: "err: ${state.error}",
            isError: true,
          );
        }
      },
    );
  }
}
