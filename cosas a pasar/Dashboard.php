<?php
/**
 * Modelo Dashboard
 * Maneja las consultas relacionadas con el dashboard
 */

class Dashboard {
    private $conn;
    private $table_projects = 'projects';
    private $table_tasks = 'tasks';
    private $table_users = 'users';
    private $table_expenses = 'expenses';
    private $table_budgets = 'budgets';
    private $table_assigned = 'task_assignments';
    private $table_roles = 'roles';
    public function __construct($db) {
        $this->conn = $db;
    }

    /**
     * Obtener estadísticas generales del dashboard
     */
    public function getGeneralStats() {
        $query = "SELECT 
            (SELECT COUNT(*) FROM " . $this->table_projects . " WHERE status = 'En progreso' OR status = 'Planificación') as active_projects,
            (SELECT COUNT(*) FROM " . $this->table_projects . ") as total_projects,
            (SELECT COUNT(*) FROM " . $this->table_tasks . " WHERE status = 'Completada') as completed_tasks,
            (SELECT COUNT(*) FROM " . $this->table_tasks . ") as total_tasks,
            (SELECT COUNT(*) FROM " . $this->table_users . " WHERE active = '1') as active_users,
            (SELECT COUNT(*) FROM " . $this->table_users . ") as total_users";

        $stmt = $this->conn->prepare($query);
        $stmt->execute();
        
        return $stmt->fetch(PDO::FETCH_ASSOC);
    }

    /**
     * Obtener estadísticas financieras
     */
    public function getFinancialStats() {
        $query = "SELECT 
            COALESCE(SUM(b.allocated_amount), 0) as total_budget,
            COALESCE(SUM(e.amount), 0) as total_expenses,
            (COALESCE(SUM(b.allocated_amount), 0) - COALESCE(SUM(e.amount), 0)) as remaining_budget,
            COUNT(DISTINCT e.id) as total_transactions
        FROM " . $this->table_budgets . " b
        LEFT JOIN " . $this->table_expenses . " e ON b.project_id = e.project_id
        WHERE b.status = 'active' AND (e.status IS NULL OR e.status = 'approved')";

        $stmt = $this->conn->prepare($query);
        $stmt->execute();
        
        return $stmt->fetch(PDO::FETCH_ASSOC);
    }

    /**
     * Obtener proyectos recientes
     */
    public function getRecentProjects($limit = 5) {
        $query = "SELECT 
            p.id,
            p.name,
            p.description,
            p.status,
            p.priority,
            p.progress,
            p.start_date,
            p.end_date,
            p.created_at,
            u.name as user_name,
            (SELECT COUNT(*) FROM " . $this->table_tasks . " WHERE project_id = p.id) as total_tasks,
            (SELECT COUNT(*) FROM " . $this->table_tasks . " WHERE project_id = p.id AND status = 'Completada') as completed_tasks
        FROM " . $this->table_projects . " p
        LEFT JOIN " . $this->table_users . " u ON p.creator_id = u.id
        ORDER BY p.created_at DESC
        LIMIT :limit";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':limit', $limit, PDO::PARAM_INT);
        $stmt->execute();
        
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    /**
     * Obtener tareas recientes
     */
    public function getRecentTasks($limit = 10) {
        $query = "SELECT 
            t.id,
            t.title,
            t.description,
            t.status,
            t.priority,
            t.due_date,
            t.created_at,
            p.name as project_name,
            u.name as assignee_name,
            u.email as assignee_email
        
        FROM " . $this->table_tasks . " t
        LEFT JOIN " . $this->table_projects . " p ON t.project_id = p.id
        LEFT JOIN " . $this->table_assigned . " ta on t.id = ta.task_id
        LEFT JOIN " . $this->table_users . " u ON ta.user_id = u.id

        ORDER BY t.created_at DESC
        LIMIT :limit";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':limit', $limit, PDO::PARAM_INT);
        $stmt->execute();
        
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    /**
     * Obtener gastos recientes
     */
    public function getRecentExpenses($limit = 10) {
        $query = "SELECT 
            e.id,
            e.description,
            e.amount,
            e.category_id,
            e.status,
            e.date,
            e.created_at,
            p.name as project_name,
            u.name as approved_by_name
        FROM " . $this->table_expenses . " e
        LEFT JOIN " . $this->table_tasks . " t ON e.task_id = t.id
        LEFT JOIN " . $this->table_projects . " p ON t.project_id = p.id
        LEFT JOIN " . $this->table_users . " u ON e.approved_by = u.id
        ORDER BY e.created_at DESC LIMIT :limit
        ";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':limit', $limit, PDO::PARAM_INT);
        $stmt->execute();
        
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    /**
     * Obtener datos para gráfico de progreso de proyectos (últimos 6 meses)
     */
    public function getProjectProgressChart() {
        $query = "SELECT 
            DATE_FORMAT(created_at, '%Y-%m') as month,
            COUNT(*) as projects_created,
            SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) as projects_completed,
            AVG(progress) as avg_progress
        FROM " . $this->table_projects . "
        WHERE created_at >= DATE_SUB(NOW(), INTERVAL 6 MONTH)
        GROUP BY DATE_FORMAT(created_at, '%Y-%m')
        ORDER BY month ASC";

        $stmt = $this->conn->prepare($query);
        $stmt->execute();
        
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    /**
     * Obtener distribución de tareas por estado
     */
    public function getTasksDistribution() {
        $query = "SELECT 
            status,
            COUNT(*) as count,
            ROUND((COUNT(*) * 100.0 / (SELECT COUNT(*) FROM " . $this->table_tasks . ")), 2) as percentage
        FROM " . $this->table_tasks . "
        GROUP BY status
        ORDER BY count DESC";

        $stmt = $this->conn->prepare($query);
        $stmt->execute();
        
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    /**
     * Obtener distribución de gastos por categoría
     */
    public function getExpensesByCategory() {
        $query = "SELECT 
            category_id,
            SUM(amount) as total_amount,
            COUNT(*) as count
        FROM " . $this->table_expenses . "
        WHERE status = 'approved'
        GROUP BY category_id
        ORDER BY total_amount DESC";

        $stmt = $this->conn->prepare($query);
        $stmt->execute();
        
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    /**
     * Obtener proyectos por prioridad
     */
    public function getProjectsByPriority() {
        $query = "SELECT 
            priority,
            COUNT(*) as count,
            ROUND((COUNT(*) * 100.0 / (SELECT COUNT(*) FROM " . $this->table_projects . ")), 2) as percentage
        FROM " . $this->table_projects . "
        WHERE status != 'cancelled'
        GROUP BY priority
        ORDER BY 
            CASE priority
                WHEN 'Alta' THEN 1
                WHEN 'Media' THEN 2
                WHEN 'Baja' THEN 3
                ELSE 4
            END";

        $stmt = $this->conn->prepare($query);
        $stmt->execute();
        
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    /**
     * Obtener actividad reciente del sistema
     * NOTA: Tabla user_activity no existe, retornando array vacío
     */
    public function getRecentActivity($limit = 15) {
        // TODO: Crear tabla user_activity o usar otra tabla
        return [];
        
        /* QUERY ORIGINAL (comentado hasta crear la tabla):
        $query = "SELECT 
            a.id,
            a.action,
            a.ip_address,
            a.created_at,
            u.name as user_name,
            u.email as user_email
        FROM user_activity a
        LEFT JOIN " . $this->table_users . " u ON a.user_id = u.id
        ORDER BY a.created_at DESC
        LIMIT :limit";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':limit', $limit, PDO::PARAM_INT);
        $stmt->execute();
        
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
        */
    }

    /**
     * Obtener usuarios más activos
     * NOTA: Modificado para no usar tabla user_activity
     */
    public function getTopActiveUsers($limit = 5) {
        $query = "SELECT 
            u.id,
            u.name,
            u.email,
            u.role_id,
            r.name as role_name,
            COUNT(DISTINCT ta.task_id) as tasks_assigned,
            COUNT(DISTINCT p.id) as projects_managed,
            (COUNT(DISTINCT ta.task_id) + COUNT(DISTINCT p.id)) as total_activities
        FROM " . $this->table_users . " u
        LEFT JOIN " . $this->table_assigned . " ta ON u.id = ta.user_id
        LEFT JOIN " . $this->table_projects . " p ON u.id = p.creator_id
        LEFT JOIN " . $this->table_roles . " r ON u.role_id = r.id
        WHERE u.active = '1'
        GROUP BY u.id, u.name, u.email, u.role_id, r.name
        ORDER BY total_activities DESC
        LIMIT :limit";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':limit', $limit, PDO::PARAM_INT);
        $stmt->execute();
        
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    /**
     * Obtener estadísticas de proyectos por estado
     */
    public function getProjectStatsByStatus() {
        $query = "SELECT 
            status,
            COUNT(*) as count,
            ROUND((COUNT(*) * 100.0 / (SELECT COUNT(*) FROM " . $this->table_projects . ")), 2) as percentage
        FROM " . $this->table_projects . "
        GROUP BY status
        ORDER BY count DESC";

        $stmt = $this->conn->prepare($query);
        $stmt->execute();
        
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    /**
     * Obtener estadísticas de tareas por estado
     */
    public function getTaskStatsByStatus() {
        $query = "SELECT 
            status,
            COUNT(*) as count,
            ROUND((COUNT(*) * 100.0 / (SELECT COUNT(*) FROM " . $this->table_tasks . ")), 2) as percentage
        FROM " . $this->table_tasks . "
        GROUP BY status
        ORDER BY count DESC";

        $stmt = $this->conn->prepare($query);
        $stmt->execute();
        
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    /**
     * Obtener proyectos asignados a un usuario
     */
    public function getUserProjects($userId) {
        $query = "SELECT 
            p.id,
            p.name,
            p.description,
            p.status,
            p.priority,
            p.progress,
            p.start_date,
            p.end_date,
            p.created_at,
            u.name as creator_name,
            (SELECT COUNT(*) FROM " . $this->table_tasks . " WHERE project_id = p.id) as total_tasks,
            (SELECT COUNT(*) FROM " . $this->table_tasks . " WHERE project_id = p.id AND status = 'Completada') as completed_tasks
        FROM " . $this->table_projects . " p
        LEFT JOIN " . $this->table_users . " u ON p.creator_id = u.id
        LEFT JOIN project_users pu ON p.id = pu.project_id
        WHERE pu.user_id = :user_id
        ORDER BY p.created_at DESC";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':user_id', $userId, PDO::PARAM_INT);
        $stmt->execute();
        
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    /**
     * Obtener tareas asignadas a un usuario
     */
    public function getUserTasks($userId) {
        $query = "SELECT 
            t.id,
            t.title,
            t.description,
            t.status,
            t.priority,
            t.due_date,
            t.progress,
            t.created_at,
            p.name as project_name,
            p.id as project_id
        FROM " . $this->table_tasks . " t
        LEFT JOIN " . $this->table_projects . " p ON t.project_id = p.id
        LEFT JOIN " . $this->table_assigned . " ta ON t.id = ta.task_id
        WHERE ta.user_id = :user_id
        ORDER BY t.created_at DESC";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':user_id', $userId, PDO::PARAM_INT);
        $stmt->execute();
        
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    /**
     * Obtener tareas completadas de un usuario
     */
    public function getUserCompletedTasks($userId) {
        $query = "SELECT 
            t.id,
            t.title,
            t.description,
            t.status,
            t.priority,
            t.due_date,
            t.progress,
            t.created_at,
            t.updated_at,
            p.name as project_name,
            p.id as project_id
        FROM " . $this->table_tasks . " t
        LEFT JOIN " . $this->table_projects . " p ON t.project_id = p.id
        LEFT JOIN " . $this->table_assigned . " ta ON t.id = ta.task_id
        WHERE ta.user_id = :user_id AND t.status = 'Completada'
        ORDER BY t.updated_at DESC";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':user_id', $userId, PDO::PARAM_INT);
        $stmt->execute();
        
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }
}
?>

