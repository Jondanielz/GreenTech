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
        $query = "INSERT INTO " . $this->table_name . " 
            (project_id, title, description, status, priority, due_date, estimated_hours, created_at)
        VALUES 
            (:project_id, :title, :description, :status, :priority, :due_date, :estimated_hours, NOW())";

        $stmt = $this->conn->prepare($query);

        $stmt->bindParam(':project_id', $data['project_id']);
        $stmt->bindParam(':title', $data['title']);
        $stmt->bindParam(':description', $data['description']);
        $stmt->bindParam(':status', $data['status']);
        $stmt->bindParam(':priority', $data['priority']);
        $stmt->bindParam(':due_date', $data['due_date']);
        $stmt->bindParam(':estimated_hours', $data['estimated_hours']);

        if ($stmt->execute()) {
            return $this->conn->lastInsertId();
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
            estimated_hours = :estimated_hours,
            updated_at = NOW()
        WHERE id = :id";

        $stmt = $this->conn->prepare($query);

        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->bindParam(':title', $data['title']);
        $stmt->bindParam(':description', $data['description']);
        $stmt->bindParam(':status', $data['status']);
        $stmt->bindParam(':priority', $data['priority']);
        $stmt->bindParam(':due_date', $data['due_date']);
        $stmt->bindParam(':estimated_hours', $data['estimated_hours']);

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
}
?>

