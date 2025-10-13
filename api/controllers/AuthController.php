<?php
/**
 * Controlador de Autenticación
 * Maneja login, registro, logout y verificación de sesión
 */

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../models/User.php';

class AuthController {
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
     * Login de usuario
     * @param array $data - Datos del formulario (user, password)
     * @return array - Respuesta JSON
     */
    public function login($data) {
        // Validar datos requeridos
        if (!isset($data['user']) || !isset($data['password'])) {
            return [
                'success' => false,
                'message' => 'Usuario y contraseña son requeridos'
            ];
        }

        // Validar que no estén vacíos
        if (empty(trim($data['user'])) || empty(trim($data['password']))) {
            return [
                'success' => false,
                'message' => 'Usuario y contraseña no pueden estar vacíos'
            ];
        }

        // Buscar usuario en la base de datos
        $this->user->user = $data['user'];
        $stmt = $this->user->login();
        $row = $stmt->fetch();

        if ($row) {
            // Usuario encontrado, verificar contraseña
            $password_valid = false;
            
            // Soportar tanto bcrypt como MD5 (legacy)
            if (password_verify($data['password'], $row['password'])) {
                // Contraseña con bcrypt (segura)
                $password_valid = true;
            } elseif (md5($data['password']) === $row['password']) {
                // Contraseña con MD5 (legacy - usuarios antiguos)
                $password_valid = true;
            }

            if ($password_valid) {
                // Contraseña correcta
                
                // Actualizar último login
                $this->user->updateLastLogin($row['id']);

                // Registrar actividad de login
                $details = [
                    'ip' => $_SERVER['REMOTE_ADDR'] ?? 'unknown',
                    'user_agent' => $_SERVER['HTTP_USER_AGENT'] ?? 'unknown'
                ];
                $this->user->logActivity($row['id'], 'login', $details);

                // Generar token de sesión (32 bytes = 64 caracteres hex)
                $token = bin2hex(random_bytes(32));
                
                // Guardar token en user_sessions (válido por 24 horas)
                $this->user->createSession($row['id'], $token, 86400);

                // Limpiar sesiones expiradas
                $this->user->cleanExpiredSessions();

                // Parsear permisos JSON
                if (isset($row['permissions'])) {
                    $row['permissions'] = json_decode($row['permissions'], true);
                }

                // Remover contraseña de la respuesta
                unset($row['password']);
                
                // Asegurar que el campo se llame user_id para consistencia en el backend
                if (isset($row['id']) && !isset($row['user_id'])) {
                    $row['user_id'] = $row['id'];
                }

                return [
                    'success' => true,
                    'message' => 'Login exitoso',
                    'token' => $token,
                    'user' => $row
                ];
            } else {
                // Contraseña incorrecta
                return [
                    'success' => false,
                    'message' => 'Contraseña incorrecta'
                ];
            }
        } else {
            // Usuario no encontrado o inactivo
            return [
                'success' => false,
                'message' => 'Usuario no encontrado o cuenta inactiva'
            ];
        }
    }

    /**
     * Registro de nuevo usuario
     * @param array $data - Datos del formulario
     * @return array - Respuesta JSON
     */
    public function register($data) {
        // Validar campos requeridos
        $requiredFields = ['name', 'email', 'user', 'password'];
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
        $this->user->name = $data['name'];
        $this->user->email = $data['email'];
        $this->user->user = $data['user'];
        $this->user->password = $data['password'];
        $this->user->role_id = $data['role_id'] ?? 3;  // Rol 3 = Participante por defecto
        $this->user->position_id = $data['position_id'] ?? null;
        
        // Generar avatar aleatorio si no se proporciona
        $this->user->avatar = $data['avatar'] ?? 'https://i.pravatar.cc/150?img=' . rand(1, 70);

        // Crear usuario
        if ($this->user->create()) {
            // Obtener datos del usuario creado
            $userData = $this->user->getUserById($this->user->id);
            
            if ($userData) {
                // Registrar actividad de registro
                $details = [
                    'ip' => $_SERVER['REMOTE_ADDR'] ?? 'unknown',
                    'user_agent' => $_SERVER['HTTP_USER_AGENT'] ?? 'unknown'
                ];
                $this->user->logActivity($this->user->id, 'register', $details);

                // Parsear permisos
                if (isset($userData['permissions'])) {
                    $userData['permissions'] = json_decode($userData['permissions'], true);
                }
                
                // Asegurar que el campo se llame user_id para consistencia en el backend
                if (isset($userData['id']) && !isset($userData['user_id'])) {
                    $userData['user_id'] = $userData['id'];
                }

                return [
                    'success' => true,
                    'message' => 'Usuario registrado exitosamente',
                    'user' => $userData
                ];
            }
        }

        return [
            'success' => false,
            'message' => 'Error al registrar usuario. Intente nuevamente.'
        ];
    }

    /**
     * Logout de usuario
     * @param array $data - Debe contener 'token' o 'user_id'
     * @return array - Respuesta JSON
     */
    public function logout($data) {
        $success = false;
        
        // Si se proporciona token, eliminar sesión
        if (isset($data['token']) && !empty($data['token'])) {
            $success = $this->user->deleteSession($data['token']);
        }

        // Registrar actividad de logout si se proporciona user_id
        if (isset($data['user_id'])) {
            $details = [
                'ip' => $_SERVER['REMOTE_ADDR'] ?? 'unknown',
                'user_agent' => $_SERVER['HTTP_USER_AGENT'] ?? 'unknown'
            ];
            $this->user->logActivity($data['user_id'], 'logout', $details);
        }

        return [
            'success' => true,
            'message' => 'Logout exitoso'
        ];
    }

    /**
     * Verificar sesión/token
     * @param string $token - Token a verificar
     * @return array - Respuesta JSON
     */
    public function verifySession($token) {
        if (empty($token)) {
            return [
                'success' => false,
                'message' => 'Token no proporcionado'
            ];
        }

        $userData = $this->user->verifyToken($token);

        if ($userData) {
            // Token válido
            unset($userData['password']); // No enviar contraseña
            
            // Asegurar que el campo se llame user_id para consistencia en el backend
            if (isset($userData['id']) && !isset($userData['user_id'])) {
                $userData['user_id'] = $userData['id'];
            }
            
            return [
                'success' => true,
                'message' => 'Sesión válida',
                'user' => $userData
            ];
        } else {
            // Token inválido o expirado
            return [
                'success' => false,
                'message' => 'Sesión inválida o expirada'
            ];
        }
    }

    /**
     * Obtener información del usuario actual
     * @param string $token - Token de sesión
     * @return array - Respuesta JSON
     */
    public function getCurrentUser($token) {
        if (empty($token)) {
            return [
                'success' => false,
                'message' => 'Token no proporcionado'
            ];
        }

        $userData = $this->user->verifyToken($token);

        if ($userData) {
            // Obtener información completa del usuario
            $fullUserData = $this->user->getUserById($userData['id']);
            
            if ($fullUserData) {
                unset($fullUserData['password']);
                
                // Parsear permisos
                if (isset($fullUserData['permissions'])) {
                    $fullUserData['permissions'] = json_decode($fullUserData['permissions'], true);
                }
                
                // Asegurar que el campo se llame user_id para consistencia en el backend
                if (isset($fullUserData['id']) && !isset($fullUserData['user_id'])) {
                    $fullUserData['user_id'] = $fullUserData['id'];
                }
                
                return [
                    'success' => true,
                    'user' => $fullUserData
                ];
            }
        }

        return [
            'success' => false,
            'message' => 'Usuario no encontrado'
        ];
    }

    /**
     * Obtener todos los usuarios (solo administradores)
     * @param array $userData - Datos del usuario autenticado
     * @return array - Respuesta JSON
     */
    public function getAllUsers($userData) {
        // Verificar que el usuario esté autenticado
        if (!$userData) {
            return [
                'success' => false,
                'message' => 'No autorizado'
            ];
        }

        // Verificar que sea administrador
        if ($userData['role_id'] != 1) {
            return [
                'success' => false,
                'message' => 'No tienes permisos para acceder a esta información'
            ];
        }

        try {
            $users = $this->user->getAllUsers();
            
            if ($users !== false) {
                return [
                    'success' => true,
                    'data' => $users
                ];
            } else {
                return [
                    'success' => false,
                    'message' => 'Error al obtener usuarios'
                ];
            }
        } catch (Exception $e) {
            error_log("Error en getAllUsers: " . $e->getMessage());
            return [
                'success' => false,
                'message' => 'Error interno del servidor'
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

