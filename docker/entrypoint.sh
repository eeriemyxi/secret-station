#!/bin/sh
# Runs Comentario (backend + embed script) and Caddy (static site + proxy) in
# one container; tini is PID 1 and forwards signals here.
set -eu

: "${POSTGRES_PASSWORD:?POSTGRES_PASSWORD is required}"
: "${BASE_URL:?BASE_URL is required}"

# Render secrets so the DB password lives only in .env.
mkdir -p /data
sed "s|__POSTGRES_PASSWORD__|${POSTGRES_PASSWORD}|g" \
    /etc/comentario/secrets.yaml.tmpl > /data/secrets.yaml
chmod 600 /data/secrets.yaml

/opt/comentario/comentario --secrets /data/secrets.yaml &
comentario_pid=$!

caddy run --config /etc/caddy/Caddyfile --adapter caddyfile &
caddy_pid=$!

stopping=0
trap 'stopping=1; kill -TERM "$comentario_pid" "$caddy_pid" 2>/dev/null' INT TERM

# If either process dies, take the container down so it gets restarted.
wait -n
[ "$stopping" = 1 ] && exit 0
exit 1
