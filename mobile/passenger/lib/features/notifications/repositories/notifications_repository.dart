import '../models/app_notification.dart';

/// Port for the notifications inbox.
///
/// TODO(backend): No notifications inbox endpoints exist yet. Expected contract:
///   * `GET    /users/me/notifications`            -> { items, nextCursor }
///   * `POST   /users/me/notifications/{id}/read`  -> 204
///   * `POST   /users/me/notifications/read-all`   -> 204
abstract class NotificationsRepository {
  Future<List<AppNotification>> list();
  Future<void> markRead(String id);
  Future<void> markAllRead();
}
