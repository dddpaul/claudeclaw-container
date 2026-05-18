FROM node:24-slim

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    unzip \
    jq \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Install Bun
RUN curl -fsSL https://bun.sh/install | bash
ENV PATH="/root/.bun/bin:$PATH"

# Install UV (fast Python package and project manager)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:$PATH"

# Install Claude Code CLI and pnpm.
# pnpm's content-addressable store is configured to the persistent volume path so
# that downloaded package content survives image rebuilds. The store-dir setting is
# written to pnpm's global rc file (/root/.config/pnpm/rc) which lives in the image
# layer; actual store data lands in the volume at runtime via PNPM_HOME (entrypoint).
RUN npm install -g @anthropic-ai/claude-code pnpm \
    && mkdir -p /root/.config/pnpm \
    && printf 'store-dir=/root/.claude/pnpm-store\n' > /root/.config/pnpm/rc

# Clone claudeclaw at the ref specified by CLAUDECLAW_REF.
# Override at build time with --build-arg CLAUDECLAW_REF=<branch|tag|sha> to pin.
WORKDIR /app
ARG CLAUDECLAW_REF=master
RUN git clone https://github.com/moazbuilds/claudeclaw . \
    && git checkout "${CLAUDECLAW_REF}" \
    && bun install --frozen-lockfile

COPY entrypoint.sh /entrypoint.sh
COPY backup.sh /backup.sh
COPY migrate-python.sh /migrate-python.sh
COPY migrate-npm.sh /migrate-npm.sh
COPY migrate-pnpm.sh /migrate-pnpm.sh
COPY migrate-uv.sh /migrate-uv.sh
RUN chmod +x /entrypoint.sh /backup.sh /migrate-python.sh /migrate-npm.sh /migrate-pnpm.sh /migrate-uv.sh

# Persist Claude Code config, claudeclaw settings/logs/jobs, and whisper models
VOLUME /root/.claude

EXPOSE 4632

ENTRYPOINT ["/entrypoint.sh"]
CMD ["start"]
