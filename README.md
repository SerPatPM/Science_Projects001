# DB Web UI (Java + MySQL + HTML/JS/CSS)

Proyecto mínimo para:
- **Consultar tablas** (SELECT, listado con pestañas)
- **Altas** (INSERT) y **Modificaciones** (UPDATE) desde interfaz
- **Pestaña de consultas** con **solo SELECT** (seguridad)

## Requisitos
- Java 17+
- Maven 3+
- MySQL (por ejemplo XAMPP)

## Configuración
Edita `src/main/resources/application.properties`:
- `spring.datasource.url` (BD, host, puerto)
- `username` / `password`

Ejemplo (XAMPP típico):
```
spring.datasource.url=jdbc:mysql://localhost:3306/sams?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC
spring.datasource.username=root
spring.datasource.password=
```

## Correr
En la carpeta del proyecto:
```bash
mvn spring-boot:run
```
Luego abre:
- http://localhost:8080

## Nota importante (para poder editar)
Para que el botón **Editar** funcione, la tabla debe tener **PRIMARY KEY de una sola columna**.

Ejemplo de tabla de prueba:
```sql
CREATE TABLE cliente (
  id_cliente INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  edad INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO cliente (nombre, edad) VALUES ('Ana', 23), ('Luis', 31);
```

## Endpoints
- `GET /api/tables`
- `GET /api/table/{table}/meta`
- `GET /api/table/{table}/rows?limit=100&offset=0`
- `POST /api/table/{table}/insert` (JSON key/value)
- `POST /api/table/{table}/update` (JSON { pkColumn, pkValue, values })
- `POST /api/query` (JSON { sql })  -> solo SELECT
