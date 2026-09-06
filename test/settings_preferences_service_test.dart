import 'package:flutter_test/flutter_test.dart';
import 'package:focus_flow/core/services/settings_preferences_service.dart';
import 'package:focus_flow/features/settings/data/repositories/settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SettingsPreferencesService Auth Tests', () {
    late SharedPreferences prefs;
    late SettingsPreferencesService service;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      service = SettingsPreferencesService(prefs);
    });

    test('Default login state is false and user data is null', () {
      expect(service.isLoggedIn, isFalse);
      expect(service.userEmail, isNull);
      expect(service.userName, isNull);
      expect(service.userId, isNull);
    });

    test('setIsLoggedIn updates login status', () async {
      await service.setIsLoggedIn(true);
      expect(service.isLoggedIn, isTrue);

      await service.setIsLoggedIn(false);
      expect(service.isLoggedIn, isFalse);
    });

    test('setUserEmail updates and removes email correctly', () async {
      await service.setUserEmail('test@test.com');
      expect(service.userEmail, 'test@test.com');

      await service.setUserEmail(null);
      expect(service.userEmail, isNull);
    });

    test('saveUserSession saves all credentials and marks logged in', () async {
      await service.saveUserSession(
        email: 'focus@flow.app',
        name: 'Focus User',
        id: 'user-uuid-456',
      );

      expect(service.isLoggedIn, isTrue);
      expect(service.userEmail, 'focus@flow.app');
      expect(service.userName, 'Focus User');
      expect(service.userId, 'user-uuid-456');
    });

    test('clearUserSession clears session and marks logged out', () async {
      await service.saveUserSession(
        email: 'focus@flow.app',
        name: 'Focus User',
        id: 'user-uuid-456',
      );

      await service.clearUserSession();

      expect(service.isLoggedIn, isFalse);
      expect(service.userEmail, isNull);
      expect(service.userName, isNull);
      expect(service.userId, isNull);
    });
  });

  group('SettingsRepositoryImpl Auth Integration Tests', () {
    late SharedPreferences prefs;
    late SettingsPreferencesService service;
    late SettingsRepositoryImpl repository;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      service = SettingsPreferencesService(prefs);
      repository = SettingsRepositoryImpl(service);
    });

    test('Repository delegates login status and session methods', () async {
      expect(repository.isLoggedIn, isFalse);
      expect(repository.userEmail, isNull);

      await repository.saveUserSession(
        email: 'repo@test.com',
        id: 'repo-id-1',
      );

      expect(repository.isLoggedIn, isTrue);
      expect(repository.userEmail, 'repo@test.com');

      await repository.logout();

      expect(repository.isLoggedIn, isFalse);
      expect(repository.userEmail, isNull);
    });
  });
}
