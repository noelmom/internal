# MeloLab PiHub

Central control-hub node for the MeloLab / Birdview homelab. Runs on a
Raspberry Pi 4B (Debian 13) and hosts the always-on infrastructure as a
modular **Docker Compose v2** stack: the remote-access dashboard, monitoring,
and the Cloudflare tunnel.

Everything is reached over Tailscale (tailnet `tail9b70d.ts.net`). The
dashboard is the primary UI; only what is explicitly noted is exposed to the
public internet.

---

# Goals

* Infrastructure as Code
* Docker-first, modular Compose (one file per service)
* Portable between Raspberry Pi, Ubuntu, and Proxmox
* Easy disaster recovery
* Secure by default
* Fully documented

---

# Services (as-built)

| Service     | Port  | Exposure            | Purpose                                        |
| ----------- | ----- | ------------------- | ---------------------------------------------- |
| dashboard   | 8090  | tailnet / LAN       | Custom nginx UI shell (HTTPS, Tailscale cert)  |
| webterm     | 8091  | via dashboard proxy | Go + xterm.js SSH terminals (client-side)      |
| guacamole   | 8080  | tailnet / LAN       | VNC/RDP tiles via guacd (server-side render)   |
| uptime-kuma | -     | Cloudflare tunnel   | Monitoring (behind Cloudflare Access)          |
| cloudflared | -     | -                   | Cloudflare tunnel for `*.melolab.dev`          |

Removed in the July 2026 pivot to a remote-access dashboard: **Homepage** and
**Pi-hole**. Grafana / Loki / Prometheus remain possible future additions but
are not deployed.

---

# Layout

```text
melolab-pihub/
|
+-- compose.yml            # top-level; includes compose/*.yml
|
+-- compose/               # one Compose file per service
|   +-- cloudflared.yml
|   +-- dashboard.yml
|   +-- guacamole.yml
|   +-- uptime-kuma.yml
|   +-- webterm.yml
|   +-- template.yml       # scaffold for a new service
|
+-- services/              # build contexts + static config
|   +-- cloudflared/       #   tunnel config.yml
|   +-- dashboard/         #   index.html (the dashboard shell)
|   +-- dashboard-nginx.conf
|   +-- guacamole/         #   connections.sql seed
|   +-- webterm/           #   Go + xterm.js terminal (see its README)
|
+-- runtime/               # gitignored: data, certs, keys (never committed)
|
+-- README.md
```

---

# Configuration

Runtime config lives in `.env` (gitignored), created from `.env.example`.

Never commit:

* `.env`
* API keys
* Certificates / private keys (`runtime/`)
* Cloudflare credentials

---

# Docker

```bash
docker compose config       # validate
docker compose up -d        # deploy / reconcile the whole stack
docker compose up -d <svc>  # one service
docker compose build <svc>  # rebuild an image (e.g. webterm)
docker compose restart <svc>
```

The top-level `compose.yml` uses `include:` to pull in each `compose/*.yml`;
all services share the external `pihub` network.

---

# Remote-access dashboard

Served by nginx at `https://pihub.tail9b70d.ts.net:8090` (TLS via a Tailscale
cert), tailnet/LAN only. It embeds:

* **Guacamole** tiles for VNC/RDP (rendered server-side by guacd).
* **webterm** tiles for SSH (rendered client-side with xterm.js) - proxied
  same-origin at `/webterm/` so clipboard and key handling work. See
  `services/webterm/README.md` for the UTF-8 locale fix and self-hosted font.

---

# Cloudflare

Tunnel name: `homelabinternal`. Credentials live outside the repo in
`~/.cloudflared/` (`cert.pem` + `<tunnel-id>.json`) - backed up, never
committed. Public endpoints (`*.melolab.dev`) are all gated by **Cloudflare
Access** with a specific-email allowlist.

---

# Backup / Restore

Config is the backup: the whole stack definition is in this repo, secrets are
in `.env` / 1Password, and persistent data is in `runtime/`. Rebuild is:

1. Install Raspberry Pi OS / Debian, clone this repo.
2. Restore `.env` and `~/.cloudflared/` credentials.
3. Restore `runtime/` data (or start fresh).
4. `docker compose up -d`.

Fleet backups (Proxmox -> Synology) are documented in the Birdview repo
(`docs/backups.md`), not here.

---

# Remote Access Roadmap

The dashboard is how the fleet is driven from a browser.

Current:

* **Guacamole (guacd)** - VNC/RDP tiles, rendered **server-side** as pixels.
* **webterm (Go + xterm.js)** - SSH terminals, rendered **client-side** in the
  browser. Self-hosted CaskaydiaCove Nerd Font (woff2) and a UTF-8 locale fix
  so Claude Code glyphs render. See `services/webterm/README.md`.

Next:

* **noVNC (pure JS) + a WebSocket-to-TCP proxy route** - render VNC
  client-side the same way webterm does for SSH, dropping the guacd raster.
* **Later: guacamole-lite (Node) or IronRDP** - client-side RDP.
* **Auth in front of webterm / the proxy** before any non-LAN exposure -
  today anyone who can reach the service can open any configured target.

---

# Design Principles

* Docker Compose v2, modular compose files
* Infrastructure as Code, portable architecture
* Minimal manual configuration
* Secure by default
* Documentation is part of the project

Every change should improve portability, maintainability, and recoverability.
