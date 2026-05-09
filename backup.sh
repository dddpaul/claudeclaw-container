#!/bin/zsh
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_DIR="${CLAUDECLAW_BACKUP_DIR:-$SCRIPT_DIR/backups}"
TIMESTAMP=$(date +%Y-%m-%d-%H%M%S)
BACKUP_FILE="$BACKUP_DIR/claudeclaw-$TIMESTAMP.tar.gz"

mkdir -p "$BACKUP_DIR"

echo "Backing up claudeclaw volume..."
docker run --rm \
  -v claudeclaw-data:/data:ro \
  -v "$BACKUP_DIR":/backup \
  alpine tar czf "/backup/claudeclaw-$TIMESTAMP.tar.gz" -C /data .

SIZE=$(du -sh "$BACKUP_FILE" | cut -f1)
echo "Saved: $BACKUP_FILE ($SIZE)"
