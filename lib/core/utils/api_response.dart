import 'package:flutter/foundation.dart';
import 'error_handler.dart';

/// Represents the state of an API response
enum ApiStatus {
  initial,
  loading,
  success,
  error,
}

/// Generic class to handle API responses
class ApiResponse<T> {
  final ApiStatus status;
  final T? data;
  final AppException? error;
  final bool isLoading;

  ApiResponse._({
    this.status = ApiStatus.initial,
    this.data,
    this.error,
    this.isLoading = false,
  });

  /// Creates an initial state
  factory ApiResponse.initial() => ApiResponse._();

  /// Creates a loading state
  factory ApiResponse.loading() => ApiResponse._(
        status: ApiStatus.loading,
        isLoading: true,
      );

  /// Creates a success state with data
  factory ApiResponse.success(T data) => ApiResponse._(
        status: ApiStatus.success,
        data: data,
      );

  /// Creates an error state
  factory ApiResponse.error(dynamic error, [StackTrace? stackTrace]) {
    final appException = ErrorHandler.handleError(error, stackTrace);
    if (kDebugMode) {
      print('API Error: ${appException.toString()}');
      if (appException.stackTrace != null) {
        print('Stacktrace: ${appException.stackTrace}');
      }
    }
    return ApiResponse._(
      status: ApiStatus.error,
      error: appException,
    );
  }

  /// Whether the response is in initial state
  bool get isInitial => status == ApiStatus.initial;

  /// Whether the response has error
  bool get hasError => status == ApiStatus.error;

  /// Whether the response has data
  bool get hasData => data != null;

  /// Gets the error message if any
  String? get errorMessage => error?.message;

  /// Maps the response to a different type
  ApiResponse<R> map<R>(R Function(T data) mapper) {
    return ApiResponse._(
      status: status,
      data: hasData ? mapper(data as T) : null,
      error: error,
      isLoading: isLoading,
    );
  }

  /// Handles different states with callbacks
  R when<R>({
    required R Function() initial,
    required R Function() loading,
    required R Function(T data) success,
    required R Function(AppException error) error,
  }) {
    switch (status) {
      case ApiStatus.initial:
        return initial();
      case ApiStatus.loading:
        return loading();
      case ApiStatus.success:
        return success(data as T);
      case ApiStatus.error:
        return error(this.error!);
    }
  }

  @override
  String toString() {
    return 'ApiResponse{status: $status, data: $data, error: $error, isLoading: $isLoading}';
  }
}

/// Extension to handle Future operations with ApiResponse
extension FutureApiResponseExtension<T> on Future<T> {
  /// Converts a Future to a Future<ApiResponse>
  Future<ApiResponse<T>> toApiResponse() async {
    try {
      final data = await this;
      return ApiResponse.success(data);
    } catch (error, stackTrace) {
      return ApiResponse.error(error, stackTrace);
    }
  }
}

/// Extension to handle Stream operations with ApiResponse
extension StreamApiResponseExtension<T> on Stream<T> {
  /// Converts a Stream to a Stream<ApiResponse>
  Stream<ApiResponse<T>> toApiResponse() async* {
    yield ApiResponse.loading();
    try {
      await for (final data in this) {
        yield ApiResponse.success(data);
      }
    } catch (error, stackTrace) {
      yield ApiResponse.error(error, stackTrace);
    }
  }
}
