# Docker DS-2025 - Arquitectura Separada por Servicios

Esta configuración separa cada servicio en su propio contenedor dedicado con su docker-compose independiente, todos conectados a través de una red Docker compartida llamada `ds2025-network`.

## Estructura de Directorios

```
docker-ds-2025/
├── keycloak/              # Servicio de autenticación + PostgreSQL
│   ├── docker-compose.yml
│   └── realm-config/
├── logistica/             # Backend de logística + MySQL
│   └── docker-compose.yml
├── stock/                 # Backend de stock + PostgreSQL
│   ├── docker-compose.yml
│   ├── init.sql
│   └── schema.sql
├── compras/               # Backend de compras
│   └── docker-compose.yml
├── api-gateway/           # Nginx API Gateway
│   ├── docker-compose.yml
│   ├── Dockerfile
│   └── nginx.conf
├── setup-network.ps1      # Script para levantar todo
└── teardown.ps1           # Script para detener todo
```

## Inicio Rápido

### 1. Levantar todos los servicios

```powershell
.\setup-network.ps1
```

Este script automáticamente:
- Crea la red compartida `ds2025-network`
- Levanta todos los servicios en orden
- Muestra las URLs de acceso

### 2. Detener todos los servicios

```powershell
.\teardown.ps1
```

## Gestión Individual de Servicios

Cada servicio puede ser gestionado de forma independiente:

### Keycloak
```powershell
cd keycloak
docker compose up -d    # Iniciar
docker compose down     # Detener
docker compose logs -f  # Ver logs
```

### Logística
```powershell
cd logistica
docker compose up -d
docker compose down
```

### Stock
```powershell
cd stock
docker compose up -d
docker compose down
```

### Compras
```powershell
cd compras
docker compose up -d
docker compose down
```

### API Gateway
```powershell
cd api-gateway
docker compose up -d
docker compose down
```

## Red Compartida

Todos los servicios están conectados a través de la red `ds2025-network`. Esto permite:
- Comunicación entre contenedores usando nombres de servicio (ej: `http://keycloak:8080`)
- Aislamiento de otros contenedores Docker
- Gestión independiente de cada servicio

### Crear la red manualmente (si es necesario)
```powershell
docker network create ds2025-network
```

### Eliminar la red
```powershell
docker network rm ds2025-network
```

## Puertos Expuestos

| Servicio      | Puerto | URL                          |
|---------------|--------|------------------------------|
| Keycloak      | 8080   | http://localhost:8080        |
| API Gateway   | 3088   | http://localhost:3088        |
| Logística     | 3010   | http://localhost:3010        |
| Stock         | 3099   | http://localhost:3099        |
| Compras       | 3081   | http://localhost:3081        |
| MySQL         | 3306   | localhost:3306               |
| PostgreSQL    | 5432   | localhost:5432               |

## Comunicación entre Servicios

Los servicios se comunican entre sí usando los nombres de los contenedores:
- **Keycloak**: `http://keycloak:8080`
- **Backend Logística**: `http://shipping_back:3000`
- **Backend Stock**: `http://backend-stock:3000`
- **Backend Compras**: `http://backend-compras:8081`
- **API Gateway**: `http://api-gateway:80`

## Variables de Entorno

Cada servicio puede tener su propio archivo `.env`:

### keycloak/.env
```env
POSTGRES_DB=keycloak_db
POSTGRES_USER=keycloak_user
POSTGRES_PASSWORD=keycloak_password
KEYCLOAK_ADMIN=admin
KEYCLOAK_ADMIN_PASSWORD=admin
```

## Troubleshooting

### Error: network ds2025-network not found
```powershell
docker network create ds2025-network
```

### Ver todos los contenedores en la red
```powershell
docker network inspect ds2025-network
```

### Reiniciar un servicio específico
```powershell
cd <servicio>
docker compose restart
```

### Ver logs de todos los servicios
```powershell
docker compose -f keycloak/docker-compose.yml logs -f &
docker compose -f logistica/docker-compose.yml logs -f &
docker compose -f stock/docker-compose.yml logs -f &
docker compose -f compras/docker-compose.yml logs -f &
docker compose -f api-gateway/docker-compose.yml logs -f
```

## Ventajas de esta Arquitectura

1. **Independencia**: Cada servicio puede iniciarse/detenerse sin afectar a los demás
2. **Escalabilidad**: Fácil agregar réplicas de servicios específicos
3. **Desarrollo**: Permite trabajar en un servicio sin necesidad de levantar todo
4. **Debugging**: Logs y gestión aislada por servicio
5. **Despliegue**: Cada servicio puede desplegarse en diferentes hosts si es necesario
