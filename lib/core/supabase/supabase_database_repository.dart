import 'supabase_repository.dart';

class SupabaseDatabaseRepository extends SupabaseRepository {
  SupabaseDatabaseRepository({
    required super.client,
  });


  Future<List<Map<String, dynamic>>> getAll(
    String table, {
    Map<String, dynamic>? filters,
    String? orderBy,
    bool ascending = true,
    int? limit,
  }) async {
    dynamic query = client.from(table).select();

    if (filters != null) {
      for (final entry in filters.entries) {
        query = query.eq(entry.key, entry.value);
      }
    } else {
        query = query.eq("user_id", client.auth.currentUser!.id);
    }

    if (orderBy != null) {
      query = query.order(
        orderBy,
        ascending: ascending,
      );
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    final response = await query;

    return List<Map<String, dynamic>>.from(response);
  }


  Future<Map<String, dynamic>?> getSingle(
    String table, {
    Map<String, dynamic>? filters,
  }) async {
    dynamic query = client.from(table).select();

    if (filters != null) {
      for (final entry in filters.entries) {
        query = query.eq(entry.key, entry.value);
      }
    }

    return await query.maybeSingle();
  }

  Future<Map<String, dynamic>> insert(
    String table,
    Map<String, dynamic> data,
  ) async {
    final response = await client
        .from(table)
        .insert(data)
        .select()
        .single();

    return response;
  }

  Future<List<Map<String, dynamic>>> insertMany(
    String table,
    List<Map<String, dynamic>> data,
  ) async {
    final response = await client
        .from(table)
        .insert(data)
        .select();

    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> update(
    String table,
    Map<String, dynamic> data, {
    required Map<String, dynamic> filters,
  }) async {
    dynamic query = client.from(table).update(data);

    for (final entry in filters.entries) {
      query = query.eq(entry.key, entry.value);
    }

    final response = await query
        .select()
        .single();

    return response;
  }

  Future<void> delete(
    String table, {
    required Map<String, dynamic> filters,
  }) async {
    dynamic query = client.from(table).delete();

    for (final entry in filters.entries) {
      query = query.eq(entry.key, entry.value);
    }

    await query;
  }

  Future<Map<String, dynamic>> upsert(
    String table,
    Map<String, dynamic> data, {
    String? onConflict,
  }) async {
    final response = await client
        .from(table)
        .upsert(
          data,
          onConflict: onConflict,
        )
        .select()
        .single();

    return response;
  }

  Future<dynamic> rpc(
    String functionName, {
    Map<String, dynamic>? params,
  }) async {
    return await client.rpc(
      functionName,
      params: params,
    );
  }
}