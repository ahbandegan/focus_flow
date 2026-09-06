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
  MockSupabaseAuthRepository() : super(client: SupabaseClient('https://mock.supabase.co', 'fake-key'));

  @override
  User? get currentUser => null;

  @override
  Session? get currentSession => null;
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

    expect(find.text('ورود به حساب کاربری'), findsWidgets);
    expect(find.text('ایمیل (Email)'), findsOneWidget);
    expect(find.text('رمز عبور (Password)'), findsOneWidget);
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

    expect(find.text('لطفاً ایمیل خود را وارد کنید'), findsOneWidget);
    expect(find.text('لطفاً رمز عبور را وارد کنید'), findsOneWidget);
  });

  testWidgets('Renders Logged In profile view when user is logged in', (tester) async {
    final service = di<SettingsPreferencesService>();
    await service.saveUserSession(email: 'user@test.com', id: 'uid-999');
    final repo = SettingsRepositoryImpl(service);
    final cubit = SettingsCubit(repo);

    await tester.pumpWidget(createWidgetUnderTest(cubit));
    await tester.pumpAndSettle();

    expect(find.text('پروفایل کاربری'), findsOneWidget);
    expect(find.text('user@test.com'), findsWidgets);
    expect(find.text('حساب فعال و متصل'), findsOneWidget);
    expect(find.text('خروج از حساب کاربری'), findsOneWidget);
  });
}
