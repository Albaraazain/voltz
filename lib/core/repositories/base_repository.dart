import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/api_response.dart';

/// Base repository class that implements common CRUD operations
abstract class BaseRepository<T> {
  final SupabaseClient supabase;
  final String table;

  BaseRepository(this.supabase, this.table);

  /// Convert a JSON map to an entity
  T fromJson(Map<String, dynamic> json);

  /// Convert an entity to a JSON map
  Map<String, dynamic> toJson(T entity);

  /// Create a new record
  Future<ApiResponse<T>> create(T entity) async {
    try {
      final response =
          await supabase.from(table).insert(toJson(entity)).select().single();

      return ApiResponse.success(fromJson(response));
    } catch (error, stackTrace) {
      return ApiResponse.error(error, stackTrace);
    }
  }

  /// Read a record by ID
  Future<ApiResponse<T>> read(String id) async {
    try {
      final response =
          await supabase.from(table).select().eq('id', id).single();

      return ApiResponse.success(fromJson(response));
    } catch (error, stackTrace) {
      return ApiResponse.error(error, stackTrace);
    }
  }

  /// Update a record
  Future<ApiResponse<T>> update(String id, T entity) async {
    try {
      final response = await supabase
          .from(table)
          .update(toJson(entity))
          .eq('id', id)
          .select()
          .single();

      return ApiResponse.success(fromJson(response));
    } catch (error, stackTrace) {
      return ApiResponse.error(error, stackTrace);
    }
  }

  /// Delete a record
  Future<ApiResponse<bool>> delete(String id) async {
    try {
      await supabase.from(table).delete().eq('id', id);

      return ApiResponse.success(true);
    } catch (error, stackTrace) {
      return ApiResponse.error(error, stackTrace);
    }
  }

  /// List all records with optional filtering
  Future<ApiResponse<List<T>>> list({
    Map<String, dynamic>? filters,
    String? orderBy,
    bool ascending = true,
    int? limit,
    int? offset,
  }) async {
    try {
      dynamic query = supabase.from(table).select();

      // Apply filters if provided
      if (filters != null) {
        filters.forEach((key, value) {
          if (value != null) {
            query = query.eq(key, value);
          }
        });
      }

      // Apply ordering if provided
      if (orderBy != null) {
        query = ascending
            ? query.order(orderBy)
            : query.order(orderBy, ascending: false);
      }

      // Apply pagination if provided
      if (limit != null) {
        query = query.limit(limit);
      }
      if (offset != null) {
        query = query.range(offset, offset + (limit ?? 10) - 1);
      }

      final response = await query;
      final items = (response as List)
          .map((item) => fromJson(item as Map<String, dynamic>))
          .toList();

      return ApiResponse.success(items);
    } catch (error, stackTrace) {
      return ApiResponse.error(error, stackTrace);
    }
  }

  /// Stream records with real-time updates
  Stream<ApiResponse<List<T>>> stream({
    Map<String, dynamic>? filters,
    String? orderBy,
    bool ascending = true,
    int? limit,
  }) async* {
    yield ApiResponse.loading();

    try {
      dynamic query = supabase.from(table).stream(primaryKey: ['id']);

      // Apply filters if provided
      if (filters != null) {
        filters.forEach((key, value) {
          if (value != null) {
            query = query.eq(key, value);
          }
        });
      }

      // Apply ordering if provided
      if (orderBy != null) {
        query = ascending
            ? query.order(orderBy)
            : query.order(orderBy, ascending: false);
      }

      // Apply limit if provided
      if (limit != null) {
        query = query.limit(limit);
      }

      await for (final response in query) {
        final items = response
            .map((item) => fromJson(item as Map<String, dynamic>))
            .toList();
        yield ApiResponse.success(items);
      }
    } catch (error, stackTrace) {
      yield ApiResponse.error(error, stackTrace);
    }
  }

  /// Execute a custom query
  Future<ApiResponse<List<T>>> customQuery(
    Future<List<Map<String, dynamic>>> Function(SupabaseClient) queryBuilder,
  ) async {
    try {
      final response = await queryBuilder(supabase);
      final items = response.map((item) => fromJson(item)).toList();
      return ApiResponse.success(items);
    } catch (error, stackTrace) {
      return ApiResponse.error(error, stackTrace);
    }
  }

  /// Execute a custom mutation
  Future<ApiResponse<T>> customMutation(
    Future<Map<String, dynamic>> Function(SupabaseClient) mutationBuilder,
  ) async {
    try {
      final response = await mutationBuilder(supabase);
      return ApiResponse.success(fromJson(response));
    } catch (error, stackTrace) {
      return ApiResponse.error(error, stackTrace);
    }
  }
}
