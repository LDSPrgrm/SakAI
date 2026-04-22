DROP TRIGGER IF EXISTS incident_status_history_trg ON incidents;
DROP FUNCTION IF EXISTS trg_incident_status_history();
DROP TABLE IF EXISTS incident_status_history;
