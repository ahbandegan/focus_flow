import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focus_flow/features/tasks/presentation/bloc/tasks_bloc.dart';
import 'package:intl/intl.dart';

/// Data model representing task form fields collected from the user.
class TaskFormData {
  final String title;
  final String? description;
  final int priority;
  final int estimatedPomodoros;
  final DateTime? dueDate;
  final TimeOfDay? dueTime;

  const TaskFormData({
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

  @override
  String toString() {
    return 'TaskFormData(title: $title, description: $description, priority: $priority, estimatedPomodoros: $estimatedPomodoros, dueDate: $dueDate, dueTime: $dueTime)';
  }
}

/// Opens an AlertDialog on Windows / Desktop, and a ModalBottomSheet on Mobile.
Future<void> showAddTaskModal(BuildContext context) async {
  final bool isWindows =
      (!kIsWeb && Platform.isWindows) ||
      Theme.of(context).platform == TargetPlatform.windows ||
      MediaQuery.sizeOf(context).width >= 768;

  if (isWindows) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => AddTaskDialog(),
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
      builder: (sheetContext) => AddTaskBottomSheet(),
    );
  }
}

/// Windows / Desktop AlertDialog for creating a new task.
class AddTaskDialog extends StatelessWidget {
  const AddTaskDialog({super.key});

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
              Icons.add_task_rounded,
              color: theme.colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Add New Task',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: AddTaskFormContent(
            onCancel: () => Navigator.of(context).pop(),
          ),
        ),
      ),
    );
  }
}

/// Mobile BottomSheet for creating a new task.
class AddTaskBottomSheet extends StatelessWidget {
  const AddTaskBottomSheet({super.key});

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
                      Icons.add_task_rounded,
                      color: theme.colorScheme.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Add New Task',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              AddTaskFormContent(onCancel: () => Navigator.of(context).pop()),
            ],
          ),
        ),
      ),
    );
  }
}

/// Form inputs and submission handling for task creation.
class AddTaskFormContent extends StatefulWidget {
  final VoidCallback onCancel;

  const AddTaskFormContent({super.key, required this.onCancel});

  @override
  State<AddTaskFormContent> createState() => _AddTaskFormContentState();
}

class _AddTaskFormContentState extends State<AddTaskFormContent> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  int _priority = 0; // 0: Low, 1: Medium, 2: High, 3: Urgent
  int _estimatedPomodoros = 1;
  DateTime? _dueDate;
  TimeOfDay? _dueTime;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // ===========================================================================
  // CONFIRMATION METHOD (YOU CAN WRITE YOUR OWN LOGIC HERE!)
  // ===========================================================================
  /// This method is called when the user validates the form and clicks "Add Task".
  /// Write your custom repository/Bloc execution or any other business logic below.
  void _onConfirmTask(TaskFormData data) {
    // Available fields:
    // - data.title (String)
    // - data.description (String?)
    // - data.priority (int: 0=Low, 1=Medium, 2=High, 3=Urgent)
    // - data.estimatedPomodoros (int)
    // - data.dueDate (DateTime? with time applied)
    // - data.dueTime (TimeOfDay?)
    // - data.dueDateTime (DateTime?)
    //
    context.read<TasksBloc>().add(
      OnAddTaskEvent(
        title: data.title,
        description: data.description,
        priority: data.priority,
        isCompleted: false,
        estimatedPomodoros: data.estimatedPomodoros,
        completedPomodoros: 0,
        orderIndex: 0,
        isDeleted: false,
        dueDate: data.dueDate,
        dueTime: data.dueTime,
      ),
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

      final data = TaskFormData(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        priority: _priority,
        estimatedPomodoros: _estimatedPomodoros,
        dueDate: combinedDueDate,
        dueTime: _dueTime,
      );

      _onConfirmTask(data);
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

      // If due date is today, check that the picked time is not in the past:
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
            autofocus: true,
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

          // 3. Priority Selector (Select Box)
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
                icon: const Icon(Icons.check_rounded, size: 18),
                label: const Text('Add Task'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
