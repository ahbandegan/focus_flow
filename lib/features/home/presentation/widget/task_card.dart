import 'package:flutter/material.dart';
import 'package:focus_flow/core/database/app_database.dart';
import 'package:focus_flow/features/tasks/presentation/widget/edit_task_dialog.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final bool isActive; // در صورتی که تایمر پومودورو روی این تسک ران باشد
  final void Function(bool isCompleted) onCheck;
  final void Function() onStart;
  final void Function(int id) onDelete;

  const TaskCard({
    super.key,
    required this.task,
    this.isActive = false,
    required this.onCheck,
    required this.onStart,
    required this.onDelete,
  });

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 0:
        return Colors.green;
      case 1:
        return Colors.amber;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.redAccent;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompleted = task.isCompleted;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: isCompleted ? 0.6 : 1.0,
      child: Material(
        color: isActive
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.35)
            : theme.colorScheme.onPrimaryFixedVariant.withValues(alpha: 0.15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isActive
              ? BorderSide(color: theme.colorScheme.primary, width: 1.5)
              : BorderSide.none,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => onStart(),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 14.0,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1. Checkbox وضعیت انجام تسک
                Checkbox(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  value: isCompleted,
                  onChanged: (bool? value) {
                    if (value != null) {
                      onCheck(value);
                    }
                  },
                ),
                const SizedBox(width: 8),

                // 2. محتوای تسک (عنوان، توضیحات و مشخصات)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // سطر اول: عنوان و توضیحات
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              task.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                decoration: isCompleted
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                                color: isCompleted
                                    ? theme.colorScheme.outline
                                    : theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                          if (task.description != null &&
                              task.description!.trim().isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                              ),
                              child: Text(
                                '|',
                                style: TextStyle(
                                  color: theme.colorScheme.outlineVariant,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                task.description!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.outline,
                                  decoration: isCompleted
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),

                      // سطر دوم: شاخص‌ها (Priority, Due Date, Pomodoros)
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 12,
                        runSpacing: 4,
                        children: [
                          // نشانگر اولویت
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.flag_rounded,
                                color: _getPriorityColor(task.priority),
                                size: 16,
                              ),
                            ],
                          ),

                          // تاریخ سررسید (در صورت وجود)
                          if (task.dueDate != null)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.access_time_rounded,
                                  color: theme.colorScheme.outline,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  TimeOfDay.fromDateTime(task.dueDate!)
                                      .format(context),
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.outline,
                                  ),
                                ),
                              ],
                            ),

                          // نمایش بصری پومودوروها (کامل شده و باقیمانده)
                          _buildPomodoroBars(context, theme),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // 3. منوی اقدامات (Actions Menu)
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert_rounded,
                    color: theme.colorScheme.outline,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  onSelected: (value) {
                    switch (value) {
                      case 'play':
                        onStart();
                        break;
                      case 'edit':
                        showEditTaskModal(context: context, task: task);
                        break;
                      case 'delete':
                        onDelete(task.id);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'play',
                      child: Row(
                        children: [
                          Icon(
                            isActive
                                ? Icons.pause_circle_outline_rounded
                                : Icons.play_circle_outline_rounded,
                            size: 18,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(isActive ? 'Pause Focus' : 'Start Focus'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 18),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline_rounded,
                            size: 18,
                            color: Colors.redAccent,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Delete',
                            style: TextStyle(color: Colors.redAccent),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// متد کمکی برای رسم میله‌های پیشرفت پومودورو
  Widget _buildPomodoroBars(BuildContext context, ThemeData theme) {
    final completed = task.completedPomodoros;
    final remaining = (task.estimatedPomodoros - completed).clamp(0, 50);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < completed; i++)
          Container(
            width: 4,
            height: 12,
            margin: const EdgeInsets.symmetric(horizontal: 1.5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Colors.redAccent,
            ),
          ),
        for (int i = 0; i < remaining; i++)
          Container(
            width: 4,
            height: 12,
            margin: const EdgeInsets.symmetric(horizontal: 1.5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
      ],
    );
  }
}
