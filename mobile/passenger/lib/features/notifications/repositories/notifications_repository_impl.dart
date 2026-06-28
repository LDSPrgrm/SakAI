import 'package:sakai_shared/sakai_shared.dart';

import '../models/app_notification.dart';
import 'notifications_repository.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  NotificationsRepositoryImpl(this._client);

  // ignore: unused_field
  final SakaiApiClient _client;

  @override
  Future<List<AppNotification>> list() {
    // TODO(backend): wire to GET /users/me/notifications once endpoint exists.
    throw const BackendUnavailableException(feature: 'notifications');
  }

  @override
  Future<void> markRead(String id) {
    // TODO(backend): wire to POST /users/me/notifications/{id}/read.
    throw const BackendUnavailableException(feature: 'notifications');
  }

  @override
  Future<void> markAllRead() {
    // TODO(backend): wire to POST /users/me/notifications/read-all.
    throw const BackendUnavailableException(feature: 'notifications');
  }
}
