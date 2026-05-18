import 'package:sakai_shared/sakai_shared.dart';

import '../models/app_notification.dart';
import 'notifications_repository.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  NotificationsRepositoryImpl(this._client);
  // ignore: unused_field
  final SakaiApiClient _client;

  @override
  Future<List<AppNotification>> list() {
    throw const BackendUnavailableException(feature: 'notifications');
  }

  @override
  Future<void> markRead(String id) {
    throw const BackendUnavailableException(feature: 'notifications');
  }

  @override
  Future<void> markAllRead() {
    throw const BackendUnavailableException(feature: 'notifications');
  }
}
