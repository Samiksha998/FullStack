#!/bin/sh

host="$1"
shift

echo "⏳ Waiting for PostgreSQL at $host:5432..."

until pg_isready -h "$host" -p 5432 -U postgres > /dev/null 2>&1; do
  echo "🔁 Still waiting for $host..."
  sleep 2
done

echo "✅ PostgreSQL is ready — starting backend"
exec "$@"
