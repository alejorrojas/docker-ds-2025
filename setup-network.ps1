# Script para crear la red compartida y levantar todos los servicios

Write-Host "Creando red compartida ds2025-network..." -ForegroundColor Green
docker network create ds2025-network 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "Red creada exitosamente" -ForegroundColor Green
} else {
    Write-Host "La red ya existe (esto es normal)" -ForegroundColor Yellow
}

Write-Host "`nLevantando servicios..." -ForegroundColor Green

Write-Host "`n1. Iniciando Keycloak..." -ForegroundColor Cyan
Set-Location keycloak
docker compose up -d
if ($LASTEXITCODE -eq 0) { Write-Host "OK - Keycloak iniciado" -ForegroundColor Green }
Set-Location ..

Write-Host "`n2. Iniciando Stock..." -ForegroundColor Cyan
Set-Location stock
docker compose up -d
if ($LASTEXITCODE -eq 0) { Write-Host "OK - Stock iniciado" -ForegroundColor Green }
Set-Location ..

Write-Host "`n3. Iniciando Logistica..." -ForegroundColor Cyan
Set-Location logistica
docker compose up -d
if ($LASTEXITCODE -eq 0) { Write-Host "OK - Logistica iniciado" -ForegroundColor Green }
Set-Location ..

Write-Host "`n4. Iniciando Compras..." -ForegroundColor Cyan
Set-Location compras
docker compose up -d
if ($LASTEXITCODE -eq 0) { Write-Host "OK - Compras iniciado" -ForegroundColor Green }
Set-Location ..

Write-Host "`n5. Iniciando API Gateway..." -ForegroundColor Cyan
Set-Location api-gateway
docker compose up -d
if ($LASTEXITCODE -eq 0) { Write-Host "OK - API Gateway iniciado" -ForegroundColor Green }
Set-Location ..

Write-Host "`nTodos los servicios han sido iniciados" -ForegroundColor Green
Write-Host "`nServicios disponibles:" -ForegroundColor Yellow
Write-Host "  - Keycloak:      http://localhost:8080" -ForegroundColor White
Write-Host "  - API Gateway:   http://localhost:3088" -ForegroundColor White
Write-Host "  - Logistica:     http://localhost:3010" -ForegroundColor White
Write-Host "  - Stock:         http://localhost:3099" -ForegroundColor White
Write-Host "  - Compras:       http://localhost:3081" -ForegroundColor White
