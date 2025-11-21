# Stack Unificado - Keycloak, Stock, Logística y Compras

Este proyecto contiene un stack completo de microservicios unificado en un solo `docker-compose.yml`, incluyendo Keycloak para autenticación, y los backends de Stock, Logística y Compras.

## 📋 Tabla de Contenidos

- [Arquitectura](#arquitectura)
- [Uso](#uso)
- [Pruebas con CURL](#Pruebas-con-CURL)
- [Configuración Inicial](#configuración-inicial)
- [Servicios](#servicios)
- [Comunicación entre Servicios](#comunicación-entre-servicios)
- [Keycloak y Autenticación](#keycloak-y-autenticación)
- [Troubleshooting](#troubleshooting)

## 🏗️ Arquitectura

El stack está compuesto por los siguientes servicios:

```
┌─────────────────────────────────────────────────────────────┐
│                    Docker Compose Unificado                  │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│                        ┌──────────────┐                      │
│                        │   Cliente    │                      │
│                        │  (Browser)   │                      │
│                        └──────┬───────┘                      │
│                               │                              │
│                        ┌──────▼──────────────┐              │
│                        │   API Gateway       │              │
│                        │   (Nginx) :3088     │              │
│                        │                     │              │
│                        │  /compras  →        │              │
│                        │  /api/     →        │              │
│                        │  /shipping →        │              │
│                        └──┬──────┬──────┬────┘              │
│                           │      │      │                   │
│                           │      │      │                   │
│  ┌──────────────┐    ┌────▼──┐  │  ┌───────┐              │
│  │ PostgreSQL   │◄───┤ Keycloak│  │  │Backend│              │
│  │ (Keycloak)   │    │  :8080 │  │  │Compras│              │
│  └──────────────┘    └────────┘  │  │ :3081 │              │
│                                  │  └───────┘              │
│                                  │                         │
│  ┌──────────────┐          ┌────▼────┐                   │
│  │ PostgreSQL   │◄─────────┤ Backend │                   │
│  │   (Stock)    │          │  Stock  │                   │
│  └──────────────┘          │  :3099  │                   │
│                            └─────────┘                   │
│                                                           │
│  ┌──────────────┐          ┌─────────┐                   │
│  │   MySQL      │◄─────────┤ Backend │                   │
│  │ (Logística)  │          │Logística│                   │
│  └──────────────┘          │  :3010  │                   │
│                            └─────────┘                   │
│                                                           │
└───────────────────────────────────────────────────────────┘
```

## 🚀 Uso

### Levantar todos los servicios

```bash
docker compose up -d
```

## Pruebas con CURL

Una vez que todos los servicios estén corriendo, puedes probar los endpoints con los siguientes comandos:

#### Obtener Token de Keycloak

```bash
curl --location 'http://localhost:8080/realms/ds-2025-realm/protocol/openid-connect/token' \
--header 'Content-Type: application/x-www-form-urlencoded' \
--data-urlencode 'grant_type=client_credentials' \
--data-urlencode 'client_id=grupo-03' \
--data-urlencode 'client_secret=21cd6616-6571-4ee7-be29-0f781f77c74e'
```

Este comando retorna un JSON con el `access_token` que necesitarás para las siguientes peticiones.

#### Obtener Productos de Stock (requiere token)

Reemplaza `{token}` con el `access_token` obtenido del paso anterior:

```bash
curl --location 'http://localhost:3088/api/productos' \
--header 'Authorization: Bearer {token}'
```

#### Obtener Envíos de Logística (requiere token)

```bash
curl --location 'http://localhost:3088/shipping' \
--header 'Authorization: Bearer {token}'
```

#### Obtener Métodos de Transporte (público, no requiere token)

Este endpoint es público y no requiere autenticación:

```bash
curl --location 'http://localhost:3088/shipping/transport-methods'
```

> **Nota**: Aunque el endpoint es público, puedes incluir el header de Authorization si lo deseas, pero no es necesario.

- Service accounts configurados

## 🔧 Servicios

### Keycloak (Puerto 8080)

**Servicio de autenticación y autorización**

- **URL**: http://localhost:8080
- **Admin Console**: http://localhost:8080/admin
- **Usuario admin**: `admin` / `ds2025`
- **Realm**: `ds-2025-realm`
- **Base de datos**: PostgreSQL (`postgres-keycloak`)

**Configuración**:
- Importa automáticamente el realm desde `keycloak/realm-config/ds-2025-realm.json`
- Hostname interno: `keycloak` (para comunicación entre contenedores)
- Health check habilitado

### Backend Stock (Puerto 3099)

**Microservicio de gestión de stock**

- **URL**: http://localhost:3099
- **Base de datos**: PostgreSQL (`postgres-stock`)
- **Cliente Keycloak**: `grupo-11`
- **Secret**: `ef7f0900-8de5-46c0-b813-ce76d61e0158`

**Variables de entorno**:
- `DB_HOST=postgres-stock`
- `DB_NAME=stock_management`
- `KEYCLOAK_ISSUER=http://keycloak:8080/realms/ds-2025-realm`
- `KEYCLOAK_CLIENT_ID=grupo-11`

### Backend Logística (Puerto 3010)

**Microservicio de gestión logística**

- **URL**: http://localhost:3010
- **Base de datos**: MySQL (`mysql-logistica`)
- **Cliente Keycloak**: `grupo-03`
- **Secret**: `21cd6616-6571-4ee7-be29-0f781f77c74e`

**Variables de entorno**:
- `DB_HOST=mysql-logistica`
- `KEYCLOAK_AUTH_SERVER_URL=http://keycloak:8080`
- `KEYCLOAK_REALM=ds-2025-realm`

### Backend Compras

**Microservicio de gestión de compras**

- **Contenedor**: `backend-compras`
- **Imagen**: `ghcr.io/frre-ds/backend-compras-g01:7ac7a4efec1f0551fbb8267e391989126ff6b82d`
- **Puerto**: 3081

> **Nota**: Este servicio está en configuración inicial. Puede requerir variables de entorno adicionales según sus necesidades.

### API Gateway (Puerto 3088)

**Punto de entrada unificado para todos los microservicios**

- **URL**: http://localhost:3088
- **Tecnología**: Nginx
- **Rutas configuradas**:
  - `/compras` → Proxy a `backend-compras:8081/compras/`
  - `/api/` → Proxy a `backend-stock:3000/api/`
  - `/shipping` → Proxy a `back-logistica:3010/shipping`
  - `/` → Contenido estático (por defecto)

**Configuración**:
- Archivo de configuración: `api-gateway/nginx.conf`
- Depende de: `backend-compras`, `backend-stock`, `back-logistica`
- Timeouts configurados: `proxy_connect_timeout: 5s`, `proxy_read_timeout: 30s`

> **Nota**: Todas las peticiones a los microservicios deben pasar a través del API Gateway usando las rutas configuradas.

### Bases de Datos

#### PostgreSQL (Keycloak)
- **Puerto**: 5432 (interno, no expuesto)
- **Base de datos**: `keycloak_db`
- **Usuario**: `keycloak_db_user`
- **Volumen**: `postgres_keycloak_data`

#### PostgreSQL (Stock)
- **Puerto**: 5432
- **Base de datos**: `postgres`
- **Usuario**: `postgres`
- **Volumen**: `postgres_stock_data`
- **Scripts de inicialización**: 
  - `stock/init.sql`
  - `stock/schema.sql`

#### MySQL (Logística)
- **Puerto**: 3306
- **Base de datos**: `shipping_db`
- **Usuario**: `shipping_user`
- **Volumen**: `mysql_logistica_data`

## 🔗 Comunicación entre Servicios

### Red Docker Compose

**No es necesario crear una red compartida manualmente**. Docker Compose crea automáticamente una red por defecto para todos los servicios en el mismo `docker-compose.yml`.

### Regla de Oro: Usar nombres de servicio, NO localhost

Dentro de los contenedores, los servicios se comunican usando el **nombre del servicio** como hostname:

✅ **CORRECTO**:
```yaml
KEYCLOAK_ISSUER: http://keycloak:8080/realms/ds-2025-realm
DB_HOST: postgres-stock
DB_HOST: mysql-logistica
```

❌ **INCORRECTO**:
  ```yaml
KEYCLOAK_ISSUER: http://localhost:8080/realms/ds-2025-realm  # No funciona
DB_HOST: localhost  # No funciona
```

### Ejemplos de Comunicación

1. **Backend Stock → Keycloak**:
   ```
   http://keycloak:8080/realms/ds-2025-realm
   ```

2. **Backend Logística → Keycloak**:
   ```
   http://keycloak:8080
   ```

3. **Backend Stock → PostgreSQL**:
   ```
   postgres-stock:5432
   ```

4. **Backend Logística → MySQL**:
   ```
   mysql-logistica:3306
   ```

## 🔐 Keycloak y Autenticación

### Obtener Token (Client Credentials)

Ejemplo para el cliente `grupo-03`:

```bash
curl --location 'http://localhost:8080/realms/ds-2025-realm/protocol/openid-connect/token' \
--header 'Content-Type: application/x-www-form-urlencoded' \
--data-urlencode 'grant_type=client_credentials' \
--data-urlencode 'client_id=grupo-03' \
--data-urlencode 'client_secret=21cd6616-6571-4ee7-be29-0f781f77c74e'
```

### Clientes Disponibles

El realm incluye los siguientes clientes (grupo-01 a grupo-13) con sus respectivos secrets configurados en `keycloak/realm-config/ds-2025-realm.json`.

### Client Scopes

El realm incluye los siguientes scopes personalizados:
- `usuarios:read`, `usuarios:write`
- `productos:read`, `productos:write`
- `stock:read`, `stock:write`
- `compras:read`, `compras:write`
- `categorias:read`, `categorias:write`
- `reservas:read`, `reservas:write`
- `envios:read`, `envios:write`

### Roles del Realm

- `compras-be`: Rol para backend de compras
- `stock-be`: Rol para backend de stock
- `logistica-be`: Rol para backend de logística

### Importación Automática del Realm

Keycloak importa automáticamente el realm al iniciar usando:
- **Comando**: `start --import-realm`
- **Directorio**: `./keycloak/realm-config:/opt/keycloak/data/import`
- **Estrategia**: `IGNORE_EXISTING` (no sobrescribe si ya existe)

## 🔍 Troubleshooting

### Verificar conectividad entre servicios

```bash
# Desde el backend-stock a keycloak
docker exec backend-stock ping -c 2 keycloak

# Verificar que keycloak responde
  docker exec backend-stock wget -qO- http://keycloak:8080/realms/ds-2025-realm/.well-known/openid-configuration
  ```

### Ver logs de Keycloak

```bash
docker compose logs keycloak | grep -i "import\|realm\|error"
```

### Verificar que el realm se importó correctamente

```bash
curl http://localhost:8080/realms/ds-2025-realm/.well-known/openid-configuration
```

### Reiniciar un servicio específico

```bash
docker compose restart keycloak
docker compose restart backend-stock
```

### Ver estado de health checks

```bash
docker compose ps
```

### Problema: "Realm does not exist"

Si obtienes este error, verifica:
1. Que el archivo `keycloak/realm-config/ds-2025-realm.json` existe
2. Que Keycloak terminó de iniciar (ver logs)
3. Que el realm se importó correctamente (ver logs de importación)

### Problema: Variables de entorno no definidas

Asegúrate de que el archivo `.env` en la raíz contiene todas las variables necesarias (ver sección [Configuración Inicial](#configuración-inicial)).

## 📁 Estructura del Proyecto

```
test-stock/
├── docker-compose.yml          # Stack unificado
├── .env                        # Variables de entorno
├── api-gateway/
│   ├── Dockerfile              # Imagen del API Gateway
│   └── nginx.conf              # Configuración de Nginx
├── keycloak/
│   ├── .env                    # Variables de Keycloak (fuente)
│   ├── docker-compose.yml      # (legacy, no usar)
│   └── realm-config/
│       └── ds-2025-realm.json  # Configuración del realm
├── stock/
│   ├── docker-compose.yml      # (legacy, no usar)
│   ├── init.sql                # Script de inicialización DB
│   └── schema.sql              # Schema de la base de datos
├── logistica/
│   └── docker-compose.yml      # (legacy, no usar)
└── README.md                   # Esta documentación
```

## 📝 Notas Importantes

1. **Fuente de verdad**: 
   - Realm: `keycloak/realm-config/ds-2025-realm.json`
   - Variables: `keycloak/.env` (copiadas a `.env` principal)

2. **Persistencia**: Los datos se guardan en volúmenes Docker. Si eliminas los volúmenes (`docker compose down -v`), perderás todos los datos.

3. **Reinicio**: Al reiniciar los servicios, Keycloak verificará si el realm existe. Si no existe, lo importará automáticamente desde el JSON.

4. **Comunicación interna**: Todos los servicios pueden comunicarse entre sí usando el nombre del servicio como hostname, sin necesidad de configurar redes externas.

## 🎯 Resumen de Puertos

| Servicio | Puerto Externo | Puerto Interno |
|----------|---------------|----------------|
| API Gateway (Nginx) | 3088 | 80 |
| Keycloak | 8080 | 8080 |
| Backend Stock | 3099 | 3000 |
| Backend Logística | 3010 | 3000 |
| Backend Compras | 3081 | 8081 |
| PostgreSQL (Stock) | 5432 | 5432 |
| MySQL (Logística) | 3306 | 3306 |

---

**Última actualización**: Noviembre 2025
