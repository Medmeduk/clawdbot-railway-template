#!/usr/bin/env bash
set -euo pipefail

echo "=== OUR BOOTSTRAP STARTING ==="

mkdir -p /data/.openclaw/agents/main/agent

# Розпакувати auth-profiles.json
if [ -n "${OPENCLAW_AUTH_PROFILES_B64:-}" ]; then
  echo "=== DECODING AUTH PROFILES ==="
  echo "$OPENCLAW_AUTH_PROFILES_B64" | base64 -d > /data/.openclaw/agents/main/agent/auth-profiles.json
else
  echo "=== WARNING: OPENCLAW_AUTH_PROFILES_B64 NOT SET ==="
fi

# Розпакувати openclaw.json
if [ -n "${OPENCLAW_CONFIG_B64:-}" ]; then
  echo "=== DECODING OPENCLAW CONFIG ==="
  echo "$OPENCLAW_CONFIG_B64" | base64 -d > /data/.openclaw/openclaw.json
else
  echo "=== WARNING: OPENCLAW_CONFIG_B64 NOT SET ==="
fi

# Записати workspace bootstrap
echo "=== WRITING WORKSPACE BOOTSTRAP ==="
mkdir -p /data/workspace

cat > /data/workspace/bootstrap.sh << 'WSEOF'
#!/usr/bin/env bash
echo "=== WORKSPACE BOOTSTRAP RUNNING ==="
python3 -c "
import json, os
path = '/data/.openclaw/openclaw.json'
if not os.path.exists(path):
    print('ERROR: openclaw.json not found')
    exit(0)
with open(path) as f:
    d = json.load(f)
d.setdefault('gateway', {}).setdefault('auth', {})
d['gateway']['auth']['requirePairing'] = False
d['gateway']['auth']['trustedDevices'] = ['a42fa361bbbd59a4ffd1a7ef18043ac7babbcfef1e4def1da3c21d788d679101']
with open(path, 'w') as f:
    json.dump(d, f, indent=2)
print('=== TRUSTED DEVICES PATCHED OK ===')
"
WSEOF

chmod +x /data/workspace/bootstrap.sh
echo "=== WORKSPACE BOOTSTRAP WRITTEN ==="
echo "=== OUR BOOTSTRAP DONE ==="
exec "$@"
