#!/bin/bash

# Remplace les variables d'environnement dans le fichier template
envsubst < /data/dailymaps-template.qgs > /data/dailymaps.qgs

[[ $DEBUG == "1" ]] && env

exec /usr/bin/xvfb-run --auto-servernum --server-num=1 /usr/bin/spawn-fcgi -p 5555 -n -d /home/qgis -- /usr/lib/cgi-bin/qgis_mapserv.fcgi