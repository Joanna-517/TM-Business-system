#!/usr/bin/env bash
# TAIMA WorkBuddy 技能同步脚本（Git Bash / macOS / Linux）
# 用法: bash sync.sh
# 作用: 拉取最新技能并复制到 ~/.workbuddy/skills/
set -euo pipefail

REPO="$(cd "$(dirname "$0")" && pwd)"
SKILLS="$HOME/.workbuddy/skills"

echo "[sync] repo: $REPO"
echo "[sync] pull latest..."
git -C "$REPO" pull --ff-only

echo "[sync] install to $SKILLS ..."
mkdir -p "$SKILLS"
for d in taima-partner-lib taima-crm-pipeline; do
  if [ -d "$REPO/$d" ]; then
    rm -rf "$SKILLS/$d"
    cp -r "$REPO/$d" "$SKILLS/$d"
    echo "[sync]   + $d"
  fi
done

echo "[sync] done. 重启 WorkBuddy 以加载新技能。"
