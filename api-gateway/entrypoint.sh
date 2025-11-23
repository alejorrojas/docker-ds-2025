#!/bin/sh
set -e

# Generar nginx.conf desde el template usando envsubst
# Solo reemplaza las variables definidas en el template
envsubst '${COMPRAS_SERVICE_HOST} ${COMPRAS_SERVICE_PORT} ${STOCK_SERVICE_HOST} ${STOCK_SERVICE_PORT} ${LOGISTICA_SERVICE_HOST} ${LOGISTICA_SERVICE_PORT}' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

# Ejecutar nginx
exec nginx -g 'daemon off;'

