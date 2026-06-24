#!/usr/bin/env bash
set -e

source .env

mkdir -p "$LOCAL_BACKUP_ROOT/docker"

tar czf \
"$LOCAL_BACKUP_ROOT/docker/docker-data.tar.gz" \
/opt/internal/infrastructure/melolab-pihub/services

rsync -avz \
-e "ssh -p $BACKUP_PORT" \
"$LOCAL_BACKUP_ROOT/docker/" \
"$BACKUP_USER@$BACKUP_HOST:$BACKUP_PATH/docker/"
