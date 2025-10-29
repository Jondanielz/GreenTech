# Documentación del Sistema de Configuración - GreenTech

## Descripción General

El sistema de configuración de GreenTech permite personalizar los encabezados de los reportes con información de la empresa, incluyendo nombre, logo, dirección, teléfono, email y texto personalizado del pie de página.

## Características Principales

### 1. Información de la Empresa

- **Nombre de la empresa**: Personalizable para todos los reportes
- **Logo**: Subida de imagen (JPG, PNG, GIF, SVG) con vista previa
- **Dirección**: Información de ubicación de la empresa
- **Teléfono**: Número de contacto
- **Email**: Correo electrónico de contacto

### 2. Personalización de Reportes

- **Encabezados personalizados**: Logo y nombre de empresa en todos los reportes
- **Información de contacto**: Dirección, teléfono y email en encabezados
- **Pie de página personalizado**: Texto personalizado para reportes
- **Exportación CSV**: Encabezados personalizados en archivos exportados

### 3. Gestión de Archivos

- **Subida de logo**: Drag & drop o selección de archivo
- **Validación de archivos**: Tipos y tamaños permitidos
- **Vista previa**: Visualización inmediata del logo
- **Eliminación**: Opción para remover logo actual

## Funcionalidades Técnicas

### Validaciones

- **Nombre de empresa**: Campo requerido
- **Email**: Validación de formato si se proporciona
- **Teléfono**: Validación de formato numérico
- **Archivo de logo**: Tipos permitidos (JPG, PNG, GIF, SVG), máximo 2MB

### Permisos de Acceso

- **Solo administradores**: Acceso completo a la configuración
- **Coordinadores y participantes**: Sin acceso a la configuración

### Almacenamiento

- **Base de datos**: Tabla `report_config` para persistencia
- **Archivos**: Directorio `assets/images/logos/` para logos
- **Configuración por defecto**: Valores iniciales automáticos

## Estructura de Archivos

### Backend (API)

```
api/
├── models/
│   └── ReportConfig.php          # Modelo de configuración
├── controllers/
│   └── ConfigController.php      # Controlador de configuración
└── index.php                     # Rutas de la API actualizadas
```

### Frontend

```
src/
├── views/config/
│   └── config.html               # Interfaz de configuración
└── assets/images/logos/          # Directorio para logos
```

## Rutas de la API

### Configuración General

- `GET /api/config` - Obtener configuración actual
- `PUT /api/config` - Actualizar configuración
- `POST /api/config/reset` - Resetear a valores por defecto

### Gestión de Logo

- `POST /api/config/logo` - Subir logo de la empresa
- `DELETE /api/config/logo` - Eliminar logo actual

### Utilidades

- `GET /api/config/stats` - Estadísticas de configuración
- `GET /api/config/report-config` - Configuración para reportes

## Uso del Sistema

### 1. Acceder a Configuración

1. Iniciar sesión como administrador
2. Navegar a la sección "Configuración" en el menú lateral
3. Completar los campos de información de la empresa

### 2. Configurar Información Básica

1. Ingresar nombre de la empresa (requerido)
2. Agregar dirección, teléfono y email (opcional)
3. Personalizar texto del pie de página de reportes
4. Hacer clic en "Guardar Configuración"

### 3. Subir Logo de la Empresa

1. Arrastrar y soltar el archivo en el área designada
2. O hacer clic en "Seleccionar Logo"
3. El logo se mostrará en vista previa
4. El logo aparecerá automáticamente en todos los reportes

### 4. Gestionar Configuración

- **Vista previa**: Ver cómo se verá el encabezado en reportes
- **Estadísticas**: Ver qué elementos están configurados
- **Resetear**: Volver a valores por defecto si es necesario

## Ejemplos de Uso

### Actualizar Configuración

```javascript
// Actualizar información de la empresa
const response = await fetch("/api/config", {
  method: "PUT",
  headers: {
    "Content-Type": "application/json",
    Authorization: "Bearer " + token,
  },
  body: JSON.stringify({
    company_name: "Mi Empresa S.A.",
    company_address: "Av. Principal 123, Ciudad",
    company_phone: "+1 (555) 123-4567",
    company_email: "contacto@miempresa.com",
    report_footer_text: "Reporte generado por Mi Empresa S.A.",
  }),
});
```

### Subir Logo

```javascript
// Subir logo de la empresa
const formData = new FormData();
formData.append("logo", fileInput.files[0]);

const response = await fetch("/api/config/logo", {
  method: "POST",
  headers: {
    Authorization: "Bearer " + token,
  },
  body: formData,
});
```

### Obtener Configuración para Reportes

```javascript
// Obtener configuración para usar en reportes
const response = await fetch("/api/config/report-config", {
  method: "GET",
  headers: {
    Authorization: "Bearer " + token,
  },
});
```

## Estructura de la Base de Datos

### Tabla: report_config

```sql
CREATE TABLE report_config (
    id INT AUTO_INCREMENT PRIMARY KEY,
    company_name VARCHAR(255) NOT NULL DEFAULT 'GreenTech',
    company_logo VARCHAR(500) NULL,
    company_address TEXT NULL,
    company_phone VARCHAR(50) NULL,
    company_email VARCHAR(100) NULL,
    report_footer_text TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

## Integración con Reportes

### Encabezados Personalizados

Los reportes ahora incluyen automáticamente:

- Logo de la empresa (si está configurado)
- Nombre de la empresa
- Información de contacto (dirección, teléfono, email)
- Fecha y hora de generación

### Exportación CSV

Los archivos CSV exportados incluyen:

- Encabezado personalizado con información de la empresa
- Título del reporte
- Fecha de generación
- Datos del reporte

## Consideraciones de Seguridad

### Validación de Archivos

- Tipos de archivo permitidos: JPG, PNG, GIF, SVG
- Tamaño máximo: 2MB
- Sanitización de nombres de archivo
- Validación de contenido de archivo

### Permisos

- Solo administradores pueden modificar configuración
- Verificación de autenticación en todas las rutas
- Validación de datos de entrada

### Almacenamiento Seguro

- Directorio de logos con permisos restringidos
- Nombres de archivo únicos para evitar conflictos
- Limpieza de archivos antiguos al actualizar

## Mantenimiento

### Backup de Configuración

- La configuración se almacena en la base de datos
- Los logos se almacenan en el sistema de archivos
- Realizar backup regular de ambos

### Limpieza de Archivos

- Los logos antiguos se pueden acumular
- Implementar limpieza periódica de archivos no utilizados
- Considerar rotación de logs de subida

### Monitoreo

- Verificar espacio en disco para logos
- Monitorear errores de subida de archivos
- Revisar logs de configuración

## Troubleshooting

### Error de Subida de Logo

- Verificar permisos del directorio `assets/images/logos/`
- Comprobar límites de tamaño de archivo en PHP
- Validar formato de archivo

### Error de Configuración

- Verificar conexión a la base de datos
- Comprobar que la tabla `report_config` existe
- Revisar logs de PHP para errores específicos

### Problemas de Visualización

- Verificar que las rutas de imágenes sean correctas
- Comprobar permisos de lectura de archivos
- Validar formato de datos en la base de datos

## Próximas Mejoras

- [ ] Múltiples logos por tipo de reporte
- [ ] Plantillas de encabezado predefinidas
- [ ] Configuración de colores corporativos
- [ ] Integración con sistemas de gestión de identidad
- [ ] Configuración por usuario/rol
- [ ] Historial de cambios de configuración
- [ ] Configuración de márgenes y formato de reportes
- [ ] Integración con sistemas de firma digital
