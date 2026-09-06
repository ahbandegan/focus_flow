import 'package:shared_preferences/shared_preferences.dart';

abstract class AppPrefKeys {
  static const String focusDuration = 'prefs_focus_duration';
  static const String restDuration = 'prefs_rest_duration';
  static const String shortBreak = 'prefs_short_break';
  static const String longBreak = 'prefs_long_break';
  static const String longBreakInterval = 'prefs_long_break_interval';
  static const String autoStartBreaks = 'prefs_auto_start_breaks';
  static const String autoStartPomodoros = 'prefs_auto_start_pomodoros';
  static const String soundEnabled = 'prefs_sound_enabled';
  static const String soundName = 'prefs_sound_name';
  static const String notificationsEnabled = 'prefs_notifications_enabled';
  static const String themeMode = 'prefs_theme_mode';
  static const String dailyTarget = 'prefs_daily_target';
  static const String isLoggedIn = 'prefs_is_logged_in';
  static const String userEmail = 'prefs_user_email';
  static const String userName = 'prefs_user_name';
  static const String userId = 'prefs_user_id';
}

class SettingsPreferencesService {
  final SharedPreferences _prefs;

  SettingsPreferencesService(this._prefs);

  // Focus duration (minutes)
  int get focusDuration => _prefs.getInt(AppPrefKeys.focusDuration) ?? 25;
  Future<bool> setFocusDuration(int minutes) =>
      _prefs.setInt(AppPrefKeys.focusDuration, minutes);

  // Rest duration (minutes)
  int get restDuration => _prefs.getInt(AppPrefKeys.restDuration) ?? 5;
  Future<bool> setRestDuration(int minutes) =>
      _prefs.setInt(AppPrefKeys.restDuration, minutes);

  // Short break (minutes)
  int get shortBreak => _prefs.getInt(AppPrefKeys.shortBreak) ?? 5;
  Future<bool> setShortBreak(int minutes) =>
      _prefs.setInt(AppPrefKeys.shortBreak, minutes);

  // Long break (minutes)
  int get longBreak => _prefs.getInt(AppPrefKeys.longBreak) ?? 15;
  Future<bool> setLongBreak(int minutes) =>
      _prefs.setInt(AppPrefKeys.longBreak, minutes);

  // Long break interval (cycles)
  int get longBreakInterval =>
      _prefs.getInt(AppPrefKeys.longBreakInterval) ?? 4;
  Future<bool> setLongBreakInterval(int count) =>
      _prefs.setInt(AppPrefKeys.longBreakInterval, count);

  // Auto-start breaks
  bool get autoStartBreaks =>
      _prefs.getBool(AppPrefKeys.autoStartBreaks) ?? false;
  Future<bool> setAutoStartBreaks(bool value) =>
      _prefs.setBool(AppPrefKeys.autoStartBreaks, value);

  // Auto-start pomodoros
  bool get autoStartPomodoros =>
      _prefs.getBool(AppPrefKeys.autoStartPomodoros) ?? false;
  Future<bool> setAutoStartPomodoros(bool value) =>
      _prefs.setBool(AppPrefKeys.autoStartPomodoros, value);

  // Sound enabled
  bool get soundEnabled => _prefs.getBool(AppPrefKeys.soundEnabled) ?? true;
  Future<bool> setSoundEnabled(bool value) =>
      _prefs.setBool(AppPrefKeys.soundEnabled, value);

  // Sound name / asset
  String get soundName => _prefs.getString(AppPrefKeys.soundName) ?? 'bell';
  Future<bool> setSoundName(String name) =>
      _prefs.setString(AppPrefKeys.soundName, name);

  // Notifications enabled
  bool get notificationsEnabled =>
      _prefs.getBool(AppPrefKeys.notificationsEnabled) ?? true;
  Future<bool> setNotificationsEnabled(bool value) =>
      _prefs.setBool(AppPrefKeys.notificationsEnabled, value);

  // Theme mode ('system', 'light', 'dark')
  String get themeMode => _prefs.getString(AppPrefKeys.themeMode) ?? 'system';
  Future<bool> setThemeMode(String mode) =>
      _prefs.setString(AppPrefKeys.themeMode, mode);

  // Daily target pomodoros
  int get dailyTarget => _prefs.getInt(AppPrefKeys.dailyTarget) ?? 8;
  Future<bool> setDailyTarget(int count) =>
      _prefs.setInt(AppPrefKeys.dailyTarget, count);

  // Login status
  bool get isLoggedIn => _prefs.getBool(AppPrefKeys.isLoggedIn) ?? false;
  Future<bool> setIsLoggedIn(bool value) =>
      _prefs.setBool(AppPrefKeys.isLoggedIn, value);

  // User Email
  String? get userEmail => _prefs.getString(AppPrefKeys.userEmail);
  Future<bool> setUserEmail(String? email) {
    if (email == null) {
      return _prefs.remove(AppPrefKeys.userEmail);
    }
    return _prefs.setString(AppPrefKeys.userEmail, email);
  }

  // User Name
  String? get userName => _prefs.getString(AppPrefKeys.userName);
  Future<bool> setUserName(String? name) {
    if (name == null) {
      return _prefs.remove(AppPrefKeys.userName);
    }
    return _prefs.setString(AppPrefKeys.userName, name);
  }

  // User ID
  String? get userId => _prefs.getString(AppPrefKeys.userId);
  Future<bool> setUserId(String? id) {
    if (id == null) {
      return _prefs.remove(AppPrefKeys.userId);
    }
    return _prefs.setString(AppPrefKeys.userId, id);
  }

  // Save session convenience method
  Future<void> saveUserSession({
    required String email,
    String? name,
    String? id,
  }) async {
    await setIsLoggedIn(true);
    await setUserEmail(email);
    if (name != null) await setUserName(name);
    if (id != null) await setUserId(id);
  }

  // Clear session convenience method
  Future<void> clearUserSession() async {
    await setIsLoggedIn(false);
    await _prefs.remove(AppPrefKeys.userEmail);
    await _prefs.remove(AppPrefKeys.userName);
    await _prefs.remove(AppPrefKeys.userId);
  }
}
