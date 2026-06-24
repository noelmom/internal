#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "======================================="
echo " Melo Lab Bootstrap"
echo "======================================="
echo

"$SCRIPT_DIR/install-basics.sh"
"$SCRIPT_DIR/install-docker.sh"
"$SCRIPT_DIR/install-cloudflared.sh"
"$SCRIPT_DIR/install-ship.sh"

echo
echo "======================================="
echo " Bootstrap complete."
echo "======================================="
echo
echo "Next steps:"
echo "  1. Log out and back in, or run: newgrp docker"
echo "  2. Run: docker run hello-world"
echo "  3. Run: cloudflared tunnel list"
echo "  4. Run: ship \"Add bootstrap scripts\""
