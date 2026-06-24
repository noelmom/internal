#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

"$SCRIPT_DIR/backup-cloudflared.sh"
"$SCRIPT_DIR/backup-configs.sh"
"$SCRIPT_DIR/backup-docker.sh"

echo
echo "All backups completed successfully."
