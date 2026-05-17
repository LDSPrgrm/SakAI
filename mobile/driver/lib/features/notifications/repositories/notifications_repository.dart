import '../models/app_notification.dart';

/// TODO(backend): see passenger app's notifications_repository for endpoint
/// contract notes. No endpoints exist yet.
abstract class NotificationsRepository {
  Future<List<AppNotification>> list();
  Future<void> markRead(String id);
  Future<void> markAllRead();
}
