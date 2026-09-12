import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focus_flow/core/utils/format_minutes.dart';
import 'package:focus_flow/core/utils/show_snackbar.dart';
import 'package:focus_flow/features/home/presentation/widget/stat_card.dart';
import 'package:focus_flow/features/statistics/presentation/bloc/statistics_bloc.dart';
import 'package:intl/intl.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  @override
  void initState() {
    super.initState();
    context.read<StatisticsBloc>().add(LoadStatisticsEvent());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: BlocConsumer<StatisticsBloc, StatisticsState>(
        listener: (context, state) {
          if (state is StatisticsSuccessMessageState) {
            showSnackbar(context: context, msg: state.message, isError: false);
          } else if (state is StatisticsErrorState) {
            showSnackbar(context: context, msg: state.message, isError: true);
          }
        },
        buildWhen: (previous, current) =>
            current is! StatisticsSuccessMessageState,
        builder: (context, state) {
          if (state is StatisticsLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is StatisticsErrorState) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 48,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load statistics',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: TextStyle(color: theme.colorScheme.outline),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () {
                      context.read<StatisticsBloc>().add(RefreshStatisticsEvent());
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is StatisticsLoadedState) {
            final size = MediaQuery.sizeOf(context);
            final isDesktop = size.width >= 600;

            return RefreshIndicator(
              onRefresh: () async {
                context.read<StatisticsBloc>().add(RefreshStatisticsEvent());
              },
              child: ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 24.0 : 16.0,
                  vertical: isDesktop ? 20.0 : 16.0,
                ),
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                children: [
                  // 1. Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('EEEE, MMMM d').format(DateTime.now()),
                              style: TextStyle(
                                color: theme.colorScheme.outline,
                                fontWeight: FontWeight.w600,
                                fontSize: isDesktop ? 14 : 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Statistics",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: isDesktop ? 28 : 24,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton.filledTonal(
                        onPressed: () {
                          context.read<StatisticsBloc>().add(
                                RefreshStatisticsEvent(),
                              );
                        },
                        icon: const Icon(Icons.refresh_rounded),
                        tooltip: 'Refresh Statistics',
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 2. Streak Banner
                  _buildStreakCard(context, state, isDesktop),
                  const SizedBox(height: 20),

                  // 3. Quick Metrics Grid
                  GridView.extent(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    maxCrossAxisExtent: 250,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    mainAxisExtent: isDesktop ? 130 : 120,
                    children: [
                      StatCard(
                        icon: Icons.timelapse_rounded,
                        color: Colors.blueAccent,
                        value: formatMinutes(state.todayFocusMinutes),
                        title: "Today's Focus",
                      ),
                      StatCard(
                        icon: Icons.check_circle_outline_rounded,
                        color: Colors.redAccent,
                        iconColor: Colors.red,
                        value: "${state.todayCompletedPomodoros}",
                        title: "Completed Pomodoros",
                      ),
                      StatCard(
                        icon: Icons.date_range_rounded,
                        color: Colors.deepPurpleAccent,
                        iconColor: Colors.deepPurple,
                        value: formatMinutes(state.weekFocusMinutes),
                        title: "Weekly Focus",
                      ),
                      StatCard(
                        icon: Icons.pie_chart_outline_rounded,
                        color: Colors.teal,
                        value: "${state.completionRate.toStringAsFixed(0)}%",
                        title: "Task Completion",
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 4. Weekly Focus Activity Chart
                  _buildWeeklyChartCard(context, state, isDesktop),
                  const SizedBox(height: 24),

                  // 5. Task Efficiency Breakdown Card
                  _buildTaskBreakdownCard(context, state, isDesktop),
                  const SizedBox(height: 30),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildStreakCard(
    BuildContext context,
    StatisticsLoadedState state,
    bool isDesktop,
  ) {
    final theme = Theme.of(context);
    final hasStreak = state.streakDays > 0;

    return Container(
      padding: EdgeInsets.all(isDesktop ? 20.0 : 16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: hasStreak
              ? [
                  const Color(0xFFF97316), // Tailwind Orange 500
                  const Color(0xFFEA580C), // Tailwind Orange 600
                ]
              : [
                  theme.colorScheme.surfaceContainerHighest,
                  theme.colorScheme.surfaceContainer,
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: hasStreak
            ? [
                BoxShadow(
                  color: const Color(0xFFF97316).withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: hasStreak
                  ? Colors.white.withValues(alpha: 0.2)
                  : theme.colorScheme.primaryContainer,
            ),
            child: Icon(
              Icons.local_fire_department_rounded,
              color: hasStreak ? Colors.white : theme.colorScheme.primary,
              size: 34,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasStreak
                      ? "${state.streakDays} Day Streak!"
                      : "Start Your Streak!",
                  style: TextStyle(
                    color: hasStreak
                        ? Colors.white
                        : theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hasStreak
                      ? "Consistency is key to deep productivity. Keep the momentum going!"
                      : "Complete at least one focus session today to build your streak.",
                  style: TextStyle(
                    color: hasStreak
                        ? Colors.white.withValues(alpha: 0.9)
                        : theme.colorScheme.outline,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChartCard(
    BuildContext context,
    StatisticsLoadedState state,
    bool isDesktop,
  ) {
    final theme = Theme.of(context);
    final maxVal = state.weekDailyMinutes.isEmpty
        ? 0.0
        : state.weekDailyMinutes.reduce((a, b) => a > b ? a : b);
    final computedMaxY =
        (maxVal < 60 ? 60.0 : (maxVal * 1.25)).ceilToDouble();
    final gridInterval = (computedMaxY / 4).clamp(15.0, 120.0);

    return Container(
      padding: EdgeInsets.all(isDesktop ? 20.0 : 16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Weekly Focus Activity",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isDesktop ? 18 : 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Daily focus time for the past 7 days",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: theme.colorScheme.outline,
                        fontSize: isDesktop ? 13 : 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "${state.weekFocusMinutes}m Total",
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: computedMaxY,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final minutes = rod.toY.toInt();
                      final date = DateTime.now().subtract(
                        Duration(days: 6 - group.x),
                      );
                      final dayName = DateFormat('EEEE').format(date);
                      return BarTooltipItem(
                        "$dayName\n$minutes min",
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 38,
                      getTitlesWidget: (value, meta) {
                        if (value == 0 || value > computedMaxY) {
                          return const SizedBox.shrink();
                        }
                        return Text(
                          "${value.toInt()}m",
                          style: TextStyle(
                            color: theme.colorScheme.outline,
                            fontSize: 11,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= 7) {
                          return const SizedBox.shrink();
                        }
                        final date = DateTime.now().subtract(
                          Duration(days: 6 - index),
                        );
                        final isToday = index == 6;
                        final label = isToday
                            ? 'Today'
                            : DateFormat('E').format(date);

                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            label,
                            style: TextStyle(
                              color: isToday
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.outline,
                              fontWeight: isToday
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: gridInterval,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: theme.dividerColor.withValues(alpha: 0.15),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  for (int i = 0; i < state.weekDailyMinutes.length; i++)
                    BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: state.weekDailyMinutes[i],
                          gradient: LinearGradient(
                            colors: i == 6
                                ? [
                                    theme.colorScheme.primary,
                                    theme.colorScheme.primary.withValues(
                                      alpha: 0.7,
                                    ),
                                  ]
                                : [
                                    theme.colorScheme.primary.withValues(
                                      alpha: 0.7,
                                    ),
                                    theme.colorScheme.primary.withValues(
                                      alpha: 0.4,
                                    ),
                                  ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                          width: 18,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6),
                          ),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: computedMaxY,
                            color: theme.colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.35),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskBreakdownCard(
    BuildContext context,
    StatisticsLoadedState state,
    bool isDesktop,
  ) {
    final theme = Theme.of(context);
    final total = state.totalCompletedTasks + state.totalActiveTasks;
    final progressFraction = total > 0 ? (state.totalCompletedTasks / total) : 0.0;

    return Container(
      padding: EdgeInsets.all(isDesktop ? 20.0 : 16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Task Efficiency",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isDesktop ? 18 : 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Overview of completed and pending tasks",
            style: TextStyle(
              color: theme.colorScheme.outline,
              fontSize: isDesktop ? 13 : 12,
            ),
          ),
          const SizedBox(height: 20),

          // Linear Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progressFraction,
              minHeight: 12,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 16),

          // Legend & Counts
          Wrap(
            spacing: 16,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            children: [
              _buildLegendItem(
                color: Colors.green,
                label: "Completed",
                count: state.totalCompletedTasks,
              ),
              _buildLegendItem(
                color: theme.colorScheme.surfaceContainerHighest,
                label: "Pending",
                count: state.totalActiveTasks,
              ),
              _buildLegendItem(
                color: theme.colorScheme.primary,
                label: "Total",
                count: total,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required int count,
  }) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          "$label: ",
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          "$count",
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
