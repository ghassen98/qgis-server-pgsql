#!/bin/bash
set -e

# Source les variables de connexion à la base de données
source "/usr/bin/init_vars.sh"

# Export the password so ogr2ogr can use it
export PGPASSWORD=$DB_PASSWORD

# Importer chaque Shapefile dans la base de données
for file in /shapefiles/*.shp; do
  table_name=$(basename "$file" .shp)

  # Importer le Shapefile dans la base de données
  echo "Importing $file into table $table_name"
  shp2pgsql -I -s 4326 "$file" "$table_name" | psql -d "$DB_NAME" -U "$DB_USER"

  # Créer un index spatial sur la table importée
  echo "Creating spatial index on table $table_name"
  psql -d "$DB_NAME" -U "$DB_USER" -c "CREATE INDEX IF NOT EXISTS spatial_index_$table_name ON $table_name USING GIST(geom);"
done

echo "All Shapefiles have been imported and indexed."

