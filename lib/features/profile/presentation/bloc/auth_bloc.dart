import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focus_flow/core/supabase/supabase_auth_repository.dart';
import 'package:focus_flow/features/settings/domin/repositories/settings_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SupabaseAuthRepository authRepository;
  final SettingsRepository settingsRepository;

  AuthBloc({
    required this.authRepository,
    required this.settingsRepository,
  }) : super(AuthInitialState()) {
    on<AuthCheckStatusEvent>(_onCheckStatus);
    on<AuthSignInRequested>(_onSignIn);
    on<AuthSignUpRequested>(_onSignUp);
    on<AuthSignOutRequested>(_onSignOut);
  }

  Future<void> _onCheckStatus(
    AuthCheckStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    final currentUser = authRepository.currentUser;
    final isLoggedIn = settingsRepository.isLoggedIn;
    final storedEmail = settingsRepository.userEmail;

    if (isLoggedIn && (currentUser != null || storedEmail != null)) {
      emit(
        AuthenticatedState(
          email: currentUser?.email ?? storedEmail ?? 'User',
          userId: currentUser?.id,
        ),
      );
    } else {
      emit(UnauthenticatedState());
    }
  }

  Future<void> _onSignIn(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadingState());
    try {
      final response = await authRepository.signIn(
        email: event.email,
        password: event.password,
      );

      final user = response.user;
      final email = user?.email ?? event.email;
      final userId = user?.id;

      await settingsRepository.saveUserSession(
        email: email,
        id: userId,
      );

      emit(AuthenticatedState(email: email, userId: userId));
    } catch (e) {
      emit(AuthFailureState(message: _mapAuthError(e)));
      emit(UnauthenticatedState());
    }
  }

  Future<void> _onSignUp(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadingState());
    try {
      await authRepository.signUp(
        email: event.email,
        password: event.password,
      );

      emit(AuthVerificationEmailSentState(email: event.email));
      emit(UnauthenticatedState());
    } catch (e) {
      emit(AuthFailureState(message: _mapAuthError(e)));
      emit(UnauthenticatedState());
    }
  }

  Future<void> _onSignOut(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadingState());
    try {
      await authRepository.signOut();
    } catch (_) {
      // Even if remote sign out fails, continue local logout
    }

    await settingsRepository.logout();
    emit(UnauthenticatedState());
  }

  String _mapAuthError(Object error) {
    if (error is AuthException) {
      final msg = error.message.toLowerCase();
      if (msg.contains('invalid login credentials') ||
          msg.contains('invalid grant')) {
        return 'Invalid email or password.';
      } else if (msg.contains('user already registered') ||
          msg.contains('already exists')) {
        return 'User with these credentials already exists.';
      } else if (msg.contains('password should be at least')) {
        return 'Password must be at least 6 characters.';
      } else if (msg.contains('invalid email')) {
        return 'Please enter a valid email address.';
      }
      return error.message;
    }
    return 'An error occurred connecting to the server. Please check your internet connection.';
  }
}
