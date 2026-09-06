import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:focus_flow/core/services/settings_preferences_service.dart';
import 'package:focus_flow/core/supabase/supabase_auth_repository.dart';
import 'package:focus_flow/features/profile/presentation/widget/profile_bottom_sheet.dart';
import 'package:focus_flow/features/settings/data/repositories/settings_repository.dart';
import 'package:focus_flow/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseAuthRepository extends SupabaseAuthRepository {
  MockSupabaseAuthRepository()
      : super(client: SupabaseClient('https://mock.supabase.co', 'fake-key'));

  @override
  User? get currentUser => null;

  @override
  Session? get currentSession => null;

  @override
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    return AuthResponse(
      user: User(
        id: 'mock-user-id',
        appMetadata: {},
        userMetadata: {},
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
        email: email,
      ),
    );
  }

  @override
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return AuthResponse(
      user: User(
        id: 'mock-user-id',
        appMetadata: {},
        userMetadata: {},
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
        email: email,
      ),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final di = GetIt.instance;

  setUp(() async {
    await di.reset();
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final service = SettingsPreferencesService(prefs);
    di.registerSingleton<SettingsPreferencesService>(service);
    di.registerSingleton<SupabaseAuthRepository>(MockSupabaseAuthRepository());
  });

  tearDown(() async {
    await di.reset();
  });

  Widget createWidgetUnderTest(SettingsCubit cubit) {
    return MaterialApp(
      home: Scaffold(
        body: BlocProvider<SettingsCubit>.value(
          value: cubit,
          child: const ProfileBottomSheet(),
        ),
      ),
    );
  }

  testWidgets('Renders Auth form when user is not logged in', (tester) async {
    final service = di<SettingsPreferencesService>();
    final repo = SettingsRepositoryImpl(service);
    final cubit = SettingsCubit(repo);

    await tester.pumpWidget(createWidgetUnderTest(cubit));
    await tester.pumpAndSettle();

    expect(find.text('Sign In to Account'), findsWidgets);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.byType(FilledButton), findsOneWidget);
  });

  testWidgets('Validates empty email and password on submit', (tester) async {
    final service = di<SettingsPreferencesService>();
    final repo = SettingsRepositoryImpl(service);
    final cubit = SettingsCubit(repo);

    await tester.pumpWidget(createWidgetUnderTest(cubit));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(find.text('Please enter your email'), findsOneWidget);
    expect(find.text('Please enter your password'), findsOneWidget);
  });

  testWidgets('Shows email verification modal after sign up', (tester) async {
    final service = di<SettingsPreferencesService>();
    final repo = SettingsRepositoryImpl(service);
    final cubit = SettingsCubit(repo);

    await tester.pumpWidget(createWidgetUnderTest(cubit));
    await tester.pumpAndSettle();

    // Switch to Sign Up
    await tester.tap(find.text('Sign Up').first);
    await tester.pumpAndSettle();

    // Enter email & password
    await tester.enterText(find.byType(TextFormField).at(0), 'verify@test.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.pumpAndSettle();

    // Tap submit
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    // Verification modal should be visible
    expect(find.text('Verify Your Email'), findsOneWidget);
    expect(find.widgetWithText(AlertDialog, 'Verify Your Email'), findsOneWidget);
    expect(find.text('Go to Sign In'), findsOneWidget);

    // Tap Go to Sign In
    await tester.tap(find.text('Go to Sign In'));
    await tester.pumpAndSettle();

    // Modal is dismissed, and user is back on Sign In tab
    expect(find.text('Verify Your Email'), findsNothing);
    expect(find.text('Sign In to Account'), findsWidgets);
  });

  testWidgets('Renders Logged In profile view when user is logged in', (tester) async {
    final service = di<SettingsPreferencesService>();
    await service.saveUserSession(email: 'user@test.com', id: 'uid-999');
    final repo = SettingsRepositoryImpl(service);
    final cubit = SettingsCubit(repo);

    await tester.pumpWidget(createWidgetUnderTest(cubit));
    await tester.pumpAndSettle();

    expect(find.text('User Profile'), findsOneWidget);
    expect(find.text('user@test.com'), findsWidgets);
    expect(find.text('Active & Connected'), findsOneWidget);
    expect(find.text('Log Out'), findsOneWidget);
  });
}
