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
            isLoggedIn: _repository.isLoggedIn,
            userEmail: _repository.userEmail,
          ),
        );

  void _emitWithSuccessMessage(SettingsState newState, String message) {
    emit(
      SettingsSuccessMessageState(
        message: message,
        focusDuration: newState.focusDuration,
        restDuration: newState.restDuration,
        shortBreak: newState.shortBreak,
        longBreak: newState.longBreak,
        soundEnabled: newState.soundEnabled,
        themeMode: newState.themeMode,
        isLoggedIn: newState.isLoggedIn,
        userEmail: newState.userEmail,
      ),
    );
    emit(newState);
  }

  Future<void> updateFocusDuration(int minutes) async {
    await _repository.updateFocusDuration(minutes);
    _emitWithSuccessMessage(
      state.copyWith(focusDuration: minutes),
      "Focus duration updated to $minutes minutes",
    );
  }

  Future<void> updateRestDuration(int minutes) async {
    await _repository.updateRestDuration(minutes);
    _emitWithSuccessMessage(
      state.copyWith(restDuration: minutes, shortBreak: minutes),
      "Rest duration updated to $minutes minutes",
    );
  }

  Future<void> toggleSound(bool enabled) async {
    await _repository.toggleSound(enabled);
    _emitWithSuccessMessage(
      state.copyWith(soundEnabled: enabled),
      enabled ? "Sound effects enabled" : "Sound effects disabled",
    );
  }

  Future<void> changeTheme(String mode) async {
    await _repository.changeTheme(mode);
    final label = mode.isNotEmpty ? mode[0].toUpperCase() + mode.substring(1) : mode;
    _emitWithSuccessMessage(
      state.copyWith(themeMode: mode),
      "Theme updated to $label",
    );
  }

  Future<void> updateLoginSession({
    required String email,
    String? name,
    String? id,
  }) async {
    await _repository.saveUserSession(email: email, name: name, id: id);
    _emitWithSuccessMessage(
      state.copyWith(isLoggedIn: true, userEmail: email),
      "Logged in successfully",
    );
  }

  Future<void> logout() async {
    await _repository.logout();
    _emitWithSuccessMessage(
      state.copyWith(isLoggedIn: false, userEmail: null),
      "Logged out successfully",
    );
  }
}
