#!/bin/bash

# Script para detener todos los servicios del stack

set -e

echo "🛑 Deteniendo servicios principales..."
docker compose -p test-stock down

echo "🛑 Deteniendo Keycloak..."
cd keycloak
docker compose -p keycloak down
cd ..

echo "✅ Todos los servicios han sido detenidos"
echo ""
echo "Nota: La red 'shared_net' se mantiene activa."
echo "Si deseas eliminarla, ejecuta: docker network rm shared_net"

