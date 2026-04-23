-- 026_create_notification_outbox.down.sql

DELETE FROM notification_templates WHERE event LIKE 'alert.%';

DROP INDEX IF EXISTS idx_notification_outbox_pending;
DROP TABLE IF EXISTS notification_outbox;
