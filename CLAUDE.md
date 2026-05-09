# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Docker container for [claudeclaw](https://github.com/moazbuilds/claudeclaw) — a daemon that extends Claude Code into a personal assistant with Telegram/Discord/Slack bridges, cron jobs, voice transcription, and a web dashboard.

claudeclaw source is cloned from GitHub at image build time (`ARG CLAUDECLAW_REF=main`). No claudeclaw source lives in this repo.

## Build & run

```bash
# Build
docker build -t claudeclaw .

# Build a specific claudeclaw ref
docker build --build-arg CLAUDECLAW_REF=v1.0.34 -t claudeclaw .

# Authenticate Claude Code into the volume (once)
docker compose run --rm claudeclaw claude login

# Run via Compose (recommended)
docker compose up

# Run directly
docker run -p 4632:4632 -v claudeclaw-data:/root/.claude claudeclaw
```

## Architecture

**`Dockerfile`** — Installs Node.js, Bun, Claude Code CLI, clones claudeclaw, runs `bun install`.

**`entrypoint.sh`** — Runs before `bun run src/index.ts`. Two responsibilities:
1. Bootstraps a minimal `settings.json` on first run if none exists under `/root/.claude/claudeclaw/`.
2. Patches `web.host` from `127.0.0.1` → `0.0.0.0` so the dashboard is reachable outside the container.

**`docker-compose.yml`** — Named volume `claudeclaw-data` mounts at `/root/.claude`, persisting Claude Code auth, claudeclaw settings/logs/jobs, and whisper model downloads across container restarts.

## Configuration

claudeclaw settings live at `/root/.claude/claudeclaw/settings.json` inside the container (persisted in the named volume). On first start, `entrypoint.sh` creates a skeleton config. To use your own:

```yaml
# docker-compose.yml — uncomment and provide the file:
- ./settings.json:/root/.claude/claudeclaw/settings.json:ro
```

Web dashboard is exposed on port 4632. `entrypoint.sh` ensures `web.host` is always `0.0.0.0`.

## claudeclaw internals (for context)

- Runtime: Bun; Node.js required for `ogg-opus-decoder` (voice messages)
- Entry: `bun run src/index.ts [start|stop|status|telegram|discord|slack|send]`
- whisper.cpp binaries auto-download on first voice transcription (linux-x64/arm64 in containers)
- Auth: uses Claude Code's OAuth credential store at `/root/.claude/.credentials.json` — no API key needed. Run `claude login` once into the volume before starting the daemon.
