#!/usr/bin/env bash
set -euo pipefail

SUDO=""
[[ $EUID -ne 0 ]] && SUDO="sudo"

echo "==> Installing Docker..."

$SUDO apt update
$SUDO apt install -y curl ca-certificates gnupg

curl -fsSL https://get.docker.com | sh

$SUDO usermod -aG docker "$USER"

$SUDO systemctl enable docker
$SUDO systemctl start docker

echo "Docker installed."
echo "IMPORTANT: log out and back in, or run: newgrp docker"
