# Focus Flow

A modern, minimalist productivity application built with Flutter, designed to facilitate deep work and cognitive clarity. 

Focus Flow combines task management, project organization, habit tracking, and a Pomodoro timer into a single, cohesive experience. The app is tailored for high-performance individuals who need a reliable and functional tool that minimizes mental noise.

## Features

- **Task & Project Management**: Organize your work efficiently with projects, tasks, and tags.
- **Pomodoro Timer**: Stay focused using the built-in Pomodoro technique timer with customizable work and break intervals.
- **Habit Tracking**: Build and maintain positive routines alongside your daily tasks.
- **Statistics & Insights**: Track your productivity with daily, weekly, and monthly statistics visualized with interactive charts.
- **Customizable Settings**: Adjust timers, themes (Light/Dark mode), and notifications to fit your workflow.

## Design Philosophy

The application features a **Modern Corporate** aesthetic emphasizing minimalism:
- **Colors**: Deep Productivity Blue for stability, Slate for balance, and Tomato Red for critical alerts and active Pomodoro timers.
- **Typography**: Inter for clean legibility and JetBrains Mono for a technical, data-driven feel in labels.
- **Layout**: High content density with a 4px baseline grid for mathematical harmony, using tonal layering and subtle shadows for depth.

## Tech Stack

Focus Flow is built utilizing modern Flutter development practices and robust packages:
- **State Management**: [flutter_bloc](https://pub.dev/packages/flutter_bloc) (Bloc & Cubit)
- **Local Database**: [drift](https://pub.dev/packages/drift) (built on SQLite)
- **Charts & Data Visualization**: [fl_chart](https://pub.dev/packages/fl_chart)
- **Notifications**: [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications)
- **Audio**: [audioplayers](https://pub.dev/packages/audioplayers) (for timer alerts)

## Architecture Overview

The app follows a feature-first, Bloc-based architecture:
- `TaskBloc`: Manages task creation, updates, completion, and filtering.
- `ProjectBloc`: Handles project lifecycle and organization.
- `PomodoroBloc`: Controls the focus timer, breaks, and ticks.
- `StatisticsBloc`: Aggregates and loads productivity data for charts.
- `HabitBloc`: Tracks habit completions and streaks.
- `SettingsCubit`: Manages app-wide preferences like themes and timer durations.

## Getting Started

To run this project locally, ensure you have Flutter installed (SDK version ^3.13.0).

1. Clone the repository.
2. Get dependencies:
   ```bash
   flutter pub get
   ```
3. Run code generation (for Drift and other generated files):
   ```bash
   dart run build_runner build -d
   ```
4. Run the app:
   ```bash
   flutter run
   ```
