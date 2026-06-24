#!/usr/bin/env bash
set -e

BIN_DIR="$HOME/.local/bin"
SHIP_PATH="$BIN_DIR/ship"

mkdir -p "$BIN_DIR"

cat > "$SHIP_PATH" <<'EOF'
#!/usr/bin/env bash
set -e

MESSAGE="$*"

if ! git rev-parse --git-dir >/dev/null 2>&1; then
  echo "Error: Not inside a git repository."
  exit 1
fi

if [ -z "$MESSAGE" ]; then
  read -rp "Commit message: " MESSAGE
fi

if [ -z "$MESSAGE" ]; then
  echo "Cancelled: no commit message provided."
  exit 1
fi

echo
echo "Repository: $(basename "$(git rev-parse --show-toplevel)")"
echo
echo "Changes:"
git status --short
echo

git add .

if git diff --cached --quiet; then
  echo "Nothing to commit."
  exit 0
fi

echo "Commit Message: $MESSAGE"
echo
read -rp "Ship it? [y/N] " CONFIRM

case "$CONFIRM" in
  y|Y|yes|YES) ;;
  *) echo "Cancelled."; exit 1 ;;
esac

git commit -m "$MESSAGE"
git push

echo
echo "Success!"
git log -1 --oneline
echo "Branch: $(git branch --show-current)"
echo "Remote: $(git remote get-url origin)"
EOF

chmod +x "$SHIP_PATH"

# Add ~/.local/bin to PATH for common shells
for RC in "$HOME/.bashrc" "$HOME/.zshrc"; do
  if [ -f "$RC" ] && ! grep -q 'HOME/.local/bin' "$RC"; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$RC"
  fi
done

# Create deploy alias
for RC in "$HOME/.bashrc" "$HOME/.zshrc"; do
  if [ -f "$RC" ] && ! grep -q "alias deploy=ship" "$RC"; then
    echo "alias deploy=ship" >> "$RC"
  fi
done

echo "Installed ship to: $SHIP_PATH"
echo "Restart your terminal or run:"
echo 'export PATH="$HOME/.local/bin:$PATH"'
echo
echo "Usage:"
echo '  ship "commit message"'
echo '  deploy "commit message"'
