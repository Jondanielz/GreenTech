# 📋 Sistema de Gestión de Proyectos - GreenTech

## ✅ Sistema Completado

Se ha implementado un sistema completo de gestión de proyectos con funcionalidades diferenciadas por roles de usuario.

---

## 🏗️ Arquitectura del Sistema

### **Backend (PHP + MySQL)**

#### **Modelos**

- `api/models/Project.php` - Gestión de proyectos
- `api/models/Task.php` - Gestión de tareas

#### **Controladores**

- `api/controllers/ProjectController.php` - Lógica de negocio para proyectos
- `api/controllers/TaskController.php` - Lógica de negocio para tareas

#### **Rutas API**

Configuradas en `api/index.php`:

**Proyectos:**

- `GET /api/projects` - Obtener proyectos (todos o del usuario según rol)
- `GET /api/projects/my` - Obtener proyectos del usuario
- `GET /api/projects/{id}` - Obtener proyecto por ID
- `POST /api/projects` - Crear proyecto (Admin/Coordinador)
- `PUT /api/projects/{id}` - Actualizar proyecto (Admin/Creador)
- `DELETE /api/projects/{id}` - Cancelar proyecto (Solo Admin)

**Tareas:**

- `GET /api/tasks/project/{project_id}` - Obtener tareas de un proyecto
- `GET /api/tasks/{id}` - Obtener tarea por ID
- `POST /api/tasks` - Crear tarea (Admin/Coordinador)
- `PUT /api/tasks/{id}` - Actualizar tarea (Admin/Coordinador)
- `PATCH /api/tasks/{id}` - Actualizar estado (Kanban - Todos los miembros)
- `DELETE /api/tasks/{id}` - Eliminar tarea (Admin/Coordinador)

---

### **Frontend (JavaScript ES6 Modules)**

#### **Servicios**

- `src/services/projects.js` - Comunicación con API de proyectos
- `src/services/tasks.js` - Comunicación con API de tareas

#### **Vistas**

**1. Gestión de Proyectos (Administrador)**

- **Archivo:** `src/views/projects/projects-management.html`
- **Acceso:** Solo administradores (role_id = 1)
- **Funcionalidades:**
  - ✅ Ver todos los proyectos en tarjetas
  - ✅ Crear nuevos proyectos
  - ✅ Editar proyectos existentes
  - ✅ Cancelar proyectos
  - ✅ Filtrar por estado y buscar por nombre
  - ✅ Ver progreso, estadísticas y presupuestos
  - ✅ Acceso completo a detalles

**2. Mis Proyectos (Coordinador/Participante)**

- **Archivo:** `src/views/projects/my-projects.html`
- **Acceso:** Coordinadores (role_id = 2) y Participantes (role_id = 3)
- **Funcionalidades:**
  - ✅ Ver solo proyectos asignados
  - ✅ Filtrar y buscar proyectos
  - ✅ Ver progreso y estadísticas
  - ✅ Acceso a detalles (sin edición/cancelación de proyectos)
  - ✅ Indicador de rol en el proyecto

**3. Detalles del Proyecto (Todos los roles)**

- **Archivo:** `src/views/projects/project-details.html`
- **Acceso:** Todos los miembros del proyecto
- **Funcionalidades:**

  **Pestaña "Información":**

  - ✅ Información general del proyecto
  - ✅ Descripción y objetivos
  - ✅ Estadísticas (tareas, progreso, presupuesto)
  - ✅ Lista de miembros del equipo
  - ✅ Fechas y días restantes
  - ✅ Indicadores de estado

  **Pestaña "Tablero Kanban":**

  - ✅ Tres columnas: Pendiente, En Progreso, Completada
  - ✅ Drag & Drop funcional (Sortable.js)
  - ✅ Tarjetas de tareas con:
    - Título y descripción
    - Prioridad (Baja, Media, Alta, Crítica)
    - Asignados (iniciales)
    - Fecha de vencimiento
    - Indicador de retraso
  - ✅ Crear/Editar/Eliminar tareas (Admin/Coordinador)
  - ✅ Mover tareas (Todos los miembros)
  - ✅ Actualización automática de contadores

---

## 🔐 Control de Permisos por Rol

### **Administrador (role_id = 1)**

- ✅ Ver todos los proyectos del sistema
- ✅ Crear nuevos proyectos
- ✅ Editar cualquier proyecto
- ✅ Cancelar cualquier proyecto
- ✅ Crear, editar y eliminar tareas
- ✅ Ver todos los detalles
- ✅ Mover tareas en el Kanban

### **Coordinador (role_id = 2)**

- ✅ Ver solo proyectos asignados
- ✅ Crear nuevos proyectos
- ✅ Editar proyectos propios
- ❌ No puede cancelar proyectos
- ✅ Crear, editar y eliminar tareas
- ✅ Ver detalles de proyectos asignados
- ✅ Mover tareas en el Kanban

### **Participante (role_id = 3)**

- ✅ Ver solo proyectos asignados
- ❌ No puede crear proyectos
- ❌ No puede editar proyectos
- ❌ No puede cancelar proyectos
- ❌ No puede crear/editar/eliminar tareas
- ✅ Ver detalles de proyectos asignados
- ✅ Mover tareas en el Kanban (solo cambiar estado)

---

## 🎨 Características de Interfaz

### **Tarjetas de Proyecto**

- Diseño atractivo con gradientes
- Badge de estado (Planificación, En Progreso, Completado, Cancelado, En Espera)
- Progreso visual con barra de progreso
- Estadísticas de tareas (completadas/total)
- Número de miembros
- Presupuesto formateado
- Días restantes con indicador de retraso
- Hover effects y animaciones
- Acciones rápidas: Ver, Editar, Cancelar

### **Tablero Kanban**

- Diseño de 3 columnas responsivo
- Drag & Drop suave con Sortable.js
- Tarjetas de tareas con diseño profesional
- Colores por prioridad
- Avatares de asignados
- Indicadores de vencimiento
- Contadores dinámicos por columna
- Feedback visual durante arrastre
- Actualización en tiempo real

### **Filtros y Búsqueda**

- Filtro por estado
- Búsqueda por nombre
- Contador de proyectos filtrados
- Interfaz intuitiva

---

## 🚀 Cómo Usar el Sistema

### **Paso 1: Iniciar Servidor**

```bash
# Iniciar Vite
npm run dev

# Verificar que Apache y MySQL estén corriendo en XAMPP
```

### **Paso 2: Acceder según tu Rol**

#### **Como Administrador**

```
1. Login: admin / 12345678
2. Click en "Gestión de Proyectos" en el sidebar
3. Ver todos los proyectos del sistema
4. Click en "Nuevo Proyecto" para crear
5. Click en "Editar" o "Ver" en cualquier tarjeta
6. Acceso completo al Kanban
```

#### **Como Coordinador**

```
1. Login: coord / coord123
2. Click en "Mis Proyectos" en el sidebar
3. Ver solo proyectos asignados
4. Click en "Ver Detalles" en cualquier tarjeta
5. Crear y editar tareas en el Kanban
```

#### **Como Participante**

```
1. Login: part / part123
2. Click en "Mis Proyectos" en el sidebar
3. Ver solo proyectos asignados
4. Click en "Ver Detalles" en cualquier tarjeta
5. Ver y mover tareas en el Kanban (sin editar)
```

---

## 📊 Funcionalidades del Tablero Kanban

### **Drag & Drop**

1. Click y mantén presionado en una tarjeta de tarea
2. Arrastra la tarjeta a otra columna
3. Suelta para cambiar el estado
4. El sistema actualiza automáticamente en la base de datos
5. Los contadores se actualizan en tiempo real

### **Gestión de Tareas (Admin/Coordinador)**

1. Click en "Nueva Tarea" para crear
2. Click en cualquier tarjeta para ver/editar
3. Formulario con:
   - Título (requerido)
   - Descripción
   - Estado (Pendiente/En Progreso/Completada)
   - Prioridad (Baja/Media/Alta/Crítica)
   - Fecha de vencimiento
   - Horas estimadas
4. Click en "Eliminar" para borrar tarea

---

## 🔧 Configuración Técnica

### **Base de Datos (eco_system)**

**Tablas utilizadas:**

- `projects` - Información de proyectos
- `tasks` - Información de tareas
- `users` - Usuarios del sistema
- `roles` - Roles y permisos
- `project_members` - Relación usuarios-proyectos
- `task_assignments` - Asignación de tareas a usuarios

### **Dependencias Frontend**

- Bootstrap 5 (Modales, tabs, componentes UI)
- Sortable.js (Drag & Drop del Kanban)
- Material Design Icons
- ES6 Modules (import/export)

### **Stack Técnico**

- **Frontend:** HTML5, CSS3, JavaScript ES6, Vite
- **Backend:** PHP 8.2, PDO
- **Base de Datos:** MySQL 8.0
- **Servidor:** Apache 2.4 (XAMPP)

---

## 📁 Estructura de Archivos

```
purple-free/
├── api/
│   ├── models/
│   │   ├── Project.php          ✅ NUEVO
│   │   └── Task.php              ✅ NUEVO
│   ├── controllers/
│   │   ├── ProjectController.php ✅ NUEVO
│   │   └── TaskController.php    ✅ NUEVO
│   └── index.php                 ✅ ACTUALIZADO (nuevas rutas)
├── src/
│   ├── services/
│   │   ├── projects.js           ✅ NUEVO
│   │   └── tasks.js              ✅ NUEVO
│   ├── views/
│   │   └── projects/             ✅ NUEVA CARPETA
│   │       ├── projects-management.html  ✅ NUEVO (Admin)
│   │       ├── my-projects.html          ✅ NUEVO (Usuario)
│   │       └── project-details.html      ✅ NUEVO (Todos)
│   └── components/
│       ├── sidebar-admin.html         ✅ ACTUALIZADO
│       ├── sidebar-coordinador.html   ✅ ACTUALIZADO
│       └── sidebar-participante.html  ✅ ACTUALIZADO
└── SISTEMA_PROYECTOS_DOCUMENTACION.md ✅ NUEVO
```

---

## 🧪 Casos de Prueba

### **Test 1: Administrador - Gestión Completa**

- [ ] Login como admin
- [ ] Acceder a "Gestión de Proyectos"
- [ ] Ver todos los proyectos
- [ ] Crear nuevo proyecto
- [ ] Editar proyecto existente
- [ ] Ver detalles de un proyecto
- [ ] Crear tarea en Kanban
- [ ] Mover tarea entre columnas
- [ ] Editar tarea
- [ ] Eliminar tarea
- [ ] Cancelar proyecto

### **Test 2: Coordinador - Gestión Limitada**

- [ ] Login como coordinador
- [ ] Acceder a "Mis Proyectos"
- [ ] Ver solo proyectos asignados
- [ ] Verificar que no aparece botón "Cancelar"
- [ ] Ver detalles de proyecto
- [ ] Crear tarea en Kanban
- [ ] Mover tarea entre columnas
- [ ] Editar tarea existente
- [ ] Verificar que puede eliminar tareas

### **Test 3: Participante - Solo Lectura/Movimiento**

- [ ] Login como participante
- [ ] Acceder a "Mis Proyectos"
- [ ] Ver solo proyectos asignados
- [ ] Ver detalles de proyecto
- [ ] Verificar que NO aparece botón "Nueva Tarea"
- [ ] Mover tarea entre columnas (solo esto está permitido)
- [ ] Verificar que NO puede crear tareas
- [ ] Verificar que NO puede editar tareas
- [ ] Verificar que NO puede eliminar tareas

### **Test 4: Filtros y Búsqueda**

- [ ] Filtrar proyectos por estado
- [ ] Buscar proyecto por nombre
- [ ] Verificar contador de proyectos
- [ ] Limpiar filtros

### **Test 5: Drag & Drop del Kanban**

- [ ] Arrastrar tarea de Pendiente a En Progreso
- [ ] Verificar actualización de contadores
- [ ] Arrastrar tarea a Completada
- [ ] Recargar página y verificar que se guardó
- [ ] Intentar arrastrar como participante

---

## 🎯 Funcionalidades Destacadas

### **1. Sistema de Permisos Granular**

- Validación en backend y frontend
- Diferentes capacidades por rol
- Mensajes claros de permisos insuficientes

### **2. Interfaz Intuitiva**

- Diseño moderno con Bootstrap
- Animaciones y efectos visuales
- Responsive design
- Feedback inmediato

### **3. Drag & Drop Profesional**

- Librería Sortable.js
- Animaciones suaves
- Feedback visual durante arrastre
- Persistencia en base de datos

### **4. Gestión Completa de Proyectos**

- CRUD completo según permisos
- Estadísticas en tiempo real
- Progreso visual
- Información detallada

---

## 🔄 Flujo de Trabajo

### **Crear Proyecto → Asignar Miembros → Crear Tareas → Gestionar con Kanban**

```
1. Admin/Coordinador crea proyecto
   ↓
2. Se asignan miembros al proyecto (via project_members)
   ↓
3. Admin/Coordinador crea tareas en el proyecto
   ↓
4. Se asignan usuarios a tareas (via task_assignments)
   ↓
5. Todos los miembros mueven tareas en Kanban
   ↓
6. Estado se actualiza automáticamente
   ↓
7. Progreso del proyecto se calcula en tiempo real
```

---

## 📈 Próximas Mejoras (Opcionales)

- [ ] Notificaciones en tiempo real
- [ ] Comentarios en tareas
- [ ] Archivos adjuntos
- [ ] Timeline de actividades
- [ ] Exportar a PDF/Excel
- [ ] Dashboard de métricas avanzadas
- [ ] Integración con calendario
- [ ] Chat del proyecto
- [ ] Historial de cambios
- [ ] API REST completa

---

## ✅ Estado del Desarrollo

**Backend:** ✅ 100% Completado

- Modelos: Project, Task
- Controladores: ProjectController, TaskController
- Rutas API configuradas
- Permisos implementados

**Frontend:** ✅ 100% Completado

- Servicios: projects.js, tasks.js
- Vistas: 3 vistas completas
- Componentes actualizados
- Drag & Drop funcional

**Integración:** ✅ 100% Completada

- Enlaces en sidebars actualizados
- Flujo de autenticación
- Control de permisos
- Navegación completa

---

**Sistema de Gestión de Proyectos Completado** 🎉

**Fecha:** 11 de Octubre, 2025
**Versión:** 1.0.0
**Desarrollado para:** GreenTech - Eco System
