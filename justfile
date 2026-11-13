set shell := ["bash", "-euo", "pipefail", "-c"]

# Build the site and (re)start everything
up:
    docker compose up -d --build

# Stop and remove the containers (volumes survive)
down:
    docker compose down

# Rebuild only the site container, e.g. after editing content/
site:
    docker compose build web && docker compose up -d --no-deps web

# Container status
ps:
    docker compose ps

# Follow logs (web, db, migrate)
logs service="web":
    docker compose logs -f --tail=200 {{service}}

# Shell inside a container
sh service="web":
    docker compose exec {{service}} sh

# psql into the comentario database
psql:
    docker compose exec db psql -U postgres -d comentario

# Regenerate the site locally
update:
    hugo

# Tarball the postgres cluster (comments, users, domains)
#
# Hugo output, the theme and /data all rebuild from this repo, so they are out.
backup dir="backups":
    #!/usr/bin/env bash
    set -euo pipefail
    mkdir -p "{{dir}}"
    out="{{dir}}/postgres-$(date +%Y%m%d-%H%M%S).tar.gz"
    tmp=$(mktemp -d)
    trap 'rm -rf "$tmp"' EXIT
    docker compose exec -T db pg_dumpall -U postgres > "$tmp/postgres.sql"
    tar -czf "$out" -C "$tmp" postgres.sql
    chmod 600 "$out"
    echo "$out ($(du -h "$out" | cut -f1))"

# Hidden (underscore = omitted from --list): loads a backup tarball, wiping the
# postgres volume first, because pg_dumpall only restores into an empty cluster.
__restore file:
    #!/usr/bin/env bash
    set -euo pipefail
    [ -f "{{file}}" ] || { echo "no such file: {{file}}" >&2; exit 1; }
    echo "Restoring {{file}}."
    echo "This DELETES the postgres volume and every container/volume of this stack."
    read -rp 'Type "yes" to continue: ' answer
    [ "$answer" = yes ] || { echo "aborted"; exit 1; }
    docker compose down -v --remove-orphans
    docker compose up -d --wait db
    gunzip -c "{{file}}" | tar xO postgres.sql | docker compose exec -T db psql -U postgres
    docker compose up -d
    echo 'restored (the "role postgres already exists" error on import is expected)'
