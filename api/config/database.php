<?php
/**
 * Configuración de conexión a la base de datos MySQL
 * Base de datos: eco_system
 */

class Database {
    // Configuración de conexión
    private $host = "localhost";
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
            
            $this->conn = new PDO($dsn, $this->username, $this->password);
            
            // Configurar PDO para lanzar excepciones en errores
            $this->conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
            
            // Configurar PDO para devolver arrays asociativos por defecto
            $this->conn->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
            
            // Desactivar emulación de prepared statements
            $this->conn->setAttribute(PDO::ATTR_EMULATE_PREPARES, false);
            
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

