<?php
/**
 * Modelo User - Manejo de usuarios
 * Basado en la tabla 'users' de eco_system
 */

class User {
    private $conn;
    private $table_name = "users";

    // Propiedades de la tabla users
    public $id;
    public $name;
    public $email;
    public $user;
    public $password;
    public $role_id;
    public $position;
    public $avatar;
    public $active;
    public $last_login;
    public $created_at;
    public $updated_at;

    /**
     * Constructor
     * @param PDO $db - Conexión a la base de datos
     */
    public function __construct($db) {
        $this->conn = $db;
    }

    /**
     * Login de usuario - Obtener datos del usuario por username
     * @return PDOStatement
     */
    public function login() {
        $query = "SELECT 
                    u.id, u.name, u.email, u.user, u.password, 
                    u.role_id, u.position, u.avatar, u.active, u.last_login,
                    r.name as role_name, 
                    r.permissions,
                    r.description as role_description
                  FROM " . $this->table_name . " u
                  LEFT JOIN roles r ON u.role_id = r.id
                  WHERE u.user = :user AND u.active = 1
                  LIMIT 1";

        $stmt = $this->conn->prepare($query);
        
        // Sanitizar y vincular el parámetro
        $this->user = htmlspecialchars(strip_tags($this->user));
        $stmt->bindParam(":user", $this->user);
        
        $stmt->execute();

        return $stmt;
    }

    /**
     * Obtener usuario por email
     * @return PDOStatement
     */
    public function getUserByEmail() {
        $query = "SELECT id, email, user FROM " . $this->table_name . " 
                  WHERE email = :email LIMIT 1";
        
        $stmt = $this->conn->prepare($query);
        $this->email = htmlspecialchars(strip_tags($this->email));
        $stmt->bindParam(":email", $this->email);
        $stmt->execute();
        
        return $stmt;
    }

    /**
     * Obtener usuario por username
     * @return PDOStatement
     */
    public function getUserByUsername() {
        $query = "SELECT id, user FROM " . $this->table_name . " 
                  WHERE user = :user LIMIT 1";
        
        $stmt = $this->conn->prepare($query);
        $this->user = htmlspecialchars(strip_tags($this->user));
        $stmt->bindParam(":user", $this->user);
        $stmt->execute();
        
        return $stmt;
    }

    /**
     * Registrar actividad de usuario en user_activities
     * @param int $user_id - ID del usuario
     * @param string $activity_type - Tipo de actividad (login, logout, etc.)
     * @param array $details - Detalles adicionales en formato JSON
     * @return bool
     */
    public function logActivity($user_id, $activity_type, $details = null) {
        $query = "INSERT INTO user_activities (user_id, activity_type, details) 
                  VALUES (:user_id, :activity_type, :details)";
        
        $stmt = $this->conn->prepare($query);
        
        // Convertir detalles a JSON si es un array
        $details_json = is_array($details) ? json_encode($details) : $details;
        
        $stmt->bindParam(":user_id", $user_id);
        $stmt->bindParam(":activity_type", $activity_type);
        $stmt->bindParam(":details", $details_json);
        
        try {
            return $stmt->execute();
        } catch(PDOException $e) {
            error_log("Error al registrar actividad: " . $e->getMessage());
            return false;
        }
    }

    /**
     * Actualizar fecha de último login
     * @param int $user_id - ID del usuario
     * @return bool
     */
    public function updateLastLogin($user_id) {
        $query = "UPDATE " . $this->table_name . " 
                  SET last_login = NOW() 
                  WHERE id = :id";
        
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(":id", $user_id);
        
        try {
            return $stmt->execute();
        } catch(PDOException $e) {
            error_log("Error al actualizar último login: " . $e->getMessage());
            return false;
        }
    }

    /**
     * Verificar si el email ya existe
     * @return bool
     */
    public function emailExists() {
        $stmt = $this->getUserByEmail();
        return $stmt->rowCount() > 0;
    }

    /**
     * Verificar si el username ya existe
     * @return bool
     */
    public function usernameExists() {
        $stmt = $this->getUserByUsername();
        return $stmt->rowCount() > 0;
    }

    /**
     * Crear nuevo usuario
     * @return bool
     */
    public function create() {
        $query = "INSERT INTO " . $this->table_name . " 
                  (name, email, user, password, role_id, position_id, avatar, active)
                  VALUES 
                  (:name, :email, :user, :password, :role_id, :position_id, :avatar, 1)";

        $stmt = $this->conn->prepare($query);

        // Sanitizar datos
        $this->name = htmlspecialchars(strip_tags($this->name));
        $this->email = htmlspecialchars(strip_tags($this->email));
        $this->user = htmlspecialchars(strip_tags($this->user));
        
        // Hash de la contraseña con bcrypt
        $hashed_password = password_hash($this->password, PASSWORD_BCRYPT);

        // Vincular parámetros
        $stmt->bindParam(":name", $this->name);
        $stmt->bindParam(":email", $this->email);
        $stmt->bindParam(":user", $this->user);
        $stmt->bindParam(":password", $hashed_password);
        $stmt->bindParam(":role_id", $this->role_id);
        $stmt->bindParam(":position_id", $this->position_id);
        $stmt->bindParam(":avatar", $this->avatar);

        try {
            if ($stmt->execute()) {
                $this->id = $this->conn->lastInsertId();
                return true;
            }
            return false;
        } catch(PDOException $e) {
            error_log("Error al crear usuario: " . $e->getMessage());
            return false;
        }
    }

    /**
     * Obtener usuario por ID con información completa
     * @param int $id - ID del usuario
     * @return array|false
     */
    public function getUserById($id) {
        $query = "SELECT 
                    u.id, u.name, u.email, u.user, 
                    u.role_id, u.position, u.avatar, u.active, u.last_login,
                    r.name as role_name, 
                    r.permissions,
                    u.created_at, u.updated_at
                  FROM " . $this->table_name . " u
                  LEFT JOIN roles r ON u.role_id = r.id
                  WHERE u.id = :id LIMIT 1";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(":id", $id);
        
        try {
            $stmt->execute();
            return $stmt->fetch();
        } catch(PDOException $e) {
            error_log("Error al obtener usuario: " . $e->getMessage());
            return false;
        }
    }

    /**
     * Crear sesión de usuario en user_sessions
     * @param int $user_id - ID del usuario
     * @param string $token - Token de sesión
     * @param int $expires_in - Tiempo de expiración en segundos (default: 24 horas)
     * @return bool
     */
    public function createSession($user_id, $token, $expires_in = 86400) {
        $query = "INSERT INTO user_sessions (user_id, token, expires_at) 
                  VALUES (:user_id, :token, DATE_ADD(NOW(), INTERVAL :expires_in SECOND))";
        
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(":user_id", $user_id);
        $stmt->bindParam(":token", $token);
        $stmt->bindParam(":expires_in", $expires_in);
        
        try {
            return $stmt->execute();
        } catch(PDOException $e) {
            error_log("Error al crear sesión: " . $e->getMessage());
            return false;
        }
    }

    /**
     * Verificar si un token es válido
     * @param string $token - Token a verificar
     * @return array|false - Datos del usuario si el token es válido, false si no
     */
    public function verifyToken($token) {
        $query = "SELECT 
                    u.id, u.name, u.email, u.user, 
                    u.role_id, u.position, u.avatar, u.active, u.last_login,
                    r.name as role_name, 
                    r.permissions,
                    r.description as role_description
                  FROM " . $this->table_name . " u
                  LEFT JOIN roles r ON u.role_id = r.id
                  INNER JOIN user_sessions s ON u.id = s.user_id
                  WHERE s.token = :token 
                  AND s.expires_at > NOW() 
                  AND u.active = 1
                  LIMIT 1";
        
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(":token", $token);
        
        try {
            $stmt->execute();
            return $stmt->fetch();
        } catch(PDOException $e) {
            error_log("Error al verificar token: " . $e->getMessage());
            return false;
        }
    }

    /**
     * Eliminar sesión (logout)
     * @param string $token - Token de la sesión a eliminar
     * @return bool
     */
    public function deleteSession($token) {
        $query = "DELETE FROM user_sessions WHERE token = :token";
        
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(":token", $token);
        
        try {
            return $stmt->execute();
        } catch(PDOException $e) {
            error_log("Error al eliminar sesión: " . $e->getMessage());
            return false;
        }
    }

    /**
     * Limpiar sesiones expiradas
     * @return bool
     */
    public function cleanExpiredSessions() {
        $query = "DELETE FROM user_sessions WHERE expires_at < NOW()";
        
        $stmt = $this->conn->prepare($query);
        
        try {
            return $stmt->execute();
        } catch(PDOException $e) {
            error_log("Error al limpiar sesiones: " . $e->getMessage());
            return false;
        }
    }

    /**
     * Obtener todos los usuarios con información completa
     * @return array
     */
    public function getAllUsers() {
        $query = "SELECT 
                    u.id, u.name, u.email, u.user, 
                    u.role_id, u.position, u.avatar, u.active, u.last_login,
                    r.name as role_name, 
                    u.created_at, u.updated_at
                  FROM " . $this->table_name . " u
                  LEFT JOIN roles r ON u.role_id = r.id
                  ORDER BY u.created_at DESC";

        $stmt = $this->conn->prepare($query);
        
        try {
            $stmt->execute();
            return $stmt->fetchAll();
        } catch(PDOException $e) {
            error_log("Error al obtener usuarios: " . $e->getMessage());
            return [];
        }
    }

    /**
     * Obtener solo participantes (rol_id = 3)
     * @return array
     */
    public function getParticipants() {
        $query = "SELECT 
                    u.id, u.name, u.email, u.user, 
                    u.role_id, u.position, u.avatar, u.active, u.last_login,
                    r.name as role_name, 
                    u.created_at, u.updated_at
                  FROM " . $this->table_name . " u
                  LEFT JOIN roles r ON u.role_id = r.id
                  WHERE u.role_id = 3
                  ORDER BY u.created_at DESC";

        $stmt = $this->conn->prepare($query);
        
        try {
            $stmt->execute();
            return $stmt->fetchAll();
        } catch(PDOException $e) {
            error_log("Error al obtener participantes: " . $e->getMessage());
            return [];
        }
    }

    /**
     * Actualizar usuario
     * @param int $id - ID del usuario
     * @param array $data - Datos a actualizar
     * @return bool
     */
    public function updateUser($id, $data) {
        $fields = [];
        $params = [':id' => $id];

        // Campos que se pueden actualizar
        $allowedFields = ['name', 'email', 'user', 'role_id', 'position', 'avatar', 'active'];
        
        foreach ($allowedFields as $field) {
            if (isset($data[$field])) {
                $fields[] = "$field = :$field";
                $params[":$field"] = $data[$field];
            }
        }

        // Si se proporciona contraseña, hashearla
        if (isset($data['password']) && !empty($data['password'])) {
            $fields[] = "password = :password";
            $params[':password'] = password_hash($data['password'], PASSWORD_BCRYPT);
        }

        if (empty($fields)) {
            return false;
        }

        $fields[] = "updated_at = NOW()";
        $query = "UPDATE " . $this->table_name . " SET " . implode(', ', $fields) . " WHERE id = :id";

        $stmt = $this->conn->prepare($query);
        
        // Sanitizar datos
        foreach ($params as $key => $value) {
            if ($key !== ':id' && $key !== ':password') {
                $params[$key] = htmlspecialchars(strip_tags($value));
            }
        }
        
        $stmt->bindParam(':id', $params[':id']);
        foreach ($params as $key => $value) {
            if ($key !== ':id') {
                $stmt->bindValue($key, $value);
            }
        }

        try {
            return $stmt->execute();
        } catch(PDOException $e) {
            error_log("Error al actualizar usuario: " . $e->getMessage());
            return false;
        }
    }

    /**
     * Eliminar usuario (eliminación real - solo usuarios inactivos)
     * @param int $id - ID del usuario
     * @return bool
     */
    public function deleteUser($id) {
        $query = "DELETE FROM " . $this->table_name . " 
                  WHERE id = :id AND active = 0";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':id', $id);

        try {
            return $stmt->execute();
        } catch(PDOException $e) {
            error_log("Error al eliminar usuario: " . $e->getMessage());
            return false;
        }
    }

    /**
     * Crear usuario con datos extendidos
     * @param array $data - Datos del usuario
     * @return bool
     */
    public function createUser($data) {
        $query = "INSERT INTO " . $this->table_name . " 
                  (name, email, user, password, role_id, position, avatar, active)
                  VALUES 
                  (:name, :email, :user, :password, :role_id, :position, :avatar, 1)";

        $stmt = $this->conn->prepare($query);

        // Sanitizar datos
        $name = htmlspecialchars(strip_tags($data['name']));
        $email = htmlspecialchars(strip_tags($data['email']));
        $user = htmlspecialchars(strip_tags($data['user']));
        $password = password_hash($data['password'], PASSWORD_BCRYPT);
        $role_id = $data['role_id'];
        $position = $data['position'] ?? null;
        $avatar = $data['avatar'] ?? null;

        // Vincular parámetros
        $stmt->bindParam(":name", $name);
        $stmt->bindParam(":email", $email);
        $stmt->bindParam(":user", $user);
        $stmt->bindParam(":password", $password);
        $stmt->bindParam(":role_id", $role_id);
        $stmt->bindParam(":position", $position);
        $stmt->bindParam(":avatar", $avatar);

        try {
            if ($stmt->execute()) {
                $this->id = $this->conn->lastInsertId();
                return true;
            }
            return false;
        } catch(PDOException $e) {
            error_log("Error al crear usuario: " . $e->getMessage());
            return false;
        }
    }

    /**
     * Obtener estadísticas de usuarios
     * @return array
     */
    public function getUserStats() {
        $query = "SELECT 
                    COUNT(*) as total_users,
                    SUM(CASE WHEN active = 1 THEN 1 ELSE 0 END) as active_users,
                    SUM(CASE WHEN role_id = 1 THEN 1 ELSE 0 END) as admin_users,
                    SUM(CASE WHEN role_id = 2 THEN 1 ELSE 0 END) as coordinator_users,
                    SUM(CASE WHEN role_id = 3 THEN 1 ELSE 0 END) as participant_users,
                    SUM(CASE WHEN created_at >= DATE_SUB(NOW(), INTERVAL 1 MONTH) THEN 1 ELSE 0 END) as new_this_month
                  FROM " . $this->table_name;

        $stmt = $this->conn->prepare($query);
        
        try {
            $stmt->execute();
            return $stmt->fetch();
        } catch(PDOException $e) {
            error_log("Error al obtener estadísticas: " . $e->getMessage());
            return [];
        }
    }

    /**
     * Obtener proyectos asignados a un usuario
     * @param int $userId - ID del usuario
     * @return array
     */
    public function getUserProjects($userId) {
        $query = "SELECT 
                    p.id, p.name, p.description, p.status, p.priority,
                    p.start_date, p.end_date, p.progress, p.budget,
                    pu.assigned_at, pu.assigned_by
                  FROM projects p
                  INNER JOIN project_users pu ON p.id = pu.project_id
                  WHERE pu.user_id = :user_id
                  ORDER BY pu.assigned_at DESC";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(":user_id", $userId);
        
        try {
            $stmt->execute();
            return $stmt->fetchAll(PDO::FETCH_ASSOC);
        } catch(PDOException $e) {
            error_log("Error al obtener proyectos del usuario: " . $e->getMessage());
            return [];
        }
    }

    /**
     * Obtener tareas asignadas a un usuario
     * @param int $userId - ID del usuario
     * @return array
     */
    public function getUserTasks($userId) {
        $query = "SELECT 
                    t.id, t.title, t.description, t.status, t.priority,
                    t.due_date, t.progress, t.estimated_hours, t.actual_hours,
                    p.name as project_name,
                    ta.assigned_at, ta.assigned_by
                  FROM tasks t
                  INNER JOIN task_assignments ta ON t.id = ta.task_id
                  LEFT JOIN projects p ON t.project_id = p.id
                  WHERE ta.user_id = :user_id
                  ORDER BY ta.assigned_at DESC";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(":user_id", $userId);
        
        try {
            $stmt->execute();
            return $stmt->fetchAll(PDO::FETCH_ASSOC);
        } catch(PDOException $e) {
            error_log("Error al obtener tareas del usuario: " . $e->getMessage());
            return [];
        }
    }
}
?>

