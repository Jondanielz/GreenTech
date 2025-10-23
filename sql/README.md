# Base de Datos Eco System - Backup

Este directorio contiene el backup completo de la base de datos `eco_system` utilizada en el sistema GreenTech.

## Archivos

- `eco_system_backup.sql` - Exportación completa de la base de datos (183KB)
- `README.md` - Este archivo de documentación

## Estructura de la Base de Datos

La base de datos incluye las siguientes tablas principales:

### Tablas de Usuarios y Autenticación
- `users` - Información de usuarios del sistema
- `roles` - Roles del sistema (Admin, Coordinador, Participante)
- `user_details` - Detalles adicionales de usuarios
- `user_activities` - Registro de actividades de usuarios
- `user_sessions` - Sesiones de usuarios

### Tablas de Proyectos
- `projects` - Información principal de proyectos
- `project_details` - Detalles adicionales de proyectos
- `project_users` - Asignación de usuarios a proyectos
- `project_files` - Archivos adjuntos de proyectos
- `project_indicators` - Indicadores asignados a proyectos

### Tablas de Tareas
- `tasks` - Información principal de tareas
- `task_assignments` - Asignación de tareas a usuarios
- `task_dependencies` - Dependencias entre tareas
- `task_details` - Detalles adicionales de tareas

### Sistema de Indicadores
- `indicators` - Indicadores del sistema
- `units` - Unidades de medida
- `indicator_readings` - Lecturas de indicadores
- `project_indicators` - Asignación de indicadores a proyectos

### Sistema de Métricas
- `metrics` - Métricas del sistema
- `metric_types` - Tipos de métricas
- `metric_details` - Detalles de métricas
- `metric_history` - Historial de métricas

### Sistema Financiero
- `budgets` - Presupuestos
- `expenses` - Gastos
- `expense_categories` - Categorías de gastos
- `expense_details` - Detalles de gastos
- `financial_reports` - Reportes financieros

### Otros
- `milestones` - Hitos de proyectos
- `notifications` - Notificaciones del sistema
- `attachments` - Archivos adjuntos
- `resource_allocations` - Asignación de recursos

## Cómo Importar

Para importar esta base de datos en otro servidor:

1. Crear la base de datos:
```sql
CREATE DATABASE eco_system;
```

2. Importar el backup:
```bash
mysql -u root -p eco_system < eco_system_backup.sql
```

## Notas

- El backup incluye todas las tablas, datos, procedimientos almacenados y triggers
- Se excluyó la vista `user_details` que tenía referencias inválidas
- El archivo tiene un tamaño de aproximadamente 183KB
- Fecha de creación: $(Get-Date)

## Versión del Sistema

Este backup corresponde al sistema GreenTech con:
- Sistema de gestión de proyectos
- Sistema de gestión de tareas con Kanban
- Sistema de indicadores y métricas
- Sistema de usuarios con roles (Admin, Coordinador, Participante)
- Sistema de notificaciones
- Sistema financiero básico
