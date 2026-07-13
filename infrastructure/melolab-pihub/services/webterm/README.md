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

xterm.js uses `'CaskaydiaCove Nerd Font'` at size 12. The font is **self-hosted**
(no device install required, so it works on iPad too): `font.woff2` in this dir
(CaskaydiaCove Nerd Font Mono, converted from the Nerd Fonts CascadiaCode v3.2.1
release with `woff2_compress`, ~1 MB) is mounted into the container (`FONT_PATH`)
and served by the Go server at `/font.woff2` with a long `Cache-Control`. nginx
proxies it at `/webterm/font.woff2`. `index.html` declares it via `@font-face`
with `local('CaskaydiaCove Nerd Font'), local(... Mono)` first, so a device that
already has the font skips the download and only others fetch the woff2. After
the web font loads, `document.fonts.load(...)` triggers a `fit()` refit so the
xterm.js cell grid is measured against the real font, not the fallback.

To regenerate the woff2: download the Nerd Fonts `CascadiaCode.zip` release,
`woff2_compress CaskaydiaCoveNerdFontMono-Regular.ttf`, drop the result in as
`font.woff2`.

## VNC (noVNC + WebSocket-to-TCP proxy)

The same Go service also fronts **client-side VNC** (the roadmap step toward
dropping guacd's server-side raster for VNC), mirroring what it does for SSH:

- **Proxy route `/vncws?t=<name>`** (`handleVNC` in `main.go`): upgrades the
  browser WebSocket and pumps bytes straight to/from a raw TCP VNC server. The
  upgrader advertises the `binary` subprotocol that noVNC requests. Targets are
  a simple `name -> host:port` map in `vnc-targets.json` (`VNC_TARGETS_PATH`).
- **Tile `/vnc.html?t=<name>`** (`VNC_INDEX_PATH`): loads noVNC (`@novnc/novnc`
  `lib/rfb.js` from jsdelivr as an ES module) and points its RFB at `/vncws`.
  `scaleViewport` on. Served through the dashboard nginx at
  `https://pihub...:8090/webterm/vnc.html?t=<name>` (the existing `/webterm/`
  proxy already forwards `/vncws` with WS upgrade - no nginx change needed).

Targets are the Macs' Screen Sharing (`mini`, `vox` on `:5900`). They speak
**Apple Remote Desktop auth** (RFB banner `RFB 003.889`, security type 30 =
Diffie-Hellman), so noVNC asks for **username + password** (the macOS login),
not a legacy VNC password - the tile prompts for whatever `credentialsrequired`
reports. A plain-VNC host would just prompt for a password.

Verify the proxy end to end (a live VNC server sends its banner on connect):
open a WS to `/vncws?t=mini` and the first binary frame is `RFB 003.889`.

**Not done yet:** auth in front of the proxy (same gap as the SSH side), and
dashboard tile integration. `noVNC` renders client-side, so this path is
immune to the guacd font/emoji limits.
