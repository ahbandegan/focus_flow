import 'package:flutter/material.dart';
import 'package:focus_flow/core/database/app_database.dart';

class TaskCard extends StatefulWidget {
  final Task task;
  final Function(int, bool) onCheck;
  final Function(int) onStart;
  final Function(int) onDelete;
  final Function(int) onEdit;
  const TaskCard({
    super.key,
    required this.task,
    required this.onCheck,
    required this.onStart,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Material(
            color: Theme.of(context).colorScheme.onPrimaryFixedVariant
                .withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              child: SizedBox(
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                        child: Checkbox(
                          value: widget.task.isCompleted,
                          onChanged: (value) =>
                              widget.onCheck(widget.task.id, !(value ?? false)),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 10,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            spacing: 10,
                            children: [
                              Text(
                                widget.task.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              Text("|"),
                              Text(
                                widget.task.description ??
                                    "not have description",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            spacing: 15,
                            children: [
                              Icon(
                                Icons.flag,
                                color: switch (widget.task.estimatedPomodoros) {
                                  0 => Colors.green,
                                  1 => Colors.amber,
                                  2 => Colors.orange,
                                  3 => Colors.red,
                                  _ => Colors.green,
                                },
                                size: 20,
                              ),
                              if (widget.task.dueDate != null)
                                Row(
                                  spacing: 4,
                                  children: [
                                    Icon(
                                      Icons.timer,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outline,
                                      size: 15,
                                    ),
                                    Text(
                                      TimeOfDay.fromDateTime(
                                        widget.task.dueDate!,
                                      ).format(context),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outline,
                                      ),
                                    ),
                                  ],
                                ),

                              Row(
                                spacing: 3,
                                children: [
                                  for (
                                    int i = 0;
                                    i < widget.task.completedPomodoros;
                                    i++
                                  )
                                    Container(
                                      width: 5,
                                      height: 15,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Colors.red,
                                      ),
                                    ),
                                  for (
                                    int i = 0;
                                    i <
                                        (widget.task.estimatedPomodoros -
                                            widget.task.completedPomodoros);
                                    i++
                                  )
                                    Container(
                                      width: 5,
                                      height: 15,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outline,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
