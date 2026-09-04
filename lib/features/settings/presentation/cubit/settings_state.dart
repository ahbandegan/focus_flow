part of 'settings_cubit.dart';

// State
class SettingsState extends Equatable {
  final int focusDuration;
  final int restDuration;
  final int shortBreak;
  final int longBreak;
  final bool soundEnabled;
  final String themeMode;

  const SettingsState({
    required this.focusDuration,
    required this.restDuration,
    required this.shortBreak,
    required this.longBreak,
    required this.soundEnabled,
    required this.themeMode,
  });

  SettingsState copyWith({
    int? focusDuration,
    int? restDuration,
    int? shortBreak,
    int? longBreak,
    bool? soundEnabled,
    String? themeMode,
  }) {
    return SettingsState(
      focusDuration: focusDuration ?? this.focusDuration,
      restDuration: restDuration ?? this.restDuration,
      shortBreak: shortBreak ?? this.shortBreak,
      longBreak: longBreak ?? this.longBreak,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  @override
  List<Object?> get props => [
        focusDuration,
        restDuration,
        shortBreak,
        longBreak,
        soundEnabled,
        themeMode,
      ];
}
