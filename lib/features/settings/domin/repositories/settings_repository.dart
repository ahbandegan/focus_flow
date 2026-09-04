abstract class SettingsRepository {
  int get focusDuration;
  int get restDuration;
  int get shortBreak;
  int get longBreak;
  bool get soundEnabled;
  String get themeMode;

  Future<void> changeTheme(String newTheme);
  Future<void> toggleSound(bool newValue);
  Future<void> updateFocusDuration(int newDuration);
  Future<void> updateRestDuration(int newDuration);
}