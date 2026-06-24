#!/usr/bin/env bash
set -euo pipefail

SUDO=""
[[ $EUID -ne 0 ]] && SUDO="sudo"

echo "==> Installing base tools..."

$SUDO apt update
$SUDO apt install -y \
  git \
  curl \
  wget \
  jq \
  vim \
  nano \
  htop \
  tree \
  unzip \
  zip \
  net-tools \
  dnsutils \
  ca-certificates \
  gnupg \
  lsb-release

echo "Base tools installed."
