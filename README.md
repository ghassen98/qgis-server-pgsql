# qgis-server-pgsql

Plateforme Docker complète pour servir des couches cartographiques via **QGIS Server + PostGIS + Nginx**, avec une API **NestJS** en façade et **pgAdmin** pour l’administration de la base.

## 1) Vue d’ensemble

Le projet démarre 5 services via `docker-compose` :

- `postgis` : base PostgreSQL/PostGIS + import automatique des jeux de données
- `qgis-server` : moteur cartographique (WMS/WFS)
- `nginx` : reverse proxy + interface web Leaflet
- `nest-app` : API backend (proxy applicatif vers QGIS)
- `pgadmin` : interface d’administration SQL

Flux principal :

1. Les données sont chargées dans PostGIS au démarrage (`/postgis/load_*.sh`).
2. Le projet QGIS (`qgis-server/data/project/dailymaps.qgs`) lit ces tables.
3. Nginx expose QGIS sur `http://localhost:8080/qgis-server`.
4. NestJS expose une route `POST /carto` qui appelle QGIS en WFS.

---

## 2) Arborescence utile

- `docker-compose.yml` : orchestration des services
- `qgis-server/` : image QGIS Server + projets `.qgs`
- `postgis/` : image PostGIS + scripts d’import (GeoJSON/Shapefile)
- `nginx/` : configuration reverse proxy + page Leaflet de démo
- `nestjs/` : API NestJS
- `pgadmin/servers.json` : pré-configuration serveur pgAdmin
- `update-ip/` : script utilitaire legacy de remplacement d’IP

---

## 3) Prérequis

- Docker Engine 24+
- Docker Compose v2 (`docker compose`)
- 4 Go RAM minimum recommandés
- Ports libres : `3000`, `5432`, `8080`, `8081`

Vérification rapide :

```bash
docker --version
docker compose version
```

---

## 4) Configuration `.env`

Créer un fichier `.env` à la racine du dépôt (même niveau que `docker-compose.yml`) :

```env
# PostGIS / QGIS
POSTGRES_HOST=postgis
POSTGRES_PORT=5432
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_DB=gis

# NestJS
PORT=3000
EXTERNAL_SERVICE_URL=http://nginx/qgis-server
```

Notes importantes :

- `EXTERNAL_SERVICE_URL` est validée par l’API NestJS (doit être définie).
- `PORT` doit être aligné avec le mapping `3000:3000` du compose.

---

## 5) Démarrage rapide

Depuis la racine du projet :

```bash
docker compose up -d --build
```

Suivre les logs :

```bash
docker compose logs -f
```

Arrêter :

```bash
docker compose down
```

Reset complet (⚠ supprime volumes/données locales) :

```bash
docker compose down -v
docker system prune -f
docker compose up -d --build
```

---

## 6) Endpoints et accès

### Interfaces

- UI Leaflet : `http://localhost:8080`
- pgAdmin : `http://localhost:8081`
    - user : `admin@admin.com`
    - password : `admin`
- API NestJS : `http://localhost:3000`

### QGIS Server (via Nginx)

- GetCapabilities WMS :

```text
http://localhost:8080/qgis-server?SERVICE=WMS&VERSION=1.3.0&REQUEST=GetCapabilities
```

- Exemple WFS GetFeature :

```text
http://localhost:8080/qgis-server?SERVICE=WFS&VERSION=1.0.0&REQUEST=GetFeature&TYPENAME=segments_finaux&outputFormat=application/json&BBOX=8.46,42.53,11.84,50.98
```

### API NestJS

- Health simple :

```bash
curl http://localhost:3000/
```

- Appel carto :

```bash
curl -X POST http://localhost:3000/carto \
    -H "Content-Type: application/json" \
    -d '{"bbox":"8.46,42.53,11.84,50.98","layername":"segments_finaux"}'
```

Contraintes d’entrée `POST /carto` :

- `bbox` obligatoire, format `minX,minY,maxX,maxY`
- `minX < maxX` et `minY < maxY`
- `layername` obligatoire (nom de couche QGIS)

---

## 7) Données chargées automatiquement

Au premier démarrage de `postgis`, les scripts importent :

- Tous les `*.shp` depuis `postgis/data/shapefile/` (via `shp2pgsql`)
- Tous les `*.geojson` depuis `postgis/data/geojson/` (via `ogr2ogr`)

Tables attendues (selon les fichiers présents) :

- `segments_finaux`
- `fire_hydrant`
- `bus_stop`
- `bornes_electriques`
- `feux_circulation`
- `signalisation_arret`
- etc.

Un index spatial GiST est créé pour chaque table importée.

---

## 8) Commandes utiles

État des services :

```bash
docker compose ps
```

Logs d’un service :

```bash
docker compose logs -f qgis-server
docker compose logs -f postgis
docker compose logs -f nest-app
```

Entrer dans PostGIS :

```bash
docker exec -it postgis psql -U "$POSTGRES_USER" -d "$POSTGRES_DB"
```

Lister les tables :

```sql
\dt
```

---

## Annexe A) Commandes historiques (legacy)

Cette section conserve les anciennes commandes présentes dans le README d’origine.

### Build et run manuel QGIS Server

```bash
docker build -f Dockerfile -t qgis-server ./
```

```bash
docker network create qgis
docker run -d --rm --name qgis-server --net=qgis --hostname=qgis-server \
    -v $(pwd)/data:/data:ro -p 5555:5555 \
    -e "QGIS_PROJECT_FILE=/data/osm.qgs" \
    qgis-server
```

Voir les conteneurs :

```bash
docker ps -a
```

### Run manuel Nginx

```bash
docker run -d --rm --name nginx --net=qgis --hostname=nginx \
    -v $(pwd)/nginx.conf:/etc/nginx/conf.d/default.conf:ro -p 8080:80 \
    nginx:1.13
```

Test capacité WMS :

```text
http://localhost:8080/qgis-server/?SERVICE=WMS&VERSION=1.3.0&REQUEST=GetCapabilities
```

### Variantes Docker Compose historiques

```bash
docker-compose up -d
```

```bash
docker system prune -a
docker-compose pull
docker-compose up --force-recreate --build -d
```

### Commandes historiques pgAdmin / PostGIS

```bash
docker run --name pgadmin -e PGADMIN_DEFAULT_EMAIL=admin@admin.com -e PGADMIN_DEFAULT_PASSWORD=admin -p 8081:80 -d dpage/pgadmin4:latest
docker volume create pg_data
docker build -t postgis:1.0 .
docker run --name postgis -p 5432:5432 -v pg_data:/var/lib/postgresql -e ALLOW_IP_RANGE=0.0.0.0/0 -e POSTGRES_DB=gis -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=postgres --restart=always -d postgis/postgis:16-3.4
docker network create postgis_network
docker network connect postgis_network <container_ID>
```

Vérification DB :

```bash
psql -h localhost -p 5432 -U postgres
pg_isready -h postgis -p 5432 -U postgres
```

### Exemples historiques supplémentaires

```bash
# Construire l'image Docker
docker build -t custom-postgis .

# Exécuter le conteneur Docker
docker run --name postgis-container -e POSTGRES_DB=mydatabase -e POSTGRES_USER=myuser -e POSTGRES_PASSWORD=mypassword -d custom-postgis

# Variante (non recommandée)
docker run --name postgis-container -p 5432:5432 -e POSTGRES_HOST_AUTH_METHOD=trust -e POSTGRES_DB=mydatabase -e POSTGRES_USER=myuser -e POSTGRES_PASSWORD=mypassword -d custom-postgis
```

Rappels historiques :

- `ALLOW_IP_RANGE=0.0.0.0/0`
- `/usr/local/bin/docker-entrypoint.sh` : script d’entrée PostGIS
- Démarrage DB possible avec `pg_ctl -D /var/lib/postgresql/data -l logfile start`
- `POSTGRES_HOST_AUTH_METHOD=trust` autorise les connexions sans mot de passe (non recommandé)
- `psql -d my_database -U my_user`
- `\c` : lister les bases
- `\dt` : lister les tables

---

## 9) Développement local NestJS (hors Docker)

Depuis `nestjs/` :

```bash
npm install
npm run start:dev
```

Scripts disponibles :

- `npm run build`
- `npm run lint`
- `npm run test`
- `npm run start:prod`

---

## 10) Troubleshooting

### QGIS ne répond pas

- Vérifier `qgis-server` et `nginx` : `docker compose ps`
- Vérifier les logs : `docker compose logs -f qgis-server nginx`
- Tester directement GetCapabilities (URL section 6)

### L’API `/carto` retourne une erreur 500

- Vérifier que `EXTERNAL_SERVICE_URL` est défini dans `.env`
- Vérifier que la couche `layername` existe dans le projet QGIS
- Vérifier le format du `bbox`

### Les couches sont vides

- Vérifier les imports dans les logs `postgis`
- Confirmer la présence des fichiers dans `postgis/data/geojson` et `postgis/data/shapefile`
- Vérifier que les tables existent dans PostGIS

### pgAdmin ne se connecte pas

- Hôte : `postgis` (depuis le réseau Docker)
- Port : `5432`
- Aligner user/db/password avec `.env`

---

## 11) Limites et améliorations recommandées

- Éviter les secrets en dur (mots de passe par défaut)
- Ajouter un `.env.example` versionné
- Aligner `pgadmin/servers.json` avec les variables réelles du projet
- Ajouter des healthchecks sur `qgis-server`, `nginx`, `nest-app`
- Ajouter des tests e2e sur `POST /carto`

---

## 12) Licence

Le projet est distribué sous la licence présente dans [LICENSE](LICENSE).
