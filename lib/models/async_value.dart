class AsyncValue<T> {
  final T? data;
  final Object? error;
  final bool isLoading;

  const AsyncValue._({
    this.data,
    this.error,
    this.isLoading = false,
  });

  const AsyncValue.data(T value)
      : data = value,
        error = null,
        isLoading = false;

  const AsyncValue.error(Object error)
      : data = null,
        error = error,
        isLoading = false;

  const AsyncValue.loading()
      : data = null,
        error = null,
        isLoading = true;

  bool get hasData => data != null;
  bool get hasError => error != null;

  R when<R>({
    required R Function(T data) data,
    required R Function(Object error) error,
    required R Function() loading,
  }) {
    if (isLoading) return loading();
    if (this.error != null) return error(this.error!);
    if (this.data != null) return data(this.data as T);
    throw StateError('Unreachable');
  }
}
