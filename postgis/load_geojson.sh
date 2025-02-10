#!/bin/bash
set -e

# Source les variables de connexion à la base de données
source "/usr/bin/init_vars.sh"

# Export the password so ogr2ogr can use it
export PGPASSWORD=$DB_PASSWORD

# Import each GeoJSON file into the database
echo "Loading GeoJSON files.."
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