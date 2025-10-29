# Documentación del Sistema de Reportes - GreenTech

## Descripción General

El sistema de reportes de GreenTech permite generar reportes detallados sobre usuarios, proyectos y tareas del sistema. Los reportes están disponibles para administradores y coordinadores, y pueden ser exportados en formato CSV.

## Características Principales

### 1. Reporte de Usuarios del Sistema

- **Descripción**: Información completa de todos los usuarios registrados en el sistema
- **Datos incluidos**:
  - Información personal (ID, nombre, email, usuario)
  - Rol y posición
  - Estado de actividad
  - Estadísticas de proyectos y tareas asignadas
  - Tareas completadas
  - Fecha de último login
  - Fecha de creación

### 2. Reporte de Usuarios por Proyecto

- **Descripción**: Usuarios asignados a cada proyecto con estadísticas detalladas
- **Datos incluidos**:
  - Información del proyecto (nombre, descripción, estado)
  - Lista de miembros del proyecto
  - Estadísticas de tareas por usuario en el proyecto
  - Tareas completadas por usuario
  - Fecha de asignación al proyecto

### 3. Reporte de Tareas por Proyecto

- **Descripción**: Tareas de cada proyecto con información de progreso y asignaciones
- **Datos incluidos**:
  - Información del proyecto
  - Lista de tareas con detalles completos
  - Estado y prioridad de cada tarea
  - Progreso de completado
  - Usuarios asignados a cada tarea
  - Fechas de vencimiento
  - Estadísticas generales del proyecto

### 4. Reporte Completo

- **Descripción**: Combinación de todos los reportes en una sola vista
- **Incluye**: Resumen de usuarios, proyectos y tareas del sistema

## Funcionalidades Técnicas

### Filtros Disponibles

- **Por Proyecto**: Filtrar reportes para un proyecto específico
- **Por Fecha**: Filtrar por rango de fechas (próximamente)
- **Por Estado**: Filtrar por estado de usuarios, proyectos o tareas

### Exportación

- **Formato CSV**: Todos los reportes pueden ser exportados en formato CSV
- **Descarga Automática**: Los archivos se descargan automáticamente al navegador
- **Nombres de Archivo**: Nombres descriptivos con timestamp

### Permisos de Acceso

- **Administradores**: Acceso completo a todos los reportes
- **Coordinadores**: Acceso completo a todos los reportes
- **Participantes**: Sin acceso a los reportes

## Estructura de Archivos

### Backend (API)

```
api/
├── controllers/
│   └── ReportsController.php    # Controlador principal de reportes
└── index.php                    # Rutas de la API actualizadas
```

### Frontend

```
src/
├── views/reports/
│   └── reports.html             # Interfaz de usuario para reportes
└── services/
    └── reports.js               # Servicio JavaScript para API
```

## Rutas de la API

### Generar Reportes

- `POST /api/reports/users` - Reporte de usuarios
- `POST /api/reports/users-by-project` - Reporte de usuarios por proyecto
- `POST /api/reports/tasks-by-project` - Reporte de tareas por proyecto
- `POST /api/reports/complete` - Reporte completo

### Exportar Reportes

- `POST /api/reports/export` - Exportar reporte a CSV

### Parámetros de Exportación

```json
{
  "report_type": "users|users_by_project|tasks_by_project|complete",
  "project_id": 123 // Opcional, para filtrar por proyecto
}
```

## Uso del Sistema

### 1. Acceder a Reportes

1. Iniciar sesión como administrador o coordinador
2. Navegar a la sección "Reportes" en el menú lateral
3. Seleccionar el tipo de reporte deseado

### 2. Generar Reporte

1. Hacer clic en la tarjeta del tipo de reporte deseado
2. Aplicar filtros si es necesario
3. El reporte se generará automáticamente

### 3. Exportar Reporte

1. Una vez generado el reporte, hacer clic en "Exportar CSV"
2. El archivo se descargará automáticamente
3. El archivo incluirá todos los datos mostrados en la tabla

## Ejemplos de Uso

### Reporte de Usuarios

```javascript
// Generar reporte de usuarios
const response = await fetch("/api/reports/users", {
  method: "POST",
  headers: {
    Authorization: "Bearer " + token,
  },
});
```

### Reporte de Usuarios por Proyecto

```javascript
// Generar reporte para un proyecto específico
const response = await fetch("/api/reports/users-by-project", {
  method: "POST",
  headers: {
    Authorization: "Bearer " + token,
  },
  body: JSON.stringify({
    project_id: 123,
  }),
});
```

### Exportar Reporte

```javascript
// Exportar reporte a CSV
const response = await fetch("/api/reports/export", {
  method: "POST",
  headers: {
    Authorization: "Bearer " + token,
  },
  body: JSON.stringify({
    report_type: "users",
    project_id: 123,
  }),
});
```

## Consideraciones de Rendimiento

- Los reportes se generan en tiempo real
- Para sistemas con muchos datos, considerar implementar paginación
- Los archivos CSV se generan en memoria, considerar streaming para archivos grandes

## Seguridad

- Autenticación requerida para todos los endpoints
- Verificación de permisos por rol de usuario
- Sanitización de datos de entrada
- Validación de parámetros

## Mantenimiento

### Agregar Nuevos Tipos de Reporte

1. Agregar método en `ReportsController.php`
2. Agregar ruta en `api/index.php`
3. Agregar interfaz en `reports.html`
4. Actualizar servicio JavaScript

### Modificar Datos de Reporte

1. Editar consultas SQL en el controlador
2. Actualizar formato de respuesta
3. Modificar interfaz de usuario si es necesario

## Troubleshooting

### Error de Permisos

- Verificar que el usuario tenga rol de administrador o coordinador
- Verificar que el token de autenticación sea válido

### Error de Generación de Reporte

- Verificar conexión a la base de datos
- Revisar logs de PHP para errores específicos
- Verificar que los modelos estén correctamente configurados

### Error de Exportación

- Verificar que el tipo de reporte sea válido
- Verificar permisos de escritura en el servidor
- Revisar límites de memoria de PHP

## Próximas Mejoras

- [ ] Filtros por fecha más avanzados
- [ ] Reportes programados
- [ ] Exportación a PDF
- [ ] Gráficos y visualizaciones
- [ ] Reportes personalizados
- [ ] Notificaciones por email
- [ ] Caché de reportes para mejor rendimiento
