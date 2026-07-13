# webterm

A tiny Go (gorilla/websocket + x/crypto/ssh) bridge that fronts an xterm.js
terminal in the browser and dials one of several SSH targets (`targets.json`,
picked by `?t=<name>`). Rendering is client-side, so emoji / Unicode / fonts /
keyboard / scrollback all come from the browser, not a server-side rasterizer
(the reason we moved off Guacamole's guacd for terminals).

Served behind the dashboard nginx at `/webterm/` (TLS). `index.html` is bind
-mounted (`INDEX_PATH`), so edits are live on browser reload with no rebuild.

## IMPORTANT: UTF-8 locale (do not chase this again)

**Symptom:** Claude Code's icons/emoji show as blank gaps *only* in the webterm,
while a plain shell in the same tile renders the very same glyphs fine, and a
native terminal (which forwards `LANG`) renders them too.

**Cause:** it is NOT a font problem - the browser can already draw the glyphs.
The Go SSH bridge does not forward a locale, so the remote session comes up in
the **C / POSIX (US-ASCII)** locale. A plain shell ignores locale and passes
bytes straight through, but Claude Code (like many TUIs) inspects the locale and
**downgrades its Unicode glyphs to blanks** when the charmap is not UTF-8.

Verify:
```
# forwarded login (works):            LANG=C.UTF-8   locale charmap -> UTF-8
# bare bridge-style session (broken): LANG unset     locale charmap -> US-ASCII
LANG= LC_ALL= ssh -o SendEnv=none <host> 'locale charmap'
```

**Fix (in place):** `tmux-menu` on each target host exports `LANG=C.UTF-8` /
`LC_ALL=C.UTF-8` and pushes them into tmux's *global* environment
(`tmux setenv -g ...`) so newly created panes inherit UTF-8. A brand-new tmux
server inherits it from the export; an existing server picks it up for **new
windows only** (tmux does not refresh `LANG` on attach - it is not in
`update-environment`). A Claude Code process already running in an old pane
keeps its ASCII env and must be relaunched in a fresh window to get icons.

Host `tmux-menu` locations:
- pihub / pve : `/usr/local/bin/tmux-menu`
- mini / vox  : `/opt/homebrew/bin/tmux-menu`

Canonical contents (macOS variant; Linux drops the `TMUX=` path and calls
`tmux` from `PATH`):
```sh
#!/bin/sh
export LANG=C.UTF-8
export LC_ALL=C.UTF-8
TMUX=/opt/homebrew/bin/tmux
if "$TMUX" has-session 2>/dev/null; then
  "$TMUX" setenv -g LANG C.UTF-8 2>/dev/null
  "$TMUX" setenv -g LC_ALL C.UTF-8 2>/dev/null
  exec "$TMUX" attach \; choose-tree -Zs
else
  exec "$TMUX" new-session
fi
```

## Font

xterm.js uses `'CaskaydiaCove Nerd Font'` (size 12) with a mono +
system fallback chain. Nerd-Font PUA glyphs render only on devices that have the
font installed; other devices fall back to the system mono font and (post
-locale-fix) system emoji fonts. If PUA icons are ever needed on a device
without the font (e.g. iPad), embed the woff2 via `@font-face` served by nginx.
