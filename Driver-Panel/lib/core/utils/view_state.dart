/// Generic async state for MVVM view models.
sealed class ViewState<T> {
  const ViewState();
}

class ViewStateInitial<T> extends ViewState<T> {
  const ViewStateInitial();
}

class ViewStateLoading<T> extends ViewState<T> {
  const ViewStateLoading();
}

class ViewStateSuccess<T> extends ViewState<T> {
  const ViewStateSuccess(this.data);
  final T data;
}

class ViewStateError<T> extends ViewState<T> {
  const ViewStateError(this.message);
  final String message;
}

class PaginatedState<T> {
  const PaginatedState({
    this.items = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
    this.page = 1,
  });

  final List<T> items;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;
  final int page;

  PaginatedState<T> copyWith({
    List<T>? items,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    int? page,
  }) {
    return PaginatedState<T>(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: error,
      page: page ?? this.page,
    );
  }
}
