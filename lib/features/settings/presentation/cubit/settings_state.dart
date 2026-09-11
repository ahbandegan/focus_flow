part of 'settings_cubit.dart';

// State
class SettingsState extends Equatable {
  final int focusDuration;
  final int restDuration;
  final int shortBreak;
  final int longBreak;
  final bool soundEnabled;
  final String themeMode;
  final bool isLoggedIn;
  final String? userEmail;

  const SettingsState({
    required this.focusDuration,
    required this.restDuration,
    required this.shortBreak,
    required this.longBreak,
    required this.soundEnabled,
    required this.themeMode,
    this.isLoggedIn = false,
    this.userEmail,
  });

  SettingsState copyWith({
    int? focusDuration,
    int? restDuration,
    int? shortBreak,
    int? longBreak,
    bool? soundEnabled,
    String? themeMode,
    bool? isLoggedIn,
    String? userEmail,
  }) {
    return SettingsState(
      focusDuration: focusDuration ?? this.focusDuration,
      restDuration: restDuration ?? this.restDuration,
      shortBreak: shortBreak ?? this.shortBreak,
      longBreak: longBreak ?? this.longBreak,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      themeMode: themeMode ?? this.themeMode,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      userEmail: userEmail ?? this.userEmail,
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
        isLoggedIn,
        userEmail,
      ];
}

final class SettingsSuccessMessageState extends SettingsState {
  final String message;
  String get data => message;

  const SettingsSuccessMessageState({
    required this.message,
    required super.focusDuration,
    required super.restDuration,
    required super.shortBreak,
    required super.longBreak,
    required super.soundEnabled,
    required super.themeMode,
    super.isLoggedIn,
    super.userEmail,
  });

  @override
  List<Object?> get props => [...super.props, message];
}

