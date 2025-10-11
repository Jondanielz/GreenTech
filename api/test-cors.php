<?php
/**
 * Archivo de prueba de CORS
 */

// Incluir configuración CORS
require_once 'config/cors.php';

// Obtener información del request
$origin = isset($_SERVER['HTTP_ORIGIN']) ? $_SERVER['HTTP_ORIGIN'] : 'N/A';
$method = $_SERVER['REQUEST_METHOD'];

// Responder con información de debug
echo json_encode([
    'success' => true,
    'message' => 'CORS Test',
    'debug' => [
        'origin_received' => $origin,
        'method' => $method,
        'headers_sent' => headers_list(),
    ]
], JSON_PRETTY_PRINT);
?>

