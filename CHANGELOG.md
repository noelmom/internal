# Changelog

All notable changes to the MeloLab Infrastructure project will be documented in this file.

The format loosely follows [Keep a Changelog](https://keepachangelog.com/) and uses semantic versioning where practical.

---

# Unreleased

## Planned

* Pi-hole
* Unbound
* Grafana
* Loki
* Grafana Alloy
* Cloudflare Access
* Vaultwarden
* Gitea
* Backup automation
* labctl utility

---

# v0.2.0 - Foundation Milestone

**Date:** 2026-06-24 / 2026-06-25

## Added

### Repository

* Created centralized infrastructure repository.
* Standardized project layout under `/opt/internal`.
* Added documentation structure.
* Added `.gitignore` for secrets and runtime files.
* Removed accidentally committed secrets from Git tracking.

### Infrastructure Layout

* Standardized directory structure:

  * infrastructure/
  * applications/
  * automation/
  * backups/
  * scripts/
  * docs/

### Docker

* Migrated to modular Docker Compose v2 layout.
* Split services into individual compose files.
* Created reusable services directory.
* Added persistent bind mounts.

### Cloudflare

* Installed cloudflared.
* Created `homelabinternal` tunnel.
* Configured Dockerized cloudflared service.
* Added tunnel configuration management.
* Successfully exposed Homepage through Cloudflare Tunnel.
* Successfully exposed Uptime Kuma through Cloudflare Tunnel.

### Homepage

* Installed Homepage.
* Configured Docker integration.
* Added external HTTPS access.
* Configured `HOMEPAGE_ALLOWED_HOSTS`.
* Fixed host validation errors.
* Verified public access through Cloudflare Tunnel.

### Uptime Kuma

* Installed Uptime Kuma.
* Added persistent data storage.
* Exposed through Cloudflare Tunnel.

### Documentation

* Added README files.
* Added backup documentation.
* Added infrastructure planning documentation.

### Backup Strategy

* Defined backup locations.
* Defined credentials to preserve.
* Standardized backup directory structure.

### Git

* Created reusable `ship` helper.
* Simplified commit workflow.
* Standardized repository organization.

### DNS

* Identified local router DNS negative caching issue.
* Verified Cloudflare DNS propagation.
* Confirmed Cloudflare Tunnel functionality.
* Determined local DNS cache as cause of delayed hostname resolution.

---

# v0.1.0 - Initial Bootstrap

**Date:** 2026-06-24

## Added

* Raspberry Pi 4 deployment.
* Docker installation.
* Git installation.
* Initial project structure.
* Initial Docker Compose deployment.
* GitHub repository creation.
* SSH configuration.
* Cloudflared installation.
* Initial documentation.

---

# Notes

## Lessons Learned

* Cloudflare Tunnel was functioning correctly throughout troubleshooting.
* Router DNS cache can retain NXDOMAIN responses after new DNS records are created.
* Environment variable changes may require `docker compose up -d --force-recreate`.
* Keep credentials outside the Git repository.
* Modular Docker Compose layout is significantly easier to maintain than a single large compose file.

---

## Current Services

| Service     | Status        |
| ----------- | ------------- |
| Homepage    | ✅ Operational |
| Uptime Kuma | ✅ Operational |
| Cloudflared | ✅ Operational |

---

## Next Milestone

* Deploy Pi-hole
* Migrate LAN DNS to Pi-hole
* Deploy Unbound
* Deploy Grafana
* Deploy Loki
