import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_repository.dart';

class SupabaseAuthRepository extends SupabaseRepository {
  SupabaseAuthRepository({
    required super.client,
  });

  User? get currentUser => client.auth.currentUser;

  Session? get currentSession => client.auth.currentSession;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    return await client.auth.signUp(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await client.auth.signOut();
  }
}