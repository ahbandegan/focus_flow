import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:focus_flow/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  runApp(const FocusFlowApp());
}

class FocusFlowApp extends StatelessWidget {
  const FocusFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Focus Flow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB), // Tomato/Coral Red primary
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.plusJakartaSansTextTheme(
          ThemeData(brightness: Brightness.light).textTheme,
        ),
        scaffoldBackgroundColor: const Color(0xFFF9FAFB), // Tailwind gray-50
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB), // Tomato/Coral Red primary
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.plusJakartaSansTextTheme(
          ThemeData(brightness: Brightness.dark).textTheme,
        ),
        scaffoldBackgroundColor: const Color(0xFF030712), // Tailwind gray-950
      ),
      themeMode: ThemeMode.system, // Supports dark mode out of the box
      home: SafeArea(child: const InitialPage()),
    );
  }
}

class InitialPage extends StatefulWidget {
  const InitialPage({super.key});

  @override
  State<InitialPage> createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage> {
  int currentIndex = 0;
  List<Widget> currentPage = [];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      body: size.width < 768
          ? Column(
              children: [
                Expanded(child: Text("test")),
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
                                GestureDetector(
                                  onTap: () => setState(() {
                                    currentIndex = 0;
                                  }),
                                  child: AnimatedContainer(
                                    color: currentIndex == 0
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
                                            color: currentIndex == 0
                                                ? Theme.of(context)
                                                      .colorScheme
                                                      .primary
                                                : Theme.of(context)
                                                      .colorScheme
                                                      .onSurface,
                                          ),
                                          AnimatedDefaultTextStyle(
                                            style: TextStyle(
                                              color: currentIndex == 0
                                                  ? Theme.of(context)
                                                        .colorScheme
                                                        .primary
                                                  : Theme.of(context)
                                                        .colorScheme
                                                        .onSurface,
                                              fontWeight: currentIndex == 0
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                            ),
                                            duration: Duration(
                                              milliseconds: 200,
                                            ),
                                            child: Text("Today"),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                GestureDetector(
                                  onTap: () => setState(() {
                                    currentIndex = 1;
                                  }),
                                  child: AnimatedContainer(
                                    color: currentIndex == 1
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
                                            color: currentIndex == 1
                                                ? Theme.of(context)
                                                      .colorScheme
                                                      .primary
                                                : Theme.of(context)
                                                      .colorScheme
                                                      .onSurface,
                                          ),
                                          AnimatedDefaultTextStyle(
                                            style: TextStyle(
                                              color: currentIndex == 1
                                                  ? Theme.of(context)
                                                        .colorScheme
                                                        .primary
                                                  : Theme.of(context)
                                                        .colorScheme
                                                        .onSurface,
                                              fontWeight: currentIndex == 1
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                            ),
                                            duration: Duration(
                                              milliseconds: 200,
                                            ),
                                            child: Text("Tasks"),
                                          ),
                                        ],
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
                                GestureDetector(
                                  onTap: () => setState(() {
                                    currentIndex = 2;
                                  }),
                                  child: AnimatedContainer(
                                    color: currentIndex == 2
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
                                            color: currentIndex == 2
                                                ? Theme.of(context)
                                                      .colorScheme
                                                      .primary
                                                : Theme.of(context)
                                                      .colorScheme
                                                      .onSurface,
                                          ),
                                          AnimatedDefaultTextStyle(
                                            style: TextStyle(
                                              color: currentIndex == 2
                                                  ? Theme.of(context)
                                                        .colorScheme
                                                        .primary
                                                  : Theme.of(context)
                                                        .colorScheme
                                                        .onSurface,
                                              fontWeight: currentIndex == 2
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                            ),
                                            duration: Duration(
                                              milliseconds: 200,
                                            ),
                                            child: Text("Focus"),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                GestureDetector(
                                  onTap: () => setState(() {
                                    currentIndex = 3;
                                  }),
                                  child: AnimatedContainer(
                                    color: currentIndex == 3
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
                                            color: currentIndex == 3
                                                ? Theme.of(context)
                                                      .colorScheme
                                                      .primary
                                                : Theme.of(context)
                                                      .colorScheme
                                                      .onSurface,
                                          ),
                                          AnimatedDefaultTextStyle(
                                            style: TextStyle(
                                              color: currentIndex == 3
                                                  ? Theme.of(context)
                                                        .colorScheme
                                                        .primary
                                                  : Theme.of(context)
                                                        .colorScheme
                                                        .onSurface,
                                              fontWeight: currentIndex == 3
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                            ),
                                            duration: Duration(
                                              milliseconds: 200,
                                            ),
                                            child: Text("Stats"),
                                          ),
                                        ],
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
                      right: size.width / 2 - 35,
                      left: size.width / 2 - 35,
                      top: -20,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        width: 70,
                        height: 70,
                        child: Icon(Icons.add, size: 40),
                      ),
                    ),
                  ],
                ),
              ],
            )
          : Row(children: [Expanded(child: Text("test"))]),
    );
  }
}
