# Restore Procedure

## Fresh Server

Clone repository

```bash
git clone ...
```

Run bootstrap

```bash
./scripts/bootstrap.sh
```

Restore backups

```bash
rsync ...
```

Restore Cloudflare

```
~/.cloudflared
```

Restore Docker

```
docker compose up -d
```

Restore .env

```
cp .env.example .env
```

Infrastructure should now be operational.
