#!/bin/bash
set -e

# Nom de la base de données et du fichier GeoJSON
DB_NAME="my_database"
GEOJSON_FILE="/docker-entrypoint-initdb.d/data.geojson"

# Attendre que la base de données soit prête
# until pg_isready -d "postgresql://$POSTGRES_USER:$POSTGRES_PASSWORD@localhost:5432/$DB_NAME"; do
until pg_isready; do
  echo "En attente que PostgreSQL soit prêt..."
  sleep 2
done

echo "postgresql://$POSTGRES_USER:$POSTGRES_PASSWORD@localhost:5432/$DB_NAME"
echo "L15"

# Créez la base de données si elle n'existe pas
psql -d "$DB_NAME" -U "$POSTGRES_USER" -c "CREATE DATABASE $DB_NAME;" || echo "La base de données existe déjà."

echo "L20"

# Importer le fichier GeoJSON dans PostGIS
ogr2ogr \
  -f "PostgreSQL" \
  "PG:dbname=$DB_NAME user=$POSTGRES_USER password=$POSTGRES_PASSWORD" \
  "$GEOJSON_FILE" \
  -nln my_table \
  -overwrite \
  -lco GEOMETRY_NAME=geom \
  -lco FID=id \
  -lco PRECISION=NO

echo "L34"