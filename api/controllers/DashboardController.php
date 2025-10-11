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
}
?>

