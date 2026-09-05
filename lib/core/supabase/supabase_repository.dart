import 'package:supabase_flutter/supabase_flutter.dart';

abstract class SupabaseRepository {
  final SupabaseClient client;

  SupabaseRepository({
    required this.client,
  });
}