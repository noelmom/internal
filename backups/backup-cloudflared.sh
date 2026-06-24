#!/usr/bin/env bash
set -e

source .env

mkdir -p "$LOCAL_BACKUP_ROOT/cloudflared"

cp -a ~/.cloudflared \
"$LOCAL_BACKUP_ROOT/cloudflared"

rsync -avz \
-e "ssh -p $BACKUP_PORT" \
"$LOCAL_BACKUP_ROOT/cloudflared/" \
"$BACKUP_USER@$BACKUP_HOST:$BACKUP_PATH/cloudflared/"
