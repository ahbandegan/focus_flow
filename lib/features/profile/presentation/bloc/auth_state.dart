part of 'auth_bloc.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

final class AuthInitialState extends AuthState {}

final class AuthLoadingState extends AuthState {}

final class AuthenticatedState extends AuthState {
  final String email;
  final String? userId;

  const AuthenticatedState({required this.email, this.userId});

  @override
  List<Object?> get props => [email, userId];
}

final class UnauthenticatedState extends AuthState {}

final class AuthVerificationEmailSentState extends AuthState {
  final String email;

  const AuthVerificationEmailSentState({required this.email});

  @override
  List<Object?> get props => [email];
}

final class AuthFailureState extends AuthState {
  final String message;

  const AuthFailureState({required this.message});

  @override
  List<Object?> get props => [message];
}
