# Internal

Private infrastructure, applications, automation, and documentation for **Melo Lab**.

---

# Repository Structure

```text
internal/
├── infrastructure/
│   └── melolab-pihub/
│
├── applications/
│
├── automation/
│
├── docs/
│
└── scripts/
```

---

# Purpose

This repository serves as the central source of truth for:

* Infrastructure as Code
* Docker Compose stacks
* Internal applications
* Automation
* Monitoring
* Documentation
* Bootstrap scripts

Infrastructure should be reproducible from Git with minimal manual configuration.

---

# Design Principles

* Infrastructure first
* Dockerized services whenever possible
* Configuration stored in Git
* Secrets never committed
* Portable across Raspberry Pi, Proxmox, Ubuntu, macOS, and future hosts

---

# Current Infrastructure

## Pihub

Primary infrastructure node.

Current responsibilities:

* Cloudflared
* Homepage
* Uptime Kuma
* Pi-hole (planned)
* Grafana (planned)
* Loki (planned)
* Prometheus (planned)

Project location:

```text
infrastructure/melolab-pihub
```

---

# Scripts

Located under:

```text
scripts/
```

Current utilities:

```text
bootstrap.sh
install-basics.sh
install-cloudflared.sh
install-docker.sh
install-ship.sh
```

Install a new server:

```bash
./scripts/bootstrap.sh
```

---

# Git Workflow

Commit changes:

```bash
ship
```

or

```bash
ship "Describe changes"
```

Alias:

```bash
deploy "Describe changes"
```

---

# Backup Checklist

The following should be backed up regularly.

## Cloudflare

Location:

```text
~/.cloudflared/
```

Files:

```text
cert.pem
*.json
```

These files allow:

* Tunnel management
* DNS route management
* Tunnel authentication

**Do NOT commit these to Git.**

---

## Environment Files

```text
.env
```

Only commit:

```text
.env.example
```

---

## Runtime Data

As services are added, back up their data directories.

Examples:

```text
services/homepage/data
services/uptime-kuma/data
services/grafana/data
services/loki/data
services/prometheus/data
services/pihole/
```

These should be included in scheduled backups but ignored by Git.

---

# Disaster Recovery

To rebuild a new server:

1. Install Raspberry Pi OS / Ubuntu.
2. Clone this repository.
3. Run:

```bash
./scripts/bootstrap.sh
```

4. Restore:

```text
~/.cloudflared/
```

5. Restore runtime data.

6. Configure:

```text
.env
```

7. Start the stack:

```bash
docker compose up -d
```

The objective is to fully rebuild the infrastructure in less than 30 minutes.

---

# Security

Never commit:

* Passwords
* API Keys
* Private Keys
* Certificates
* Cloudflare credentials
* Tunnel JSON files
* Production databases

Always commit templates instead:

```text
.env.example
config.yml.example
```

---

# Future Roadmap

* Homepage Dashboard
* Uptime Kuma
* Cloudflared
* Pi-hole
* Grafana
* Loki
* Prometheus
* Centralized logging
* Automated backups
* Configuration management
* Infrastructure monitoring
* One-command server bootstrap
