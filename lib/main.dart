import 'package:flutter/material.dart';
import 'package:focus_flow/core/widgets/desktop_navigation.dart';
import 'package:focus_flow/features/home/presentation/page/home_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:focus_flow/core/notifications/notification_service.dart';

import 'core/widgets/mobile_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  await NotificationService().requestPermissions();

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
  List<Widget> pages = [HomePage(), HomePage(), HomePage(), HomePage()];
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      body: size.width < 768
          ? MobileNavigation(
              pages: pages,
              size: size,
              currentIndex: currentIndex,
              onTap: onTap,
            )
          : DesktopNavigation(
              pages: pages,
              size: size,
              currentIndex: currentIndex,
              onTap: onTap,
            ),
    );
  }

  void onTap(int index) => setState(() {
    currentIndex = index;
  });
}
