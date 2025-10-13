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
require_once 'controllers/UserController.php';

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
                    // Verificar si es para obtener usuarios disponibles
                    if (isset($uri_parts[2]) && $uri_parts[2] === 'available-users') {
                        // GET /api/projects/{id}/available-users
                        $response = $projectController->getAvailableUsers($action, $userData);
                        sendResponse($response, 200);
                    } else {
                        // GET /api/projects/{id}
                        $response = $projectController->getProjectById($action, $userData);
                        sendResponse($response, 200);
                    }
                } 
                else if ($method === 'POST') {
                    // Verificar si es para asignar usuario
                    if (isset($uri_parts[2]) && $uri_parts[2] === 'members') {
                        // POST /api/projects/{id}/members
                        $user_id = $input['user_id'] ?? null;
                        if (!$user_id) {
                            sendResponse(['error' => 'ID de usuario requerido'], 400);
                        }
                        $response = $projectController->assignUserToProject($action, $user_id, $userData);
                        sendResponse($response, 200);
                    } else {
                        sendResponse(['error' => 'Ruta no encontrada'], 404);
                    }
                }
                else if ($method === 'PUT' || $method === 'PATCH') {
                    $response = $projectController->updateProject($action, $input, $userData);
                    sendResponse($response, 200);
                } 
                else if ($method === 'DELETE') {
                    // Log para debugging
                    error_log("DELETE request - uri_parts: " . json_encode($uri_parts));
                    error_log("DELETE request - action: $action");
                    
                    // Verificar si es para desasignar usuario o cancelar proyecto
                    if (isset($uri_parts[2]) && $uri_parts[2] === 'members' && isset($uri_parts[3])) {
                        // DELETE /api/projects/{id}/members/{user_id}
                        $user_id = $uri_parts[3];
                        error_log("DELETE members - project_id: $action, user_id: $user_id");
                        $response = $projectController->unassignUserFromProject($action, $user_id, $userData);
                        sendResponse($response, 200);
                    } else {
                        // DELETE /api/projects/{id} - Cancelar proyecto
                        error_log("DELETE project - project_id: $action");
                        $response = $projectController->cancelProject($action, $userData);
                        sendResponse($response, 200);
                    }
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
    
    // ========== RUTAS DE USUARIOS ==========
    else if (isset($uri_parts[0]) && $uri_parts[0] === 'users') {
        $userController = new UserController();
        $userData = getUserFromToken();
        $action = $uri_parts[1] ?? '';
        
        switch ($action) {
            // GET /api/users - Obtener todos los usuarios (solo admin)
            case '':
                if ($method !== 'GET') {
                    sendResponse(['error' => 'Método no permitido'], 405);
                }
                
                // Verificar permisos de administrador
                if ($userData['role_id'] != 1) {
                    sendResponse([
                        'success' => false,
                        'message' => 'No tienes permisos para acceder a esta sección'
                    ], 403);
                }
                
                $response = $userController->getUsers();
                sendResponse($response, 200);
                break;
            
            // GET /api/users/participants - Obtener solo participantes
            case 'participants':
                if ($method !== 'GET') {
                    sendResponse(['error' => 'Método no permitido'], 405);
                }
                
                // Verificar permisos (admin o coordinador)
                if (!in_array($userData['role_id'], [1, 2])) {
                    sendResponse([
                        'success' => false,
                        'message' => 'No tienes permisos para acceder a esta sección'
                    ], 403);
                }
                
                $response = $userController->getParticipants();
                sendResponse($response, 200);
                break;
            
            // GET /api/users/stats - Obtener estadísticas de usuarios
            case 'stats':
                if ($method !== 'GET') {
                    sendResponse(['error' => 'Método no permitido'], 405);
                }
                
                // Verificar permisos de administrador
                if ($userData['role_id'] != 1) {
                    sendResponse([
                        'success' => false,
                        'message' => 'No tienes permisos para acceder a esta sección'
                    ], 403);
                }
                
                $response = $userController->getUserStats();
                sendResponse($response, 200);
                break;
            
            // POST /api/users - Crear nuevo usuario (solo admin)
            case 'create':
                if ($method !== 'POST') {
                    sendResponse(['error' => 'Método no permitido'], 405);
                }
                
                // Verificar permisos de administrador
                if ($userData['role_id'] != 1) {
                    sendResponse([
                        'success' => false,
                        'message' => 'No tienes permisos para crear usuarios'
                    ], 403);
                }
                
                $response = $userController->createUser($input);
                $statusCode = $response['success'] ? 201 : 400;
                sendResponse($response, $statusCode);
                break;
            
            // PUT /api/users/{id} - Actualizar usuario (solo admin)
            case (is_numeric($action) ? $action : ''):
                if ($method === 'PUT') {
                    // Verificar permisos de administrador
                    if ($userData['role_id'] != 1) {
                        sendResponse([
                            'success' => false,
                            'message' => 'No tienes permisos para actualizar usuarios'
                        ], 403);
                    }
                    
                    $response = $userController->updateUser($action, $input);
                    sendResponse($response, 200);
                } else if ($method === 'DELETE') {
                    // Verificar permisos de administrador
                    if ($userData['role_id'] != 1) {
                        sendResponse([
                            'success' => false,
                            'message' => 'No tienes permisos para eliminar usuarios'
                        ], 403);
                    }
                    
                    $response = $userController->deleteUser($action);
                    sendResponse($response, 200);
                } else if ($method === 'GET') {
                    // Verificar si es para obtener proyectos o tareas del usuario
                    if (isset($uri_parts[2])) {
                        $subAction = $uri_parts[2];
                        
                        if ($subAction === 'projects') {
                            // GET /api/users/{id}/projects
                            $response = $userController->getUserProjects($action);
                            sendResponse($response, 200);
                        } else if ($subAction === 'tasks') {
                            // GET /api/users/{id}/tasks
                            $response = $userController->getUserTasks($action);
                            sendResponse($response, 200);
                        } else {
                            sendResponse(['error' => 'Subruta no encontrada'], 404);
                        }
                    } else {
                        // GET /api/users/{id} - Obtener usuario por ID
                        // Verificar permisos (admin, coordinador o el propio usuario)
                        if ($userData['role_id'] != 1 && $userData['role_id'] != 2 && $userData['id'] != $action) {
                            sendResponse([
                                'success' => false,
                                'message' => 'No tienes permisos para acceder a esta información'
                            ], 403);
                        }
                        
                        $response = $userController->getUserById($action);
                        sendResponse($response, 200);
                    }
                } else {
                    sendResponse(['error' => 'Método no permitido'], 405);
                }
                break;
            
            default:
                sendResponse([
                    'error' => 'Ruta no encontrada',
                    'path' => '/users/' . $action
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
                ],
                'users' => [
                    'GET /users' => 'Obtener todos los usuarios (solo admin)',
                    'GET /users/participants' => 'Obtener solo participantes (admin/coord)',
                    'GET /users/stats' => 'Obtener estadísticas de usuarios (solo admin)',
                    'GET /users/{id}' => 'Obtener usuario por ID',
                    'GET /users/{id}/projects' => 'Obtener proyectos asignados a un usuario',
                    'GET /users/{id}/tasks' => 'Obtener tareas asignadas a un usuario',
                    'POST /users/create' => 'Crear nuevo usuario (solo admin)',
                    'PUT /users/{id}' => 'Actualizar usuario (solo admin)',
                    'DELETE /users/{id}' => 'Eliminar usuario (solo admin)'
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

