import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focus_flow/features/settings/presentation/cubit/settings_cubit.dart';

void openSettingsSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      return BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Settings',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),

                  // 1. Theme Mode
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Theme Mode'),
                    subtitle: Text(
                      state.themeMode[0].toUpperCase() +
                          state.themeMode.substring(1),
                    ),
                    trailing: SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(
                          value: 'light',
                          icon: Icon(Icons.light_mode, size: 18),
                          label: Text('Light'),
                        ),
                        ButtonSegment(
                          value: 'system',
                          icon: Icon(Icons.brightness_auto, size: 18),
                          label: Text('Auto'),
                        ),
                        ButtonSegment(
                          value: 'dark',
                          icon: Icon(Icons.dark_mode, size: 18),
                          label: Text('Dark'),
                        ),
                      ],
                      selected: {state.themeMode},
                      onSelectionChanged: (selection) {
                        context.read<SettingsCubit>().changeTheme(selection.first);
                      },
                    ),
                  ),
                  const Divider(height: 24),

                  // 2. Focus Duration Slider
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.timer_outlined,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Focus Duration',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${state.focusDuration} min',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Slider(
                        value: state.focusDuration.toDouble().clamp(5.0, 90.0),
                        min: 5.0,
                        max: 90.0,
                        divisions: 17, // 5, 10, 15, ..., 90 (step of 5)
                        label: '${state.focusDuration} min',
                        onChanged: (val) {
                          context
                              .read<SettingsCubit>()
                              .updateFocusDuration(val.round());
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '5 min',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context).colorScheme.outline,
                                  ),
                            ),
                            Text(
                              '90 min',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context).colorScheme.outline,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),

                  // 3. Rest Duration Slider
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.coffee_outlined,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Rest Duration',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${state.restDuration} min',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSecondaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Slider(
                        value: state.restDuration.toDouble().clamp(1.0, 30.0),
                        min: 1.0,
                        max: 30.0,
                        divisions: 29, // 1, 2, 3, ..., 30 (step of 1)
                        label: '${state.restDuration} min',
                        onChanged: (val) {
                          context
                              .read<SettingsCubit>()
                              .updateRestDuration(val.round());
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '1 min',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context).colorScheme.outline,
                                  ),
                            ),
                            Text(
                              '30 min',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context).colorScheme.outline,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),

                  // 4. Sound Alerts
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    secondary: const Icon(Icons.notifications_active_outlined),
                    title: const Text('Sound Alerts'),
                    subtitle: const Text('Play sound when session finishes'),
                    value: state.soundEnabled,
                    onChanged: (val) {
                      context.read<SettingsCubit>().toggleSound(val);
                    },
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
