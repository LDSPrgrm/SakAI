import 'package:sakai_api_client/sakai_api_client.dart';

import '../models/app_notification.dart';
import 'notifications_repository.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  NotificationsRepositoryImpl(this._client);

  // ignore: unused_field
  final SakaiApiClient _client;

  @override
  Future<List<AppNotification>> list() {
    // TODO(backend): wire to GET /users/me/notifications once endpoint exists.
    throw UnimplementedError('Notifications inbox endpoint not implemented.');
  }

  @override
  Future<void> markRead(String id) {
    // TODO(backend): wire to POST /users/me/notifications/{id}/read.
    throw UnimplementedError('Mark-read endpoint not implemented.');
  }

  @override
  Future<void> markAllRead() {
    // TODO(backend): wire to POST /users/me/notifications/read-all.
    throw UnimplementedError('Mark-all-read endpoint not implemented.');
  }
}
