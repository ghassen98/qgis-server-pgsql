#!/bin/bash
set -e

echo "Sleeping 10 sec until postgresql is available.."
sleep 10

# Display the connected user
echo "Connected user is $(whoami)"

# Variables de connexion à la base de données
DB_NAME=${POSTGRES_DB:-postgres}
DB_USER=${POSTGRES_USER:-postgres}

# Importer chaque Shapefile dans la base de données
for file in /shapefiles/*.shp; do
  table_name=$(basename "$file" .shp)
  echo "Importing $file into table $table_name"
  shp2pgsql -I -s 4326 "$file" "$table_name" | psql -d "$DB_NAME" -U "$DB_USER"
done
