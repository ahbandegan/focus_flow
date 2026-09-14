# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.1] - 2026-09-14

### Fixed
- **Linux Notifications**: Resolved notification initialization and display issues on Linux desktop by configuring `LinuxInitializationSettings` and `LinuxNotificationDetails`.
- **Desktop Application Identifiers**: Set proper GTK Application ID (`ir.amirhesambandegan.focusflow`) and binary name for Linux, and updated Windows App User Model ID and metadata.

---

## [1.0.0] - 2026-09-13

### Added
- Initial release of **Focus Flow**.
- Pomodoro timer with customizable focus, short break, and long break intervals.
- Task management with priorities, due dates, soft-delete & restore, and task-pomodoro linking.
- Analytics & Statistics dashboard with interactive weekly bar charts (`fl_chart`) and day streaks.
- Local notification alerts for timer completions and task deadlines.
- Responsive design supporting mobile, tablet, and desktop screens with dark/light theme support.
