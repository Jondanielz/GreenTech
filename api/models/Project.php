<?php
/**
 * Modelo Project
 * Maneja las operaciones de proyectos en la base de datos
 */

class Project {
    private $conn;
    private $table_name = 'projects';
    private $table_users = 'users';
    private $table_members = 'project_users';
    private $table_tasks = 'tasks';
    private $table_expenses = 'expenses';
    private $table_budgets = 'budgets';
    private $table_assigned = 'task_assignments';
    private $table_roles = 'roles';

    public function __construct($db) {
        $this->conn = $db;
    }

    /**
     * Obtener todos los proyectos (para administradores)
     */
    public function getAll($limit = null, $offset = 0) {
        $query = "SELECT 
            p.*,
            u.name as creator_name,
            u.email as creator_email,
            (SELECT COUNT(*) FROM tasks WHERE project_id = p.id) as total_tasks,
            (SELECT COUNT(*) FROM tasks WHERE project_id = p.id AND status = 'Completada') as completed_tasks,
            (SELECT COUNT(DISTINCT user_id) FROM " . $this->table_members . " WHERE project_id = p.id) as members_count
        FROM " . $this->table_name . " p
        LEFT JOIN " . $this->table_users . " u ON p.creator_id = u.id
        ORDER BY p.created_at DESC";

        if ($limit) {
            $query .= " LIMIT :limit OFFSET :offset";
        }

        $stmt = $this->conn->prepare($query);

        if ($limit) {
            $stmt->bindParam(':limit', $limit, PDO::PARAM_INT);
            $stmt->bindParam(':offset', $offset, PDO::PARAM_INT);
        }

        $stmt->execute();
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    /**
     * Obtener proyectos de un usuario específico
     */
    public function getUserProjects($user_id) {
        $query = "SELECT DISTINCT
            p.*,
            u.name as creator_name,
            u.email as creator_email,
            (SELECT COUNT(*) FROM tasks WHERE project_id = p.id) as total_tasks,
            (SELECT COUNT(*) FROM tasks WHERE project_id = p.id AND status = 'Completada') as completed_tasks,
            (SELECT COUNT(DISTINCT user_id) FROM " . $this->table_members . " WHERE project_id = p.id) as members_count
        FROM " . $this->table_name . " p
        LEFT JOIN " . $this->table_users . " u ON p.creator_id = u.id
        LEFT JOIN " . $this->table_members . " pm ON p.id = pm.project_id
        WHERE pm.user_id = ? OR p.creator_id = ?
        ORDER BY p.created_at DESC";

        $stmt = $this->conn->prepare($query);
        $stmt->execute([$user_id, $user_id]);

        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    /**
     * Obtener un proyecto por ID
     */
    public function getById($id) {
        $query = "SELECT 
            p.*,
            u.name as creator_name,
            u.email as creator_email,
            u.avatar as creator_avatar,
            (SELECT COUNT(*) FROM tasks WHERE project_id = p.id) as total_tasks,
            (SELECT COUNT(*) FROM tasks WHERE project_id = p.id AND status = 'Completada') as completed_tasks,
            (SELECT COUNT(*) FROM tasks WHERE project_id = p.id AND status = 'En progreso') as in_progress_tasks,
            (SELECT COUNT(*) FROM tasks WHERE project_id = p.id AND status = 'Pendiente') as pending_tasks,
            (SELECT COUNT(DISTINCT user_id) FROM " . $this->table_members . " WHERE project_id = p.id) as members_count
        FROM " . $this->table_name . " p
        LEFT JOIN " . $this->table_users . " u ON p.creator_id = u.id
        WHERE p.id = :id
        LIMIT 1";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();

        return $stmt->fetch(PDO::FETCH_ASSOC);
    }

    /**
     * Obtener miembros de un proyecto
     */
    public function getProjectMembers($project_id) {
        $query = "SELECT 
            pm.*,
            u.name,
            u.email,
            u.avatar,
            r.name as role_name,
            r.id as role_id
        FROM " . $this->table_members . " pm
        LEFT JOIN " . $this->table_users . " u ON pm.user_id = u.id
        LEFT JOIN roles r ON u.role_id = r.id
        WHERE pm.project_id = :project_id
        ORDER BY pm.assigned_at DESC";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':project_id', $project_id, PDO::PARAM_INT);
        $stmt->execute();

        $members = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        // Log para debugging
        error_log("getProjectMembers for project_id=$project_id: Found " . count($members) . " members");
        foreach ($members as $member) {
            error_log("Member: user_id=" . $member['user_id'] . ", name=" . $member['name']);
        }

        return $members;
    }

    /**
     * Crear nuevo proyecto
     */
    public function create($data) {
        $query = "INSERT INTO " . $this->table_name . " 
            (name, description, start_date, end_date, status, budget, creator_id, priority, progress, created_at)
        VALUES 
            (:name, :description, :start_date, :end_date, :status, :budget, :creator_id, :priority, :progress, NOW())";

        $stmt = $this->conn->prepare($query);

        $stmt->bindParam(':name', $data['name']);
        $stmt->bindParam(':description', $data['description']);
        $stmt->bindParam(':start_date', $data['start_date']);
        $stmt->bindParam(':end_date', $data['end_date']);
        $stmt->bindParam(':status', $data['status']);
        $stmt->bindParam(':budget', $data['budget']);
        $stmt->bindParam(':creator_id', $data['creator_id']);
        $stmt->bindParam(':priority', $data['priority']);
        $stmt->bindParam(':progress', $data['progress']);

        if ($stmt->execute()) {
            return $this->conn->lastInsertId();
        }

        return false;
    }

    /**
     * Actualizar proyecto
     */
    public function update($id, $data) {
        $query = "UPDATE " . $this->table_name . " 
        SET 
            name = :name,
            description = :description,
            start_date = :start_date,
            end_date = :end_date,
            status = :status,
            budget = :budget,
            priority = :priority,
            progress = :progress,
            updated_at = NOW()
        WHERE id = :id";

        $stmt = $this->conn->prepare($query);

        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->bindParam(':name', $data['name']);
        $stmt->bindParam(':description', $data['description']);
        $stmt->bindParam(':start_date', $data['start_date']);
        $stmt->bindParam(':end_date', $data['end_date']);
        $stmt->bindParam(':status', $data['status']);
        $stmt->bindParam(':budget', $data['budget']);
        $stmt->bindParam(':priority', $data['priority']);
        $stmt->bindParam(':progress', $data['progress']);

        return $stmt->execute();
    }

    /**
     * Cambiar estado del proyecto (cancelar, completar, etc)
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
     * Eliminar proyecto (soft delete - cambiar estado a Cancelado)
     */
    public function delete($id) {
        return $this->updateStatus($id, 'Cancelado');
    }

    /**
     * Verificar si un usuario es miembro de un proyecto
     */
    public function isUserMember($project_id, $user_id) {
        $query = "SELECT COUNT(*) as count 
        FROM " . $this->table_members . " 
        WHERE project_id = :project_id AND user_id = :user_id";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':project_id', $project_id, PDO::PARAM_INT);
        $stmt->bindParam(':user_id', $user_id, PDO::PARAM_INT);
        $stmt->execute();

        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        return $row['count'] > 0;
    }

    /**
     * Verificar si un usuario es el creador del proyecto
     */
    public function isUserCreator($project_id, $user_id) {
        $query = "SELECT COUNT(*) as count 
        FROM " . $this->table_name . " 
        WHERE id = :project_id AND creator_id = :user_id";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':project_id', $project_id, PDO::PARAM_INT);
        $stmt->bindParam(':user_id', $user_id, PDO::PARAM_INT);
        $stmt->execute();

        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        return $row['count'] > 0;
    }

    /**
     * Obtener usuarios disponibles para asignar a un proyecto
     */
    public function getAvailableUsers($projectId) {
        $query = "SELECT u.id, u.name, u.email, u.avatar, r.name as role_name, r.id as role_id
                  FROM " . $this->table_users . " u
                  LEFT JOIN " . $this->table_roles . " r ON u.role_id = r.id
                  WHERE u.id NOT IN (
                      SELECT user_id FROM " . $this->table_members . " WHERE project_id = :project_id
                  )
                  ORDER BY r.id, u.name";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':project_id', $projectId, PDO::PARAM_INT);
        $stmt->execute();
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    /**
     * Asignar usuario a proyecto
     */
    public function assignUserToProject($projectId, $userId) {
        $query = "INSERT INTO " . $this->table_members . " (project_id, user_id, assigned_at) 
                  VALUES (:project_id, :user_id, NOW())";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':project_id', $projectId, PDO::PARAM_INT);
        $stmt->bindParam(':user_id', $userId, PDO::PARAM_INT);

        return $stmt->execute();
    }

    /**
     * Desasignar usuario del proyecto
     */
    public function unassignUserFromProject($projectId, $userId) {
        // Primero verificar si existe la relación
        $checkQuery = "SELECT COUNT(*) as count FROM " . $this->table_members . " 
                       WHERE project_id = :project_id AND user_id = :user_id";
        $checkStmt = $this->conn->prepare($checkQuery);
        $checkStmt->bindParam(':project_id', $projectId, PDO::PARAM_INT);
        $checkStmt->bindParam(':user_id', $userId, PDO::PARAM_INT);
        $checkStmt->execute();
        $checkResult = $checkStmt->fetch(PDO::FETCH_ASSOC);
        
        error_log("Before DELETE: Found " . $checkResult['count'] . " records for project_id=$projectId, user_id=$userId");
        
        $query = "DELETE FROM " . $this->table_members . " 
                  WHERE project_id = :project_id AND user_id = :user_id";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':project_id', $projectId, PDO::PARAM_INT);
        $stmt->bindParam(':user_id', $userId, PDO::PARAM_INT);

        $result = $stmt->execute();
        $affectedRows = $stmt->rowCount();
        
        // Log para debugging
        error_log("DELETE project_users: project_id=$projectId, user_id=$userId, result=" . ($result ? 'success' : 'failed') . ", affected_rows=$affectedRows");
        
        // Verificar después del DELETE
        $checkStmt->execute();
        $checkResultAfter = $checkStmt->fetch(PDO::FETCH_ASSOC);
        error_log("After DELETE: Found " . $checkResultAfter['count'] . " records for project_id=$projectId, user_id=$userId");
        
        return $result && $affectedRows > 0;
    }

    /**
     * Obtener usuario por ID
     */
    public function getUserById($userId) {
        $query = "SELECT u.id, u.name, u.email, u.role_id, r.name as role_name
                  FROM " . $this->table_users . " u
                  LEFT JOIN " . $this->table_roles . " r ON u.role_id = r.id
                  WHERE u.id = :user_id";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':user_id', $userId, PDO::PARAM_INT);
        $stmt->execute();
        return $stmt->fetch(PDO::FETCH_ASSOC);
    }
}
?>

