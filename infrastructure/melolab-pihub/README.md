# MeloLab PiHub

PiHub is the central infrastructure node for the MeloLab homelab.

It provides core networking, monitoring, dashboarding, and future infrastructure services using Docker Compose v2 with a modular architecture.

---

# Goals

* Infrastructure as Code
* Docker-first deployments
* Modular Docker Compose
* Portable between Raspberry Pi, Ubuntu, Proxmox, and future hardware
* Easy disaster recovery
* Secure by default
* Fully documented

---

# Current Services

| Service     | Status     |
| ----------- | ---------- |
| Homepage    | ✅          |
| Uptime Kuma | ✅          |
| Cloudflared | ✅          |
| Pi-hole     | 🚧 Planned |
| Grafana     | 🚧 Planned |
| Loki        | 🚧 Planned |
| Prometheus  | 🚧 Planned |

---

# Directory Structure

```text
melolab-pihub/
│
├── .env
├── .env.example
├── .gitignore
├── compose.yml
│
├── compose/
│   ├── homepage/
│   │   └── compose.yml
│   │
│   ├── uptime-kuma/
│   │   └── compose.yml
│   │
│   ├── cloudflared/
│   │   └── compose.yml
│   │
│   ├── pihole/
│   │   └── compose.yml
│   │
│   ├── grafana/
│   │   └── compose.yml
│   │
│   ├── loki/
│   │   └── compose.yml
│   │
│   └── prometheus/
│       └── compose.yml
│
├── services/
│   ├── homepage/
│   │   └── config/
│   │       ├── bookmarks.yaml
│   │       ├── docker.yaml
│   │       ├── services.yaml
│   │       ├── settings.yaml
│   │       └── widgets.yaml
│   │
│   ├── uptime-kuma/
│   │   └── data/
│   │
│   ├── cloudflared/
│   │   └── config.yml
│   │
│   ├── pihole/
│   │   ├── etc-pihole/
│   │   └── etc-dnsmasq.d/
│   │
│   ├── grafana/
│   │   └── data/
│   │
│   ├── loki/
│   │   └── data/
│   │
│   └── prometheus/
│       └── data/
│
├── backups/
│
├── docs/
│
├── scripts/
│
├── AGENT.md
├── BACKLOG.md
├── CHANGELOG.md
└── README.md
```

---

# Configuration

Runtime configuration:

```text
.env
```

Template:

```text
.env.example
```

Never commit:

* .env
* API Keys
* Certificates
* Cloudflare credentials

---

# Docker

Validate:

```bash
docker compose config
```

Deploy:

```bash
docker compose up -d
```

Restart a service:

```bash
restart homepage
```

Restart entire stack:

```bash
restart all
```

---

# Cloudflare

Tunnel Name

```text
homelabinternal
```

Tunnel credentials are stored outside the repository:

```text
~/.cloudflared/
```

Contents:

```text
cert.pem
<tunnel-id>.json
```

These files are backed up but never committed to Git.

---

# Homepage

Public URL

```text
https://status.melolab.dev
```

Homepage configuration:

```text
services/homepage/config/
```

Current configuration files:

* services.yaml
* bookmarks.yaml
* widgets.yaml
* settings.yaml
* docker.yaml

---

# Uptime Kuma

Public URL

```text
https://uptime.melolab.dev
```

Persistent data:

```text
services/uptime-kuma/data
```

---

# Pi-hole (Planned)

DNS

```text
53/TCP
53/UDP
```

Admin

```text
https://pihole.melolab.dev
```

Persistent configuration:

```text
services/pihole/etc-pihole
services/pihole/etc-dnsmasq.d
```

---

# Backup

Current backup targets:

* Cloudflare credentials
* Docker configuration
* Compose files
* Environment files
* Persistent service data

See:

```text
backups/
```

---

# Restore

1. Install Raspberry Pi OS or Ubuntu.
2. Clone repository.
3. Run bootstrap.
4. Restore Cloudflare credentials.
5. Restore Docker volumes.
6. Configure .env.
7. Run:

```bash
docker compose up -d
```

---

# Roadmap

## Phase 1

* Homepage
* Uptime Kuma
* Cloudflared

## Phase 2

* Pi-hole
* Unbound

## Phase 3

* Grafana
* Loki
* Prometheus

## Phase 4

* Vaultwarden
* Gitea
* Portainer

## Phase 5

* Automated backups
* Centralized logging
* AI Infrastructure Assistant
* Cloudflare Access
* GitOps

---

# Design Principles

* Docker Compose v2
* Modular compose files
* Infrastructure as Code
* Portable architecture
* Minimal manual configuration
* Secure by default
* Documentation is part of the project

Every change should improve portability, maintainability, and recoverability.
