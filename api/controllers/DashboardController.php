<?php
/**
 * Controlador del Dashboard
 * Maneja las peticiones relacionadas con el dashboard
 */

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../models/Dashboard.php';

class DashboardController {
    private $db;
    private $dashboard;

    /**
     * Constructor - Inicializa conexión y modelo
     */
    public function __construct() {
        $database = new Database();
        $this->db = $database->getConnection();
        $this->dashboard = new Dashboard($this->db);
    }

    /**
     * Obtener todos los datos del dashboard
     * @return array - Respuesta JSON con todas las estadísticas
     */
    public function getDashboardData() {
        try {
            // Obtener todas las estadísticas
            $generalStats = $this->dashboard->getGeneralStats();
            $financialStats = $this->dashboard->getFinancialStats();
            $recentProjects = $this->dashboard->getRecentProjects(5);
            $recentTasks = $this->dashboard->getRecentTasks(10);
            $recentExpenses = $this->dashboard->getRecentExpenses(5);
            $projectProgress = $this->dashboard->getProjectProgressChart();
            $tasksDistribution = $this->dashboard->getTasksDistribution();
            $expensesByCategory = $this->dashboard->getExpensesByCategory();
            $projectsByPriority = $this->dashboard->getProjectsByPriority();
            $recentActivity = $this->dashboard->getRecentActivity(10);
            $topUsers = $this->dashboard->getTopActiveUsers(5);

            return [
                'success' => true,
                'data' => [
                    'general_stats' => $generalStats,
                    'financial_stats' => $financialStats,
                    'recent_projects' => $recentProjects,
                    'recent_tasks' => $recentTasks,
                    'recent_expenses' => $recentExpenses,
                    'charts' => [
                        'project_progress' => $projectProgress,
                        'tasks_distribution' => $tasksDistribution,
                        'expenses_by_category' => $expensesByCategory,
                        'projects_by_priority' => $projectsByPriority
                    ],
                    'recent_activity' => $recentActivity,
                    'top_users' => $topUsers
                ],
                'timestamp' => date('Y-m-d H:i:s')
            ];
        } catch (Exception $e) {
            error_log("Error en getDashboardData: " . $e->getMessage());
            return [
                'success' => false,
                'message' => 'Error al obtener datos del dashboard: ' . $e->getMessage()
            ];
        }
    }

    /**
     * Obtener solo estadísticas generales
     * @return array - Respuesta JSON
     */
    public function getGeneralStats() {
        try {
            $stats = $this->dashboard->getGeneralStats();
            
            return [
                'success' => true,
                'data' => $stats
            ];
        } catch (Exception $e) {
            error_log("Error en getGeneralStats: " . $e->getMessage());
            return [
                'success' => false,
                'message' => 'Error al obtener estadísticas generales'
            ];
        }
    }

    /**
     * Obtener solo estadísticas financieras
     * @return array - Respuesta JSON
     */
    public function getFinancialStats() {
        try {
            $stats = $this->dashboard->getFinancialStats();
            
            return [
                'success' => true,
                'data' => $stats
            ];
        } catch (Exception $e) {
            error_log("Error en getFinancialStats: " . $e->getMessage());
            return [
                'success' => false,
                'message' => 'Error al obtener estadísticas financieras'
            ];
        }
    }

    /**
     * Obtener proyectos recientes
     * @param array $data - Parámetros (limit)
     * @return array - Respuesta JSON
     */
    public function getRecentProjects($data = []) {
        try {
            $limit = isset($data['limit']) ? (int)$data['limit'] : 5;
            $projects = $this->dashboard->getRecentProjects($limit);
            
            return [
                'success' => true,
                'data' => $projects,
                'count' => count($projects)
            ];
        } catch (Exception $e) {
            error_log("Error en getRecentProjects: " . $e->getMessage());
            return [
                'success' => false,
                'message' => 'Error al obtener proyectos recientes'
            ];
        }
    }

    /**
     * Obtener tareas recientes
     * @param array $data - Parámetros (limit)
     * @return array - Respuesta JSON
     */
    public function getRecentTasks($data = []) {
        try {
            $limit = isset($data['limit']) ? (int)$data['limit'] : 10;
            $tasks = $this->dashboard->getRecentTasks($limit);
            
            return [
                'success' => true,
                'data' => $tasks,
                'count' => count($tasks)
            ];
        } catch (Exception $e) {
            error_log("Error en getRecentTasks: " . $e->getMessage());
            return [
                'success' => false,
                'message' => 'Error al obtener tareas recientes'
            ];
        }
    }

    /**
     * Obtener datos para gráficos
     * @return array - Respuesta JSON
     */
    public function getChartsData() {
        try {
            $projectProgress = $this->dashboard->getProjectProgressChart();
            $tasksDistribution = $this->dashboard->getTasksDistribution();
            $expensesByCategory = $this->dashboard->getExpensesByCategory();
            $projectsByPriority = $this->dashboard->getProjectsByPriority();

            return [
                'success' => true,
                'data' => [
                    'project_progress' => $projectProgress,
                    'tasks_distribution' => $tasksDistribution,
                    'expenses_by_category' => $expensesByCategory,
                    'projects_by_priority' => $projectsByPriority
                ]
            ];
        } catch (Exception $e) {
            error_log("Error en getChartsData: " . $e->getMessage());
            return [
                'success' => false,
                'message' => 'Error al obtener datos de gráficos'
            ];
        }
    }

    /**
     * Obtener actividad reciente
     * @param array $data - Parámetros (limit)
     * @return array - Respuesta JSON
     */
    public function getRecentActivity($data = []) {
        try {
            $limit = isset($data['limit']) ? (int)$data['limit'] : 15;
            $activity = $this->dashboard->getRecentActivity($limit);
            
            return [
                'success' => true,
                'data' => $activity,
                'count' => count($activity)
            ];
        } catch (Exception $e) {
            error_log("Error en getRecentActivity: " . $e->getMessage());
            return [
                'success' => false,
                'message' => 'Error al obtener actividad reciente'
            ];
        }
    }

    /**
     * Obtener usuarios más activos
     * @param array $data - Parámetros (limit)
     * @return array - Respuesta JSON
     */
    public function getTopUsers($data = []) {
        try {
            $limit = isset($data['limit']) ? (int)$data['limit'] : 5;
            $users = $this->dashboard->getTopActiveUsers($limit);
            
            return [
                'success' => true,
                'data' => $users,
                'count' => count($users)
            ];
        } catch (Exception $e) {
            error_log("Error en getTopUsers: " . $e->getMessage());
            return [
                'success' => false,
                'message' => 'Error al obtener usuarios activos'
            ];
        }
    }

    /**
     * Dashboard para administradores
     * @param array $userData - Datos del usuario autenticado
     * @return array - Respuesta JSON
     */
    public function getAdminDashboard($userData) {
        try {
            // Estadísticas generales
            $generalStats = $this->dashboard->getGeneralStats();
            
            // Estadísticas de proyectos por estado
            $projectStatsRaw = $this->dashboard->getProjectStatsByStatus();
            $projectStats = $this->formatProjectStats($projectStatsRaw);
            
            // Estadísticas de tareas por estado
            $taskStatsRaw = $this->dashboard->getTaskStatsByStatus();
            $taskStats = $this->formatTaskStats($taskStatsRaw);
            
            // Top 5 proyectos recientes
            $recentProjects = $this->dashboard->getRecentProjects(5);
            
            // Top 5 tareas recientes
            $recentTasks = $this->dashboard->getRecentTasks(5);
            
            return [
                'success' => true,
                'data' => [
                    'general_stats' => $generalStats,
                    'project_stats' => $projectStats,
                    'task_stats' => $taskStats,
                    'recent_projects' => $recentProjects,
                    'recent_tasks' => $recentTasks
                ]
            ];
        } catch (Exception $e) {
            error_log("Error en getAdminDashboard: " . $e->getMessage());
            return [
                'success' => false,
                'message' => 'Error al obtener datos del dashboard de administrador'
            ];
        }
    }

    /**
     * Dashboard para coordinadores
     * @param array $userData - Datos del usuario autenticado
     * @return array - Respuesta JSON
     */
    public function getCoordinatorDashboard($userData) {
        try {
            // Estadísticas generales
            $generalStats = $this->dashboard->getGeneralStats();
            
            // Estadísticas de proyectos por estado
            $projectStatsRaw = $this->dashboard->getProjectStatsByStatus();
            $projectStats = $this->formatProjectStats($projectStatsRaw);
            
            // Estadísticas de tareas por estado
            $taskStatsRaw = $this->dashboard->getTaskStatsByStatus();
            $taskStats = $this->formatTaskStats($taskStatsRaw);
            
            // Proyectos asignados al coordinador
            $assignedProjects = $this->dashboard->getUserProjects($userData['id']);
            
            // Tareas asignadas al coordinador
            $assignedTasks = $this->dashboard->getUserTasks($userData['id']);
            
            // Top 5 proyectos recientes
            $recentProjects = $this->dashboard->getRecentProjects(5);
            
            // Top 5 tareas recientes
            $recentTasks = $this->dashboard->getRecentTasks(5);
            
            return [
                'success' => true,
                'data' => [
                    'general_stats' => $generalStats,
                    'project_stats' => $projectStats,
                    'task_stats' => $taskStats,
                    'assigned_projects' => $assignedProjects,
                    'assigned_tasks' => $assignedTasks,
                    'recent_projects' => $recentProjects,
                    'recent_tasks' => $recentTasks
                ]
            ];
        } catch (Exception $e) {
            error_log("Error en getCoordinatorDashboard: " . $e->getMessage());
            return [
                'success' => false,
                'message' => 'Error al obtener datos del dashboard de coordinador'
            ];
        }
    }

    /**
     * Dashboard para participantes
     * @param array $userData - Datos del usuario autenticado
     * @return array - Respuesta JSON
     */
    public function getParticipantDashboard($userData) {
        try {
            // Proyectos del usuario
            $myProjects = $this->dashboard->getUserProjects($userData['id']);
            
            // Tareas del usuario
            $myTasks = $this->dashboard->getUserTasks($userData['id']);
            
            // Tareas completadas del usuario
            $completedTasks = $this->dashboard->getUserCompletedTasks($userData['id']);
            
            // Estadísticas personales
            $personalStats = [
                'my_projects' => count($myProjects),
                'my_tasks' => count($myTasks),
                'completed_tasks' => count($completedTasks)
            ];
            
            return [
                'success' => true,
                'data' => [
                    'personal_stats' => $personalStats,
                    'my_projects' => $myProjects,
                    'my_tasks' => $myTasks,
                    'completed_tasks' => $completedTasks
                ]
            ];
        } catch (Exception $e) {
            error_log("Error en getParticipantDashboard: " . $e->getMessage());
            return [
                'success' => false,
                'message' => 'Error al obtener datos del dashboard de participante'
            ];
        }
    }

    /**
     * Obtener proyectos del usuario
     * @param array $userData - Datos del usuario autenticado
     * @return array - Respuesta JSON
     */
    public function getMyProjects($userData) {
        try {
            $projects = $this->dashboard->getUserProjects($userData['id']);
            
            return [
                'success' => true,
                'data' => $projects,
                'count' => count($projects)
            ];
        } catch (Exception $e) {
            error_log("Error en getMyProjects: " . $e->getMessage());
            return [
                'success' => false,
                'message' => 'Error al obtener proyectos del usuario'
            ];
        }
    }

    /**
     * Obtener tareas del usuario
     * @param array $userData - Datos del usuario autenticado
     * @return array - Respuesta JSON
     */
    public function getMyTasks($userData) {
        try {
            $tasks = $this->dashboard->getUserTasks($userData['id']);
            
            return [
                'success' => true,
                'data' => $tasks,
                'count' => count($tasks)
            ];
        } catch (Exception $e) {
            error_log("Error en getMyTasks: " . $e->getMessage());
            return [
                'success' => false,
                'message' => 'Error al obtener tareas del usuario'
            ];
        }
    }

    /**
     * Obtener tareas completadas del usuario
     * @param array $userData - Datos del usuario autenticado
     * @return array - Respuesta JSON
     */
    public function getMyCompletedTasks($userData) {
        try {
            $tasks = $this->dashboard->getUserCompletedTasks($userData['id']);
            
            return [
                'success' => true,
                'data' => $tasks,
                'count' => count($tasks)
            ];
        } catch (Exception $e) {
            error_log("Error en getMyCompletedTasks: " . $e->getMessage());
            return [
                'success' => false,
                'message' => 'Error al obtener tareas completadas del usuario'
            ];
        }
    }

    /**
     * Formatear estadísticas de proyectos para el frontend
     * @param array $rawStats - Estadísticas raw de la base de datos
     * @return array - Estadísticas formateadas
     */
    private function formatProjectStats($rawStats) {
        $formatted = [
            'planificacion' => 0,
            'en_progreso' => 0,
            'completado' => 0,
            'cancelado' => 0,
            'en_espera' => 0
        ];
        
        foreach ($rawStats as $stat) {
            $status = strtolower(str_replace(' ', '_', $stat['status']));
            switch ($stat['status']) {
                case 'Planificación':
                    $formatted['planificacion'] = (int)$stat['count'];
                    break;
                case 'En progreso':
                    $formatted['en_progreso'] = (int)$stat['count'];
                    break;
                case 'Completado':
                    $formatted['completado'] = (int)$stat['count'];
                    break;
                case 'Cancelado':
                    $formatted['cancelado'] = (int)$stat['count'];
                    break;
                case 'En espera':
                    $formatted['en_espera'] = (int)$stat['count'];
                    break;
            }
        }
        
        return $formatted;
    }

    /**
     * Formatear estadísticas de tareas para el frontend
     * @param array $rawStats - Estadísticas raw de la base de datos
     * @return array - Estadísticas formateadas
     */
    private function formatTaskStats($rawStats) {
        $formatted = [
            'pendiente' => 0,
            'en_progreso' => 0,
            'completada' => 0
        ];
        
        foreach ($rawStats as $stat) {
            switch ($stat['status']) {
                case 'Pendiente':
                    $formatted['pendiente'] = (int)$stat['count'];
                    break;
                case 'En progreso':
                    $formatted['en_progreso'] = (int)$stat['count'];
                    break;
                case 'Completada':
                    $formatted['completada'] = (int)$stat['count'];
                    break;
            }
        }
        
        return $formatted;
    }
}
?>

