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
require_once 'controllers/ProjectController.php';
require_once 'controllers/TaskController.php';

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

/**
 * Función auxiliar para verificar autenticación y obtener usuario del token
 */
function getUserFromToken() {
    $token = getBearerToken();
    
    if (!$token) {
        sendResponse([
            'success' => false,
            'message' => 'Token no proporcionado'
        ], 401);
    }
    
    $authController = new AuthController();
    $result = $authController->verifySession($token);
    
    if (!$result['success']) {
        sendResponse([
            'success' => false,
            'message' => 'Token inválido o expirado'
        ], 401);
    }
    
    return $result['user'];
}

try {
    // Obtener método HTTP
    $method = $_SERVER['REQUEST_METHOD'];
    
    // Obtener URI y limpiarla
    $request_uri = $_SERVER['REQUEST_URI'];
    $request_uri = parse_url($request_uri, PHP_URL_PATH);
    
    // Remover el prefijo de la ruta base (ajustar según tu estructura)
    $base_path = '/eco-app/GreenTech/api';
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
    
    // ========== RUTAS DE PROYECTOS ==========
    else if (isset($uri_parts[0]) && $uri_parts[0] === 'projects') {
        require_once 'config/database.php';
        $database = new Database();
        $db = $database->getConnection();
        $projectController = new ProjectController($db);
        
        $userData = getUserFromToken();
        $action = $uri_parts[1] ?? '';
        
        switch ($action) {
            // GET/POST /api/projects - Obtener todos los proyectos o crear uno nuevo
            case '':
                if ($method === 'GET') {
                    // Si es admin, obtener todos, si no, obtener los del usuario
                    if ($userData['role_id'] == 1) {
                        $response = $projectController->getAllProjects($userData);
                    } else {
                        $response = $projectController->getUserProjects($userData);
                    }
                    sendResponse($response, 200);
                } else if ($method === 'POST') {
                    // Crear nuevo proyecto
                    $response = $projectController->createProject($input, $userData);
                    $statusCode = $response['success'] ? 201 : 400;
                    sendResponse($response, $statusCode);
                } else {
                    sendResponse(['error' => 'Método no permitido. Use GET o POST'], 405);
                }
                break;
            
            // GET /api/projects/my - Obtener proyectos del usuario
            case 'my':
                if ($method !== 'GET') {
                    sendResponse(['error' => 'Método no permitido'], 405);
                }
                
                $response = $projectController->getUserProjects($userData);
                sendResponse($response, 200);
                break;
            
            // GET /api/projects/{id} - Obtener proyecto por ID
            case (is_numeric($action) ? $action : ''):
                if ($method === 'GET') {
                    $response = $projectController->getProjectById($action, $userData);
                    sendResponse($response, 200);
                } 
                else if ($method === 'PUT' || $method === 'PATCH') {
                    $response = $projectController->updateProject($action, $input, $userData);
                    sendResponse($response, 200);
                } 
                else if ($method === 'DELETE') {
                    $response = $projectController->cancelProject($action, $userData);
                    sendResponse($response, 200);
                } 
                else {
                    sendResponse(['error' => 'Método no permitido'], 405);
                }
                break;
            
            // Ruta no encontrada
            default:
                sendResponse([
                    'error' => 'Ruta no encontrada',
                    'path' => '/projects/' . $action
                ], 404);
                break;
        }
    }
    
    // ========== RUTAS DE TAREAS ==========
    else if (isset($uri_parts[0]) && $uri_parts[0] === 'tasks') {
        require_once 'config/database.php';
        $database = new Database();
        $db = $database->getConnection();
        $taskController = new TaskController($db);
        
        $userData = getUserFromToken();
        $action = $uri_parts[1] ?? '';
        
        switch ($action) {
            // GET /api/tasks/project/{project_id} - Obtener tareas de un proyecto
            case 'project':
                if ($method !== 'GET') {
                    sendResponse(['error' => 'Método no permitido'], 405);
                }
                
                $project_id = $uri_parts[2] ?? null;
                
                if (!$project_id) {
                    sendResponse(['error' => 'ID de proyecto requerido'], 400);
                }
                
                $response = $taskController->getProjectTasks($project_id, $userData);
                sendResponse($response, 200);
                break;
            
            // POST /api/tasks - Crear tarea
            case '':
                if ($method === 'POST') {
                    $response = $taskController->createTask($input, $userData);
                    $statusCode = $response['success'] ? 201 : 400;
                    sendResponse($response, $statusCode);
                } else {
                    sendResponse(['error' => 'Método no permitido'], 405);
                }
                break;
            
            // GET/PUT/DELETE /api/tasks/{id}
            case (is_numeric($action) ? $action : ''):
                if ($method === 'GET') {
                    $response = $taskController->getTaskById($action, $userData);
                    sendResponse($response, 200);
                } 
                else if ($method === 'PUT' || $method === 'PATCH') {
                    // Si solo se envía status, actualizar solo el status (para Kanban)
                    if (isset($input['status']) && count($input) === 1) {
                        $response = $taskController->updateTaskStatus($action, $input['status'], $userData);
                    } else {
                        $response = $taskController->updateTask($action, $input, $userData);
                    }
                    sendResponse($response, 200);
                } 
                else if ($method === 'DELETE') {
                    $response = $taskController->deleteTask($action, $userData);
                    sendResponse($response, 200);
                } 
                else {
                    sendResponse(['error' => 'Método no permitido'], 405);
                }
                break;
            
            default:
                sendResponse([
                    'error' => 'Ruta no encontrada',
                    'path' => '/tasks/' . $action
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
            'message' => 'API de GreenTech - Eco System',
            'version' => '1.0.0',
            'endpoints' => [
                'auth' => [
                    'POST /auth/login' => 'Iniciar sesión',
                    'POST /auth/register' => 'Registrar usuario',
                    'POST /auth/logout' => 'Cerrar sesión',
                    'POST /auth/verify' => 'Verificar token',
                    'GET /auth/me' => 'Obtener usuario actual'
                ],
                'projects' => [
                    'GET /projects' => 'Obtener proyectos (todos o del usuario según rol)',
                    'GET /projects/my' => 'Obtener proyectos del usuario',
                    'GET /projects/{id}' => 'Obtener proyecto por ID',
                    'POST /projects' => 'Crear proyecto',
                    'PUT /projects/{id}' => 'Actualizar proyecto',
                    'DELETE /projects/{id}' => 'Cancelar proyecto'
                ],
                'tasks' => [
                    'GET /tasks/project/{project_id}' => 'Obtener tareas de un proyecto',
                    'GET /tasks/{id}' => 'Obtener tarea por ID',
                    'POST /tasks' => 'Crear tarea',
                    'PUT /tasks/{id}' => 'Actualizar tarea',
                    'PATCH /tasks/{id}' => 'Actualizar estado de tarea (Kanban)',
                    'DELETE /tasks/{id}' => 'Eliminar tarea'
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

