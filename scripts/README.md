# Ship Installer

A lightweight Git helper that stages, commits, and pushes changes with a single command.

## Installation

Run the installer:

```bash
bash /opt/internal/scripts/install-ship.sh
```

The installer will:

* Create `~/.local/bin/ship`
* Add `~/.local/bin` to your PATH
* Create a `deploy` alias that points to `ship`
* Work on Linux, macOS, and Windows Git Bash

If this is a new shell session, reload your profile:

```bash
source ~/.bashrc
```

or

```bash
source ~/.zshrc
```

## Usage

### Prompt for Commit Message

```bash
ship
```

You will be prompted:

```text
Commit message:
```

If no message is entered, the operation is cancelled.

### Pass Commit Message Directly

```bash
ship "Add Grafana dashboard"
```

or

```bash
deploy "Add Grafana dashboard"
```

## What It Does

The command will:

1. Verify you are inside a Git repository
2. Show repository name
3. Display changed files
4. Run `git add .`
5. Confirm before proceeding
6. Create a commit
7. Push to the current remote
8. Display the latest commit information

## Example

```bash
ship "Add cloudflared service"
```

Output:

```text
Repository: internal

Changes:
M infrastructure/melolab-pihub/compose.yml
A infrastructure/melolab-pihub/services/cloudflared/

Commit Message: Add cloudflared service

Ship it? [y/N]
```

After confirmation:

```text
Success!

Latest Commit:
a1b2c3d Add cloudflared service

Branch: main
Remote: git@github.com:noelmom/internal.git
```

## Updating

If the installer script changes, simply run:

```bash
bash /opt/internal/scripts/install-ship.sh
```

The existing `ship` command will be updated automatically.

## Repository Location

Current Melo Lab script location:

```text
/opt/internal/scripts/install-ship.sh
```

Recommended location for future shared automation:

```text
/opt/internal/scripts/
├── install-ship.sh
├── install-docker.sh
├── install-cloudflared.sh
├── backup.sh
└── healthcheck.sh
```
