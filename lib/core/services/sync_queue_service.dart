import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

enum SyncAction {
  create,
  update,
  delete,
}

class SyncQueueItem {
  final String id;
  final SyncAction action;
  final int taskId;
  final Map<String, dynamic> payload;
  final DateTime timestamp;

  const SyncQueueItem({
    required this.id,
    required this.action,
    required this.taskId,
    required this.payload,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'action': action.name,
        'taskId': taskId,
        'payload': payload,
        'timestamp': timestamp.toIso8601String(),
      };

  factory SyncQueueItem.fromJson(Map<String, dynamic> map) => SyncQueueItem(
        id: map['id'] as String? ?? const Uuid().v4(),
        action: SyncAction.values.firstWhere(
          (e) => e.name == map['action'],
          orElse: () => SyncAction.update,
        ),
        taskId: map['taskId'] as int? ?? 0,
        payload: Map<String, dynamic>.from(map['payload'] as Map? ?? {}),
        timestamp: DateTime.tryParse(map['timestamp'] as String? ?? '') ??
            DateTime.now(),
      );
}

class SyncQueueService {
  static const String _queueKey = 'prefs_task_sync_queue';
  final SharedPreferences _prefs;
  final Uuid _uuid = const Uuid();

  SyncQueueService(this._prefs);

  List<SyncQueueItem> getPendingItems() {
    final rawList = _prefs.getStringList(_queueKey) ?? [];
    return rawList.map((str) {
      try {
        final map = jsonDecode(str) as Map<String, dynamic>;
        return SyncQueueItem.fromJson(map);
      } catch (_) {
        return null;
      }
    }).whereType<SyncQueueItem>().toList();
  }

  bool get hasPendingItems => getPendingItems().isNotEmpty;

  Future<void> enqueue({
    required SyncAction action,
    required int taskId,
    required Map<String, dynamic> payload,
  }) async {
    final items = getPendingItems();

    // If an item for the same task and action exists, replace it; or if it's already a 'create' and we update, update the payload
    final existingIndex = items.indexWhere((item) => item.taskId == taskId);
    if (existingIndex != -1) {
      final existing = items[existingIndex];
      if (existing.action == SyncAction.create && action == SyncAction.update) {
        // Keep as 'create' but update the payload
        items[existingIndex] = SyncQueueItem(
          id: existing.id,
          action: SyncAction.create,
          taskId: taskId,
          payload: payload,
          timestamp: DateTime.now(),
        );
      } else if (action == SyncAction.delete && existing.action == SyncAction.create) {
        // If it was created locally and deleted before ever reaching server, simply remove it
        items.removeAt(existingIndex);
      } else {
        items[existingIndex] = SyncQueueItem(
          id: existing.id,
          action: action,
          taskId: taskId,
          payload: payload,
          timestamp: DateTime.now(),
        );
      }
    } else {
      items.add(
        SyncQueueItem(
          id: _uuid.v4(),
          action: action,
          taskId: taskId,
          payload: payload,
          timestamp: DateTime.now(),
        ),
      );
    }

    await _saveQueue(items);
  }

  Future<void> remove(String id) async {
    final items = getPendingItems();
    items.removeWhere((item) => item.id == id);
    await _saveQueue(items);
  }

  Future<void> clear() async {
    await _prefs.remove(_queueKey);
  }

  Future<void> _saveQueue(List<SyncQueueItem> items) async {
    final strList = items.map((item) => jsonEncode(item.toJson())).toList();
    await _prefs.setStringList(_queueKey, strList);
  }
}
