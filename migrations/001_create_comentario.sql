-- Database for Comentario. Not declared as POSTGRES_DB on purpose: the
-- migration owns it so existing volumes pick it up too. \gexec keeps it
-- idempotent (CREATE DATABASE has no IF NOT EXISTS).
SELECT 'CREATE DATABASE comentario'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'comentario')\gexec
