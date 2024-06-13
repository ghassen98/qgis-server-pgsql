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


docker run --name my-postgis -e POSTGRES_PASSWORD=postgres -d postgis:1.0