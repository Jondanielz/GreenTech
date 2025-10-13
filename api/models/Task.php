<?php
/**
 * Modelo Task
 * Maneja las operaciones de tareas en la base de datos
 */

class Task {
    private $conn;
    private $table_name = 'tasks';
    private $table_assignments = 'task_assignments';
    private $table_users = 'users';
    private $table_projects = 'projects';
    private $table_dependencies = 'task_dependencies';
    private $table_expenses = 'expenses';
    private $table_budgets = 'budgets';
    private $table_assigned = 'task_assignments';
    private $table_roles = 'roles';

    public function __construct($db) {
        $this->conn = $db;
    }

    /**
     * Obtener tareas de un proyecto (para tablero Kanban)
     */
    public function getByProject($project_id) {
        $query = "SELECT 
            t.*,
            p.name as project_name,
            GROUP_CONCAT(DISTINCT u.name SEPARATOR ', ') as assignees,
            GROUP_CONCAT(DISTINCT u.id SEPARATOR ',') as assignee_ids
        FROM " . $this->table_name . " t
        LEFT JOIN " . $this->table_projects . " p ON t.project_id = p.id
        LEFT JOIN " . $this->table_assignments . " ta ON t.id = ta.task_id
        LEFT JOIN " . $this->table_users . " u ON ta.user_id = u.id
        WHERE t.project_id = :project_id
        GROUP BY t.id
        ORDER BY t.priority DESC, t.due_date ASC";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':project_id', $project_id, PDO::PARAM_INT);
        $stmt->execute();

        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }
    public function getMyTasks($user_id) {
        $query = "SELECT * FROM " . $this->table_name . " WHERE created_by = :user_id";
        $query = "SELECT 
            t.*,
            p.name as project_name,
            GROUP_CONCAT(DISTINCT u.name SEPARATOR ', ') as assignees,
            GROUP_CONCAT(DISTINCT u.id SEPARATOR ',') as assignee_ids
        FROM " . $this->table_name . " t
        LEFT JOIN " . $this->table_projects . " p ON t.project_id = p.id
        LEFT JOIN " . $this->table_assignments . " ta ON t.id = ta.task_id
        LEFT JOIN " . $this->table_users . " u ON ta.user_id = u.id
        WHERE t.created_by = :user_id
        GROUP BY t.id";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':user_id', $user_id, PDO::PARAM_INT);
        $stmt->execute();
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    /**
     * Obtener una tarea por ID
     */
    public function getById($id) {
        $query = "SELECT 
            t.*,
            p.name as project_name,
            GROUP_CONCAT(DISTINCT u.name SEPARATOR ', ') as assignees,
            GROUP_CONCAT(DISTINCT u.id SEPARATOR ',') as assignee_ids
        FROM " . $this->table_name . " t
        LEFT JOIN " . $this->table_projects . " p ON t.project_id = p.id
        LEFT JOIN " . $this->table_assignments . " ta ON t.id = ta.task_id
        LEFT JOIN " . $this->table_users . " u ON ta.user_id = u.id
        WHERE t.id = :id
        GROUP BY t.id
        LIMIT 1";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();

        return $stmt->fetch(PDO::FETCH_ASSOC);
    }

    /**
     * Crear nueva tarea
     */
    public function create($data) {
        error_log("Task::create - Datos recibidos: " . json_encode($data));
        
        $query = "INSERT INTO " . $this->table_name . " 
            (project_id, title, description, status, priority, due_date, created_by, progress, estimated_hours, actual_hours, created_at)
        VALUES 
            (:project_id, :title, :description, :status, :priority, :due_date, :created_by, :progress, :estimated_hours, :actual_hours, NOW())";

        $stmt = $this->conn->prepare($query);
        error_log("Task::create - Query preparada: " . $query);

        $stmt->bindParam(':project_id', $data['project_id']);
        $stmt->bindParam(':title', $data['title']);
        $stmt->bindParam(':description', $data['description']);
        $stmt->bindParam(':status', $data['status']);
        $stmt->bindParam(':priority', $data['priority']);
        $stmt->bindParam(':due_date', $data['due_date']);
        $stmt->bindParam(':created_by', $data['created_by']);
        $stmt->bindParam(':progress', $data['progress']);
        $stmt->bindParam(':estimated_hours', $data['estimated_hours']);
        $stmt->bindParam(':actual_hours', $data['actual_hours']);

        error_log("Task::create - Parámetros vinculados, ejecutando query...");
        
        if ($stmt->execute()) {
            $task_id = $this->conn->lastInsertId();
            error_log("Task::create - Tarea creada exitosamente con ID: " . $task_id);
            return $task_id;
        } else {
            $errorInfo = $stmt->errorInfo();
            error_log("Task::create - Error al ejecutar query: " . json_encode($errorInfo));
        }

        return false;
    }

    /**
     * Actualizar tarea
     */
    public function update($id, $data) {
        $query = "UPDATE " . $this->table_name . " 
        SET 
            title = :title,
            description = :description,
            status = :status,
            priority = :priority,
            due_date = :due_date,
            progress = :progress,
            estimated_hours = :estimated_hours,
            actual_hours = :actual_hours,
            updated_at = NOW()
        WHERE id = :id";

        $stmt = $this->conn->prepare($query);

        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->bindParam(':title', $data['title']);
        $stmt->bindParam(':description', $data['description']);
        $stmt->bindParam(':status', $data['status']);
        $stmt->bindParam(':priority', $data['priority']);
        $stmt->bindParam(':due_date', $data['due_date']);
        $stmt->bindParam(':progress', $data['progress']);
        $stmt->bindParam(':estimated_hours', $data['estimated_hours']);
        $stmt->bindParam(':actual_hours', $data['actual_hours']);

        return $stmt->execute();
    }

    /**
     * Actualizar solo el estado de la tarea (para Kanban drag & drop)
     */
    public function updateStatus($id, $status) {
        $query = "UPDATE " . $this->table_name . " 
        SET 
            status = :status,
            updated_at = NOW()
        WHERE id = :id";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->bindParam(':status', $status);

        return $stmt->execute();
    }

    /**
     * Eliminar tarea
     */
    public function delete($id) {
        // Primero eliminar asignaciones
        $query1 = "DELETE FROM " . $this->table_assignments . " WHERE task_id = :id";
        $stmt1 = $this->conn->prepare($query1);
        $stmt1->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt1->execute();

        // Luego eliminar la tarea
        $query2 = "DELETE FROM " . $this->table_name . " WHERE id = :id";
        $stmt2 = $this->conn->prepare($query2);
        $stmt2->bindParam(':id', $id, PDO::PARAM_INT);

        return $stmt2->execute();
    }

    /**
     * Asignar usuario a tarea
     */
    public function assignUser($task_id, $user_id) {
        // Verificar si ya está asignado
        $check = "SELECT COUNT(*) as count FROM " . $this->table_assignments . " 
                  WHERE task_id = :task_id AND user_id = :user_id";
        $stmt = $this->conn->prepare($check);
        $stmt->bindParam(':task_id', $task_id, PDO::PARAM_INT);
        $stmt->bindParam(':user_id', $user_id, PDO::PARAM_INT);
        $stmt->execute();
        $row = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($row['count'] > 0) {
            return true; // Ya está asignado
        }

        $query = "INSERT INTO " . $this->table_assignments . " 
            (task_id, user_id, assigned_at)
        VALUES 
            (:task_id, :user_id, NOW())";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':task_id', $task_id, PDO::PARAM_INT);
        $stmt->bindParam(':user_id', $user_id, PDO::PARAM_INT);

        return $stmt->execute();
    }

    /**
     * Desasignar usuario de tarea
     */
    public function unassignUser($task_id, $user_id) {
        $query = "DELETE FROM " . $this->table_assignments . " 
                  WHERE task_id = :task_id AND user_id = :user_id";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':task_id', $task_id, PDO::PARAM_INT);
        $stmt->bindParam(':user_id', $user_id, PDO::PARAM_INT);

        return $stmt->execute();
    }

    /**
     * Obtener usuarios asignados a una tarea
     */
    public function getAssignedUsers($task_id) {
        $query = "SELECT 
            u.id,
            u.name,
            u.email,
            u.avatar,
            ta.assigned_at
        FROM " . $this->table_assignments . " ta
        LEFT JOIN " . $this->table_users . " u ON ta.user_id = u.id
        WHERE ta.task_id = :task_id";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':task_id', $task_id, PDO::PARAM_INT);
        $stmt->execute();

        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    /**
     * Obtener todas las tareas
     * @return array|false
     */
    public function getAllTasks() {
        $query = "SELECT 
                    t.id, t.title, t.description, t.status, t.priority,
                    t.due_date, t.estimated_hours, t.actual_hours,
                    t.progress, t.created_at, t.updated_at,
                    t.project_id, p.name as project_name,
                    t.created_by, uc.name as created_by_name
                  FROM " . $this->table_name . " t
                  LEFT JOIN projects p ON t.project_id = p.id
                  LEFT JOIN " . $this->table_users . " uc ON t.created_by = uc.id
                  ORDER BY t.created_at DESC";

        $stmt = $this->conn->prepare($query);
        
        try {
            $stmt->execute();
            return $stmt->fetchAll(PDO::FETCH_ASSOC);
        } catch(PDOException $e) {
            error_log("Error al obtener todas las tareas: " . $e->getMessage());
            return false;
        }
    }

    /**
     * Obtener tareas de un usuario específico
     * @param int $user_id - ID del usuario
     * @return array|false
     */
    public function getTasksByUser($user_id) {
        error_log("Task::getTasksByUser - Buscando tareas para user_id: " . $user_id);
        
        $query = "SELECT 
                    t.id, t.title, t.description, t.status, t.priority,
                    t.due_date, t.estimated_hours, t.actual_hours,
                    t.progress, t.created_at, t.updated_at,
                    t.project_id, p.name as project_name,
                    t.created_by, uc.name as created_by_name
                  FROM " . $this->table_name . " t
                  LEFT JOIN projects p ON t.project_id = p.id
                  LEFT JOIN " . $this->table_users . " uc ON t.created_by = uc.id
                  WHERE t.created_by = :user_id
                  AND t.id > 0
                  
                  UNION
                  
                  SELECT 
                    t.id, t.title, t.description, t.status, t.priority,
                    t.due_date, t.estimated_hours, t.actual_hours,
                    t.progress, t.created_at, t.updated_at,
                    t.project_id, p.name as project_name,
                    t.created_by, uc.name as created_by_name
                  FROM " . $this->table_name . " t
                  LEFT JOIN projects p ON t.project_id = p.id
                  LEFT JOIN " . $this->table_users . " uc ON t.created_by = uc.id
                  INNER JOIN task_assignments ta ON t.id = ta.task_id
                  WHERE ta.user_id = :user_id2
                  AND t.id > 0
                  
                  ORDER BY created_at DESC";

        error_log("Task::getTasksByUser - Query: " . $query);
        
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':user_id', $user_id, PDO::PARAM_INT);
        $stmt->bindParam(':user_id2', $user_id, PDO::PARAM_INT);
        
        try {
            $stmt->execute();
            $result = $stmt->fetchAll(PDO::FETCH_ASSOC);
            error_log("Task::getTasksByUser - Resultado: " . count($result) . " tareas encontradas");
            return $result;
        } catch(PDOException $e) {
            error_log("Error al obtener tareas del usuario: " . $e->getMessage());
            return false;
        }
    }

    /**
     * Obtener asignaciones de una tarea
     */
    public function getTaskAssignments($task_id) {
        $query = "SELECT 
            ta.id,
            ta.task_id,
            ta.user_id,
            ta.assigned_at,
            ta.assigned_by,
            u.name as user_name,
            u.email as user_email,
            r.name as role_name
        FROM " . $this->table_assignments . " ta
        LEFT JOIN " . $this->table_users . " u ON ta.user_id = u.id
        LEFT JOIN " . $this->table_roles . " r ON u.role_id = r.id
        WHERE ta.task_id = :task_id
        ORDER BY ta.assigned_at DESC";

        try {
            $stmt = $this->conn->prepare($query);
            $stmt->bindParam(':task_id', $task_id, PDO::PARAM_INT);
            $stmt->execute();
            return $stmt->fetchAll(PDO::FETCH_ASSOC);
        } catch(PDOException $e) {
            error_log("Error al obtener asignaciones de tarea: " . $e->getMessage());
            return false;
        }
    }

    /**
     * Asignar usuario a tarea
     */
    public function assignUserToTask($task_id, $user_id, $assigned_by) {
        $query = "INSERT INTO " . $this->table_assignments . " 
                  (task_id, user_id, assigned_by) 
                  VALUES (:task_id, :user_id, :assigned_by)";

        try {
            $stmt = $this->conn->prepare($query);
            $stmt->bindParam(':task_id', $task_id, PDO::PARAM_INT);
            $stmt->bindParam(':user_id', $user_id, PDO::PARAM_INT);
            $stmt->bindParam(':assigned_by', $assigned_by, PDO::PARAM_INT);
            
            if ($stmt->execute()) {
                return true;
            } else {
                error_log("Error al asignar usuario a tarea: " . implode(", ", $stmt->errorInfo()));
                return false;
            }
        } catch(PDOException $e) {
            error_log("Error al asignar usuario a tarea: " . $e->getMessage());
            return false;
        }
    }

    /**
     * Desasignar usuario de tarea
     */
    public function unassignUserFromTask($task_id, $user_id) {
        $query = "DELETE FROM " . $this->table_assignments . " 
                  WHERE task_id = :task_id AND user_id = :user_id";

        try {
            $stmt = $this->conn->prepare($query);
            $stmt->bindParam(':task_id', $task_id, PDO::PARAM_INT);
            $stmt->bindParam(':user_id', $user_id, PDO::PARAM_INT);
            
            if ($stmt->execute()) {
                return $stmt->rowCount() > 0;
            } else {
                error_log("Error al desasignar usuario de tarea: " . implode(", ", $stmt->errorInfo()));
                return false;
            }
        } catch(PDOException $e) {
            error_log("Error al desasignar usuario de tarea: " . $e->getMessage());
            return false;
        }
    }
}
?>

