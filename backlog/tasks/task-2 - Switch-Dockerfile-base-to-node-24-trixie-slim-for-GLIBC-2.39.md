---
id: TASK-2
title: >-
  Switch base to node:24-trixie-slim and add Chromium runtime deps for
  dev-browser plugin
status: Done
assignee: []
created_date: '2026-05-23 06:42'
updated_date: '2026-05-23 13:28'
labels: []
dependencies: []
ordinal: 2000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Merges the original TASK-1 (Chromium runtime deps) into TASK-2 because the two changes are operationally coupled — see "Approach" below for why.

claudeclaw's preflight auto-installs the dev-browser Claude Code plugin (https://github.com/SawyerHood/dev-browser), which drives Playwright + headless Chromium. The current bookworm-slim base has two independent problems for that plugin and both must be fixed in the same image release:

1. glibc too old. dev-browser-linux-x64 is precompiled against glibc 2.39+ (trixie / Ubuntu noble). On bookworm-slim (glibc 2.36) it aborts at startup with `libc.so.6: version GLIBC_2.39 not found`. Downstream consumers (Ansible claudeclaw role in dddpaul/mycloud, TASK-21/22) currently work around this by overwriting the dev-browser binary with dev-browser-linux-musl-x64 from the GitHub release — fragile and version-fragile.

2. Missing Chromium runtime libs. Even with the right dev-browser binary, Chromium itself fails to launch on the slim base: `chrome: error while loading shared libraries: libglib-2.0.so.0: cannot open shared object file`. apt-get inside the running container is blocked because hardened claudeclaw deployments drop CAP_SETGID — the fix has to be baked into the image.

Approach: switch the base to `node:24-trixie-slim` (verified published; ships glibc 2.41 per `ldd --version` on the pulled image, codename `trixie` / Debian 13 — NOT 2.39 as folklore says) AND add a single apt-get layer installing the Playwright/Chromium runtime deps. Both required; the two changes are coupled because trixie's `t64` time_t transition renamed many Chromium-dep package names — verified renames: `libasound2 → libasound2t64`, `libglib2.0-0 → libglib2.0-0t64`, `libatk1.0-0 → libatk1.0-0t64`, `libatk-bridge2.0-0 → libatk-bridge2.0-0t64`, `libcups2 → libcups2t64`. The full candidate set is the Playwright bookworm list with these renames applied: libnss3 libnspr4 libdbus-1-3 libatk1.0-0t64 libatk-bridge2.0-0t64 libcups2t64 libdrm2 libxcomposite1 libxdamage1 libxfixes3 libxrandr2 libgbm1 libxkbcommon0 libpango-1.0-0 libcairo2 libasound2t64 libxshmfence1 libglib2.0-0t64 fonts-liberation. Re-validate the full list against trixie (additional `t64` renames may apply) AND against the current Playwright release (the canonical list shifts release-to-release) before merging. Enumerated rather than `npx playwright install-deps chromium` to avoid pulling Playwright at build time.

Multi-arch: install the Chromium runtime deps on both linux/amd64 and linux/arm64. dev-browser ships dev-browser-linux-arm64 as of v0.2.7 (2026-04-09; confirmed via GitHub Releases API back to v0.2.3 on 2026-05-23). No `dev-browser-linux-musl-arm64` is published — a downstream concern (consumer-side base image choice on glibc-too-old arm64 bases), not something this image's install can address.

Image size and security impact: ~80MB compressed for the Chromium deps layer (current image ~368MB → ~450MB). The base bump and added packages will likely produce new findings on the weekly Trivy scan (security.yml) — expect a different CVE profile, not necessarily larger.

Existing-volume upgrade impact: bookworm-slim ships python3.11; trixie + `apt-get install python3` lands python3.13. Existing `claudeclaw-data` volumes have `python-user/lib/python3.11/site-packages/` which becomes invisible to python3.13. healthcheck.sh already detects this and prints a warning pointing at `/migrate-python.sh`. Expected and handled, but user-visible on first start of the new image — document in README. (Node ABI unchanged: Node 24 → 24, no npm native-addon migration needed.)

CI cache note: `.github/workflows/docker-publish.yml` uses `cache-from: type=gha`. The base swap invalidates the bookworm cache layer — the first post-swap CI build is slow but not broken.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Dockerfile `FROM` changes from `node:24-slim` to `node:24-trixie-slim` (explicit, no implicit floating tag).
- [x] #2 A single apt-get layer installs the Chromium runtime deps using **trixie t64-renamed package names** (the bookworm list will fail on trixie), with `--no-install-recommends` and `rm -rf /var/lib/apt/lists/*`; layer adds <100MB compressed; the package list carries a Dockerfile comment naming the Playwright version + date validated against.
- [x] #3 apt layer is installed unconditionally on both linux/amd64 and linux/arm64 (no TARGETARCH gate). Dockerfile comment cites: "dev-browser ships linux-arm64 since v0.2.3, confirmed via GitHub Releases on 2026-05-23."
- [x] #4 Built image reports glibc ≥2.39: `docker run --rm <image> ldd --version | head -1` matches `GLIBC 2\.(39|4[0-9]|[5-9][0-9])` (current trixie ships 2.41; the loose match survives future point releases).
- [x] #5 End-to-end smoke script committed at `tests/dev-browser-smoke.sh` and runnable against the built image: `npm install -g dev-browser` → `dev-browser install` → one-liner Playwright script that launches Chromium and reads about:blank's title — script exits 0 on success **without the musl-swap step** (the swap is no longer needed because the base now ships glibc 2.41).
- [x] #6 No regressions in existing tooling on trixie: bun, uv, pnpm, npm versions unchanged; entrypoint.sh + healthcheck.sh paths still resolve; jq, curl, git, python3 packages install. The python3.11 → 3.13 bump is an expected one-time migration for existing volumes — already handled by healthcheck.sh warn + `/migrate-python.sh` — and must be called out in the README / release notes.
- [x] #7 README documents (a) Chromium runtime deps are baked in, (b) consumer-side musl-swap workarounds can be removed, (c) python3.11 → 3.13 migration warning on first start of existing volumes — run `/migrate-python.sh`. Do NOT hand-edit CHANGELOG.md — use a `feat:` conventional commit so release-please generates the entry.
- [x] #8 Hadolint passes on the modified Dockerfile.
<!-- AC:END -->
