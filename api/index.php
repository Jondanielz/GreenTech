<?php
/**
 * Router Principal de la API
 * Punto de entrada para todas las peticiones a la API
 */

// Incluir configuración CORS
require_once 'config/cors.php';

// Incluir controladores
require_once 'controllers/AuthController.php';
require_once 'controllers/DashboardController.php';

// Manejo de errores
error_reporting(E_ALL);
ini_set('display_errors', 0); // No mostrar errores en producción
ini_set('log_errors', 1);
ini_set('error_log', __DIR__ . '/logs/php-errors.log');

/**
 * Función para enviar respuesta JSON
 */
function sendResponse($data, $statusCode = 200) {
    http_response_code($statusCode);
    echo json_encode($data, JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
    exit();
}

/**
 * Función para obtener el token del header Authorization
 */
function getBearerToken() {
    $headers = getallheaders();
    
    if (isset($headers['Authorization'])) {
        $matches = [];
        if (preg_match('/Bearer\s+(.*)$/i', $headers['Authorization'], $matches)) {
            return $matches[1];
        }
    }
    
    return null;
}

try {
    // Obtener método HTTP
    $method = $_SERVER['REQUEST_METHOD'];
    
    // Obtener URI y limpiarla
    $request_uri = $_SERVER['REQUEST_URI'];
    $request_uri = parse_url($request_uri, PHP_URL_PATH);
    
    // Remover el prefijo de la ruta base (ajustar según tu estructura)
    $base_path = '/purple-free/api';
    if (strpos($request_uri, $base_path) === 0) {
        $request_uri = substr($request_uri, strlen($base_path));
    }
    
    // Parsear la URI en partes
    $uri_parts = explode('/', trim($request_uri, '/'));
    
    // Obtener datos de la petición
    $input = [];
    $content_type = $_SERVER['CONTENT_TYPE'] ?? '';
    
    if (strpos($content_type, 'application/json') !== false) {
        $input = json_decode(file_get_contents('php://input'), true) ?? [];
    } else {
        $input = array_merge($_GET, $_POST);
    }
    
    // Log de la petición (debug)
    error_log("API Request: $method " . implode('/', $uri_parts));
    
    // ========== RUTAS DE AUTENTICACIÓN ==========
    if (isset($uri_parts[0]) && $uri_parts[0] === 'auth') {
        $authController = new AuthController();
        $action = $uri_parts[1] ?? '';
        
        switch ($action) {
            // POST /api/auth/login
            case 'login':
                if ($method !== 'POST') {
                    sendResponse(['error' => 'Método no permitido'], 405);
                }
                
                $response = $authController->login($input);
                $statusCode = $response['success'] ? 200 : 401;
                sendResponse($response, $statusCode);
                break;

            // POST /api/auth/register
            case 'register':
                if ($method !== 'POST') {
                    sendResponse(['error' => 'Método no permitido'], 405);
                }
                
                $response = $authController->register($input);
                $statusCode = $response['success'] ? 201 : 400;
                sendResponse($response, $statusCode);
                break;

            // POST /api/auth/logout
            case 'logout':
                if ($method !== 'POST') {
                    sendResponse(['error' => 'Método no permitido'], 405);
                }
                
                // Obtener token del header o del body
                $token = getBearerToken() ?? $input['token'] ?? '';
                $input['token'] = $token;
                
                $response = $authController->logout($input);
                sendResponse($response, 200);
                break;

            // POST /api/auth/verify
            case 'verify':
                if ($method !== 'POST' && $method !== 'GET') {
                    sendResponse(['error' => 'Método no permitido'], 405);
                }
                
                // Obtener token del header o del body/query
                $token = getBearerToken() ?? $input['token'] ?? '';
                
                $response = $authController->verifySession($token);
                $statusCode = $response['success'] ? 200 : 401;
                sendResponse($response, $statusCode);
                break;

            // GET /api/auth/me
            case 'me':
                if ($method !== 'GET') {
                    sendResponse(['error' => 'Método no permitido'], 405);
                }
                
                // Obtener token del header
                $token = getBearerToken();
                
                if (!$token) {
                    sendResponse([
                        'success' => false,
                        'message' => 'Token no proporcionado'
                    ], 401);
                }
                
                $response = $authController->getCurrentUser($token);
                $statusCode = $response['success'] ? 200 : 401;
                sendResponse($response, $statusCode);
                break;

            default:
                sendResponse([
                    'error' => 'Ruta no encontrada',
                    'path' => '/auth/' . $action
                ], 404);
                break;
        }
    }
    
    // ========== RUTAS DEL DASHBOARD ==========
    else if (isset($uri_parts[0]) && $uri_parts[0] === 'dashboard') {
        $dashboardController = new DashboardController();
        $action = $uri_parts[1] ?? 'all';
        
        switch ($action) {
            // GET /api/dashboard o /api/dashboard/all
            case 'all':
            case '':
                if ($method !== 'GET') {
                    sendResponse(['error' => 'Método no permitido'], 405);
                }
                
                $response = $dashboardController->getDashboardData();
                sendResponse($response, 200);
                break;
            
            // GET /api/dashboard/stats
            case 'stats':
                if ($method !== 'GET') {
                    sendResponse(['error' => 'Método no permitido'], 405);
                }
                
                $response = $dashboardController->getGeneralStats();
                sendResponse($response, 200);
                break;
            
            // GET /api/dashboard/financial
            case 'financial':
                if ($method !== 'GET') {
                    sendResponse(['error' => 'Método no permitido'], 405);
                }
                
                $response = $dashboardController->getFinancialStats();
                sendResponse($response, 200);
                break;
            
            // GET /api/dashboard/projects
            case 'projects':
                if ($method !== 'GET') {
                    sendResponse(['error' => 'Método no permitido'], 405);
                }
                
                $response = $dashboardController->getRecentProjects($input);
                sendResponse($response, 200);
                break;
            
            // GET /api/dashboard/tasks
            case 'tasks':
                if ($method !== 'GET') {
                    sendResponse(['error' => 'Método no permitido'], 405);
                }
                
                $response = $dashboardController->getRecentTasks($input);
                sendResponse($response, 200);
                break;
            
            // GET /api/dashboard/charts
            case 'charts':
                if ($method !== 'GET') {
                    sendResponse(['error' => 'Método no permitido'], 405);
                }
                
                $response = $dashboardController->getChartsData();
                sendResponse($response, 200);
                break;
            
            // GET /api/dashboard/activity
            case 'activity':
                if ($method !== 'GET') {
                    sendResponse(['error' => 'Método no permitido'], 405);
                }
                
                $response = $dashboardController->getRecentActivity($input);
                sendResponse($response, 200);
                break;
            
            // GET /api/dashboard/top-users
            case 'top-users':
                if ($method !== 'GET') {
                    sendResponse(['error' => 'Método no permitido'], 405);
                }
                
                $response = $dashboardController->getTopUsers($input);
                sendResponse($response, 200);
                break;
            
            default:
                sendResponse([
                    'error' => 'Ruta no encontrada',
                    'path' => '/dashboard/' . $action
                ], 404);
                break;
        }
    }
    
    // ========== RUTA RAÍZ ==========
    else if (empty($uri_parts[0])) {
        sendResponse([
            'success' => true,
            'message' => 'API de Purple Admin - Eco System',
            'version' => '1.0.0',
            'endpoints' => [
                'auth' => [
                    'POST /auth/login' => 'Iniciar sesión',
                    'POST /auth/register' => 'Registrar usuario',
                    'POST /auth/logout' => 'Cerrar sesión',
                    'POST /auth/verify' => 'Verificar token',
                    'GET /auth/me' => 'Obtener usuario actual'
                ],
                'dashboard' => [
                    'GET /dashboard' => 'Obtener todos los datos del dashboard',
                    'GET /dashboard/stats' => 'Obtener estadísticas generales',
                    'GET /dashboard/financial' => 'Obtener estadísticas financieras',
                    'GET /dashboard/projects' => 'Obtener proyectos recientes',
                    'GET /dashboard/tasks' => 'Obtener tareas recientes',
                    'GET /dashboard/charts' => 'Obtener datos para gráficos',
                    'GET /dashboard/activity' => 'Obtener actividad reciente',
                    'GET /dashboard/top-users' => 'Obtener usuarios más activos'
                ]
            ]
        ], 200);
    }
    
    // ========== RUTA NO ENCONTRADA ==========
    else {
        sendResponse([
            'error' => 'Endpoint no encontrado',
            'path' => '/' . implode('/', $uri_parts),
            'method' => $method
        ], 404);
    }

} catch (Exception $e) {
    // Log del error
    error_log("API Error: " . $e->getMessage());
    error_log("Stack trace: " . $e->getTraceAsString());
    
    // Respuesta de error
    sendResponse([
        'error' => 'Error del servidor',
        'message' => 'Ha ocurrido un error interno. Por favor, contacte al administrador.',
        'debug' => [
            'message' => $e->getMessage(),
            'file' => $e->getFile(),
            'line' => $e->getLine()
        ]
    ], 500);
}
?>

