#!/usr/bin/env bash
set -euo pipefail

mkdir -p /data/.openclaw/agents/main/agent

# Розпакувати auth-profiles.json
if [ -n "${OPENCLAW_AUTH_PROFILES_B64:-}" ]; then
  echo "auth bootstrap: decoding auth profiles"
  echo "$OPENCLAW_AUTH_PROFILES_B64" | base64 -d > /data/.openclaw/agents/main/agent/auth-profiles.json
fi

# Розпакувати openclaw.json
if [ -n "${OPENCLAW_CONFIG_B64:-}" ]; then
  echo "auth bootstrap: decoding openclaw.json"
  echo "$OPENCLAW_CONFIG_B64" | base64 -d > /data/.openclaw/openclaw.json
fi

# Перезаписати /data/workspace/bootstrap.sh щоб патчити config ПІСЛЯ wrapper sync
mkdir -p /data/workspace
cat > /data/workspace/bootstrap.sh << 'EOF'
#!/usr/bin/env bash
echo "workspace bootstrap: patching trustedDevices..."
python3 - << 'PYEOF'
import json, os

path = '/data/.openclaw/openclaw.json'
if not os.path.exists(path):
    print("workspace bootstrap: openclaw.json not found, skipping patch")
    exit(0)

with open(path) as f:
    d = json.load(f)

d.setdefault('gateway', {}).setdefault('auth', {})
d['gateway']['auth']['requirePairing'] = False
d['gateway']['auth']['trustedDevices'] = [
    'a42fa361bbbd59a4ffd1a7ef18043ac7babbcfef1e4def1da3c21d788d679101'
]

with open(path, 'w') as f:
    json.dump(d, f, indent=2)

print("workspace bootstrap: trustedDevices patched OK")
PYEOF
EOF
chmod +x /data/workspace/bootstrap.sh

echo "auth bootstrap complete"
exec "$@"
