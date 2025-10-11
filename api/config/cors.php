<?php
/**
 * Configuración de CORS (Cross-Origin Resource Sharing)
 * Permite que Vite (localhost:3000) se comunique con la API PHP
 */

// Obtener el origen de la petición
$origin = isset($_SERVER['HTTP_ORIGIN']) ? $_SERVER['HTTP_ORIGIN'] : '';

// Lista de orígenes permitidos
$allowedOrigins = [
    'http://localhost:3000',
    'http://127.0.0.1:3000',
    'http://localhost:3001',  // Puerto alternativo de Vite
    'http://127.0.0.1:3001',
    'http://localhost:5173',  // Puerto por defecto de Vite
    'http://127.0.0.1:5173',
];

// Verificar si el origen está permitido y configurar CORS
if (in_array($origin, $allowedOrigins)) {
    // Permitir el origen específico (NO usar *)
    header("Access-Control-Allow-Origin: $origin");
    header("Access-Control-Allow-Credentials: true");
} else {
    // Si el origen no está en la lista, NO permitir credenciales
    header("Access-Control-Allow-Origin: *");
}

// Headers y métodos permitidos
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS, PATCH");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With, Accept, Origin");
header("Access-Control-Max-Age: 3600"); // Cache preflight por 1 hora

// Tipo de contenido JSON
header("Content-Type: application/json; charset=UTF-8");

// Manejar peticiones OPTIONS (preflight)
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}
?>

