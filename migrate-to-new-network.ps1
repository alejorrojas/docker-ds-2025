# Script para migrar de shared_net a ds2025-network

Write-Host "Deteniendo servicios existentes..." -ForegroundColor Yellow
docker compose down 2>$null

Write-Host "`nActualizando archivos docker-compose..." -ForegroundColor Cyan

# Actualizar keycloak
(Get-Content .\keycloak\docker-compose.yml) -replace 'shared_net', 'ds2025-network' | Set-Content .\keycloak\docker-compose.yml

# Actualizar logistica
(Get-Content .\logistica\docker-compose.yml) -replace 'shared_net', 'ds2025-network' | Set-Content .\logistica\docker-compose.yml

# Actualizar stock
(Get-Content .\stock\docker-compose.yml) -replace 'shared_net', 'ds2025-network' | Set-Content .\stock\docker-compose.yml

Write-Host "Archivos actualizados exitosamente" -ForegroundColor Green

Write-Host "`nEliminando red antigua..." -ForegroundColor Yellow
docker network rm shared_net 2>$null

Write-Host "`nAhora ejecuta: .\setup-network.ps1" -ForegroundColor Green
