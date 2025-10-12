<?php
/**
 * Configuración de conexión a la base de datos MySQL
 * Base de datos: eco_system
 */

class Database {
    // Configuración de conexión
    private $host = "127.0.0.1";  // Usar IP directa en lugar de localhost para evitar problemas IPv6
    private $db_name = "eco_system";
    private $username = "root";
    private $password = "";  // Cambia esto si tu MySQL tiene contraseña
    private $charset = "utf8mb4";
    
    public $conn;

    /**
     * Obtener conexión a la base de datos usando PDO
     * @return PDO|null
     */
    public function getConnection() {
        $this->conn = null;

        try {
            $dsn = "mysql:host=" . $this->host . ";dbname=" . $this->db_name . ";charset=" . $this->charset;
            
            // Opciones de PDO con timeout
            $options = [
                PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                PDO::ATTR_EMULATE_PREPARES => false,
                PDO::ATTR_TIMEOUT => 5  // Timeout de 5 segundos
            ];
            
            $this->conn = new PDO($dsn, $this->username, $this->password, $options);
            
        } catch(PDOException $exception) {
            // Log del error (en producción, no mostrar detalles al usuario)
            error_log("Error de conexión: " . $exception->getMessage());
            throw new Exception("Error al conectar con la base de datos");
        }

        return $this->conn;
    }

    /**
     * Cerrar la conexión
     */
    public function closeConnection() {
        $this->conn = null;
    }

    /**
     * Verificar si la conexión está activa
     * @return bool
     */
    public function isConnected() {
        return $this->conn !== null;
    }
}
?>

