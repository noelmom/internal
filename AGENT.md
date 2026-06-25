# AGENT.md

# MeloLab Infrastructure

Welcome! You are contributing to the MeloLab Infrastructure project.

Your goal is to safely build, maintain, and improve the infrastructure while keeping the repository clean, portable, and production-ready.

---

# Project Philosophy

* Infrastructure as Code
* Docker First
* Everything reproducible
* Everything documented
* Everything backed up
* Security by default
* Keep the repository portable between machines

The repository should be deployable on a Raspberry Pi, VM, or physical server with minimal changes.

---

# Repository Layout

```
/opt/internal

applications/
automation/
backups/
docs/
infrastructure/
scripts/
```

Infrastructure services live under:

```
infrastructure/melolab-pihub
```

---

# Docker Standards

* Docker Compose v2
* One compose file per service
* Modular architecture
* Persistent bind mounts
* Avoid anonymous Docker volumes

Example:

```
compose/

homepage/
compose.yml

grafana/
compose.yml

loki/
compose.yml
```

---

# Secrets

Never commit:

* .env
* API Keys
* Private keys
* Cloudflare credentials
* Certificates

Always verify:

```
git status
```

before committing.

---

# Git

Before making changes:

```
git pull
```

After completing work:

* Update documentation if necessary.
* Update CHANGELOG.md.
* Update BACKLOG.md if new work is identified.

Use:

```
ship "Meaningful commit message"
```

Do not commit temporary files.

---

# Documentation

Maintain:

* README.md
* CHANGELOG.md
* BACKLOG.md

If architecture changes:

Create or update documentation.

---

# Coding Standards

* Keep YAML clean.
* Use comments sparingly.
* Prefer readability.
* Keep directory structure organized.
* Reuse existing patterns.

---

# Docker Workflow

Validate before deployment:

```
docker compose config
```

Deploy:

```
docker compose up -d
```

Restart a service:

```
restart <service>
```

Check logs:

```
docker compose logs -f <service>
```

---

# Troubleshooting

Always verify:

* Docker container health
* Logs
* Network connectivity
* DNS
* Cloudflare Tunnel
* Persistent volumes

Never assume.

Gather evidence first.

---

# Security

Never expose services directly if Cloudflare Tunnel is available.

Future public services should be protected with Cloudflare Access.

Prefer least privilege.

---

# Backups

Before making risky changes:

* Verify backups exist.
* Never delete persistent data.
* Preserve configuration.

---

# Design Principles

Prioritize:

1. Reliability
2. Simplicity
3. Maintainability
4. Security
5. Performance

Do not over-engineer.

---

# Agent Expectations

When completing work:

✔ Explain what changed.

✔ Explain why.

✔ Explain any risks.

✔ Suggest improvements if appropriate.

If blocked:

* Document the issue.
* Leave the repository in a working state.
* Record next steps in BACKLOG.md.

---

# Future Vision

This repository is the foundation of the MeloLab Infrastructure Platform.

Long-term goals include:

* Pi-hole
* Unbound
* Grafana
* Loki
* Alloy
* Vaultwarden
* Gitea
* Infrastructure monitoring
* Automated backups
* AI services
* Cloudflare Access
* GitOps

Design every change with future scalability in mind.

---

# Definition of Done

A task is complete only when:

* Code works.
* Configuration validates.
* Documentation is updated.
* No secrets are committed.
* CHANGELOG.md is updated.
* BACKLOG.md is updated (if needed).
* Repository is ready to deploy.

If any of the above is incomplete, the task is not finished.
