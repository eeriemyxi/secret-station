#!/bin/sh
# Applies migrations/*.sql once each, tracked in _migrations. Runs in the
# postgres image, so psql/pg_isready are available.
set -eu

export PGHOST="${PGHOST:-db}" PGUSER="${PGUSER:-postgres}" PGDATABASE="${PGDATABASE:-postgres}"

until pg_isready -q; do
	sleep 1
done

psql -v ON_ERROR_STOP=1 -q -c \
	'CREATE TABLE IF NOT EXISTS _migrations (name text PRIMARY KEY, applied_at timestamptz NOT NULL DEFAULT now())'

for file in "${MIGRATIONS_DIR:-/migrations}"/*.sql; do
	name=$(basename "$file")
	if [ "$(psql -tAq -c "SELECT 1 FROM _migrations WHERE name = '$name'")" = "1" ]; then
		echo "skip    $name"
		continue
	fi
	echo "apply   $name"
	# No -1/--single-transaction: CREATE DATABASE can't run inside a transaction.
	psql -v ON_ERROR_STOP=1 -q -f "$file"
	psql -v ON_ERROR_STOP=1 -q -c "INSERT INTO _migrations (name) VALUES ('$name')"
done
