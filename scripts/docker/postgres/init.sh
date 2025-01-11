#!/bin/bash
set -e

# Create user and database
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE USER asm3 WITH PASSWORD 'asm3';
    CREATE DATABASE asm;
    \c asm
    GRANT ALL PRIVILEGES ON DATABASE asm TO asm3;
    GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO asm3;
    ALTER DATABASE asm OWNER TO asm3;
EOSQL