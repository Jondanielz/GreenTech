# 🚨 SOLUCIÓN: Error "Failed to fetch" en Dashboard

## ❌ Error que estás viendo:

```
TypeError: Failed to fetch
❌ Error al cargar dashboard: Error de conexión con el servidor
```

---

## ✅ SOLUCIÓN RÁPIDA (5 pasos)

### **PASO 1: Abrir XAMPP Control Panel**

```
1. Presiona la tecla Windows (⊞)
2. Escribe: "XAMPP"
3. Click en "XAMPP Control Panel"
```

---

### **PASO 2: Iniciar Apache**

**En el panel XAMPP verás algo como esto:**

```
┌─────────────────────────────────────────┐
│ Module    │ Status  │ Actions          │
├─────────────────────────────────────────┤
│ Apache    │         │ [START]          │  ← Click aquí en START
│ MySQL     │         │ [START]          │
│ FileZilla │         │ [START]          │
└─────────────────────────────────────────┘
```

**Después de hacer click en START junto a Apache:**

```
┌─────────────────────────────────────────┐
│ Module    │ Status  │ Actions          │
├─────────────────────────────────────────┤
│ Apache    │ Running │ [STOP] [Admin]   │  ← Debe decir "Running"
│ MySQL     │         │ [START]          │
│ FileZilla │         │ [START]          │
└─────────────────────────────────────────┘
```

**IMPORTANTE:**

- El botón cambiará de **START** (verde) a **STOP** (rojo)
- Aparecerá la palabra **"Running"** en la columna Status
- Si ves un error, es posible que el puerto 80 esté ocupado

---

### **PASO 3: Iniciar MySQL**

**Click en START junto a MySQL:**

```
┌─────────────────────────────────────────┐
│ Module    │ Status  │ Actions          │
├─────────────────────────────────────────┤
│ Apache    │ Running │ [STOP] [Admin]   │  ✅
│ MySQL     │ Running │ [STOP] [Admin]   │  ✅ Ahora MySQL también
│ FileZilla │         │ [START]          │
└─────────────────────────────────────────┘
```

---

### **PASO 4: Verificar que la API funciona**

**Abre en tu navegador:**

```
http://localhost/purple-free/api
```

**Si Apache está corriendo correctamente, verás:**

```json
{
  "success": true,
  "message": "API de GreenTech - Eco System",
  "version": "1.0.0",
  "endpoints": {
    "auth": { ... },
    "projects": { ... },
    "tasks": { ... },
    "dashboard": { ... }
  }
}
```

**✅ Si ves esto = ¡Apache funciona!**

**❌ Si NO ves esto:**

- Apache no está iniciado correctamente
- Revisa el log de errores en XAMPP (botón "Logs")
- Verifica que no haya otro programa usando el puerto 80

---

### **PASO 5: Recargar el Dashboard**

```
1. Ir a: http://localhost:3000
2. Presionar F5 (o Ctrl + R)
3. El dashboard debería cargar con datos
```

**Verás:**

- ✅ Estadísticas de proyectos
- ✅ Tareas completadas
- ✅ Usuarios activos
- ✅ Presupuesto restante
- ✅ Tabla de tareas recientes

---

## 🔧 Errores Comunes

### **Error: "Port 80 in use by..."**

**Solución:**

1. Otro programa está usando el puerto 80
2. Opciones:
   - Cierra Skype, IIS, u otro servidor web
   - O cambia el puerto de Apache en XAMPP:
     - Click en "Config" → "httpd.conf"
     - Busca "Listen 80"
     - Cambia a "Listen 8080"
     - Reinicia Apache
     - Actualiza la URL de la API a: `http://localhost:8080/purple-free/api`

### **Error: "MySQL shutdown unexpectedly"**

**Solución:**

1. El puerto 3306 puede estar ocupado
2. Click en "Logs" en XAMPP para ver el error
3. Reinicia MySQL desde el panel

---

## 🛠️ Herramienta de Diagnóstico

**Usa esta herramienta para diagnosticar el problema:**

```
http://localhost:3000/test-api-connection.html
```

Esta página:

- ✅ Prueba la conexión automáticamente
- ✅ Te dice exactamente qué está mal
- ✅ Muestra soluciones específicas
- ✅ Incluye logs técnicos completos

---

## 📋 Checklist Final

Marca cada paso cuando lo completes:

- [ ] XAMPP Control Panel abierto
- [ ] Apache iniciado (botón dice "STOP", status "Running")
- [ ] MySQL iniciado (botón dice "STOP", status "Running")
- [ ] API responde en: http://localhost/purple-free/api
- [ ] Test de conexión exitoso
- [ ] Dashboard carga en: http://localhost:3000
- [ ] Datos del dashboard se muestran correctamente

---

## 🎯 Resumen Visual

```
ANTES (Error):
┌──────────────────────────────────────────────────────┐
│ Dashboard (http://localhost:3000)                    │
│                                                      │
│ ❌ Error al cargar dashboard                        │
│ ❌ TypeError: Failed to fetch                       │
│                                                      │
│ [No se muestra ningún dato]                          │
└──────────────────────────────────────────────────────┘
              ↑
              │ NO HAY CONEXIÓN
              │
┌──────────────────────────────────────────────────────┐
│ API (http://localhost/purple-free/api)              │
│                                                      │
│ ❌ No responde (Apache detenido)                    │
└──────────────────────────────────────────────────────┘


DESPUÉS (Funcionando):
┌──────────────────────────────────────────────────────┐
│ Dashboard (http://localhost:3000)                    │
│                                                      │
│ ✅ Proyectos Activos: 5                             │
│ ✅ Tareas Completadas: 23                           │
│ ✅ Usuarios Activos: 12                             │
│ ✅ Presupuesto: $45,000                             │
│                                                      │
│ [Todos los datos se muestran correctamente]         │
└──────────────────────────────────────────────────────┘
              ↑
              │ CONEXIÓN EXITOSA ✅
              │
┌──────────────────────────────────────────────────────┐
│ API (http://localhost/purple-free/api)              │
│                                                      │
│ ✅ {                                                 │
│   "success": true,                                  │
│   "message": "API de GreenTech",                    │
│   "version": "1.0.0"                                │
│ }                                                    │
└──────────────────────────────────────────────────────┘
              ↑
              │ APACHE CORRIENDO ✅
              │
┌──────────────────────────────────────────────────────┐
│ XAMPP Control Panel                                  │
│                                                      │
│ Apache  │ Running │ [STOP] [Admin]  ✅             │
│ MySQL   │ Running │ [STOP] [Admin]  ✅             │
└──────────────────────────────────────────────────────┘
```

---

## 💡 Nota Final

**El problema NO está en tu código.**  
El problema es simplemente que **Apache no está corriendo**.

Una vez que inicies Apache en XAMPP, todo funcionará perfectamente.

---

**Última actualización:** 11 de Octubre, 2025  
**Versión:** 1.0.0
