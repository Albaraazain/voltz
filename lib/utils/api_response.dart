enum ApiStatus {
  initial,
  loading,
  completed,
  error,
}

class ApiResponse<T> {
  final ApiStatus status;
  final T? data;
  final String? error;

  ApiResponse._({
    required this.status,
    this.data,
    this.error,
  });

  factory ApiResponse.initial() {
    return ApiResponse._(status: ApiStatus.initial);
  }

  factory ApiResponse.loading() {
    return ApiResponse._(status: ApiStatus.loading);
  }

  factory ApiResponse.completed(T data) {
    return ApiResponse._(
      status: ApiStatus.completed,
      data: data,
    );
  }

  factory ApiResponse.error(String error) {
    return ApiResponse._(
      status: ApiStatus.error,
      error: error,
    );
  }

  bool get isInitial => status == ApiStatus.initial;
  bool get isLoading => status == ApiStatus.loading;
  bool get isCompleted => status == ApiStatus.completed;
  bool get isError => status == ApiStatus.error;
  bool get hasData => data != null;
}
