#!/bin/bash
set -e

echo "Sleeping 10 sec until postgresql is available.."
sleep 10

# Perform all actions as $POSTGRES_USER
# export PGUSER="$POSTGRES_USER"
# export PGPASSWORD="$POSTGRES_PASSWORD"

echo "LOAD - Connected user is $(whoami)"
# echo "PGUSER is $PGUSER"
# echo "PGPASSWORD is $PGPASSWORD"

# Wait for the PostgreSQL server to start
echo "Waiting for PostgreSQL to become available..."

# Variables de connexion à la base de données
DB_NAME=${POSTGRES_DB:-postgres}
DB_USER=${POSTGRES_USER:-postgres}

# Importer chaque Shapefile dans la base de données
for file in /shapefiles/*.shp; do
  table_name=$(basename "$file" .shp)
  echo "Importing $file into table $table_name"
  shp2pgsql -I -s 4326 "$file" "$table_name" | psql -d "$DB_NAME" -U "$DB_USER"
done

# Load the shapefile into the database using shp2pgsql
# shp2pgsql -I -s 4326 /shapefile/admin_0_countries/admin_0_countries.shp admin_0_countries | PGPASSWORD=$POSTGRES_PASSWORD psql -h postgis -U $POSTGRES_USER -d $POSTGRES_DBNAME

