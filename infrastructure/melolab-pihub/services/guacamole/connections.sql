-- Guacamole connection definitions for the melolab-pihub deployment.
-- Idempotent; safe to re-run. Apply with:
--   docker exec -i guac-postgres psql -U guacamole_user -d guacamole_db < connections.sql
--
-- SECRETS: the Mac Ai VNC password is intentionally NOT stored here. Set it in
-- the Guacamole UI (Connections > Mac Ai > "Password"). Everything else is
-- non-sensitive (pve uses Tailscale SSH, no stored credentials).
--
-- NOTE: leave each connection's "guacd" hostname/port blank. A literal 0 in
-- proxy_port makes the webapp connect to guacd:0 -> "connection refused".

BEGIN;

-- 1) pve - SSH brokered by Tailscale SSH (no stored credentials)
INSERT INTO guacamole_connection (connection_name, protocol)
SELECT 'pve (root, Tailscale SSH)', 'ssh'
WHERE NOT EXISTS (SELECT 1 FROM guacamole_connection WHERE connection_name='pve (root, Tailscale SSH)');

INSERT INTO guacamole_connection_parameter (connection_id, parameter_name, parameter_value)
SELECT c.connection_id, v.name, v.val
FROM guacamole_connection c
JOIN (VALUES
  ('hostname','100.68.96.14'), ('port','22'), ('username','root'),
  ('recording-path','/recordings'), ('create-recording-path','true'),
  ('recording-name','${GUAC_DATE}-${GUAC_TIME}-pve')
) AS v(name,val) ON TRUE
WHERE c.connection_name='pve (root, Tailscale SSH)'
ON CONFLICT (connection_id, parameter_name) DO UPDATE SET parameter_value=EXCLUDED.parameter_value;

-- 2) Mac Ai - VNC to mini-ai (macOS Screen Sharing). Set VNC password in the UI.
INSERT INTO guacamole_connection (connection_name, protocol)
SELECT 'Mac Ai', 'vnc'
WHERE NOT EXISTS (SELECT 1 FROM guacamole_connection WHERE connection_name='Mac Ai');

INSERT INTO guacamole_connection_parameter (connection_id, parameter_name, parameter_value)
SELECT c.connection_id, v.name, v.val
FROM guacamole_connection c
JOIN (VALUES
  ('hostname','100.126.156.116'), ('port','5900'), ('username','noelmomelo'),
  ('clipboard-encoding','ISO8859-1'),
  ('recording-path','/recordings'), ('create-recording-path','true'),
  ('recording-name','${GUAC_DATE}-${GUAC_TIME}-mac-ai')
) AS v(name,val) ON TRUE
WHERE c.connection_name='Mac Ai'
ON CONFLICT (connection_id, parameter_name) DO UPDATE SET parameter_value=EXCLUDED.parameter_value;

-- Grant READ on both to guacadmin
INSERT INTO guacamole_connection_permission (entity_id, connection_id, permission)
SELECT e.entity_id, c.connection_id, 'READ'
FROM guacamole_entity e
JOIN guacamole_connection c ON c.connection_name IN ('pve (root, Tailscale SSH)','Mac Ai')
WHERE e.name='guacadmin' AND e.type='USER'
ON CONFLICT (entity_id, connection_id, permission) DO NOTHING;

COMMIT;
