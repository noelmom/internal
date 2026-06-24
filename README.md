# Internal

Private infrastructure, applications, automation, and documentation for Melo Lab.

## Repository Structure

```text
internal/
├── infrastructure/
│   ├── melolab-pihub/
│   └── ...
│
├── applications/
│   ├── codename-vox/
│   ├── okta-tools/
│   └── ...
│
├── automation/
│   ├── agents/
│   ├── workflows/
│   └── scripts/
│
├── docs/
│
└── scripts/
```

## Purpose

This repository serves as the central source of truth for:

* Infrastructure as Code
* Docker and containerized services
* Internal applications
* Automation workflows
* Monitoring and observability
* Operational documentation
* Shared utility scripts

## Principles

* Infrastructure is defined as code whenever possible.
* Dockerized services are preferred.
* Secrets are never committed to Git.
* `.env.example` files are committed; `.env` files are not.
* Configuration should be portable across environments.
* All changes should be tracked through Git.

## Common Commands

Commit and push changes:

```bash
ship "Describe your changes"
```

or

```bash
deploy "Describe your changes"
```

## Infrastructure

### Pihub

Primary infrastructure node responsible for services such as:

* Cloudflared
* Homepage
* Uptime Kuma
* Pi-hole
* Grafana
* Loki
* Prometheus

Location:

```text
infrastructure/melolab-pihub
```

## Notes

This repository contains internal-only projects and supporting infrastructure.

Do not commit:

* API keys
* Passwords
* Private certificates
* Cloudflare tunnel credentials
* Production secrets
* Runtime databases

Use:

```text
.env.example
```

for configuration templates.
