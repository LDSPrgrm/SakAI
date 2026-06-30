import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../models/app_notification.dart';
import '../repositories/notifications_repository.dart';
import '../../../app/providers.dart';

class NotificationsState {
  const NotificationsState({
    this.loading = false,
    this.items = const [],
    this.errorMessage,
    this.backendUnavailable,
  });

  final bool loading;
  final List<AppNotification> items;
  final String? errorMessage;
  final BackendUnavailableException? backendUnavailable;

  bool get isEmpty => items.isEmpty;
  int get unreadCount => items.where((n) => !n.read).length;

  NotificationsState copyWith({
    bool? loading,
    List<AppNotification>? items,
    String? errorMessage,
    BackendUnavailableException? backendUnavailable,
  }) {
    return NotificationsState(
      loading: loading ?? this.loading,
      items: items ?? this.items,
      errorMessage: errorMessage,
      backendUnavailable: backendUnavailable,
    );
  }
}

class NotificationsNotifier extends Notifier<NotificationsState> {
  @override
  NotificationsState build() {
    Future.microtask(load);
    return const NotificationsState(loading: true);
  }

  NotificationsRepository get _repo => ref.read(notificationsRepositoryProvider);

  Future<void> load() async {
    state = state.copyWith(loading: true, errorMessage: null);
    try {
      final items = await _repo.list();
      state = NotificationsState(items: items);
    } on BackendUnavailableException catch (e) {
      state = NotificationsState(backendUnavailable: e);
    } catch (e) {
      state = NotificationsState(errorMessage: e.toString());
    }
  }

  Future<void> markRead(String id) async {
    try {
      await _repo.markRead(id);
      state = state.copyWith(
        items: [
          for (final n in state.items) n.id == id ? n.copyWith(read: true) : n,
        ],
      );
    } catch (_) {}
  }

  Future<void> markAllRead() async {
    try {
      await _repo.markAllRead();
      state = state.copyWith(
        items: [for (final n in state.items) n.copyWith(read: true)],
      );
    } catch (_) {}
  }
}

final notificationsNotifierProvider =
    NotifierProvider<NotificationsNotifier, NotificationsState>(
      NotificationsNotifier.new,
    );
