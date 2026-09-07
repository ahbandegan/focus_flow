import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focus_flow/core/database/app_database.dart';
import 'package:focus_flow/features/settings/domin/repositories/settings_repository.dart';
import 'package:focus_flow/features/tasks/domain/repositories/task_repository.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final TaskRepository taskRepository;
  final SettingsRepository settingsRepository;

  HomeBloc({
    required this.taskRepository,
    required this.settingsRepository,
  }) : super(HomeInitialState()) {
    on<LoadHomeDataEvent>(_onLoadData);
    on<RefreshHomeDataEvent>(_onLoadData);
  }

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

  Future<void> _onLoadData(
    HomeEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoadingState());
    try {
      final allTasks = await taskRepository.featchAll();
      final now = DateTime.now();

      final todayTasks = allTasks.where((element) {
        if (element.isDeleted) return false;
        final targetDate = element.dueDate ?? element.createdAt;
        return targetDate.year == now.year &&
            targetDate.month == now.month &&
            targetDate.day == now.day;
      }).toList();

      final completedTasks =
          todayTasks.where((element) => element.isCompleted).toList();

      final pomodorosCount = todayTasks.fold<int>(
        0,
        (previousValue, element) =>
            previousValue + element.estimatedPomodoros,
      );

      final pomodorosCompleteCount = todayTasks.fold<int>(
        0,
        (previousValue, element) =>
            previousValue + element.completedPomodoros,
      );

      final focusTime =
          pomodorosCount * settingsRepository.focusDuration;

      emit(
        HomeLoadedState(
          todayTasks: List<Task>.unmodifiable(todayTasks),
          completedTasksCount: completedTasks.length,
          totalTasksCount: todayTasks.length,
          completedPomodorosCount: pomodorosCompleteCount,
          estimatedPomodorosCount: pomodorosCount,
          focusTimeMinutes: focusTime,
          greeting: _getGreeting(),
        ),
      );
    } catch (e) {
      emit(HomeErrorState(message: e.toString()));
    }
  }
}
