#!/bin/bash
set -e

# Perform all actions as $POSTGRES_USER
# export PGUSER="$POSTGRES_USER"

# Display the connected user
echo "Connected user is $(whoami)"

# Variables de connexion à la base de données
DB_NAME=${POSTGRES_DB:-postgres}
DB_USER=${POSTGRES_USER:-postgres}
DB_HOST=${POSTGRES_HOST:-localhost}
DB_PORT=${POSTGRES_PORT:-5432}
DB_PASSWORD=${POSTGRES_PASSWORD:-password}


DB_HOST="172.26.185.179"
DB_PORT="5432"
DB_USER="myuser"
DB_PASSWORD="mypassword"
DB_NAME="mydatabase"

# Export the password so ogr2ogr can use it
export PGPASSWORD=$DB_PASSWORD

until pg_isready; do
  echo "En attente que PostgreSQL soit prêt..."
  sleep 2
done

echo "postgresql://$DB_USER:$DB_PASSWORD@localhost:5432/$DB_NAME"
echo "L37"

# Créez la base de données si elle n'existe pas
# psql -d "$DB_NAME" -U "$DB_USER" -c "CREATE DATABASE $DB_NAME;" || echo "La base de données existe déjà."

# Importer chaque Shapefile dans la base de données
# for file in /shapefiles/*.shp; do
#   table_name=$(basename "$file" .shp)
#   echo "Importing $file into table $table_name"
#   shp2pgsql -I -s 4326 "$file" "$table_name" | psql -d "$DB_NAME" -U "$DB_USER"
# done

# echo "All Shapefiles have been imported."

echo "Loading GeoJSON files.."

# Import each GeoJSON file into the database

for file in /geojson/*.geojson; do
  table_name=$(basename "$file" .geojson)
  echo "Importing $file into table $table_name"

  ogr2ogr \
    -f "PostgreSQL" \
    "PG:dbname=$DB_NAME user=$DB_USER password=$DB_PASSWORD" \
    "$file" \
    -nln "$table_name" \
    -overwrite \
    -lco GEOMETRY_NAME=geom \
    -lco FID=id \
    -lco PRECISION=NO
done

echo "All GeoJSON files have been imported."