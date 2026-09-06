import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:focus_flow/features/tasks/presentation/widget/add_task_dialog.dart';

// ignore: must_be_immutable
class MobileNavigation extends StatefulWidget {
  List pages;
  Size size;
  int currentIndex;
  Function(int) onTap;
  final VoidCallback? onAddTask;
  MobileNavigation({
    super.key,
    required this.pages,
    required this.size,
    required this.currentIndex,
    required this.onTap,
    this.onAddTask,
  });

  @override
  State<MobileNavigation> createState() => _MobileNavigationState();
}

class _MobileNavigationState extends State<MobileNavigation> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: widget.pages[widget.currentIndex]),
        OverflowHitTestStack(
          overflowPadding: const EdgeInsets.only(top: 30),
          clipBehavior: Clip.none,
          children: [
            Container(
              color: Theme.of(context).colorScheme.surface,
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        _buildNavItem(
                          index: 0,
                          title: "Today",
                          icon: Icons.sunny,
                        ),
                        _buildNavItem(
                          index: 1,
                          title: "Task",
                          icon: Icons.task_alt,
                        ),
                      ],
                    ),
                  ),
                  // Space for the FAB
                  const SizedBox(width: 70),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        
                        _buildNavItem(
                          index: 2,
                          title: "Focus",
                          icon: Icons.timer,
                        ),
                        _buildNavItem(
                          index: 3,
                          title: "Stats",
                          icon: Icons.bar_chart,
                        ),],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: -30,
              child: Center(
                child: Material(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(50),
                  elevation: 1,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(50),
                    onTap: () {
                      if (widget.onAddTask != null) {
                        widget.onAddTask!();
                      } else {
                        showAddTaskModal(context);
                      }
                    },
                    child: SizedBox(
                      width: 60,
                      height: 60,
                      child: const Icon(
                        Icons.add,
                        size: 28,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNavItem({
    required int index,
    required String title,
    required IconData icon,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () => widget.onTap(index),
        child: AnimatedContainer(
          color: widget.currentIndex == index
              ? Theme.of(context).colorScheme.primaryContainer
              : Colors.transparent,
          duration: const Duration(milliseconds: 200),
          child: Padding(
            padding: const EdgeInsets.all(13.0),
            child: Column(
              spacing: 10,
              children: [
                Icon(
                  icon,
                  color: widget.currentIndex == index
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface,
                ),
                AnimatedDefaultTextStyle(
                  style: TextStyle(
                    color: widget.currentIndex == index
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface,
                    fontWeight: widget.currentIndex == index
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  duration: const Duration(milliseconds: 200),
                  child: Text(title),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A [Stack] that allows hit-testing on children that overflow its bounds
/// by the specified [overflowPadding].
class OverflowHitTestStack extends Stack {
  final EdgeInsets overflowPadding;

  const OverflowHitTestStack({
    super.key,
    super.alignment,
    super.textDirection,
    super.fit,
    super.clipBehavior = Clip.none,
    this.overflowPadding = EdgeInsets.zero,
    super.children,
  });

  @override
  RenderStack createRenderObject(BuildContext context) {
    return RenderOverflowHitTestStack(
      alignment: alignment,
      textDirection: textDirection ?? Directionality.maybeOf(context),
      fit: fit,
      clipBehavior: clipBehavior,
      overflowPadding: overflowPadding,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderStack renderObject) {
    super.updateRenderObject(context, renderObject);
    if (renderObject is RenderOverflowHitTestStack) {
      renderObject.overflowPadding = overflowPadding;
    }
  }
}

class RenderOverflowHitTestStack extends RenderStack {
  RenderOverflowHitTestStack({
    super.children,
    super.alignment,
    super.textDirection,
    super.fit,
    super.clipBehavior,
    this.overflowPadding = EdgeInsets.zero,
  });

  EdgeInsets overflowPadding;

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    final Rect hitRegion = Rect.fromLTRB(
      -overflowPadding.left,
      -overflowPadding.top,
      size.width + overflowPadding.right,
      size.height + overflowPadding.bottom,
    );
    if (hitRegion.contains(position)) {
      if (hitTestChildren(result, position: position) || hitTestSelf(position)) {
        result.add(BoxHitTestEntry(this, position));
        return true;
      }
    }
    return false;
  }
}
