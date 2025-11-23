#!/bin/bash

# Script para iniciar todos los servicios del stack

set -e

echo "🚀 Iniciando stack completo..."

# Verificar si la red compartida existe, si no, crearla
if ! docker network inspect shared_net >/dev/null 2>&1; then
    echo "📡 Creando red compartida 'shared_net'..."
    docker network create shared_net
else
    echo "✅ Red compartida 'shared_net' ya existe"
fi

# Levantar Keycloak con nombre de proyecto explícito
echo "🔐 Iniciando Keycloak..."
cd keycloak
docker compose -p keycloak up -d
cd ..

# Esperar un poco para que Keycloak esté listo
echo "⏳ Esperando a que Keycloak esté listo..."
sleep 5

# Levantar servicios principales con nombre de proyecto explícito
echo "📦 Iniciando servicios principales..."
docker compose -p test-stock up -d

echo "✅ Todos los servicios están iniciando..."
echo ""
echo "Para ver el estado de los servicios:"
echo "  docker compose -p test-stock ps"
echo "  cd keycloak && docker compose -p keycloak ps && cd .."
echo ""
echo "Para ver los logs:"
echo "  docker compose -p test-stock logs -f"
echo "  cd keycloak && docker compose -p keycloak logs -f && cd .."

