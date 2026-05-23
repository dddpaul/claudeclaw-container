#!/usr/bin/env bash
# Verify the built claudeclaw image can run the dev-browser Claude Code
# plugin and launch Playwright Chromium without the consumer-side
# musl-binary swap that was required on the previous bookworm-slim base.
#
# What this exercises (and how each step would have failed on bookworm):
#   1. `npm install -g dev-browser` — npm postinstall lays down
#      dev-browser-linux-{x64,arm64}, which is glibc-linked. On bookworm
#      (glibc 2.36) running it would print "version GLIBC_2.39 not found".
#      On trixie (glibc 2.41) it runs natively.
#   2. `playwright install chromium` — fetches the Chromium binary into
#      ~/.cache/ms-playwright. Unaffected by base bump.
#   3. Launch Chromium headless and read about:blank's title. Without the
#      Chromium runtime apt layer this aborts with
#      "libglib-2.0.so.0: cannot open shared object file".
#
# Usage: ./tests/dev-browser-smoke.sh [image]   (default: claudeclaw:test)
set -euo pipefail

IMAGE="${1:-claudeclaw:test}"

echo "[smoke] running against $IMAGE"

docker run --rm --entrypoint bash "$IMAGE" -c '
  set -euo pipefail

  echo "[smoke] installing dev-browser + playwright"
  npm install -g dev-browser playwright >/dev/null

  echo "[smoke] dev-browser --version:"
  dev-browser --version

  echo "[smoke] installing Chromium"
  npx --yes playwright install chromium >/dev/null

  echo "[smoke] launching Chromium and reading about:blank title"
  NODE_PATH="$(npm root -g)" node -e "
    const { chromium } = require(\"playwright\");
    (async () => {
      const browser = await chromium.launch({ headless: true });
      const page = await browser.newPage();
      await page.goto(\"about:blank\");
      console.log(\"[smoke] about:blank title: [\" + (await page.title()) + \"]\");
      await browser.close();
    })().catch(e => { console.error(e); process.exit(1); });
  "
'

echo "[smoke] PASS: $IMAGE can launch Chromium without musl-swap"
