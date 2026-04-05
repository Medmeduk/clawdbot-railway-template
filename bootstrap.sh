#!/usr/bin/env bash
set -euo pipefail

mkdir -p /data/.openclaw/agents/main/agent

# Якщо є base64 токени з Railway env var — розпакувати їх
if [ -n "${OPENCLAW_AUTH_PROFILES_B64:-}" ]; then
  echo "auth bootstrap: decoding auth profiles from env var"
  echo "$OPENCLAW_AUTH_PROFILES_B64" | base64 -d > /data/.openclaw/agents/main/agent/auth-profiles.json
elif [ -f /data/.openclaw/auth-profiles.json ]; then
  cp /data/.openclaw/auth-profiles.json /data/.openclaw/agents/main/agent/auth-profiles.json
fi

if [ -f /data/.openclaw/openclaw.json ]; then
  echo "auth bootstrap: found openclaw.json"
fi

echo "auth bootstrap complete"
exec "$@"