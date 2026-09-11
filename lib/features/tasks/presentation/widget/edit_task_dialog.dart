import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focus_flow/core/database/app_database.dart';
import 'package:focus_flow/features/tasks/presentation/bloc/tasks_bloc.dart';
import 'package:intl/intl.dart';

// مدل تسک تولید شده توسط Drift را در صورت لزوم اینجا ایمپورت کنید
// import 'package:focus_flow/.../database.dart';

/// Data model representing task form fields collected from the user for editing.
class EditTaskFormData {
  final String title;
  final String? description;
  final int priority;
  final int estimatedPomodoros;
  final DateTime? dueDate;
  final TimeOfDay? dueTime;

  const EditTaskFormData({
    required this.title,
    this.description,
    required this.priority,
    required this.estimatedPomodoros,
    this.dueDate,
    this.dueTime,
  });

  /// Returns a combined [DateTime] with [dueTime] applied to [dueDate] if available.
  DateTime? get dueDateTime {
    if (dueDate == null) return null;
    if (dueTime == null) return dueDate;
    return DateTime(
      dueDate!.year,
      dueDate!.month,
      dueDate!.day,
      dueTime!.hour,
      dueTime!.minute,
    );
  }
}

/// Opens an AlertDialog on Windows / Desktop, and a ModalBottomSheet on Mobile for Editing.
Future<void> showEditTaskModal({
  required BuildContext context,
  required Task task,
}) async {
  final bool isWindows =
      (!kIsWeb && Platform.isWindows) ||
      Theme.of(context).platform == TargetPlatform.windows ||
      MediaQuery.sizeOf(context).width >= 768;

  if (isWindows) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => EditTaskDialog(task: task),
    );
  } else {
    return showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => EditTaskBottomSheet(task: task),
    );
  }
}

/// Windows / Desktop AlertDialog for editing an existing task.
class EditTaskDialog extends StatelessWidget {
  final Task task;

  const EditTaskDialog({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
      contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.edit_note_rounded,
              color: theme.colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Edit Task',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: EditTaskFormContent(
            task: task,
            onCancel: () => Navigator.of(context).pop(),
          ),
        ),
      ),
    );
  }
}

/// Mobile BottomSheet for editing an existing task.
class EditTaskBottomSheet extends StatelessWidget {
  final Task task;

  const EditTaskBottomSheet({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    return Padding(
      padding: EdgeInsets.only(
        bottom: bottomInset > 0 ? bottomInset : bottomPadding,
      ),
      child: SafeArea(
        top: false,
        bottom: bottomInset == 0,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.edit_note_rounded,
                      color: theme.colorScheme.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Edit Task',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              EditTaskFormContent(
                task: task,
                onCancel: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Form inputs and submission handling for task modification.
class EditTaskFormContent extends StatefulWidget {
  final Task task;
  final VoidCallback onCancel;

  const EditTaskFormContent({
    super.key,
    required this.task,
    required this.onCancel,
  });

  @override
  State<EditTaskFormContent> createState() => _EditTaskFormContentState();
}

class _EditTaskFormContentState extends State<EditTaskFormContent> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  late int _priority;
  late int _estimatedPomodoros;
  DateTime? _dueDate;
  TimeOfDay? _dueTime;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController =
        TextEditingController(text: widget.task.description ?? '');
    _priority = widget.task.priority;
    _estimatedPomodoros = widget.task.estimatedPomodoros;

    if (widget.task.dueDate != null) {
      _dueDate = widget.task.dueDate;
      _dueTime = TimeOfDay(
        hour: widget.task.dueDate!.hour,
        minute: widget.task.dueDate!.minute,
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // ===========================================================================
  // UPDATE CONFIRMATION METHOD (با استفاده از copyWith و ارسال مستقیم Task)
  // ===========================================================================
  void _onConfirmEditTask(EditTaskFormData data) {
    final updatedTask = widget.task.copyWith(
      title: data.title,
      description: Value(data.description),
      priority: data.priority,
      estimatedPomodoros: data.estimatedPomodoros,
      dueDate: Value(data.dueDate),
      updatedAt: DateTime.now(),
    );

    // ارسال شیء تسک بروزرسانی شده به Bloc
    context.read<TasksBloc>().add(
      OnUpdateTaskEvent(task: updatedTask),
    );

    Navigator.of(context).pop();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final combinedDueDate = _dueDate != null
          ? (_dueTime != null
              ? DateTime(
                  _dueDate!.year,
                  _dueDate!.month,
                  _dueDate!.day,
                  _dueTime!.hour,
                  _dueTime!.minute,
                )
              : _dueDate)
          : null;

      final data = EditTaskFormData(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        priority: _priority,
        estimatedPomodoros: _estimatedPomodoros,
        dueDate: combinedDueDate,
        dueTime: _dueTime,
      );

      _onConfirmEditTask(data);
    }
  }

  Future<void> _selectDueDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final initial = (_dueDate != null && !_dueDate!.isBefore(today))
        ? _dueDate!
        : today;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  Future<void> _selectDueTime() async {
    final now = TimeOfDay.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: _dueTime ?? now,
    );
    if (picked != null) {
      final nowDate = DateTime.now();
      final today = DateTime(nowDate.year, nowDate.month, nowDate.day);

      if (_dueDate != null &&
          DateTime(
            _dueDate!.year,
            _dueDate!.month,
            _dueDate!.day,
          ).isAtSameMomentAs(today)) {
        final pickedDateTime = DateTime(
          today.year,
          today.month,
          today.day,
          picked.hour,
          picked.minute,
        );
        if (pickedDateTime.isBefore(nowDate)) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Cannot select a time in the past for today.'),
                duration: Duration(seconds: 2),
              ),
            );
          }
          return;
        }
      }

      setState(() {
        _dueTime = picked;
        _dueDate ??= today;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Task Title
          TextFormField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Task Title *',
              hintText: 'e.g., Complete project report',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.title_rounded),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a task title';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // 2. Description
          TextFormField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Description (Optional)',
              hintText: 'Add extra details or notes...',
              alignLabelWithHint: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Padding(
                padding: EdgeInsets.only(bottom: 40),
                child: Icon(Icons.notes_rounded),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 3. Priority Selector
          DropdownButtonFormField<int>(
            initialValue: _priority,
            decoration: InputDecoration(
              labelText: 'Priority',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.flag_outlined),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
            ),
            items: const [
              DropdownMenuItem(
                value: 0,
                child: Row(
                  children: [
                    Icon(Icons.flag_rounded, size: 18, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Low Priority'),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: 1,
                child: Row(
                  children: [
                    Icon(Icons.flag_rounded, size: 18, color: Colors.amber),
                    SizedBox(width: 8),
                    Text('Medium Priority'),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: 2,
                child: Row(
                  children: [
                    Icon(Icons.flag_rounded, size: 18, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('High Priority'),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: 3,
                child: Row(
                  children: [
                    Icon(Icons.flag_rounded, size: 18, color: Colors.redAccent),
                    SizedBox(width: 8),
                    Text('Urgent Priority'),
                  ],
                ),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _priority = value;
                });
              }
            },
          ),
          const SizedBox(height: 16),

          // 4. Estimated Pomodoros
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Estimated Pomodoros',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton.outlined(
                    onPressed: _estimatedPomodoros > 1
                        ? () => setState(() => _estimatedPomodoros--)
                        : null,
                    icon: const Icon(Icons.remove, size: 18),
                    visualDensity: VisualDensity.compact,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      '$_estimatedPomodoros',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton.outlined(
                    onPressed: _estimatedPomodoros < 20
                        ? () => setState(() => _estimatedPomodoros++)
                        : null,
                    icon: const Icon(Icons.add, size: 18),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 5. Due Date & Time
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Due Date & Time',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              if (_dueDate != null || _dueTime != null)
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18),
                  tooltip: 'Clear Date & Time',
                  onPressed: () => setState(() {
                    _dueDate = null;
                    _dueTime = null;
                  }),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _selectDueDate,
                  icon: const Icon(Icons.edit_calendar_rounded, size: 18),
                  label: Text(
                    _dueDate != null
                        ? DateFormat('MMM d, yyyy').format(_dueDate!)
                        : 'Pick Date',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _selectDueTime,
                  icon: const Icon(Icons.access_time_rounded, size: 18),
                  label: Text(
                    _dueTime != null ? _dueTime!.format(context) : 'Pick Time',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 6. Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: widget.onCancel,
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.save_rounded, size: 18),
                label: const Text('Save Changes'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}