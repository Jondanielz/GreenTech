# 🚀 API Backend - Purple Admin Eco System

API RESTful construida en PHP para gestionar autenticación y operaciones del sistema Purple Admin.

## 📁 Estructura de Archivos

```
api/
├── config/
│   ├── database.php      # Configuración de conexión MySQL
│   └── cors.php          # Configuración CORS
│
├── controllers/
│   └── AuthController.php # Controlador de autenticación
│
├── models/
│   └── User.php          # Modelo de usuario
│
├── logs/
│   └── .gitkeep          # Directorio de logs
│
├── index.php             # Router principal
└── README.md             # Esta documentación
```

---

## ⚙️ Configuración

### 1. Base de Datos

Edita `config/database.php` con tus credenciales:

```php
private $host = "localhost";
private $db_name = "eco_system";
private $username = "root";
private $password = "";  // Tu contraseña de MySQL
```

### 2. Importar Base de Datos

```bash
mysql -u root -p < ../src/utils/eco_system.sql
```

O desde phpMyAdmin:

1. Crear base de datos `eco_system`
2. Importar `../src/utils/eco_system.sql`

### 3. Verificar Apache

Asegúrate de que `mod_rewrite` y `mod_headers` estén habilitados:

```bash
# En Ubuntu/Debian
sudo a2enmod rewrite
sudo a2enmod headers
sudo systemctl restart apache2

# En Windows (XAMPP)
# Descomentar en httpd.conf:
# LoadModule rewrite_module modules/mod_rewrite.so
# LoadModule headers_module modules/mod_headers.so
```

---

## 🔗 Endpoints Disponibles

| Método | Endpoint         | Descripción            |
| ------ | ---------------- | ---------------------- |
| `POST` | `/auth/login`    | Iniciar sesión         |
| `POST` | `/auth/register` | Registrar usuario      |
| `POST` | `/auth/logout`   | Cerrar sesión          |
| `POST` | `/auth/verify`   | Verificar token        |
| `GET`  | `/auth/me`       | Obtener usuario actual |

---

## 🧪 Probar la API

### 1. Verificar que la API está corriendo

Abre en el navegador:

```
http://localhost/purple-free/api
```

Deberías ver:

```json
{
  "success": true,
  "message": "API de Purple Admin - Eco System",
  "version": "1.0.0"
}
```

### 2. Probar Login

```bash
curl -X POST http://localhost/purple-free/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"user":"admin","password":"12345678"}'
```

### 3. Usuarios de Prueba

| Usuario | Contraseña | Rol           | Tipo Hash |
| ------- | ---------- | ------------- | --------- |
| `admin` | `12345678` | Administrador | MD5       |
| `coord` | `1234`     | Coordinador   | MD5       |
| `part`  | `part`     | Participante  | bcrypt    |

---

## 🔒 Seguridad

### Contraseñas

- **Nuevos usuarios:** Se usa `password_hash()` con bcrypt
- **Usuarios legacy:** Se soporta MD5 para compatibilidad

### Tokens

- Generados con `random_bytes(32)`
- Almacenados en tabla `user_sessions`
- Válidos por 24 horas
- Se limpian automáticamente al expirar

### Headers de Seguridad

Configurados en `.htaccess`:

- `X-Frame-Options: SAMEORIGIN`
- `X-Content-Type-Options: nosniff`
- `X-XSS-Protection: 1; mode=block`

---

## 📊 Base de Datos

### Tablas Utilizadas

- **users:** Usuarios del sistema
- **roles:** Roles y permisos
- **positions:** Cargos/posiciones
- **user_sessions:** Sesiones activas
- **user_activities:** Log de actividades

### Diagrama de Relaciones

```
users
├── role_id → roles
├── position_id → positions
├── user_sessions (1:N)
└── user_activities (1:N)
```

---

## 🐛 Debugging

### Ver Logs

Los errores se guardan en `logs/php-errors.log`:

```bash
tail -f api/logs/php-errors.log
```

### Activar Modo Debug

En `index.php`, cambiar temporalmente:

```php
ini_set('display_errors', 1);  // Solo en desarrollo
```

### Errores Comunes

1. **"Cannot connect to database"**

   - Verificar credenciales en `config/database.php`
   - Comprobar que MySQL está corriendo
   - Verificar que la BD `eco_system` existe

2. **"404 Not Found" en rutas API**

   - Verificar que `.htaccess` está en la raíz
   - Comprobar que `mod_rewrite` está habilitado
   - Revisar la ruta base en `.htaccess`

3. **"CORS Error"**
   - Verificar `config/cors.php`
   - Agregar el origen de Vite a `$allowedOrigins`
   - Reiniciar Apache

---

## 🚀 Expansión Futura

Para agregar más funcionalidad:

### 1. Nuevo Controlador

```php
// api/controllers/ProjectController.php
<?php
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../models/Project.php';

class ProjectController {
    private $db;
    private $project;

    public function __construct() {
        $database = new Database();
        $this->db = $database->getConnection();
        $this->project = new Project($this->db);
    }

    public function getAll() {
        // Implementar lógica
    }
}
?>
```

### 2. Registrar Rutas

En `index.php`:

```php
if ($uri_parts[0] === 'projects') {
    $projectController = new ProjectController();
    // Manejar rutas de proyectos
}
```

### 3. Crear Modelo

```php
// api/models/Project.php
<?php
class Project {
    private $conn;
    private $table_name = "projects";

    public function __construct($db) {
        $this->conn = $db;
    }

    public function getAll() {
        $query = "SELECT * FROM " . $this->table_name;
        $stmt = $this->conn->prepare($query);
        $stmt->execute();
        return $stmt;
    }
}
?>
```

---

## 📚 Documentación Completa

Ver [`API_DOCUMENTACION.md`](../API_DOCUMENTACION.md) en la raíz del proyecto para documentación detallada.

---

## 🛠️ Mantenimiento

### Limpiar Sesiones Expiradas

```sql
DELETE FROM user_sessions WHERE expires_at < NOW();
```

### Ver Sesiones Activas

```sql
SELECT s.*, u.name, u.email
FROM user_sessions s
JOIN users u ON s.user_id = u.id
WHERE s.expires_at > NOW();
```

### Ver Actividades Recientes

```sql
SELECT ua.*, u.name
FROM user_activities ua
JOIN users u ON ua.user_id = u.id
ORDER BY ua.timestamp DESC
LIMIT 50;
```

---

## 📞 Soporte

Si encuentras problemas:

1. Revisar logs: `api/logs/php-errors.log`
2. Verificar configuración: `config/database.php`
3. Probar conexión: `http://localhost/purple-free/api`
4. Consultar documentación: `API_DOCUMENTACION.md`

---

**Versión:** 1.0.0  
**Última actualización:** 11 de Octubre, 2025
