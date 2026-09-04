import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focus_flow/features/settings/domin/repositories/settings_repository.dart';

part 'settings_state.dart';

// Cubit
class SettingsCubit extends Cubit<SettingsState> {
  final SettingsRepository _repository;

  SettingsCubit(this._repository)
      : super(
          SettingsState(
            focusDuration: _repository.focusDuration,
            restDuration: _repository.restDuration,
            shortBreak: _repository.shortBreak,
            longBreak: _repository.longBreak,
            soundEnabled: _repository.soundEnabled,
            themeMode: _repository.themeMode,
          ),
        );

  Future<void> updateFocusDuration(int minutes) async {
    await _repository.updateFocusDuration(minutes);
    emit(state.copyWith(focusDuration: minutes));
  }

  Future<void> updateRestDuration(int minutes) async {
    await _repository.updateRestDuration(minutes);
    emit(state.copyWith(restDuration: minutes));
  }

  Future<void> toggleSound(bool enabled) async {
    await _repository.toggleSound(enabled);
    emit(state.copyWith(soundEnabled: enabled));
  }

  Future<void> changeTheme(String mode) async {
    await _repository.changeTheme(mode);
    emit(state.copyWith(themeMode: mode));
  }
}
