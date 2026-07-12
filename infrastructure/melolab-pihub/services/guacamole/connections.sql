-- Guacamole connection definitions for the melolab-pihub deployment.
-- Idempotent; safe to re-run:
--   docker exec -i guac-postgres psql -U guacamole_user -d guacamole_db < connections.sql
--
-- SECRETS ARE OMITTED (set in the UI or a separate step):
--   - "Mac Ai" VNC password
--   - "mini-ai (SSH)" private-key (dedicated guacamole@pihub ed25519 key; pubkey
--     lives in mini-ai:~/.ssh/authorized_keys)
--
-- HOST DEPENDENCY: SSH connections run command=/usr/local/bin/tmux-menu, a small
--   script on each target that attaches a tmux session (with a chooser) or makes
--   one if none. Targets need tmux + that script.
--
-- NOTE: leave each connection guacd hostname/port blank; a literal 0 in
-- proxy_port makes the webapp hit guacd:0 -> connection refused.

BEGIN;

INSERT INTO guacamole_connection (connection_name, protocol)
SELECT 'pve (root, Tailscale SSH)', 'ssh'
WHERE NOT EXISTS (SELECT 1 FROM guacamole_connection WHERE connection_name='pve (root, Tailscale SSH)');
INSERT INTO guacamole_connection_parameter (connection_id, parameter_name, parameter_value)
SELECT c.connection_id, v.name, v.val FROM guacamole_connection c
JOIN (VALUES ('hostname','100.68.96.14'),('port','22'),('username','root'),
  ('command','/usr/local/bin/tmux-menu'),
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
