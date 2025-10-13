<?php
/**
 * Controlador de Usuarios
 * Maneja CRUD de usuarios y gestión de participantes
 */

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../models/User.php';

class UserController {
    private $db;
    private $user;

    /**
     * Constructor - Inicializa conexión y modelo
     */
    public function __construct() {
        $database = new Database();
        $this->db = $database->getConnection();
        $this->user = new User($this->db);
    }

    /**
     * Obtener todos los usuarios (solo administradores)
     * @return array - Respuesta JSON
     */
    public function getUsers() {
        try {
            $users = $this->user->getAllUsers();
            
            return [
                'success' => true,
                'data' => $users,
                'message' => 'Usuarios obtenidos exitosamente'
            ];
        } catch (Exception $e) {
            return [
                'success' => false,
                'message' => 'Error al obtener usuarios: ' . $e->getMessage()
            ];
        }
    }

    /**
     * Obtener solo participantes (coordinadores y administradores)
     * @return array - Respuesta JSON
     */
    public function getParticipants() {
        try {
            $participants = $this->user->getParticipants();
            
            return [
                'success' => true,
                'data' => $participants,
                'message' => 'Participantes obtenidos exitosamente'
            ];
        } catch (Exception $e) {
            return [
                'success' => false,
                'message' => 'Error al obtener participantes: ' . $e->getMessage()
            ];
        }
    }

    /**
     * Obtener usuario por ID
     * @param int $id - ID del usuario
     * @return array - Respuesta JSON
     */
    public function getUserById($id) {
        try {
            $user = $this->user->getUserById($id);
            
            if ($user) {
                return [
                    'success' => true,
                    'data' => $user,
                    'message' => 'Usuario obtenido exitosamente'
                ];
            } else {
                return [
                    'success' => false,
                    'message' => 'Usuario no encontrado'
                ];
            }
        } catch (Exception $e) {
            return [
                'success' => false,
                'message' => 'Error al obtener usuario: ' . $e->getMessage()
            ];
        }
    }

    /**
     * Crear nuevo usuario (solo administradores)
     * @param array $data - Datos del usuario
     * @return array - Respuesta JSON
     */
    public function createUser($data) {
        // Validar campos requeridos
        $requiredFields = ['name', 'email', 'user', 'password', 'role_id'];
        foreach ($requiredFields as $field) {
            if (!isset($data[$field]) || empty(trim($data[$field]))) {
                return [
                    'success' => false,
                    'message' => "El campo '{$field}' es requerido"
                ];
            }
        }

        // Validar formato de email
        if (!filter_var($data['email'], FILTER_VALIDATE_EMAIL)) {
            return [
                'success' => false,
                'message' => 'El formato del email no es válido'
            ];
        }

        // Validar longitud de contraseña
        if (strlen($data['password']) < 4) {
            return [
                'success' => false,
                'message' => 'La contraseña debe tener al menos 4 caracteres'
            ];
        }

        // Validar rol
        if (!in_array($data['role_id'], [1, 2, 3])) {
            return [
                'success' => false,
                'message' => 'El rol seleccionado no es válido'
            ];
        }

        // Verificar si el email ya existe
        $this->user->email = $data['email'];
        if ($this->user->emailExists()) {
            return [
                'success' => false,
                'message' => 'El email ya está registrado'
            ];
        }

        // Verificar si el username ya existe
        $this->user->user = $data['user'];
        if ($this->user->usernameExists()) {
            return [
                'success' => false,
                'message' => 'El nombre de usuario ya está en uso'
            ];
        }

        // Preparar datos del usuario
        $userData = [
            'name' => $data['name'],
            'email' => $data['email'],
            'user' => $data['user'],
            'password' => $data['password'],
            'role_id' => $data['role_id'],
            'position' => $data['position'] ?? null,
            'avatar' => $data['avatar'] ?? null
        ];

        // Crear usuario
        if ($this->user->createUser($userData)) {
            // Obtener datos del usuario creado
            $newUser = $this->user->getUserById($this->user->id);
            
            if ($newUser) {
                return [
                    'success' => true,
                    'data' => $newUser,
                    'message' => 'Usuario creado exitosamente'
                ];
            }
        }

        return [
            'success' => false,
            'message' => 'Error al crear usuario. Intente nuevamente.'
        ];
    }

    /**
     * Actualizar usuario (solo administradores)
     * @param int $id - ID del usuario
     * @param array $data - Datos a actualizar
     * @return array - Respuesta JSON
     */
    public function updateUser($id, $data) {
        try {
            // Verificar que el usuario existe
            $existingUser = $this->user->getUserById($id);
            if (!$existingUser) {
                return [
                    'success' => false,
                    'message' => 'Usuario no encontrado'
                ];
            }

            // Validar email si se está cambiando
            if (isset($data['email']) && $data['email'] !== $existingUser['email']) {
                if (!filter_var($data['email'], FILTER_VALIDATE_EMAIL)) {
                    return [
                        'success' => false,
                        'message' => 'El formato del email no es válido'
                    ];
                }

                // Verificar si el nuevo email ya existe
                $this->user->email = $data['email'];
                if ($this->user->emailExists()) {
                    return [
                        'success' => false,
                        'message' => 'El email ya está registrado por otro usuario'
                    ];
                }
            }

            // Validar username si se está cambiando
            if (isset($data['user']) && $data['user'] !== $existingUser['user']) {
                $this->user->user = $data['user'];
                if ($this->user->usernameExists()) {
                    return [
                        'success' => false,
                        'message' => 'El nombre de usuario ya está en uso'
                    ];
                }
            }

            // Validar contraseña si se proporciona
            if (isset($data['password']) && !empty($data['password'])) {
                if (strlen($data['password']) < 4) {
                    return [
                        'success' => false,
                        'message' => 'La contraseña debe tener al menos 4 caracteres'
                    ];
                }
            }

            // Validar rol si se proporciona
            if (isset($data['role_id']) && !in_array($data['role_id'], [1, 2, 3])) {
                return [
                    'success' => false,
                    'message' => 'El rol seleccionado no es válido'
                ];
            }

            // Log para debug
            error_log("Actualizando usuario ID: $id con datos: " . json_encode($data));
            
            // Actualizar usuario
            $updateResult = $this->user->updateUser($id, $data);
            error_log("Resultado de updateUser: " . ($updateResult ? 'true' : 'false'));
            
            if ($updateResult) {
                // Obtener datos actualizados
                $updatedUser = $this->user->getUserById($id);
                error_log("Usuario actualizado: " . json_encode($updatedUser));
                
                return [
                    'success' => true,
                    'data' => $updatedUser,
                    'message' => 'Usuario actualizado exitosamente'
                ];
            } else {
                error_log("Error al actualizar usuario en la base de datos");
                return [
                    'success' => false,
                    'message' => 'Error al actualizar usuario en la base de datos'
                ];
            }
        } catch (Exception $e) {
            return [
                'success' => false,
                'message' => 'Error al actualizar usuario: ' . $e->getMessage()
            ];
        }
    }

    /**
     * Eliminar usuario (soft delete - solo administradores)
     * @param int $id - ID del usuario
     * @return array - Respuesta JSON
     */
    public function deleteUser($id) {
        try {
            // Verificar que el usuario existe
            $existingUser = $this->user->getUserById($id);
            if (!$existingUser) {
                return [
                    'success' => false,
                    'message' => 'Usuario no encontrado'
                ];
            }

            // Verificar que el usuario esté inactivo (active = 0)
            if ($existingUser['active'] == 1) {
                return [
                    'success' => false,
                    'message' => 'Solo se pueden eliminar usuarios inactivos. Primero desactiva el usuario.'
                ];
            }

            // No permitir eliminar el último administrador
            if ($existingUser['role_id'] == 1) {
                $adminCount = $this->user->getUserStats()['admin_users'] ?? 0;
                if ($adminCount <= 1) {
                    return [
                        'success' => false,
                        'message' => 'No se puede eliminar el último administrador del sistema'
                    ];
                }
            }

            // Log para debug
            error_log("Eliminando usuario ID: $id");
            
            // Eliminar usuario (soft delete)
            $deleteResult = $this->user->deleteUser($id);
            error_log("Resultado de deleteUser: " . ($deleteResult ? 'true' : 'false'));
            
            if ($deleteResult) {
                error_log("Usuario eliminado exitosamente");
                return [
                    'success' => true,
                    'message' => 'Usuario eliminado exitosamente'
                ];
            } else {
                error_log("Error al eliminar usuario en la base de datos");
                return [
                    'success' => false,
                    'message' => 'Error al eliminar usuario en la base de datos'
                ];
            }
        } catch (Exception $e) {
            return [
                'success' => false,
                'message' => 'Error al eliminar usuario: ' . $e->getMessage()
            ];
        }
    }

    /**
     * Obtener estadísticas de usuarios
     * @return array - Respuesta JSON
     */
    public function getUserStats() {
        try {
            $stats = $this->user->getUserStats();
            
            return [
                'success' => true,
                'data' => $stats,
                'message' => 'Estadísticas obtenidas exitosamente'
            ];
        } catch (Exception $e) {
            return [
                'success' => false,
                'message' => 'Error al obtener estadísticas: ' . $e->getMessage()
            ];
        }
    }

    /**
     * Obtener proyectos asignados a un usuario
     * @param int $userId - ID del usuario
     * @return array
     */
    public function getUserProjects($userId) {
        try {
            $projects = $this->user->getUserProjects($userId);
            
            return [
                'success' => true,
                'data' => $projects,
                'message' => 'Proyectos obtenidos exitosamente'
            ];
        } catch (Exception $e) {
            return [
                'success' => false,
                'message' => 'Error al obtener proyectos: ' . $e->getMessage()
            ];
        }
    }

    /**
     * Obtener tareas asignadas a un usuario
     * @param int $userId - ID del usuario
     * @return array
     */
    public function getUserTasks($userId) {
        try {
            $tasks = $this->user->getUserTasks($userId);
            
            return [
                'success' => true,
                'data' => $tasks,
                'message' => 'Tareas obtenidas exitosamente'
            ];
        } catch (Exception $e) {
            return [
                'success' => false,
                'message' => 'Error al obtener tareas: ' . $e->getMessage()
            ];
        }
    }

    /**
     * Cerrar conexión a la base de datos
     */
    public function __destruct() {
        $this->db = null;
    }
}
?>
