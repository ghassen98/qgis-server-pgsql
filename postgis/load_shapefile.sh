#!/bin/bash
set -e

# Source les variables de connexion à la base de données
source "/usr/bin/init_vars.sh"

# Export the password so ogr2ogr can use it
export PGPASSWORD=$DB_PASSWORD

# Importer chaque Shapefile dans la base de données
for file in /shapefiles/*.shp; do
  table_name=$(basename "$file" .shp)
  echo "Importing $file into table $table_name"
  shp2pgsql -I -s 4326 "$file" "$table_name" | psql -d "$DB_NAME" -U "$DB_USER"
done

echo "All Shapefiles have been imported."