# Focus Flow

<p align="center">
  <strong>Master your productivity, cultivate deep focus, and conquer your goals.</strong>
</p>

<p align="center">
  <a href="#features">Features</a> •
  <a href="#responsive-design">Responsive Design</a> •
  <a href="#architecture">Architecture</a> •
  <a href="#tech-stack">Tech Stack</a> •
  <a href="#getting-started">Getting Started</a> •
  <a href="#testing">Testing</a>
</p>

---

## Overview

**Focus Flow** is a modern, high-performance productivity application built with Flutter. It seamlessly unites task management, the Pomodoro technique, real-time analytics, and personalized settings into a cohesive, distraction-free environment. 

Whether running on mobile phones, tablets, or desktop platforms, Focus Flow delivers an adaptive, elegant user experience tailored for high-focus deep work.

---

## Features

### ⏱️ Pomodoro Timer & Deep Work Sessions
- **Focus & Break Cycles**: Configurable focus durations, short breaks, and long breaks.
- **Task Linking**: Connect specific tasks directly to active Pomodoro sessions. Track progress cycle-by-cycle.
- **Auto-Completion**: Automatically marks linked tasks as completed when all estimated Pomodoros finish.
- **Cycle Limits**: Enforces clean 4-cycle Pomodoro rounds for unlinked sessions to prevent cognitive burnout.
- **Audio Feedback & Notifications**: Pleasant completion chimes and alerts for mode transitions.
- **Real-Time Settings Sync**: Adjust focus or break intervals in Settings and see timer updates reflected instantly.

### 📝 Smart Task Management
- **Task Organization**: Create, edit, prioritize (Low, Medium, High, Urgent), and schedule tasks with due dates.
- **Scheduled Notifications**: Automatic local notifications scheduled for upcoming task deadlines.
- **Filters & Status**: Filter by *All*, *Pending*, and *Completed* tasks with instant reactive UI updates.
- **Soft Delete & Restore**: Safeguard tasks against accidental deletion with recovery support.
- **Auto Refresh**: Automatic state re-synchronization across navigation changes and background events.

### 📊 Comprehensive Statistics & Insights
- **Weekly Activity Chart**: Interactive 7-day focus activity bar chart built with `fl_chart`.
- **Streak Tracker**: Gamified day streak counter to build and maintain consistency.
- **Task Efficiency**: Visual breakdowns of completed vs. active tasks and completion rates.
- **Today's Metrics**: Quick-glance cards showing today's focus minutes, completed pomodoros, and total productivity.
- **Pull-to-Refresh**: Native swipe-down gesture to refresh analytics instantly.

### ⚙️ Customizable Settings
- **Theme Modes**: Seamless switching between System, Light, and Dark themes.
- **Granular Duration Sliders**: Fine-tune Focus Duration and Rest Duration with live feedback.
- **Sound Toggle**: Enable or disable audio alerts based on your environment.
- **Account & Session Management**: Secure user session persistence.

---

## Responsive Design

Focus Flow features a fully adaptive, responsive UI across screen sizes:
- **Mobile Devices**: Full-width cards with safe margins, touch-optimized hit targets, responsive typography that respects system text scaling (e.g. 1.15x – 1.3x), and vertical scrolling with zero layout overflows.
- **Tablets & Desktops**: Side navigation drawers, multi-column metric grids, and centered maximum-width containers for comfortable reading on ultra-wide screens.

---

## Tech Stack

| Layer | Technology |
|---|---|
| **Framework** | [Flutter](https://flutter.dev) (Dart 3.13+) |
| **State Management** | [flutter_bloc](https://pub.dev/packages/flutter_bloc) (Bloc & Cubit) |
| **Persistence / Database** | [Drift](https://pub.dev/packages/drift) (Type-safe SQLite ORM) |
| **Key-Value Storage** | [shared_preferences](https://pub.dev/packages/shared_preferences) |
| **Data Visualization** | [fl_chart](https://pub.dev/packages/fl_chart) |
| **Notifications** | [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications) |
| **Audio** | [audioplayers](https://pub.dev/packages/audioplayers) |
| **Dependency Injection** | [get_it](https://pub.dev/packages/get_it) |
| **Typography** | [google_fonts](https://pub.dev/packages/google_fonts) (Plus Jakarta Sans) |

---

## Architecture

The project adheres to a clean, feature-first architecture separating Presentation, Domain, and Data layers:

```text
lib/
├── core/
│   ├── database/             # Drift schema, tables, and DAOs
│   ├── services/             # Notifications, Preferences, Audio
│   ├── utils/                # Date formatting, helpers, snackbars
│   └── widgets/              # Shared navigation and layout widgets
├── features/
│   ├── home/                 # Dashboard, summary cards, navigation
│   ├── pomodoro/             # PomodoroBloc, timer page, progress indicators
│   ├── tasks/                # TasksBloc, CRUD operations, dialogs, task cards
│   ├── statistics/           # StatisticsBloc, interactive charts, streaks
│   └── settings/             # SettingsCubit, bottom sheet, preferences
├── di.dart                   # Dependency injection container
└── main.dart                 # Application entry point & theme configuration
```

---

## Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (`^3.13.0` or higher)
- Android Studio / VS Code with Dart & Flutter extensions
- Android device or emulator (Android 7.0+ / API 24+) or Windows/macOS/Linux desktop

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/focus_flow.git
   cd focus_flow
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Generate code (Drift Database):**
   ```bash
   dart run build_runner build -d
   ```

4. **Launch the application:**
   ```bash
   flutter run
   ```

---

## Testing

Focus Flow includes unit and widget tests covering BLoC state logic, repository delegations, and responsive UI interactions.

Run the test suite:
```bash
flutter test
```

Generate coverage report:
```bash
flutter test --coverage
```

---

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

