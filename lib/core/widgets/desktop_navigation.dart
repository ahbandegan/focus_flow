import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DesktopNavigation extends StatefulWidget {
  List pages;
  Size size;
  int currentIndex;
  Function(int) onTap;
  DesktopNavigation({
    super.key,
    required this.pages,
    required this.size,
    required this.currentIndex,
    required this.onTap,
  });
  @override
  State<DesktopNavigation> createState() => _DesktopNavigationState();
}

class _DesktopNavigationState extends State<DesktopNavigation> {
  bool expanded = false;
  bool showContent = false;

  void toggleExpanded(bool value) {
    if (value) {
      setState(() {
        expanded = true;
      });
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && expanded) {
          setState(() {
            showContent = true;
          });
        }
      });
    } else {
      setState(() {
        showContent = false;
        expanded = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: expanded ? 300 : 77,
          height: widget.size.height,
          color: Theme.of(context).colorScheme.surface,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                spacing: 15,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    spacing: 15,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => toggleExpanded(true),
                        child: Image.asset(
                          "assets/image/logo.png",
                          width: 47,
                          height: 47,
                        ),
                      ),
                      if (showContent)
                        IconButton(
                          onPressed: () => toggleExpanded(false),
                          icon: Icon(Icons.menu),
                        ).animate().fade(),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      // TODO show modal create task
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.blueAccent,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 3,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add),
                            if (showContent)
                              Text(
                                "Add Task",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ).animate().fade().slideX(),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Column(
                    spacing: 5,
                    children: [
                      GestureDetector(
                        onTap: () => widget.onTap(0),
                        child: AnimatedContainer(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: widget.currentIndex == 0
                                ? Theme.of(context).colorScheme.onPrimary
                                : Colors.transparent,
                          ),
                          duration: Duration(milliseconds: 200),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              spacing: 10,
                              children: [
                                Icon(Icons.sunny, color: Colors.amber),
                                if (showContent)
                                  AnimatedDefaultTextStyle(
                                    style: TextStyle(
                                      color: widget.currentIndex == 0
                                          ? Colors.blueAccent
                                          : Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                      fontWeight: widget.currentIndex == 0
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      fontSize: 16,
                                    ),
                                    duration: Duration(milliseconds: 200),
                                    child: Text("Today"),
                                  ).animate().fade().slideX(),
                              ],
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => widget.onTap(1),
                        child: AnimatedContainer(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: widget.currentIndex == 1
                                ? Theme.of(context).colorScheme.onPrimary
                                : Colors.transparent,
                          ),
                          duration: Duration(milliseconds: 200),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              spacing: 10,
                              children: [
                                Icon(Icons.task_alt, color: Colors.blueAccent),
                                if (showContent)
                                  AnimatedDefaultTextStyle(
                                    style: TextStyle(
                                      color: widget.currentIndex == 1
                                          ? Colors.blueAccent
                                          : Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                      fontWeight: widget.currentIndex == 1
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      fontSize: 16,
                                    ),
                                    duration: Duration(milliseconds: 200),
                                    child: Text("Tasks"),
                                  ).animate().fade().slideX(),
                              ],
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => widget.onTap(2),
                        child: AnimatedContainer(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: widget.currentIndex == 2
                                ? Theme.of(context).colorScheme.onPrimary
                                : Colors.transparent,
                          ),
                          duration: Duration(milliseconds: 200),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              spacing: 10,
                              children: [
                                Icon(Icons.timer, color: Colors.redAccent),
                                if (showContent)
                                  AnimatedDefaultTextStyle(
                                    style: TextStyle(
                                      color: widget.currentIndex == 2
                                          ? Colors.blueAccent
                                          : Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                      fontWeight: widget.currentIndex == 2
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      fontSize: 16,
                                    ),
                                    duration: Duration(milliseconds: 200),
                                    child: Text("Focus"),
                                  ).animate().fade().slideX(),
                              ],
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => widget.onTap(3),
                        child: AnimatedContainer(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: widget.currentIndex == 3
                                ? Theme.of(context).colorScheme.onPrimary
                                : Colors.transparent,
                          ),
                          duration: Duration(milliseconds: 200),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              spacing: 10,
                              children: [
                                Icon(Icons.bar_chart, color: Colors.deepOrange),
                                if (showContent)
                                  AnimatedDefaultTextStyle(
                                    style: TextStyle(
                                      color: widget.currentIndex == 3
                                          ? Colors.blueAccent
                                          : Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                      fontWeight: widget.currentIndex == 3
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      fontSize: 16,
                                    ),
                                    duration: Duration(milliseconds: 200),
                                    child: Text("Stats"),
                                  ).animate().fade().slideX(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(child: widget.pages[widget.currentIndex]),
      ],
    );
  }
}
