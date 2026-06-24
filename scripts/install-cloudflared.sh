#!/usr/bin/env bash
set -euo pipefail

SUDO=""
[[ $EUID -ne 0 ]] && SUDO="sudo"

echo "==> Installing cloudflared..."

$SUDO rm -f /etc/apt/sources.list.d/cloudflared.list
$SUDO apt update
$SUDO apt install -y curl gnupg ca-certificates lsb-release

$SUDO mkdir -p /usr/share/keyrings

curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | \
  $SUDO gpg --dearmor -o /usr/share/keyrings/cloudflare-main.gpg

echo "deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared any main" | \
  $SUDO tee /etc/apt/sources.list.d/cloudflared.list >/dev/null

$SUDO apt update
$SUDO apt install -y cloudflared

cloudflared --version
echo "cloudflared installed."
