#!/usr/bin/env bash
set -e

source .env

mkdir -p "$LOCAL_BACKUP_ROOT/configs"

rsync -av \
--exclude=".git" \
--exclude="*.db" \
--exclude="*.sqlite" \
--exclude="data" \
/opt/internal/ \
"$LOCAL_BACKUP_ROOT/configs"

rsync -avz \
-e "ssh -p $BACKUP_PORT" \
"$LOCAL_BACKUP_ROOT/configs/" \
"$BACKUP_USER@$BACKUP_HOST:$BACKUP_PATH/configs/"
