#!/bin/bash
set -e

# Fonction pour vérifier si PostgreSQL est prêt
function wait_for_postgres() {
  until pg_isready -h localhost; do
    echo "$1"
    sleep 2
  done
}

# Vérifier si la base de données est déjà initialisée
if [ -f /var/lib/postgresql/data/PG_VERSION ]; then
  echo "Database is already initialized."

  # Démarrer PostgreSQL
  /usr/local/bin/docker-entrypoint.sh postgres &

  # Attendre que PostgreSQL soit prêt
  wait_for_postgres "Waiting for PostgreSQL to start..."

  # Ajouter la ligne au fichier pg_hba.conf
  echo "host all all 0.0.0.0/0 md5" >> /var/lib/postgresql/data/pg_hba.conf

  # Redémarrer PostgreSQL pour appliquer les modifications
  pg_ctlcluster 12 main restart

  # Attendre que PostgreSQL soit prêt après le redémarrage
  wait_for_postgres "Waiting for PostgreSQL to restart..."

  # Exécuter le script de chargement des fichiers
  bash /docker-entrypoint-initdb.d/20-load_shapefile.sh

else
  echo "Initializing database..."

  # Appeler le script d'entrée original pour initialiser la base de données
  /usr/local/bin/docker-entrypoint.sh postgres &

  # Attendre que PostgreSQL soit prêt
  wait_for_postgres "Waiting for PostgreSQL to start..."

  # Ajouter la ligne au fichier pg_hba.conf
  echo "host all all 0.0.0.0/0 md5" >> /var/lib/postgresql/data/pg_hba.conf

  # Redémarrer PostgreSQL pour appliquer les modifications
  pg_ctlcluster 12 main restart

  # Attendre que PostgreSQL soit prêt après le redémarrage
  wait_for_postgres "Waiting for PostgreSQL to restart..."

  # Exécuter le script de chargement des fichiers
  bash /docker-entrypoint-initdb.d/20-load_shapefile.sh
fi

# Garder le conteneur en cours d'exécution
tail -f /dev/null