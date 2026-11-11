# cc-statuslines

[繁體中文](README.md) | [简体中文](README.zh-CN.md) | **English** | [日本語](README.ja.md)

A collection of custom status line styles for Claude Code. An interactive installer lists every style, previews each one in your own terminal, and installs the one you pick.

```
 Opus  xhigh   412k / 1.0M · 41%   1% · 6d12h 
└─ model + effort ─┘ └─ context usage ─┘ └─ weekly · reset ─┘
```

## Requirements

- [Claude Code](https://code.claude.com/docs/en/statusline)
- `jq` (macOS: `brew install jq`)
- A terminal with 24-bit true color
- A Nerd Font (optional; needed for rounded pills, and you can switch to square blocks without one)

## Install

```bash
gh repo clone shaohong01/cc-statuslines ~/.cc-statuslines
~/.cc-statuslines/install.sh --lang en
```

The installer lists every style with a live color preview. Enter a number to install, then open a new Claude Code session to see it.

To skip the menu, name the style directly:

```bash
~/.cc-statuslines/install.sh pills-duo
```

## Styles

| Style | Description |
|---|---|
| `pills-duo` | Two-tone pill: model and effort joined in one pill, context usage in its own, weekly usage and reset countdown in a white pill. Effort and context shift between green, yellow, and red by level and usage; the weekly text shifts between blue, yellow, and red |

## Commands

| Command | What it does |
|---|---|
| `install.sh` | Interactive menu: pick a style, change language, or remove |
| `install.sh <style>` | Install or switch to a style |
| `install.sh --list` | List all styles with previews |
| `install.sh --preview <style>` | Preview a style in each state |
| `install.sh --uninstall` | Remove the status line settings |
| `install.sh --lang <lang>` | Set the installer language: `zh-TW` (default), `zh-CN`, `en`, `ja` |

## Configuration

The installer creates `~/.claude/statusline.conf`. Put your tweaks there, and updating the repo won't overwrite them.

| Setting | Default | Description |
|---|---|---|
| `ROUND` | `1` | `1` for rounded pills (needs a Nerd Font); `0` for square blocks |
| `JOIN` | `round` | The seam between model and effort. `round` overlaps with a curve; `flat` is a straight split |
| `WARN` | `50` | Context usage percentage where the pill turns yellow |
| `CRIT` | `80` | Context usage percentage where the pill turns red |
| `WK_WARN` | `70` | Weekly usage percentage where the text turns yellow |
| `WK_CRIT` | `85` | Weekly usage percentage where the text turns red |

Save the file and the status line picks it up on its next refresh.

## Update

```bash
git -C ~/.cc-statuslines pull
```

The installed script is a link into the repo, so a pull is all it takes.

## What the installer changes

- Creates `~/.claude/statusline.sh` as a link to the style you picked.
- Writes the `statusLine` setting into `~/.claude/settings.json` and leaves your other settings as they are.
- Backs up `settings.json` to `settings.json.bak-<time>` before editing it on the first install. Switching styles later only repoints the link, so `settings.json` is not touched and no new backup is made.
- Renames an existing `statusline.sh` of your own to `statusline.sh.bak-<time>`.

Uninstalling removes only the link and the `statusLine` setting. Backups and `statusline.conf` stay.

## Add a style

1. Create `styles/<name>/statusline.sh`. It reads the JSON Claude Code sends on stdin and prints what to show on stdout.
2. Create `styles/<name>/style.meta` with a one-line description per language (`zh-TW=`, `zh-CN=`, `en=`, `ja=`).
3. Run `test/run.sh` to check it renders for every sample input.
4. Add a row to the style table in all four READMEs.

The menu scans `styles/` automatically, so `install.sh` needs no changes.

## FAQ

**The pill ends show boxes or question marks.** Your terminal font has no Nerd Font glyphs. Switch to a Nerd Font, or set `ROUND` to `0` in `statusline.conf`.

**The colors look wrong.** Your terminal doesn't support 24-bit true color. Use one that does.

**Context shows 0.** A new session, or one right after `/compact`, has no usage data yet. It appears after the next response.

**The weekly usage pill is missing.** Only claude.ai Pro, Max, and Ultra subscriptions report it, so it doesn't show with an API key. In a new session it appears after the first response.

**The effort segment is missing.** The current model doesn't support the effort parameter, so only the model is shown.
