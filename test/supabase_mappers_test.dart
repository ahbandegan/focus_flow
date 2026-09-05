import 'package:flutter_test/flutter_test.dart';
import 'package:focus_flow/core/database/app_database.dart';

void main() {
  group('Supabase Mappers Test', () {
    test('Task fromSupabase parses PostgreSQL json correctly', () {
      final json = {
        'id': 1,
        'title': 'Test Task',
        'description': 'Description',
        'priority': 2,
        'due_date': '2026-09-05T18:00:00.000Z',
        'reminder_at': null,
        'is_completed': false,
        'completed_at': null,
        'estimated_pomodoros': 3,
        'completed_pomodoros': 1,
        'order_index': 0,
        'is_deleted': false,
        'created_at': '2026-09-05T12:00:00.000Z',
        'updated_at': '2026-09-05T12:30:00.000Z',
      };

      final task = TaskSupabaseMapper.fromSupabase(json);
      expect(task.id, 1);
      expect(task.title, 'Test Task');
      expect(task.priority, 2);
      expect(task.dueDate, isNotNull);
      expect(task.estimatedPomodoros, 3);
      expect(task.completedPomodoros, 1);
      expect(task.isCompleted, false);

      final supabaseJson = task.toSupabaseJson();
      expect(supabaseJson['id'], 1);
      expect(supabaseJson['title'], 'Test Task');
      expect(supabaseJson['priority'], 2);
      expect(supabaseJson['due_date'], contains('2026-09-05'));
    });

    test('Extension methods on Map work seamlessly', () {
      final json = {
        'id': 10,
        'name': 'Work',
        'color_hex': '#2563EB',
        'created_at': '2026-09-05T12:00:00.000Z',
      };

      final tag = json.toTag();
      expect(tag.id, 10);
      expect(tag.name, 'Work');
      expect(tag.colorHex, '#2563EB');

      final backToJson = tag.toSupabaseJson();
      expect(backToJson['id'], 10);
      expect(backToJson['name'], 'Work');
    });
  });
}
