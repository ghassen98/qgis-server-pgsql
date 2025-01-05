#!/bin/bash
set -e

# Fonction pour vérifier si PostgreSQL est prêt
function wait_for_postgres() {
  until pg_isready -h localhost; do
    echo "$1"
    sleep 2
  done
}

# Variables de connexion à la base de données
DB_NAME=${POSTGRES_DB:-postgres}
DB_USER=${POSTGRES_USER:-postgres}
DB_HOST=${POSTGRES_HOST:-localhost}
DB_PORT=${POSTGRES_PORT:-5432}
DB_PASSWORD=${POSTGRES_PASSWORD:-password}

# Afficher les informations de connexion pour le débogage
echo "Connecting to database $DB_NAME at $DB_HOST:$DB_PORT with user $DB_USER"

# Export the password so ogr2ogr can use it
export PGPASSWORD=$DB_PASSWORD

# Attendre que PostgreSQL soit prêt
wait_for_postgres "Waiting for PostgreSQL to start..."

# Import each GeoJSON file into the database
for file in /geojson/*.geojson; do
  table_name=$(basename "$file" .geojson)
  echo "Importing $file into table $table_name"
  
  ogr2ogr -f "PostgreSQL" \
    PG:"host=$DB_HOST port=$DB_PORT dbname=$DB_NAME user=$DB_USER password=$DB_PASSWORD" \
    "$file" \
    -nln "$table_name" \
    -nlt GEOMETRY \
    -overwrite
done

echo "All GeoJSON files have been imported."