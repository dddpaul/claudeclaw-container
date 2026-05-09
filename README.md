# claudeclaw-container

Docker container for [claudeclaw](https://github.com/moazbuilds/claudeclaw) — a daemon that extends Claude Code into a personal assistant with Telegram, Discord, and Slack bridges, scheduled jobs, voice transcription, and a web dashboard.

---

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) with Compose
- An Anthropic API key (`sk-ant-...`)
- Optional: a Telegram bot token, Discord bot token, or Slack app token for messaging

---

## Quick start

```bash
git clone https://github.com/paulmeier/claudeclaw-container
cd claudeclaw-container
ANTHROPIC_API_KEY=sk-ant-... docker compose up
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

**Option B — mount your own file before first run:**

Create `settings.json` in the repo directory, then uncomment the bind-mount line in `docker-compose.yml`:
```yaml
volumes:
  - ./settings.json:/root/.claude/claudeclaw/settings.json:ro
```

> **Do not commit `settings.json`** — it contains your API tokens. It is already in `.gitignore`.

### Settings reference

```jsonc
{
  "model": "sonnet",          // "opus", "sonnet", or "haiku"

  "web": {
    "enabled": true,
    "host": "0.0.0.0",        // do not change — required for container networking
    "port": 4632
  },

  "telegram": {
    "token": "",              // BotFather token
    "allowedUserIds": [],     // numeric Telegram user IDs who can interact
    "receiveEnabled": true    // set true to listen for incoming messages
  },

  "discord": {
    "token": "",              // Discord bot token
    "allowedUserIds": [],     // Discord snowflake user IDs (as strings)
    "listenChannels": [],     // channel IDs to listen in
    "listenGuilds": []        // guild IDs (leave empty to listen in all guilds)
  },

  "slack": {
    "botToken": "",           // xoxb-... bot token
    "appToken": "",           // xapp-... app-level token (Socket Mode)
    "allowedUserIds": [],     // Slack member IDs
    "listenChannels": []      // channel IDs to listen in
  },

  "heartbeat": {
    "enabled": false,         // periodic check-ins from the daemon
    "interval": 60,           // minutes between heartbeats
    "prompt": "...",          // prompt sent each heartbeat
    "forwardToTelegram": false
  },

  "security": {
    "level": "moderate"       // "locked", "strict", "moderate", or "unrestricted"
  }
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

| Path | Contents |
|------|----------|
| `claudeclaw/settings.json` | Your configuration |
| `claudeclaw/logs/` | Job and session logs |
| `claudeclaw/jobs/` | Scheduled job definitions |
| `claudeclaw/whisper/` | whisper.cpp binary + model files |
| `plugins/` | Installed Claude Code plugins |

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
