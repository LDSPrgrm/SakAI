import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart' show rideHistoryRepositoryProvider;
import '../models/ride_history_item.dart';
import '../repositories/ride_history_repository.dart';
import '../repositories/ride_history_repository_impl.dart'
    show RideHistoryException;

enum RideHistoryStatus { initial, loading, success, error, empty }

class RideHistoryListState {
  const RideHistoryListState({
    this.status = RideHistoryStatus.initial,
    this.items = const [],
    this.error,
    this.currentPage = 1,
    this.hasMore = false,
    this.isRefreshing = false,
    this.isLoadingMore = false,
    this.activeFilter,
  });

  final RideHistoryStatus status;
  final List<RideHistoryItem> items;
  final String? error;
  final int currentPage;
  final bool hasMore;
  final bool isRefreshing;
  final bool isLoadingMore;
  final String? activeFilter;

  RideHistoryListState copyWith({
    RideHistoryStatus? status,
    List<RideHistoryItem>? items,
    String? error,
    int? currentPage,
    bool? hasMore,
    bool? isRefreshing,
    bool? isLoadingMore,
    String? activeFilter,
    bool clearError = false,
    bool clearItems = false,
    bool clearFilter = false,
  }) {
    return RideHistoryListState(
      status: status ?? this.status,
      items: clearItems ? [] : (items ?? this.items),
      error: clearError ? null : (error ?? this.error),
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      activeFilter: clearFilter ? null : (activeFilter ?? this.activeFilter),
    );
  }
}

final rideHistoryListNotifierProvider =
    NotifierProvider<RideHistoryListNotifier, RideHistoryListState>(
      RideHistoryListNotifier.new,
    );

class RideHistoryListNotifier extends Notifier<RideHistoryListState> {
  RideHistoryRepository get _repo => ref.read(rideHistoryRepositoryProvider);

  static const int _pageSize = 20;

  @override
  RideHistoryListState build() => const RideHistoryListState();

  /// Load history from the beginning (page 1).
  Future<void> loadHistory({bool refresh = false}) async {
    if (refresh) {
      state = state.copyWith(
        isRefreshing: true,
        clearError: true,
        clearItems: true,
      );
    } else {
      state = state.copyWith(
        status: RideHistoryStatus.loading,
        clearError: true,
        clearItems: true,
      );
    }

    try {
      final items = await _repo.getRideHistory(
        page: 1,
        limit: _pageSize,
        status: state.activeFilter,
      );

      final hasMore = _repo.hasMore;

      if (items.isEmpty) {
        state = state.copyWith(
          status: RideHistoryStatus.empty,
          isRefreshing: false,
          items: [],
          hasMore: false,
          currentPage: 1,
        );
        return;
      }

      state = state.copyWith(
        status: RideHistoryStatus.success,
        items: items,
        hasMore: hasMore,
        currentPage: 1,
        isRefreshing: false,
      );
    } catch (e) {
      final message = e is RideHistoryException
          ? e.userMessage
          : 'Failed to load ride history.';
      state = state.copyWith(
        status: RideHistoryStatus.error,
        error: message,
        isRefreshing: false,
      );
    }
  }

  /// Load the next page for infinite scroll / pagination.
  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore) return;

    state = state.copyWith(isLoadingMore: true, clearError: true);

    try {
      final nextPage = state.currentPage + 1;
      final newItems = await _repo.getRideHistory(
        page: nextPage,
        limit: _pageSize,
        status: state.activeFilter,
      );

      final hasMore = _repo.hasMore;

      state = state.copyWith(
        items: [...state.items, ...newItems],
        hasMore: hasMore,
        currentPage: nextPage,
        isLoadingMore: false,
      );
    } catch (e) {
      final message = e is RideHistoryException
          ? e.userMessage
          : 'Failed to load more rides.';
      state = state.copyWith(error: message, isLoadingMore: false);
    }
  }

  /// Pull-to-refresh handler.
  Future<void> refresh() async {
    await loadHistory(refresh: true);
  }

  /// Apply a status filter (e.g. 'completed', 'cancelled') or null for all.
  Future<void> setFilter(String? status) async {
    state = state.copyWith(activeFilter: status, clearFilter: status == null);
    await loadHistory();
  }

  /// Remove a specific history item from the state.
  void removeRecentItem(String id) {
    state = state.copyWith(
      items: state.items.where((item) => item.id != id).toList(),
    );
  }
}
