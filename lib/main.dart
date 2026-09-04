import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focus_flow/core/services/notification_service.dart';
import 'package:focus_flow/features/settings/domin/repositories/settings_repository.dart';
import 'package:focus_flow/core/widgets/desktop_navigation.dart';
import 'package:focus_flow/features/home/presentation/page/home_page.dart';
import 'package:focus_flow/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:focus_flow/features/settings/presentation/widget/settings_bottom_sheet.dart';
import 'package:focus_flow/initialize_dependensies.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/widgets/mobile_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  await NotificationService().requestPermissions();

  await initializeDi();

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(systemStatusBarContrastEnforced: true),
  );

  runApp(
    BlocProvider(
      create: (context) => SettingsCubit(di<SettingsRepository>()),
      child: const FocusFlowApp(),
    ),
  );
}

class FocusFlowApp extends StatelessWidget {
  const FocusFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      buildWhen: (prev, curr) => prev.themeMode != curr.themeMode,
      builder: (context, state) {
        final themeMode = switch (state.themeMode) {
          'light' => ThemeMode.light,
          'dark' => ThemeMode.dark,
          _ => ThemeMode.system,
        };

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
            scaffoldBackgroundColor: const Color(
              0xFFF9FAFB,
            ), // Tailwind gray-50
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
            scaffoldBackgroundColor: const Color(
              0xFF030712,
            ), // Tailwind gray-950
          ),
          themeMode: themeMode, // Supports dark mode out of the box
          home: SafeArea(child: const InitialPage()),
        );
      },
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
  bool isDesktopMenuOpen = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isDesktop = size.width >= 768;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Focus Flow'),
        leading: isDesktop
            ? IconButton(
                onPressed: () {
                  setState(() {
                    isDesktopMenuOpen = !isDesktopMenuOpen;
                  });
                },
                icon: Icon(
                  isDesktopMenuOpen
                      ? Icons.menu_open_rounded
                      : Icons.menu_rounded,
                ),
                tooltip: isDesktopMenuOpen ? 'Close Menu' : 'Open Menu',
              )
            : null,
        actions: [
          IconButton(
            onPressed: () => openSettingsSheet(context),
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: !isDesktop
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
              isMenuOpen: isDesktopMenuOpen,
              onToggleMenu: () {
                setState(() {
                  isDesktopMenuOpen = !isDesktopMenuOpen;
                });
              },
            ),
    );
  }

  void onTap(int index) => setState(() {
    currentIndex = index;
  });
}
