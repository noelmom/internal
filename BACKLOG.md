# MeloLab Infrastructure Backlog

## High Priority

### Networking

* [ ] Deploy Pi-hole
* [ ] Configure Pi-hole as primary DNS for home network
* [ ] Deploy Unbound behind Pi-hole
* [ ] Migrate clients from router DNS to Pi-hole
* [ ] Configure local DNS records (*.local and internal services)

### Monitoring

* [ ] Deploy Grafana
* [ ] Deploy Loki
* [ ] Deploy Grafana Alloy
* [ ] Create infrastructure dashboards
* [ ] Centralize Docker logs
* [ ] Centralize Cloudflared logs

### Security

* [ ] Protect public services with Cloudflare Access
* [ ] Restrict Homepage behind Cloudflare Access
* [ ] Restrict Uptime Kuma behind Cloudflare Access
* [ ] Add MFA enforcement
* [ ] Review Docker secrets management
* [ ] Replace plaintext secrets with encrypted storage

---

# Homepage

* [ ] Add Pihub widget
* [ ] Add Uptime Kuma widget
* [ ] Add Grafana widget
* [ ] Add Pi-hole widget
* [ ] Add Proxmox widget
* [ ] Add NAS widget
* [ ] Add AI Services section
* [ ] Add Infrastructure section
* [ ] Add Weather widget
* [ ] Add Docker container widgets
* [ ] Display CPU / RAM / Disk utilization
* [ ] Display Docker health

---

# Docker Management

* [ ] Build `labctl` utility
* [ ] `labctl status`
* [ ] `labctl restart <service>`
* [ ] `labctl restart all`
* [ ] `labctl logs <service>`
* [ ] `labctl shell <service>`
* [ ] `labctl update`
* [ ] `labctl pull`
* [ ] `labctl backup`
* [ ] `labctl restore`
* [ ] `labctl doctor`
* [ ] `labctl health`

---

# Backups

* [ ] Automatic nightly backups
* [ ] Backup Docker volumes
* [ ] Backup cloudflared credentials
* [ ] Backup Homepage configuration
* [ ] Backup Pi-hole configuration
* [ ] Backup Grafana dashboards
* [ ] Backup Loki configuration
* [ ] Verify backup integrity (checksums)
* [ ] Restore automation
* [ ] Discord backup notifications

---

# Logging

* [ ] Docker log aggregation
* [ ] Cloudflared log aggregation
* [ ] AI Agent log aggregation
* [ ] SSH authentication logs
* [ ] Infrastructure audit logs

---

# Automation

* [ ] Automatic Docker image updates
* [ ] Automatic security updates
* [ ] Automatic health checks
* [ ] Automatic container restart policy validation
* [ ] Automatic infrastructure inventory
* [ ] Automatic documentation generation

---

# AI

* [ ] Deploy Local Vox AI
* [ ] Deploy Hermes Dashboard
* [ ] Deploy Ollama
* [ ] Deploy Open WebUI
* [ ] Infrastructure AI Assistant
* [ ] Infrastructure troubleshooting assistant

---

# Infrastructure

* [ ] Deploy Vaultwarden
* [ ] Deploy Gitea
* [ ] Deploy Portainer
* [ ] Deploy FileBrowser
* [ ] Deploy Watchtower (optional)
* [ ] Deploy Dozzle
* [ ] Deploy Tailscale
* [ ] Deploy Prometheus

---

# Documentation

* [ ] Architecture diagram
* [ ] Network topology
* [ ] Disaster recovery guide
* [ ] New server bootstrap guide
* [ ] Backup & restore documentation
* [ ] Secrets management guide

---

# Future

* [ ] Multi-node management
* [ ] Automatic server enrollment
* [ ] Infrastructure API
* [ ] Mobile dashboard
* [ ] Cluster health monitoring
* [ ] GitOps deployment workflow
* [ ] Multi-site support

---

# Ideas

* [ ] OLED status display for Raspberry Pi
* [ ] Discord infrastructure bot
* [ ] AI-powered infrastructure reports
* [ ] One-command bootstrap for new servers
* [ ] Infrastructure analytics dashboard
* [ ] Monthly infrastructure health report
* [ ] Custom Homepage widgets
* [ ] Unified MeloLab command-line interface
