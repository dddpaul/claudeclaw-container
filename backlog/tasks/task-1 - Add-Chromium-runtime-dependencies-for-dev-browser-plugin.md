---
id: TASK-1
title: Add Chromium runtime dependencies for dev-browser plugin
status: To Do
assignee: []
created_date: '2026-05-23 06:29'
labels: []
dependencies: []
ordinal: 1000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
claudeclaw's preflight auto-installs the dev-browser Claude Code plugin (https://github.com/SawyerHood/dev-browser), which drives Playwright + headless Chromium for browser automation. The bookworm-slim base image lacks the system libraries Chromium needs to run, so dev-browser install downloads Chromium successfully but launching it fails with: chrome: error while loading shared libraries: libglib-2.0.so.0: cannot open shared object file. apt-get inside the running container is blocked because hardened claudeclaw deployments drop CAP_SETGID, so the fix has to be baked into the image.

Approach: a single apt-get layer in the Dockerfile installing the Playwright/Chromium runtime deps, enumerated rather than via `npx playwright install-deps chromium` (avoids pulling Playwright at build time). Candidate list for bookworm-slim (validate against the current Playwright release before merging and record the version + date in a Dockerfile comment): libnss3 libnspr4 libdbus-1-3 libatk1.0-0 libatk-bridge2.0-0 libcups2 libdrm2 libxcomposite1 libxdamage1 libxfixes3 libxrandr2 libgbm1 libxkbcommon0 libpango-1.0-0 libcairo2 libasound2 libxshmfence1 libglib2.0-0 fonts-liberation.

Multi-arch: install the Chromium runtime deps on both linux/amd64 and linux/arm64. dev-browser ships dev-browser-linux-arm64 as of release v0.2.7 (2026-04-09; confirmed present in every release back to v0.2.3 via the GitHub Releases API), so arm64 users can run the plugin and need the same Chromium libs as amd64. Gating the apt layer behind TARGETARCH was considered and rejected on this evidence. Downstream nuance not affecting this fix: no dev-browser-linux-musl-arm64 binary is published, so arm64 consumers on a glibc-too-old base have no musl fallback — that is a downstream concern (consumer-side base image choice), not something this image's Chromium-deps install can address.

Image size and security impact: ~80MB compressed (current image is ~368MB → ~450MB). The larger package surface will likely produce new findings on the weekly Trivy scan (security.yml).

Upstream context: empirically observed first failure is libglib-2.0.so.0. Verified end-to-end downstream (Ansible claudeclaw role in dddpaul/mycloud, TASK-21/22): the musl-binary swap unblocks the dev-browser CLI on bookworm, Playwright + Chromium download cleanly into a bind-mounted ~/.cache/ms-playwright, but Chromium itself dies at launch on the missing libs above.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 apt layer is installed unconditionally on both linux/amd64 and linux/arm64 (no TARGETARCH gate). Dockerfile comment cites: "dev-browser ships linux-arm64 since v0.2.3, confirmed via GitHub Releases on 2026-05-23."
- [ ] #2 Dockerfile installs the Chromium runtime deps in a single apt-get layer with --no-install-recommends and `rm -rf /var/lib/apt/lists/*`; layer adds <100MB compressed; the package list carries a comment naming the Playwright version + date it was validated against.
- [ ] #3 End-to-end smoke script committed at `tests/dev-browser-smoke.sh` and runnable against the built image: `npm install -g dev-browser` in the container, swap in dev-browser-linux-musl-x64, run `dev-browser install`, then a one-liner Playwright script that launches Chromium and reads about:blank's title — script exits 0 on success.
- [ ] #4 README documents the new deps and the consumer-side musl-swap caveat (dev-browser-linux-x64 ships glibc 2.39; bookworm consumers must swap to the musl variant). Do NOT hand-edit CHANGELOG.md — release-please owns it; use a `feat:` conventional commit so the changelog entry is generated automatically.
- [ ] #5 Hadolint passes on the modified Dockerfile.
<!-- AC:END -->
