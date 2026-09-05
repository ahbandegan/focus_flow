import 'package:drift/drift.dart';
import 'app_database.dart';

/// Helper functions for safe parsing of JSON values received from Supabase / PostgreSQL.
int _parseInt(dynamic value, {int defaultValue = 0}) {
  if (value == null) return defaultValue;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? defaultValue;
  return defaultValue;
}

int? _parseNullableInt(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

bool _parseBool(dynamic value, {bool defaultValue = false}) {
  if (value == null) return defaultValue;
  if (value is bool) return value;
  if (value is num) return value == 1;
  if (value is String) {
    final lower = value.toLowerCase();
    return lower == 'true' || lower == '1' || lower == 't';
  }
  return defaultValue;
}

DateTime? _parseDateTime(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  if (value is num) return DateTime.fromMillisecondsSinceEpoch(value.toInt());
  return null;
}

// ============================================================================
// TASK MAPPER & EXTENSIONS
// ============================================================================

abstract final class TaskSupabaseMapper {
  /// Converts a Supabase JSON Map (snake_case) to a Drift [Task] model.
  static Task fromSupabase(Map<String, dynamic> json) {
    return Task(
      id: _parseInt(json['id']),
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      priority: _parseInt(json['priority'], defaultValue: 1),
      dueDate: _parseDateTime(json['due_date']),
      reminderAt: _parseDateTime(json['reminder_at']),
      isCompleted: _parseBool(json['is_completed']),
      completedAt: _parseDateTime(json['completed_at']),
      estimatedPomodoros: _parseInt(json['estimated_pomodoros'], defaultValue: 1),
      completedPomodoros: _parseInt(json['completed_pomodoros'], defaultValue: 0),
      orderIndex: _parseInt(json['order_index'], defaultValue: 0),
      isDeleted: _parseBool(json['is_deleted']),
      createdAt: _parseDateTime(json['created_at']) ?? DateTime.now(),
      updatedAt: _parseDateTime(json['updated_at']) ?? DateTime.now(),
    );
  }

  /// Converts a list of Supabase JSON objects to a [List<Task>].
  static List<Task> fromSupabaseList(List<dynamic> list) {
    return list
        .whereType<Map<String, dynamic>>()
        .map(fromSupabase)
        .toList();
  }

  /// Converts a [Task] into a JSON Map ready for Supabase insert/update.
  static Map<String, dynamic> toSupabase(Task task, {bool includeId = true}) {
    final map = <String, dynamic>{
      'title': task.title,
      'description': task.description,
      'priority': task.priority,
      'due_date': task.dueDate?.toUtc().toIso8601String(),
      'reminder_at': task.reminderAt?.toUtc().toIso8601String(),
      'is_completed': task.isCompleted,
      'completed_at': task.completedAt?.toUtc().toIso8601String(),
      'estimated_pomodoros': task.estimatedPomodoros,
      'completed_pomodoros': task.completedPomodoros,
      'order_index': task.orderIndex,
      'is_deleted': task.isDeleted,
      'created_at': task.createdAt.toUtc().toIso8601String(),
      'updated_at': task.updatedAt.toUtc().toIso8601String(),
    };
    if (includeId && task.id > 0) {
      map['id'] = task.id;
    }
    return map;
  }

  /// Creates a [TasksCompanion] from Supabase JSON for inserting into Drift.
  static TasksCompanion toCompanion(Map<String, dynamic> json) {
    return TasksCompanion(
      id: json['id'] != null ? Value(_parseInt(json['id'])) : const Value.absent(),
      title: Value(json['title'] as String? ?? ''),
      description: Value(json['description'] as String?),
      priority: Value(_parseInt(json['priority'], defaultValue: 1)),
      dueDate: Value(_parseDateTime(json['due_date'])),
      reminderAt: Value(_parseDateTime(json['reminder_at'])),
      isCompleted: Value(_parseBool(json['is_completed'])),
      completedAt: Value(_parseDateTime(json['completed_at'])),
      estimatedPomodoros: Value(_parseInt(json['estimated_pomodoros'], defaultValue: 1)),
      completedPomodoros: Value(_parseInt(json['completed_pomodoros'], defaultValue: 0)),
      orderIndex: Value(_parseInt(json['order_index'], defaultValue: 0)),
      isDeleted: Value(_parseBool(json['is_deleted'])),
      createdAt: Value(_parseDateTime(json['created_at']) ?? DateTime.now()),
      updatedAt: Value(_parseDateTime(json['updated_at']) ?? DateTime.now()),
    );
  }
}

extension TaskSupabaseExtension on Task {
  /// Converts this [Task] to a Supabase-compatible JSON Map.
  Map<String, dynamic> toSupabaseJson({bool includeId = true}) =>
      TaskSupabaseMapper.toSupabase(this, includeId: includeId);
}

// ============================================================================
// SUBTASK MAPPER & EXTENSIONS
// ============================================================================

abstract final class SubtaskSupabaseMapper {
  static Subtask fromSupabase(Map<String, dynamic> json) {
    return Subtask(
      id: _parseInt(json['id']),
      taskId: _parseInt(json['task_id']),
      title: json['title'] as String? ?? '',
      isCompleted: _parseBool(json['is_completed']),
      orderIndex: _parseInt(json['order_index'], defaultValue: 0),
      createdAt: _parseDateTime(json['created_at']) ?? DateTime.now(),
    );
  }

  static List<Subtask> fromSupabaseList(List<dynamic> list) {
    return list
        .whereType<Map<String, dynamic>>()
        .map(fromSupabase)
        .toList();
  }

  static Map<String, dynamic> toSupabase(Subtask subtask, {bool includeId = true}) {
    final map = <String, dynamic>{
      'task_id': subtask.taskId,
      'title': subtask.title,
      'is_completed': subtask.isCompleted,
      'order_index': subtask.orderIndex,
      'created_at': subtask.createdAt.toUtc().toIso8601String(),
    };
    if (includeId && subtask.id > 0) {
      map['id'] = subtask.id;
    }
    return map;
  }

  static SubtasksCompanion toCompanion(Map<String, dynamic> json) {
    return SubtasksCompanion(
      id: json['id'] != null ? Value(_parseInt(json['id'])) : const Value.absent(),
      taskId: Value(_parseInt(json['task_id'])),
      title: Value(json['title'] as String? ?? ''),
      isCompleted: Value(_parseBool(json['is_completed'])),
      orderIndex: Value(_parseInt(json['order_index'], defaultValue: 0)),
      createdAt: Value(_parseDateTime(json['created_at']) ?? DateTime.now()),
    );
  }
}

extension SubtaskSupabaseExtension on Subtask {
  Map<String, dynamic> toSupabaseJson({bool includeId = true}) =>
      SubtaskSupabaseMapper.toSupabase(this, includeId: includeId);
}

// ============================================================================
// TAG MAPPER & EXTENSIONS
// ============================================================================

abstract final class TagSupabaseMapper {
  static Tag fromSupabase(Map<String, dynamic> json) {
    return Tag(
      id: _parseInt(json['id']),
      name: json['name'] as String? ?? '',
      colorHex: json['color_hex'] as String? ?? '#64748B',
      createdAt: _parseDateTime(json['created_at']) ?? DateTime.now(),
    );
  }

  static List<Tag> fromSupabaseList(List<dynamic> list) {
    return list
        .whereType<Map<String, dynamic>>()
        .map(fromSupabase)
        .toList();
  }

  static Map<String, dynamic> toSupabase(Tag tag, {bool includeId = true}) {
    final map = <String, dynamic>{
      'name': tag.name,
      'color_hex': tag.colorHex,
      'created_at': tag.createdAt.toUtc().toIso8601String(),
    };
    if (includeId && tag.id > 0) {
      map['id'] = tag.id;
    }
    return map;
  }

  static TagsCompanion toCompanion(Map<String, dynamic> json) {
    return TagsCompanion(
      id: json['id'] != null ? Value(_parseInt(json['id'])) : const Value.absent(),
      name: Value(json['name'] as String? ?? ''),
      colorHex: Value(json['color_hex'] as String? ?? '#64748B'),
      createdAt: Value(_parseDateTime(json['created_at']) ?? DateTime.now()),
    );
  }
}

extension TagSupabaseExtension on Tag {
  Map<String, dynamic> toSupabaseJson({bool includeId = true}) =>
      TagSupabaseMapper.toSupabase(this, includeId: includeId);
}

// ============================================================================
// TASK_TAG MAPPER & EXTENSIONS
// ============================================================================

abstract final class TaskTagSupabaseMapper {
  static TaskTag fromSupabase(Map<String, dynamic> json) {
    return TaskTag(
      taskId: _parseInt(json['task_id']),
      tagId: _parseInt(json['tag_id']),
    );
  }

  static List<TaskTag> fromSupabaseList(List<dynamic> list) {
    return list
        .whereType<Map<String, dynamic>>()
        .map(fromSupabase)
        .toList();
  }

  static Map<String, dynamic> toSupabase(TaskTag taskTag) {
    return {
      'task_id': taskTag.taskId,
      'tag_id': taskTag.tagId,
    };
  }

  static TaskTagsCompanion toCompanion(Map<String, dynamic> json) {
    return TaskTagsCompanion(
      taskId: Value(_parseInt(json['task_id'])),
      tagId: Value(_parseInt(json['tag_id'])),
    );
  }
}

extension TaskTagSupabaseExtension on TaskTag {
  Map<String, dynamic> toSupabaseJson() =>
      TaskTagSupabaseMapper.toSupabase(this);
}

// ============================================================================
// POMODORO SESSION MAPPER & EXTENSIONS
// ============================================================================

abstract final class PomodoroSessionSupabaseMapper {
  static PomodoroSession fromSupabase(Map<String, dynamic> json) {
    return PomodoroSession(
      id: _parseInt(json['id']),
      taskId: _parseNullableInt(json['task_id']),
      sessionType: json['session_type'] as String? ?? 'focus',
      targetDurationMinutes: _parseInt(json['target_duration_minutes'], defaultValue: 25),
      actualDurationSeconds: _parseInt(json['actual_duration_seconds'], defaultValue: 0),
      startTime: _parseDateTime(json['start_time']) ?? DateTime.now(),
      endTime: _parseDateTime(json['end_time']),
      isCompleted: _parseBool(json['is_completed']),
      notes: json['notes'] as String?,
      createdAt: _parseDateTime(json['created_at']) ?? DateTime.now(),
    );
  }

  static List<PomodoroSession> fromSupabaseList(List<dynamic> list) {
    return list
        .whereType<Map<String, dynamic>>()
        .map(fromSupabase)
        .toList();
  }

  static Map<String, dynamic> toSupabase(
    PomodoroSession session, {
    bool includeId = true,
  }) {
    final map = <String, dynamic>{
      'task_id': session.taskId,
      'session_type': session.sessionType,
      'target_duration_minutes': session.targetDurationMinutes,
      'actual_duration_seconds': session.actualDurationSeconds,
      'start_time': session.startTime.toUtc().toIso8601String(),
      'end_time': session.endTime?.toUtc().toIso8601String(),
      'is_completed': session.isCompleted,
      'notes': session.notes,
      'created_at': session.createdAt.toUtc().toIso8601String(),
    };
    if (includeId && session.id > 0) {
      map['id'] = session.id;
    }
    return map;
  }

  static PomodoroSessionsCompanion toCompanion(Map<String, dynamic> json) {
    return PomodoroSessionsCompanion(
      id: json['id'] != null ? Value(_parseInt(json['id'])) : const Value.absent(),
      taskId: Value(_parseNullableInt(json['task_id'])),
      sessionType: Value(json['session_type'] as String? ?? 'focus'),
      targetDurationMinutes: Value(_parseInt(json['target_duration_minutes'], defaultValue: 25)),
      actualDurationSeconds: Value(_parseInt(json['actual_duration_seconds'], defaultValue: 0)),
      startTime: Value(_parseDateTime(json['start_time']) ?? DateTime.now()),
      endTime: Value(_parseDateTime(json['end_time'])),
      isCompleted: Value(_parseBool(json['is_completed'])),
      notes: Value(json['notes'] as String?),
      createdAt: Value(_parseDateTime(json['created_at']) ?? DateTime.now()),
    );
  }
}

extension PomodoroSessionSupabaseExtension on PomodoroSession {
  Map<String, dynamic> toSupabaseJson({bool includeId = true}) =>
      PomodoroSessionSupabaseMapper.toSupabase(this, includeId: includeId);
}

// ============================================================================
// EXTENSIONS ON Map<String, dynamic> FOR CONVENIENCE
// ============================================================================

extension SupabaseJsonMapExtension on Map<String, dynamic> {
  Task toTask() => TaskSupabaseMapper.fromSupabase(this);
  Subtask toSubtask() => SubtaskSupabaseMapper.fromSupabase(this);
  Tag toTag() => TagSupabaseMapper.fromSupabase(this);
  TaskTag toTaskTag() => TaskTagSupabaseMapper.fromSupabase(this);
  PomodoroSession toPomodoroSession() =>
      PomodoroSessionSupabaseMapper.fromSupabase(this);
}
