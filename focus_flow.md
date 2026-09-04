## Brand & Style

The design system is anchored in a **Modern Corporate** aesthetic with a strong emphasis on **Minimalism** to facilitate deep work and cognitive clarity. The brand personality is focused, reliable, and functional, catering to high-performance individuals who require a tool that recedes into the background until needed.

The visual language utilizes heavy whitespace and precise alignment to reduce mental noise. It avoids decorative flourishes in favor of utility, using color only to denote state changes, urgency, or task completion. The interface should feel like a high-end physical stationery set—purposeful, tactile, and durable.

## Colors

This design system uses a logic-driven palette designed for long-term focus.

*   **Primary (Deep Productivity Blue):** Used for primary actions, active navigation states, and brand identifiers. It evokes stability and professional trust.
*   **Secondary (Slate):** Used for supporting elements, inactive icons, and metadata. It provides a grounded, neutral balance.
*   **Accent (Tomato Red):** Reserved exclusively for high-priority states: the active Pomodoro timer, overdue tasks, and critical alerts.
*   **Surface Strategy:** 
    *   **Light Mode:** Employs a "Paper" strategy using `#FFFFFF` for cards and `#F7FAFC` for the base background to create subtle depth without shadows.
    *   **Dark Mode:** Employs a "Charcoal" strategy using `#1A202C` as the base and `#2D3748` for elevated containers to maintain contrast and readability in low-light environments.

## Typography

The typography system relies on **Inter** for its exceptional legibility and neutral, systematic tone. **JetBrains Mono** is introduced for labels and metadata to provide a technical, "data-driven" feel that reinforces the productivity narrative.

*   **Hierarchy:** Use bold weights (700) sparingly for page titles. Medium weights (500/600) are the primary drivers for list item titles and interactive elements.
*   **Scale:** On mobile devices, `display-lg` is capped at 32px to ensure titles do not wrap aggressively.
*   **Spacing:** Tighten letter spacing on larger headings (`-0.02em`) to maintain a compact, professional appearance.

## Layout & Spacing

The design system utilizes a **4px baseline grid** to ensure mathematical harmony. 

*   **Content Density:** Prioritize high density for task lists. Use `12px` (sm+xs) vertical padding for list items to maximize the number of visible tasks per screen.
*   **Margins:** A standard `16px` margin is applied to the left and right of the screen.
*   **Safe Areas:** Ensure interactive elements (buttons, checkboxes) maintain a minimum hit target of `44x44px`, even if their visual representation is smaller.

## Elevation & Depth

Hierarchy is established through **Tonal Layering** supplemented by **Low-Contrast Outlines**.

*   **Base Layer:** The background uses the neutral surface color.
*   **Level 1 (Cards):** Use a pure white (light) or soft charcoal (dark) background with a `1px` border colored at 10% opacity of the secondary color.
*   **Shadows:** Shadows are highly diffused and faint. Use a `Y: 4, Blur: 12, Opacity: 0.05` shadow for cards to suggest they are slightly raised from the surface.
*   **Active State:** When an item is dragged or focused, the shadow intensity increases to `Opacity: 0.12` and the border color shifts to the Primary color.

## Shapes

The shape language is defined by **16px (rounded-lg)** corners for primary containers and cards. This softens the professional tone, making the app feel approachable rather than rigid.

*   **Buttons:** Use the `rounded-lg` (1rem) setting for a modern, chunky feel.
*   **Input Fields:** Match the card radius (16px) to maintain visual consistency.
*   **Small Elements:** Chips and tags should use "Pill-shaped" (3) roundedness to differentiate them from actionable cards.

## Components

*   **Cards:** The core of the UI. Must have a 16px corner radius, a 1px subtle border, and 16px internal padding.
*   **Buttons:**
    *   *Primary:* Solid Deep Blue background with white text.
    *   *Secondary:* Ghost style with a Slate 1px border.
    *   *Accent:* Solid Tomato Red for Pomodoro "Start" or "Stop" actions.
*   **Checkboxes:** Large, custom-styled circles (24px). When checked, they should fill with the Primary color and trigger a strikethrough on the associated text.
*   **Input Fields:** Use a subtle light gray fill (`#EDF2F7`) in light mode to define the field area clearly without needing a heavy border.
*   **Chips/Tags:** Used for categorizing tasks (e.g., "Work", "Personal"). Use light tint versions of the category color with dark text for high legibility.
*   **Progress Bars:** Use a thick 8px height with fully rounded ends. The track should be a 10% opacity version of the fill color.
*   **Timer Display:** Centered, large-scale typography using `timer-display` tokens, utilizing the Accent color when the timer is counting down.


## BLoC Architecture

### TaskBloc
* LoadTasks
* AddTask
* UpdateTask
* DeleteTask
* CompleteTask
* RestoreTask
* FilterTasks

### PomodoroBloc
* StartTimer
* PauseTimer
* ResumeTimer
* StopTimer
* SkipTimer
* TimerTick

### StatisticsBloc
* LoadDailyStats
* LoadWeeklyStats
* LoadMonthlyStats
* ChangeDateRange

### SettingsCubit
* Theme
* TimerSettings
* NotificationSettings
* AppSettings

---

## Database Schema (Drift & SQLite)

The database layer is implemented using **Drift** (SQLite). Below is the complete field specification, data types (Drift / Dart / SQLite), constraints, and relationships for the remaining entities.

```
┌──────────────┐ 1      * ┌──────────────┐
│    tasks     │──────────│   subtasks   │
│──────────────│          │──────────────│
│ id (PK)      │          │ id (PK)      │
│ title        │          │ task_id (FK) │
│ ...          │          │ ...          │
└──────────────┘          └──────────────┘
       │ 1
       │
       │ *
┌──────────────┐          ┌──────────────┐
│  task_tags   │ *      1 │     tags     │
│──────────────│──────────│──────────────│
│ task_id (PK) │          │ id (PK)      │
│ tag_id  (PK) │          │ name         │
└──────────────┘          └──────────────┘
       │ 1
       │
       │ *
┌────────────────────┐
│ pomodoro_sessions  │
│────────────────────│
│ id (PK)            │
│ task_id (FK)       │
│ ...                │
└────────────────────┘
```

---

### 1. Tasks Table (`tasks`)
Core entity for actionable items, supporting deadlines, priorities, tags, and pomodoro estimates.

| Field Name | Drift Column Type | Dart Type | SQLite Type | Constraints & Defaults | Description |
|---|---|---|---|---|---|
| `id` | `IntColumn` | `int` | `INTEGER` | `PRIMARY KEY AUTOINCREMENT` | Unique task identifier |
| `title` | `TextColumn` | `String` | `TEXT` | `NOT NULL`, `min: 1`, `max: 200` | Task title |
| `description` | `TextColumn` | `String?` | `TEXT` | `NULLABLE` | Rich description or notes |
| `priority` | `IntColumn` | `int` | `INTEGER` | `NOT NULL`, `DEFAULT 1` | Priority level (`0`=Low, `1`=Medium, `2`=High, `3`=Urgent) |
| `due_date` | `DateTimeColumn` | `DateTime?` | `INTEGER` | `NULLABLE` | Target completion date & time |
| `reminder_at` | `DateTimeColumn` | `DateTime?` | `INTEGER` | `NULLABLE` | Scheduled local notification time |
| `is_completed` | `BoolColumn` | `bool` | `INTEGER` | `NOT NULL`, `DEFAULT false` | Task completion status |
| `completed_at` | `DateTimeColumn` | `DateTime?` | `INTEGER` | `NULLABLE` | Timestamp when marked as completed |
| `estimated_pomodoros` | `IntColumn` | `int` | `INTEGER` | `NOT NULL`, `DEFAULT 1` | Estimated number of Pomodoros (25m each) |
| `completed_pomodoros` | `IntColumn` | `int` | `INTEGER` | `NOT NULL`, `DEFAULT 0` | Count of finished focus intervals |
| `order_index` | `IntColumn` | `int` | `INTEGER` | `NOT NULL`, `DEFAULT 0` | Manual reordering index |
| `is_deleted` | `BoolColumn` | `bool` | `INTEGER` | `NOT NULL`, `DEFAULT false` | Soft-delete flag (supports trash & restore) |
| `created_at` | `DateTimeColumn` | `DateTime` | `INTEGER` | `NOT NULL`, `DEFAULT currentDateAndTime` | Creation timestamp |
| `updated_at` | `DateTimeColumn` | `DateTime` | `INTEGER` | `NOT NULL`, `DEFAULT currentDateAndTime` | Last update timestamp |

---

### 2. Subtasks Table (`subtasks`)
Granular checklist items within a single parent task.

| Field Name | Drift Column Type | Dart Type | SQLite Type | Constraints & Defaults | Description |
|---|---|---|---|---|---|
| `id` | `IntColumn` | `int` | `INTEGER` | `PRIMARY KEY AUTOINCREMENT` | Unique subtask identifier |
| `task_id` | `IntColumn` | `int` | `INTEGER` | `NOT NULL`, `REFERENCES tasks(id) ON DELETE CASCADE` | Parent task foreign key |
| `title` | `TextColumn` | `String` | `TEXT` | `NOT NULL`, `max: 200` | Subtask title |
| `is_completed` | `BoolColumn` | `bool` | `INTEGER` | `NOT NULL`, `DEFAULT false` | Completion flag |
| `order_index` | `IntColumn` | `int` | `INTEGER` | `NOT NULL`, `DEFAULT 0` | Order within the task checklist |
| `created_at` | `DateTimeColumn` | `DateTime` | `INTEGER` | `NOT NULL`, `DEFAULT currentDateAndTime` | Creation timestamp |

---

### 3. Tags Table (`tags`)
Cross-cutting labels (e.g., "Work", "Urgent", "Personal", "Study").

| Field Name | Drift Column Type | Dart Type | SQLite Type | Constraints & Defaults | Description |
|---|---|---|---|---|---|
| `id` | `IntColumn` | `int` | `INTEGER` | `PRIMARY KEY AUTOINCREMENT` | Unique tag identifier |
| `name` | `TextColumn` | `String` | `TEXT` | `NOT NULL`, `UNIQUE`, `max: 40` | Tag label name |
| `color_hex` | `TextColumn` | `String` | `TEXT` | `NOT NULL`, `DEFAULT '#64748B'` | Tag chip tint color |
| `created_at` | `DateTimeColumn` | `DateTime` | `INTEGER` | `NOT NULL`, `DEFAULT currentDateAndTime` | Creation timestamp |

---

### 4. Task Tags Junction Table (`task_tags`)
Many-to-many link between tasks and tags.

| Field Name | Drift Column Type | Dart Type | SQLite Type | Constraints & Defaults | Description |
|---|---|---|---|---|---|
| `task_id` | `IntColumn` | `int` | `INTEGER` | `NOT NULL`, `REFERENCES tasks(id) ON DELETE CASCADE` | Target task ID |
| `tag_id` | `IntColumn` | `int` | `INTEGER` | `NOT NULL`, `REFERENCES tags(id) ON DELETE CASCADE` | Target tag ID |

* *Primary Key:* `PRIMARY KEY (task_id, tag_id)`

---

### 5. Pomodoro Sessions Table (`pomodoro_sessions`)
Historical logs of focused work and break intervals used for statistics and productivity analytics.

| Field Name | Drift Column Type | Dart Type | SQLite Type | Constraints & Defaults | Description |
|---|---|---|---|---|---|
| `id` | `IntColumn` | `int` | `INTEGER` | `PRIMARY KEY AUTOINCREMENT` | Unique session record ID |
| `task_id` | `IntColumn` | `int?` | `INTEGER` | `NULLABLE`, `REFERENCES tasks(id) ON DELETE SET NULL` | Optional associated task |
| `session_type` | `TextColumn` | `String` | `TEXT` | `NOT NULL` (`'focus'`, `'shortBreak'`, `'longBreak'`) | Pomodoro interval type |
| `target_duration_minutes` | `IntColumn` | `int` | `INTEGER` | `NOT NULL`, `DEFAULT 25` | Target duration in minutes |
| `actual_duration_seconds` | `IntColumn` | `int` | `INTEGER` | `NOT NULL`, `DEFAULT 0` | Actual elapsed time in seconds |
| `start_time` | `DateTimeColumn` | `DateTime` | `INTEGER` | `NOT NULL` | Session start timestamp |
| `end_time` | `DateTimeColumn` | `DateTime?` | `INTEGER` | `NULLABLE` | Session finish/interrupt timestamp |
| `is_completed` | `BoolColumn` | `bool` | `INTEGER` | `NOT NULL`, `DEFAULT false` | True if finished without cancel/skip |
| `notes` | `TextColumn` | `String?` | `TEXT` | `NULLABLE` | Reflection or distraction notes |
| `created_at` | `DateTimeColumn` | `DateTime` | `INTEGER` | `NOT NULL`, `DEFAULT currentDateAndTime` | Record timestamp |

### Drift Table Definitions (Dart Code Reference)

```dart
import 'package:drift/drift.dart';

// 1. Tasks
class Tasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 200)();
  TextColumn get description => text().nullable()();
  IntColumn get priority => integer().withDefault(const Constant(1))(); // 0: low, 1: med, 2: high, 3: urgent
  DateTimeColumn get dueDate => dateTime().nullable()();
  DateTimeColumn get reminderAt => dateTime().nullable()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get completedAt => dateTime().nullable()();
  IntColumn get estimatedPomodoros => integer().withDefault(const Constant(1))();
  IntColumn get completedPomodoros => integer().withDefault(const Constant(0))();
  IntColumn get orderIndex => integer().withDefault(const Constant(0))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

// 2. Subtasks
class Subtasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get taskId => integer().references(Tasks, #id, onDelete: KeyAction.cascade)();
  TextColumn get title => text().withLength(min: 1, max: 200)();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  IntColumn get orderIndex => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// 3. Tags
class Tags extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique().withLength(min: 1, max: 40)();
  TextColumn get colorHex => text().withDefault(const Constant('#64748B'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// 4. TaskTags (Junction)
class TaskTags extends Table {
  IntColumn get taskId => integer().references(Tasks, #id, onDelete: KeyAction.cascade)();
  IntColumn get tagId => integer().references(Tags, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {taskId, tagId};
}

// 5. PomodoroSessions
class PomodoroSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get taskId => integer().nullable().references(Tasks, #id, onDelete: KeyAction.setNull)();
  TextColumn get sessionType => text()(); // 'focus', 'shortBreak', 'longBreak'
  IntColumn get targetDurationMinutes => integer().withDefault(const Constant(25))();
  IntColumn get actualDurationSeconds => integer().withDefault(const Constant(0))();
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime().nullable()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
```

---

## Key-Value Storage (SharedPreferences)

App configuration, timer preferences, notification options, and UI theme mode are stored locally using **`shared_preferences`** instead of SQLite tables. This ensures zero-overhead, fast, synchronous cache reads on app launch and simple key-value persistence.

### Keys & Types Specification

| Preference Key | Constant Identifier | Dart Type | Default Value | Description |
|---|---|---|---|---|
| `prefs_focus_duration` | `AppPrefKeys.focusDuration` | `int` | `25` | Pomodoro focus duration in minutes |
| `prefs_rest_duration` | `AppPrefKeys.restDuration` | `int` | `5` | Rest / break duration in minutes |
| `prefs_short_break` | `AppPrefKeys.shortBreak` | `int` | `5` | Short break duration in minutes |
| `prefs_long_break` | `AppPrefKeys.longBreak` | `int` | `15` | Long break duration in minutes |
| `prefs_long_break_interval` | `AppPrefKeys.longBreakInterval` | `int` | `4` | Number of focus cycles before a long break |
| `prefs_auto_start_breaks` | `AppPrefKeys.autoStartBreaks` | `bool` | `false` | Automatically begin break when session finishes |
| `prefs_auto_start_pomodoros` | `AppPrefKeys.autoStartPomodoros` | `bool` | `false` | Automatically begin next focus after break ends |
| `prefs_sound_enabled` | `AppPrefKeys.soundEnabled` | `bool` | `true` | Play audio cue when timer completes |
| `prefs_sound_name` | `AppPrefKeys.soundName` | `String` | `'bell'` | Asset identifier for chosen alert tone |
| `prefs_notifications_enabled` | `AppPrefKeys.notificationsEnabled` | `bool` | `true` | Push local notifications on timer alerts |
| `prefs_theme_mode` | `AppPrefKeys.themeMode` | `String` | `'system'` | Active theme mode: `'system'`, `'light'`, or `'dark'` |
| `prefs_daily_target` | `AppPrefKeys.dailyTarget` | `int` | `8` | Target daily completed Pomodoros for statistics |

---

### Implementation Reference (Dart Code)

```dart
import 'package:shared_preferences/shared_preferences.dart';

abstract class AppPrefKeys {
  static const String focusDuration = 'prefs_focus_duration';
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
}

class SettingsPreferencesService {
  final SharedPreferences _prefs;

  SettingsPreferencesService(this._prefs);

  // Focus duration (minutes)
  int get focusDuration => _prefs.getInt(AppPrefKeys.focusDuration) ?? 25;
  Future<bool> setFocusDuration(int minutes) =>
      _prefs.setInt(AppPrefKeys.focusDuration, minutes);

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
  String get themeMode =>
      _prefs.getString(AppPrefKeys.themeMode) ?? 'system';
  Future<bool> setThemeMode(String mode) =>
      _prefs.setString(AppPrefKeys.themeMode, mode);

  // Daily target pomodoros
  int get dailyTarget => _prefs.getInt(AppPrefKeys.dailyTarget) ?? 8;
  Future<bool> setDailyTarget(int count) =>
      _prefs.setInt(AppPrefKeys.dailyTarget, count);
}
```