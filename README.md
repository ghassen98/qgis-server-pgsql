# qgis-server-pgsql
A QGis Server + PostgreSQL docker environment

## Lancement des conteneurs

### Build de l'image qgis-server

`docker build -f Dockerfile -t qgis-server ./`

### First run

```
docker network create qgis
docker run -d --rm --name qgis-server --net=qgis --hostname=qgis-server \
              -v $(pwd)/data:/data:ro -p 5555:5555 \
              -e "QGIS_PROJECT_FILE=/data/osm.qgs" \
              qgis-server
```

### Voir ce qui roule

`docker ps -a`

### Exécuter une instance de Nginx

```
docker run -d --rm --name nginx --net=qgis --hostname=nginx \
              -v $(pwd)/nginx.conf:/etc/nginx/conf.d/default.conf:ro -p 8080:80 \
              nginx:1.13
```

### To check capabilities availability 

Type in a browser [http://localhost:8080/qgis-server/?SERVICE=WMS&VERSION=1.3.0&REQUEST=GetCapabilities](http://localhost:8080/qgis-server/?SERVICE=WMS&VERSION=1.3.0&REQUEST=GetCapabilities)

## Docker compose

Dans le repertoire principal:

`docker-compose up -d`

ou 

```
docker system prune -a
docker-compose pull
docker-compose up --force-recreate --build -d
```

# Run pgAdmin container
docker run --name pgadmin -e PGADMIN_DEFAULT_EMAIL=admin@admin.com -e PGADMIN_DEFAULT_PASSWORD=admin -p 8081:80 -d dpage/pgadmin4:latest

docker volume create pg_data

docker build -t postgis:1.0 .

# Run Postgis container
docker run --name postgis -p 5432:5432 -v pg_data:/var/lib/postgresql -e ALLOW_IP_RANGE=0.0.0.0/0 -e POSTGRES_DB=gis -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=postgres --restart=always -d postgis/postgis:16-3.4

docker network create postgis_network
docker network connect postgis_network <container_ID>


psql -h localhost -p 5432 -U postgres
pg_isready -h postgis -p 5432 -U postgres

#### From Github Copilot

# Construire l'image Docker
docker build -t custom-postgis .

# Exécuter le conteneur Docker
docker run --name postgis-container -e POSTGRES_DB=mydatabase -e POSTGRES_USER=myuser -e POSTGRES_PASSWORD=mypassword -d custom-postgis