# 🔧 Solución al Problema de Timeout con MySQL

## 📋 Diagnóstico

**Síntomas:**

- ✅ MySQL está corriendo (puerto 3306 abierto)
- ❌ PHP no puede conectarse (timeout)
- ❌ Comandos MySQL CLI no responden
- ❌ Login devuelve error de timeout

**Causa:** MySQL está bloqueado o no responde correctamente a las conexiones.

---

## ✅ Solución 1: Reinicio Forzado de MySQL (RECOMENDADO)

### Paso 1: Detener MySQL completamente

1. Abre **XAMPP Control Panel**
2. Haz clic en **"Stop"** junto a MySQL
3. **Espera 10 segundos**
4. Verifica que el texto se vuelva negro/gris

Si MySQL no se detiene:

1. Abre el **Administrador de tareas** (Ctrl + Shift + Esc)
2. Ve a la pestaña **"Detalles"**
3. Busca **`mysqld.exe`**
4. Haz clic derecho → **"Finalizar tarea"**
5. Confirma
6. **Espera 5 segundos**

### Paso 2: Limpiar archivos temporales (IMPORTANTE)

Ejecuta estos comandos en PowerShell como Administrador:

```powershell
# Ir al directorio de datos de MySQL
cd C:\xampp\mysql\data

# Eliminar archivos de bloqueo
Remove-Item "*.lock" -Force -ErrorAction SilentlyContinue
Remove-Item "*.pid" -Force -ErrorAction SilentlyContinue

# Eliminar tabla temporal
Remove-Item "ibtmp1" -Force -ErrorAction SilentlyContinue

Write-Host "✅ Archivos temporales limpiados" -ForegroundColor Green
```

### Paso 3: Iniciar MySQL de nuevo

1. En **XAMPP Control Panel**, haz clic en **"Start"** junto a MySQL
2. **Espera 15-20 segundos** para que inicie completamente
3. Verifica que aparezca en verde con `Port(s): 3306`

### Paso 4: Verificar que funciona

Prueba el login en tu aplicación. Debería funcionar ahora.

---

## ✅ Solución 2: Si la Solución 1 no funciona

### Opción A: Reparar tablas de MySQL

```powershell
cd C:\xampp\mysql\bin
.\myisamchk.exe --recover C:\xampp\mysql\data\*\*.MYI
```

### Opción B: Aumentar timeout en PHP

Edita `C:\xampp\php\php.ini`:

```ini
max_execution_time = 120
default_socket_timeout = 120
mysql.connect_timeout = 10
```

Reinicia Apache después de cambiar.

### Opción C: Verificar logs de MySQL

```powershell
Get-Content C:\xampp\mysql\data\mysql_error.log -Tail 50
```

Busca mensajes de error específicos.

---

## ✅ Solución 3: Recrear la base de datos (ÚLTIMA OPCIÓN)

**⚠️ ADVERTENCIA: Esto borrará todos los datos**

1. Detén MySQL
2. Haz backup de la carpeta `C:\xampp\mysql\data\eco_system`
3. Elimina la carpeta `eco_system`
4. Inicia MySQL
5. Crea la base de datos de nuevo:

```sql
CREATE DATABASE eco_system CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

6. Importa el SQL de nuevo desde phpMyAdmin

---

## 🔍 Cambios realizados en el código

### `api/config/database.php`

**Antes:**

```php
private $host = "localhost";
```

**Después:**

```php
private $host = "127.0.0.1";  // Evita problemas IPv6
```

**Agregado timeout:**

```php
$options = [
    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    PDO::ATTR_EMULATE_PREPARES => false,
    PDO::ATTR_TIMEOUT => 5  // Timeout de 5 segundos
];
```

---

## 📝 Prevención futura

Para evitar este problema:

1. **SIEMPRE** detén MySQL desde XAMPP antes de cerrar la aplicación
2. **NO** apagues la PC con MySQL corriendo
3. Si Windows se reinicia inesperadamente, limpia los archivos `.lock` antes de iniciar MySQL
4. Considera usar un script de inicio automático

---

## 🆘 Si nada funciona

Reinstala MySQL de XAMPP:

1. Haz backup de `C:\xampp\mysql\data\eco_system`
2. Desinstala XAMPP
3. Elimina `C:\xampp` completamente
4. Instala XAMPP de nuevo
5. Restaura la base de datos

---

**Autor:** Asistente de Código
**Fecha:** 12 de Octubre, 2025

