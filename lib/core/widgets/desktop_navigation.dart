import 'package:flutter/material.dart';
import 'package:focus_flow/features/settings/presentation/widget/settings_bottom_sheet.dart';

class DesktopNavigation extends StatefulWidget {
  final List<Widget> pages;
  final Size size;
  final int currentIndex;
  final Function(int) onTap;
  final bool isMenuOpen;
  final VoidCallback onToggleMenu;

  const DesktopNavigation({
    super.key,
    required this.pages,
    required this.size,
    required this.currentIndex,
    required this.onTap,
    this.isMenuOpen = false,
    required this.onToggleMenu,
  });

  @override
  State<DesktopNavigation> createState() => _DesktopNavigationState();
}

class _DesktopNavigationState extends State<DesktopNavigation> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
          width: widget.isMenuOpen ? 260 : 0,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(
              right: BorderSide(
                color: theme.dividerColor.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
            boxShadow: widget.isMenuOpen
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(2, 0),
                    ),
                  ]
                : null,
          ),
          child: OverflowBox(
            minWidth: 260,
            maxWidth: 260,
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 260,
              height: widget.size.height,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Header: Logo + App Name + Close Button
                      Row(
                        children: [
                          Image.asset(
                            "assets/image/logo.png",
                            width: 38,
                            height: 38,
                            errorBuilder: (_, _, _) => Icon(
                              Icons.bubble_chart,
                              size: 38,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Focus Flow",
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: widget.onToggleMenu,
                            icon: const Icon(Icons.chevron_left_rounded),
                            tooltip: 'Close Menu',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 2. Add Task Button
                      Material(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(12),
                        elevation: 1,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            // TODO: Show task creation modal
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "Add Task",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 3. Section Title
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 4.0,
                        ),
                        child: Text(
                          "MENU",
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.outline,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),

                      // 4. Navigation Items
                      _buildNavItem(
                        context: context,
                        index: 0,
                        icon: Icons.wb_sunny_rounded,
                        iconColor: Colors.amber,
                        label: "Today",
                      ),
                      const SizedBox(height: 6),
                      _buildNavItem(
                        context: context,
                        index: 1,
                        icon: Icons.task_alt_rounded,
                        iconColor: Colors.blueAccent,
                        label: "Tasks",
                      ),
                      const SizedBox(height: 6),
                      _buildNavItem(
                        context: context,
                        index: 2,
                        icon: Icons.timer_rounded,
                        iconColor: Colors.redAccent,
                        label: "Focus",
                      ),
                      const SizedBox(height: 6),
                      _buildNavItem(
                        context: context,
                        index: 3,
                        icon: Icons.bar_chart_rounded,
                        iconColor: Colors.deepOrangeAccent,
                        label: "Stats",
                      ),

                      const Spacer(),

                      // 5. Divider
                      Divider(color: theme.dividerColor.withValues(alpha: 0.2)),
                      const SizedBox(height: 8),

                      // 6. Settings Shortcut
                      Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () => openSettingsSheet(context),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                              vertical: 10.0,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.settings_rounded,
                                  color: theme.colorScheme.onSurfaceVariant,
                                  size: 22,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  "Settings",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(child: widget.pages[widget.currentIndex]),
      ],
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required IconData icon,
    required Color iconColor,
    required String label,
  }) {
    final theme = Theme.of(context);
    final isSelected = widget.currentIndex == index;

    return Material(
      color: isSelected
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.7)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => widget.onTap(index),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? theme.colorScheme.primary : iconColor,
                size: 22,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
