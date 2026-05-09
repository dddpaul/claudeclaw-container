# claudeclaw-container

[![Release](https://img.shields.io/github/v/release/paulmeier/claudeclaw-container)](https://github.com/paulmeier/claudeclaw-container/releases)
[![CI](https://github.com/paulmeier/claudeclaw-container/actions/workflows/ci.yml/badge.svg)](https://github.com/paulmeier/claudeclaw-container/actions/workflows/ci.yml)
[![Lint](https://github.com/paulmeier/claudeclaw-container/actions/workflows/lint.yml/badge.svg)](https://github.com/paulmeier/claudeclaw-container/actions/workflows/lint.yml)
[![Security scan](https://github.com/paulmeier/claudeclaw-container/actions/workflows/security.yml/badge.svg)](https://github.com/paulmeier/claudeclaw-container/actions/workflows/security.yml)
[![Docker Pulls](https://img.shields.io/docker/pulls/paulmeier/claudeclaw-container)](https://hub.docker.com/r/paulmeier/claudeclaw-container)
[![Docker Image Size](https://img.shields.io/docker/image-size/paulmeier/claudeclaw-container/latest)](https://hub.docker.com/r/paulmeier/claudeclaw-container)
[![License](https://img.shields.io/github/license/paulmeier/claudeclaw-container)](LICENSE)

Docker container for [claudeclaw](https://github.com/moazbuilds/claudeclaw) — a daemon that extends Claude Code into a personal assistant with Telegram, Discord, and Slack bridges, scheduled jobs, voice transcription, and a web dashboard.

---

## Why run claudeclaw in a container?

**Zero host pollution.** claudeclaw depends on Bun, Node.js, and the Claude Code CLI. Running it natively means installing and maintaining all of that on your machine. The container bundles everything — your host stays clean.

**Controlled access.** By default the daemon can only see what you explicitly give it. Want it to access your notes? Mount that folder. Everything else on your machine is invisible to it. Running natively, claudeclaw inherits access to your entire filesystem.

**Easy to run on a server.** The same image runs on a VPS, home server, or cloud instance without any changes. Your personal assistant stays online even when your laptop is closed.

**Instant reset.** Something went wrong or you want a clean slate? `docker compose down -v` removes everything. No leftover config files scattered across your home directory.

**Reproducible.** The container always starts from a known state. No "works on my machine" issues caused by a different Bun version, a conflicting global npm package, or a PATH quirk.

---

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) with Compose
- A Claude Code subscription (claude.ai/code) — no API key required
- Optional: a Telegram bot token, Discord bot token, or Slack app token for messaging

---

## Authentication

claudeclaw wraps the `claude` CLI directly and uses your existing Claude Code credentials — it does **not** require an `ANTHROPIC_API_KEY`. Before starting the container you need to authenticate Claude Code into the persistent volume once.

**Step 1 — create the volume and log in:**

```bash
docker compose run --rm claudeclaw claude login
```

This opens an OAuth browser flow. Complete it and your credentials are saved to the volume at `/root/.claude/.credentials.json`. You only need to do this once — credentials persist across container restarts.

**Step 2 — start the daemon:**

```bash
docker compose up -d
```

**Alternatively**, if you already have Claude Code authenticated on your host machine, you can copy your credentials directly into the volume:

```bash
docker run --rm \
  -v claudeclaw-data:/root/.claude \
  -v ~/.claude:/host-claude:ro \
  alpine cp /host-claude/.credentials.json /root/.claude/.credentials.json
```

---

## Quick start

```bash
git clone https://github.com/paulmeier/claudeclaw-container
cd claudeclaw-container
docker compose run --rm claudeclaw claude login   # authenticate once
docker compose up -d
```

The web dashboard will be available at `http://localhost:4632`.

On first run the container will:

1. Create a default `settings.json` on the volume
2. Download the whisper.cpp binary and `base.en` model (~140 MB) for voice transcription
3. Install the `dev-browser` Claude Code plugin

These are all cached in the volume and skipped on subsequent starts.

---

## Configuration

All configuration lives in `settings.json` inside the named volume at `/root/.claude/claudeclaw/settings.json`. The easiest ways to edit it:

**Option A — edit in place after first run:**

```bash
docker compose up -d
docker compose exec claudeclaw cat /root/.claude/claudeclaw/settings.json
# copy, edit locally, then:
docker compose cp settings.json claudeclaw:/root/.claude/claudeclaw/settings.json
docker compose restart
```

**Option B — start from the example file:**

```bash
cp settings.example.json settings.json
# edit settings.json with your tokens, then:
```

Uncomment the bind-mount line in `docker-compose.yml`:

```yaml
volumes:
  - ./settings.json:/root/.claude/claudeclaw/settings.json:ro
```

> **Do not commit `settings.json`** — it contains your API tokens. It is already in `.gitignore`. Use `settings.example.json` as a reference; it is safe to commit.

### Settings reference

```jsonc
{
  "model": "sonnet", // "opus", "sonnet", or "haiku"

  "web": {
    "enabled": true,
    "host": "0.0.0.0", // do not change — required for container networking
    "port": 4632,
  },

  "telegram": {
    "token": "", // BotFather token
    "allowedUserIds": [], // numeric Telegram user IDs who can interact
    "receiveEnabled": true, // set true to listen for incoming messages
  },

  "discord": {
    "token": "", // Discord bot token
    "allowedUserIds": [], // Discord snowflake user IDs (as strings)
    "listenChannels": [], // channel IDs to listen in
    "listenGuilds": [], // guild IDs (leave empty to listen in all guilds)
  },

  "slack": {
    "botToken": "", // xoxb-... bot token
    "appToken": "", // xapp-... app-level token (Socket Mode)
    "allowedUserIds": [], // Slack member IDs
    "listenChannels": [], // channel IDs to listen in
  },

  "heartbeat": {
    "enabled": false, // periodic check-ins from the daemon
    "interval": 60, // minutes between heartbeats
    "prompt": "...", // prompt sent each heartbeat
    "forwardToTelegram": false,
  },

  "security": {
    "level": "moderate", // "locked", "strict", "moderate", or "unrestricted"
  },
}
```

---

## Messaging setup

### Telegram

1. Create a bot via [@BotFather](https://t.me/BotFather) and copy the token
2. Get your numeric user ID from [@userinfobot](https://t.me/userinfobot)
3. Set in `settings.json`:
   ```json
   "telegram": {
     "token": "123456:ABC-...",
     "allowedUserIds": [987654321],
     "receiveEnabled": true
   }
   ```
4. Restart the container — no extra ports needed, Telegram uses outbound polling

### Discord

1. Create a bot at [discord.com/developers](https://discord.com/developers/applications)
2. Under **Bot**, enable **Message Content Intent**
3. Copy the bot token
4. Invite the bot to your server with the `bot` scope and `Send Messages` + `Read Message History` permissions
5. Get channel/guild IDs by enabling Developer Mode in Discord (Settings → Advanced), then right-clicking a channel or server
6. Set in `settings.json`:
   ```json
   "discord": {
     "token": "your-bot-token",
     "allowedUserIds": ["your-snowflake-id"],
     "listenChannels": ["channel-id"],
     "listenGuilds": ["guild-id"]
   }
   ```
7. Restart the container — Discord uses outbound WebSockets, no extra ports needed

### Slack

1. Create a Slack app at [api.slack.com/apps](https://api.slack.com/apps) with **Socket Mode** enabled
2. Under **OAuth & Permissions**, add `chat:write`, `channels:history`, `im:history` scopes and install to workspace
3. Copy the **Bot User OAuth Token** (`xoxb-...`)
4. Under **Basic Information → App-Level Tokens**, create a token with `connections:write` scope
5. Copy the **App-Level Token** (`xapp-...`)
6. Set in `settings.json`:
   ```json
   "slack": {
     "botToken": "xoxb-...",
     "appToken": "xapp-...",
     "allowedUserIds": ["U012AB3CD"],
     "listenChannels": ["C012AB3CD"]
   }
   ```
7. Restart the container

---

## Mounting additional directories

You can give claudeclaw access to any directory on your host — notes, documents, code, media — by adding bind mounts to `docker-compose.yml`.

### Read-only access

Use `:ro` when you want claudeclaw to read files but never modify them:

```yaml
services:
  claudeclaw:
    volumes:
      - claudeclaw-data:/root/.claude # always keep this one
      - /Users/you/Notes:/mnt/notes:ro
      - /Users/you/Documents:/mnt/documents:ro
```

Inside the container those directories appear at `/mnt/notes` and `/mnt/documents`. claudeclaw can read, search, and reference them but cannot write back to your host.

### Read-write access

Omit `:ro` to allow claudeclaw to create, edit, and delete files:

```yaml
volumes:
  - claudeclaw-data:/root/.claude
  - /Users/you/Notes:/mnt/notes # full read-write
```

Use this when you want claudeclaw to save notes, update files, or write output back to your machine.

### Tips

**Use absolute paths.** Relative paths and `~` don't expand in `docker-compose.yml`. Use the full path or an environment variable:

```yaml
- ${HOME}/Notes:/mnt/notes
```

**Choose mount paths that are easy to reference.** claudeclaw will see whatever path you pick on the right side of the `:`. Keeping them short and under `/mnt/` makes it easy to refer to them in prompts and job definitions — for example: _"summarise everything in /mnt/notes from this week"_.

**Apply least privilege.** Mount read-write only for directories claudeclaw actually needs to write to. Everything else should be `:ro`.

**Changes take effect after a restart:**

```bash
docker compose down && docker compose up -d
```

---

## Web dashboard

Available at `http://localhost:4632` when `web.enabled` is `true`. Shows active jobs, logs, and session status. To access it from a remote host, either expose the port via a reverse proxy or change the port mapping in `docker-compose.yml`.

---

## Building a specific claudeclaw version

By default the image clones the `main` branch. To pin to a tag or commit:

```bash
docker build --build-arg CLAUDECLAW_REF=v1.0.34 -t claudeclaw .
```

---

## Persistent data

Everything is stored in the `claudeclaw-data` named volume at `/root/.claude/`:

| Path                       | Contents                         |
| -------------------------- | -------------------------------- |
| `claudeclaw/settings.json` | Your configuration               |
| `claudeclaw/logs/`         | Job and session logs             |
| `claudeclaw/jobs/`         | Scheduled job definitions        |
| `claudeclaw/whisper/`      | whisper.cpp binary + model files |
| `plugins/`                 | Installed Claude Code plugins    |

To back up or inspect the volume:

```bash
# Dump to a tar archive
docker run --rm -v claudeclaw-data:/data -v $(pwd):/backup alpine \
  tar czf /backup/claudeclaw-backup.tar.gz -C /data .

# Restore
docker run --rm -v claudeclaw-data:/data -v $(pwd):/backup alpine \
  tar xzf /backup/claudeclaw-backup.tar.gz -C /data
```

---

## Backups

`backup.sh` snapshots the entire claudeclaw data — credentials, settings, logs, jobs, whisper models, plugins, and session history — into a timestamped archive. It can be run from the host or from inside the container.

### From the host

```bash
./backup.sh
# Saved: ./backups/claudeclaw-2026-05-09-143022.tar.gz (187M)
```

Archives are written to `./backups/` by default. Override with `CLAUDECLAW_BACKUP_DIR`:

```bash
CLAUDECLAW_BACKUP_DIR=~/Backups/claudeclaw ./backup.sh
```

The script accesses the volume via a temporary Docker container, so it is safe to run while the daemon is running.

### From inside the container

Mount a backup destination into the container, then run `/backup.sh`:

```bash
# One-off via docker compose run
docker compose run -v ~/Backups/claudeclaw:/backup claudeclaw /backup.sh

# Or exec into a running container
docker compose exec -e CLAUDECLAW_BACKUP_DIR=/backup claudeclaw /backup.sh
```

To make this permanent, uncomment the backup mount in `docker-compose.yml`:

```yaml
volumes:
  - claudeclaw-data:/root/.claude
  - ${HOME}/Backups/claudeclaw:/backup
```

Then from any shell inside the container:

```bash
/backup.sh
# or with a custom path:
CLAUDECLAW_BACKUP_DIR=/backup /backup.sh
```

### Restore

```bash
docker compose down
docker volume rm claudeclaw-data
docker run --rm \
  -v claudeclaw-data:/data \
  -v /path/to/backups:/backup:ro \
  alpine tar xzf /backup/claudeclaw-2026-05-09-143022.tar.gz -C /data
docker compose up -d
```

### zsh alias

Add to your `~/.zshrc` to run a host-side backup from anywhere:

```bash
alias claudeclaw-backup='/bin/zsh -l /Users/you/Projects/claudeclaw-container/backup.sh'
```

Then `source ~/.zshrc` and call `claudeclaw-backup` whenever you want a snapshot.

---

## Desktop terminal access

`shell.sh` starts the container if it isn't running and drops you straight into the Claude CLI inside it:

```bash
./shell.sh
```

### iTerm2 profile

Create a dedicated iTerm2 profile so you can open a claudeclaw terminal from the menu or a hotkey:

1. iTerm2 → Settings → Profiles → `+`
2. Name it **claudeclaw**
3. Under **Command**, select *Command* and enter:
   ```
   /bin/zsh -l /Users/you/Projects/claudeclaw-container/shell.sh
   ```
4. Optionally assign a hotkey under **Keys → Hotkey Window** for instant access

The `-l` flag loads your login shell environment so `docker` is on the PATH.

### zsh alias

Add to your `~/.zshrc` for one-word access from any terminal:

```bash
alias claudeclaw='/bin/zsh -l /Users/you/Projects/claudeclaw-container/shell.sh'
```

Then run `source ~/.zshrc` and type `claudeclaw` anywhere.

---

## Troubleshooting

**Container exits immediately**
Check logs: `docker compose logs`. Usually a missing or malformed `settings.json`.

**Web dashboard not loading**
Ensure `web.enabled` is `true` and `web.host` is `"0.0.0.0"` in settings. The entrypoint auto-corrects `127.0.0.1` → `0.0.0.0`, but other values are left as-is.

**Bot not responding to messages**

- Confirm the token is correct and the user ID is in `allowedUserIds`
- For Discord: verify Message Content Intent is enabled in the developer portal
- Check logs: `docker compose logs -f`

**Whisper download fails on first start**
The container needs outbound internet access. If behind a proxy, set `HTTP_PROXY` / `HTTPS_PROXY` environment variables in `docker-compose.yml`.
