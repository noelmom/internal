-- Guacamole connection definitions for the melolab-pihub deployment.
-- Idempotent (re-runnable):
--   docker exec -i guac-postgres psql -U guacamole_user -d guacamole_db < connections.sql
--
-- SECRETS OMITTED (set in UI / separate step):
--   - "Mac Ai" VNC password
--   - private-key for the SSH-key connections: a single dedicated
--     guacamole@pihub ed25519 key, reused for mini-ai + pihub. Its pubkey is in
--     ~/.ssh/authorized_keys on each target; the private half lives only in the DB.
--
-- AUTH per connection:
--   pve    -> Tailscale SSH (no stored creds)
--   Mac Ai -> VNC password
--   mini-ai, pihub -> the shared guacamole@pihub key
--   (pihub cannot Tailscale-SSH to itself, so guacd reaches its own host via the
--    docker bridge gateway 172.19.0.1 using the key.)
--
-- HOST DEP: SSH connections run command=<tmux-menu> (attach w/ chooser or create).
--   pve + pihub: /usr/local/bin/tmux-menu ; mini-ai: /opt/homebrew/bin/tmux-menu.
--
-- NOTE: leave each connection guacd hostname/port blank (a literal 0 breaks it).

BEGIN;

INSERT INTO guacamole_connection (connection_name, protocol, max_connections, max_connections_per_user)
SELECT 'pve (root, Tailscale SSH)', 'ssh', 20, 20
WHERE NOT EXISTS (SELECT 1 FROM guacamole_connection WHERE connection_name='pve (root, Tailscale SSH)');
INSERT INTO guacamole_connection_parameter (connection_id, parameter_name, parameter_value)
SELECT c.connection_id, v.name, v.val FROM guacamole_connection c
JOIN (VALUES ('hostname','100.68.96.14'),('port','22'),('username','root'),
  ('command','/usr/local/bin/tmux-menu'),('recording-path','/recordings'),
  ('create-recording-path','true'),('recording-name','${GUAC_DATE}-${GUAC_TIME}-pve')) AS v(name,val) ON TRUE
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

INSERT INTO guacamole_connection (connection_name, protocol, max_connections, max_connections_per_user)
SELECT 'mini-ai (SSH)', 'ssh', 20, 20
WHERE NOT EXISTS (SELECT 1 FROM guacamole_connection WHERE connection_name='mini-ai (SSH)');
INSERT INTO guacamole_connection_parameter (connection_id, parameter_name, parameter_value)
SELECT c.connection_id, v.name, v.val FROM guacamole_connection c
JOIN (VALUES ('hostname','100.126.156.116'),('port','22'),('username','noelmomelo'),
  ('command','/opt/homebrew/bin/tmux-menu'),('recording-path','/recordings'),
  ('create-recording-path','true'),('recording-name','${GUAC_DATE}-${GUAC_TIME}-mini-ai')) AS v(name,val) ON TRUE
WHERE c.connection_name='mini-ai (SSH)'
ON CONFLICT (connection_id, parameter_name) DO UPDATE SET parameter_value=EXCLUDED.parameter_value;

INSERT INTO guacamole_connection (connection_name, protocol, max_connections, max_connections_per_user)
SELECT 'pihub (SSH)', 'ssh', 20, 20
WHERE NOT EXISTS (SELECT 1 FROM guacamole_connection WHERE connection_name='pihub (SSH)');
INSERT INTO guacamole_connection_parameter (connection_id, parameter_name, parameter_value)
SELECT c.connection_id, v.name, v.val FROM guacamole_connection c
JOIN (VALUES ('hostname','172.19.0.1'),('port','22'),('username','noelmomelo'),
  ('command','/usr/local/bin/tmux-menu'),('recording-path','/recordings'),
  ('create-recording-path','true'),('recording-name','${GUAC_DATE}-${GUAC_TIME}-pihub')) AS v(name,val) ON TRUE
WHERE c.connection_name='pihub (SSH)'
ON CONFLICT (connection_id, parameter_name) DO UPDATE SET parameter_value=EXCLUDED.parameter_value;

INSERT INTO guacamole_connection_permission (entity_id, connection_id, permission)
SELECT e.entity_id, c.connection_id, 'READ' FROM guacamole_entity e
JOIN guacamole_connection c ON c.connection_name IN ('pve (root, Tailscale SSH)','Mac Ai','mini-ai (SSH)','pihub (SSH)')
WHERE e.name='guacadmin' AND e.type='USER'
ON CONFLICT (entity_id, connection_id, permission) DO NOTHING;

COMMIT;
