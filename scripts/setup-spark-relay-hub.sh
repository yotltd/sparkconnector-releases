#!/usr/bin/env bash
# SPARK outbound relay: one-time setup on the central hub (64.226.124.65).
# Paste this whole file into a root shell on the hub. It installs the relay
# files from sparkconnector main (bdef7fc) into /opt/spark-relay, writes .env,
# frees TCP 443 if the old host Caddy holds it, and starts the relay.
set -euo pipefail
[[ $EUID -eq 0 ]] || { echo 'Run as root (sudo -i first).' >&2; exit 1; }
command -v docker >/dev/null && docker compose version >/dev/null || { echo 'Docker with Compose is required on the hub.' >&2; exit 1; }

read -rp 'Gateway domain, exactly as REMOTE_GATEWAY_DOMAIN in Supabase (e.g. gw.sparkdock.io): ' GW
GW="$(echo "$GW" | tr 'A-Z' 'a-z' | xargs)"
[[ "$GW" =~ ^[a-z0-9.-]+\.[a-z]{2,}$ ]] || { echo "Not a domain: $GW" >&2; exit 1; }
read -rp 'Company email for certificate notices: ' MAIL
[[ "$MAIL" == *@* ]] || { echo 'Need an email address.' >&2; exit 1; }

echo "== DNS check: $GW and w-test.$GW must both point at this hub"
for h in "$GW" "w-test.$GW"; do
  ip="$(getent ahostsv4 "$h" | awk 'NR==1{print $1}')"
  echo "  $h -> ${ip:-<nothing>}"
  [[ "$ip" == 64.226.124.65 ]] || { echo "  Fix DNS first (A records for $GW and *.$GW -> 64.226.124.65, DNS only / grey cloud), then rerun." >&2; exit 1; }
done

mkdir -p /opt/spark-relay
echo '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' | base64 -d | tar -C /opt/spark-relay -xzf -
cd /opt/spark-relay
cat > .env <<ENV
GW_DOMAIN=$GW
GW_DOMAIN_RE=${GW//./\\.}
ACME_EMAIL=$MAIL
CONNECTOR_IMAGE=ghcr.io/yotltd/sparkconnector@sha256:7c613f79196f7d4262e81f1bcdbe059ffb7aec94c7ba20f6f1fb098694b70798
RELAY_CERT_AUTH_URL=https://xhvxcgjatxghmvnwxybu.supabase.co/functions/v1/collector-relay-certificate
RELAY_AUTH_URL=https://xhvxcgjatxghmvnwxybu.supabase.co/functions/v1/collector-relay-authorize
ENV
chmod 0600 .env

if ss -H -ltnp '( sport = :443 )' | grep -q '"caddy"' && systemctl is-active -q caddy; then
  echo '== The old host Caddy holds 443; saving its config and stopping it (rollback: systemctl enable --now caddy)'
  cp -a /etc/caddy/Caddyfile /root/Caddyfile.pre-relay 2>/dev/null || true
  systemctl disable --now caddy
fi

./start.sh
sleep 20
echo '== Checks'
ss -ltn | grep -E ':(443|7000|8791|8792) ' || true
echo -n "  https://$GW/ answers: "; curl -s -o /dev/null -w '%{http_code}\n' "https://$GW/" || echo 'no answer yet (certificate may still be issuing; retry in a minute)'
echo -n '  Jemasa through the relay: '; curl -s "https://$GW/r/df3696dc-a724-4d67-9083-f9cdac25c9d3/__spark/health" || true; echo
echo 'Expected: 404 for the root (correct). Jemasa says ok only after it runs the new release.'
