import 'package:flutter/material.dart';

// ignore: must_be_immutable
class MobileNavigation extends StatefulWidget {
  List pages;
  Size size;
  int currentIndex;
  Function(int) onTap;
  MobileNavigation({
    super.key,
    required this.pages,
    required this.size,
    required this.currentIndex,
    required this.onTap,
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
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              color: Theme.of(context).colorScheme.surface,
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => widget.onTap(0),
                            child: AnimatedContainer(
                              color: widget.currentIndex == 0
                                  ? Theme.of(context)
                                        .colorScheme
                                        .primaryContainer
                                  : Colors.transparent,
                              duration: const Duration(milliseconds: 200),
                              child: Padding(
                                padding: const EdgeInsets.all(13.0),
                                child: Column(
                                  spacing: 10,
                                  children: [
                                    Icon(
                                      Icons.sunny,
                                      color: widget.currentIndex == 0
                                          ? Theme.of(context)
                                                .colorScheme
                                                .primary
                                          : Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                    ),
                                    AnimatedDefaultTextStyle(
                                      style: TextStyle(
                                        color: widget.currentIndex == 0
                                            ? Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                            : Theme.of(context)
                                                  .colorScheme
                                                  .onSurface,
                                        fontWeight: widget.currentIndex == 0
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      child: const Text("Today"),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        Expanded(
                          child: GestureDetector(
                            onTap: () => widget.onTap(1),
                            child: AnimatedContainer(
                              color: widget.currentIndex == 1
                                  ? Theme.of(context)
                                        .colorScheme
                                        .primaryContainer
                                  : Colors.transparent,
                              duration: const Duration(milliseconds: 200),
                              child: Padding(
                                padding: const EdgeInsets.all(13.0),
                                child: Column(
                                  spacing: 10,
                                  children: [
                                    Icon(
                                      Icons.task_alt,
                                      color: widget.currentIndex == 1
                                          ? Theme.of(context)
                                                .colorScheme
                                                .primary
                                          : Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                    ),
                                    AnimatedDefaultTextStyle(
                                      style: TextStyle(
                                        color: widget.currentIndex == 1
                                            ? Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                            : Theme.of(context)
                                                  .colorScheme
                                                  .onSurface,
                                        fontWeight: widget.currentIndex == 1
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      child: const Text("Tasks"),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
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
                        Expanded(
                          child: GestureDetector(
                            onTap: () => widget.onTap(2),
                            child: AnimatedContainer(
                              color: widget.currentIndex == 2
                                  ? Theme.of(context)
                                        .colorScheme
                                        .primaryContainer
                                  : Colors.transparent,
                              duration: const Duration(milliseconds: 200),
                              child: Padding(
                                padding: const EdgeInsets.all(13.0),
                                child: Column(
                                  spacing: 10,
                                  children: [
                                    Icon(
                                      Icons.timer,
                                      color: widget.currentIndex == 2
                                          ? Theme.of(context)
                                                .colorScheme
                                                .primary
                                          : Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                    ),
                                    AnimatedDefaultTextStyle(
                                      style: TextStyle(
                                        color: widget.currentIndex == 2
                                            ? Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                            : Theme.of(context)
                                                  .colorScheme
                                                  .onSurface,
                                        fontWeight: widget.currentIndex == 2
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      child: const Text("Focus"),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        Expanded(
                          child: GestureDetector(
                            onTap: () => widget.onTap(3),
                            child: AnimatedContainer(
                              color: widget.currentIndex == 3
                                  ? Theme.of(context)
                                        .colorScheme
                                        .primaryContainer
                                  : Colors.transparent,
                              duration: const Duration(milliseconds: 200),
                              child: Padding(
                                padding: const EdgeInsets.all(13.0),
                                child: Column(
                                  spacing: 10,
                                  children: [
                                    Icon(
                                      Icons.bar_chart,
                                      color: widget.currentIndex == 3
                                          ? Theme.of(context)
                                                .colorScheme
                                                .primary
                                          : Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                    ),
                                    AnimatedDefaultTextStyle(
                                      style: TextStyle(
                                        color: widget.currentIndex == 3
                                            ? Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                            : Theme.of(context)
                                                  .colorScheme
                                                  .onSurface,
                                        fontWeight: widget.currentIndex == 3
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      child: const Text("Stats"),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
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
                child: GestureDetector(
                  onTap: () {
                    // TODO show modal create task
                  },
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    width: 60,
                    height: 60,
                    child: const Icon(Icons.add, size: 28, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
