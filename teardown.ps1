# Script para detener todos los servicios y limpiar

Write-Host "Deteniendo todos los servicios..." -ForegroundColor Yellow

Write-Host "`n1. Deteniendo API Gateway..." -ForegroundColor Cyan
Set-Location api-gateway
docker compose down
Set-Location ..

Write-Host "`n2. Deteniendo Compras..." -ForegroundColor Cyan
Set-Location compras
docker compose down
Set-Location ..

Write-Host "`n3. Deteniendo Logística..." -ForegroundColor Cyan
Set-Location logistica
docker compose down
Set-Location ..

Write-Host "`n4. Deteniendo Stock..." -ForegroundColor Cyan
Set-Location stock
docker compose down
Set-Location ..

Write-Host "`n5. Deteniendo Keycloak..." -ForegroundColor Cyan
Set-Location keycloak
docker compose down
Set-Location ..

Write-Host "`n✅ Todos los servicios han sido detenidos" -ForegroundColor Green

$removeNetwork = Read-Host "`n¿Deseas eliminar la red ds2025-network? (s/n)"
if ($removeNetwork -eq "s" -or $removeNetwork -eq "S") {
    Write-Host "`nEliminando red ds2025-network..." -ForegroundColor Yellow
    docker network rm ds2025-network
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Red eliminada" -ForegroundColor Green
    }
}
