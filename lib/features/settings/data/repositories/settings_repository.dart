import 'package:focus_flow/core/services/settings_preferences_service.dart';
import 'package:focus_flow/features/settings/domin/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsPreferencesService _preferencesService;

  SettingsRepositoryImpl(this._preferencesService);

  @override
  int get focusDuration => _preferencesService.focusDuration;

  @override
  int get restDuration => _preferencesService.restDuration;

  @override
  int get shortBreak => _preferencesService.shortBreak;

  @override
  int get longBreak => _preferencesService.longBreak;

  @override
  bool get soundEnabled => _preferencesService.soundEnabled;

  @override
  String get themeMode => _preferencesService.themeMode;

  @override
  Future<void> changeTheme(String newTheme) =>
      _preferencesService.setThemeMode(newTheme);

  @override
  Future<void> toggleSound(bool newValue) =>
      _preferencesService.setSoundEnabled(newValue);

  @override
  Future<void> updateFocusDuration(int newDuration) =>
      _preferencesService.setFocusDuration(newDuration);

  @override
  Future<void> updateRestDuration(int newDuration) =>
      _preferencesService.setRestDuration(newDuration);
}
