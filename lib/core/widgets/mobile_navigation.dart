import 'package:flutter/material.dart';

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
                              duration: Duration(milliseconds: 200),
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
                                      duration: Duration(milliseconds: 200),
                                      child: Text("Today"),
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
                              duration: Duration(milliseconds: 200),
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
                                      duration: Duration(milliseconds: 200),
                                      child: Text("Tasks"),
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
                              duration: Duration(milliseconds: 200),
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
                                      duration: Duration(milliseconds: 200),
                                      child: Text("Focus"),
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
                              duration: Duration(milliseconds: 200),
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
                                      duration: Duration(milliseconds: 200),
                                      child: Text("Stats"),
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
              right: widget.size.width / 2 - 35,
              left: widget.size.width / 2 - 35,
              top: -20,
              child: GestureDetector(
                onTap: () {
                  // TODO show modal create task
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  width: widget.size.width * 10 / 100,
                  height: widget.size.width * 10 / 100,
                  child: Icon(Icons.add, size: widget.size.width * 6 / 100),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
