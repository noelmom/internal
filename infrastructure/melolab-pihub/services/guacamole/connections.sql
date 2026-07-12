-- Guacamole connection definitions for the melolab-pihub deployment.
-- Idempotent; safe to re-run. Apply with:
--   docker exec -i guac-postgres psql -U guacamole_user -d guacamole_db < connections.sql
--
-- SECRETS ARE OMITTED (set them in the UI or via a separate secret step):
--   - "Mac Ai" VNC password
--   - "mini-ai (SSH)" private-key (dedicated guacamole@pihub ed25519 key; its
--     public half is in mini-ai:~/.ssh/authorized_keys)
--
-- NOTE: leave each connection's "guacd" hostname/port blank. A literal 0 in
-- proxy_port makes the webapp connect to guacd:0 -> "connection refused".

BEGIN;

INSERT INTO guacamole_connection (connection_name, protocol)
SELECT 'pve (root, Tailscale SSH)', 'ssh'
WHERE NOT EXISTS (SELECT 1 FROM guacamole_connection WHERE connection_name='pve (root, Tailscale SSH)');
INSERT INTO guacamole_connection_parameter (connection_id, parameter_name, parameter_value)
SELECT c.connection_id, v.name, v.val FROM guacamole_connection c
JOIN (VALUES ('hostname','100.68.96.14'),('port','22'),('username','root'),
  ('recording-path','/recordings'),('create-recording-path','true'),
  ('recording-name','${GUAC_DATE}-${GUAC_TIME}-pve')) AS v(name,val) ON TRUE
WHERE c.connection_name='pve (root, Tailscale SSH)'
ON CONFLICT (connection_id, parameter_name) DO UPDATE SET parameter_value=EXCLUDED.parameter_value;

INSERT INTO guacamole_connection (connection_name, protocol)
SELECT 'Mac Ai', 'vnc'
WHERE NOT EXISTS (SELECT 1 FROM guacamole_connection WHERE connection_name='Mac Ai');
INSERT INTO guacamole_connection_parameter (connection_id, parameter_name, parameter_value)
SELECT c.connection_id, v.name, v.val FROM guacamole_connection c
JOIN (VALUES ('hostname','100.126.156.116'),('port','5900'),('username','noelmomelo'),
  ('clipboard-encoding','ISO8859-1'),('recording-path','/recordings'),
  ('create-recording-path','true'),('recording-name','${GUAC_DATE}-${GUAC_TIME}-mac-ai')) AS v(name,val) ON TRUE
WHERE c.connection_name='Mac Ai'
ON CONFLICT (connection_id, parameter_name) DO UPDATE SET parameter_value=EXCLUDED.parameter_value;

INSERT INTO guacamole_connection (connection_name, protocol)
SELECT 'mini-ai (SSH)', 'ssh'
WHERE NOT EXISTS (SELECT 1 FROM guacamole_connection WHERE connection_name='mini-ai (SSH)');
INSERT INTO guacamole_connection_parameter (connection_id, parameter_name, parameter_value)
SELECT c.connection_id, v.name, v.val FROM guacamole_connection c
JOIN (VALUES ('hostname','100.126.156.116'),('port','22'),('username','noelmomelo'),
  ('recording-path','/recordings'),('create-recording-path','true'),
  ('recording-name','${GUAC_DATE}-${GUAC_TIME}-mini-ai')) AS v(name,val) ON TRUE
WHERE c.connection_name='mini-ai (SSH)'
ON CONFLICT (connection_id, parameter_name) DO UPDATE SET parameter_value=EXCLUDED.parameter_value;

INSERT INTO guacamole_connection_permission (entity_id, connection_id, permission)
SELECT e.entity_id, c.connection_id, 'READ' FROM guacamole_entity e
JOIN guacamole_connection c ON c.connection_name IN ('pve (root, Tailscale SSH)','Mac Ai','mini-ai (SSH)')
WHERE e.name='guacadmin' AND e.type='USER'
ON CONFLICT (entity_id, connection_id, permission) DO NOTHING;

COMMIT;
