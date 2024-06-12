#!/bin/bash
set -e

# Unzip the shapefile
unzip /admin_0_countries.zip -d /shapefile

# Wait for the PostgreSQL server to start
until pg_isready -h postgis -p 5432 -U "$POSTGRES_USER"; do
  >&2 echo "Postgres is unavailable - sleeping AAA"
  sleep 1
done
 
# Load the shapefile into the database using shp2pgsql
shp2pgsql -I -s 4326 /shapefile/admin_0_countries/admin_0_countries.shp admin_0_countries | PGPASSWORD=$POSTGRES_PASSWORD psql -h postgis -U $POSTGRES_USER -d $POSTGRES_DBNAME
