<?php
/**
 * Modelo ReportConfig - Manejo de configuración de reportes
 * Almacena configuraciones personalizadas para los encabezados de reportes
 */

class ReportConfig {
    private $conn;
    private $table_name = "report_config";

    // Propiedades de configuración
    public $id;
    public $company_name;
    public $company_logo;
    public $company_address;
    public $company_phone;
    public $company_email;
    public $report_footer_text;
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
     * Crear tabla de configuración si no existe
     * @return bool
     */
    public function createTable() {
        $query = "CREATE TABLE IF NOT EXISTS " . $this->table_name . " (
            id INT AUTO_INCREMENT PRIMARY KEY,
            company_name VARCHAR(255) NOT NULL DEFAULT 'GreenTech',
            company_logo VARCHAR(500) NULL,
            company_address TEXT NULL,
            company_phone VARCHAR(50) NULL,
            company_email VARCHAR(100) NULL,
            report_footer_text TEXT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        )";

        try {
            $stmt = $this->conn->prepare($query);
            $result = $stmt->execute();
            
            // Insertar configuración por defecto si no existe
            $this->insertDefaultConfig();
            
            return $result;
        } catch(PDOException $e) {
            error_log("Error al crear tabla de configuración: " . $e->getMessage());
            return false;
        }
    }

    /**
     * Insertar configuración por defecto
     * @return bool
     */
    private function insertDefaultConfig() {
        $query = "INSERT IGNORE INTO " . $this->table_name . " 
                  (id, company_name, company_logo, company_address, company_phone, company_email, report_footer_text)
                  VALUES 
                  (1, 'GreenTech', NULL, 'Sistema de Gestión de Proyectos Ecológicos', NULL, NULL, 'Reporte generado automáticamente por GreenTech')";

        try {
            $stmt = $this->conn->prepare($query);
            return $stmt->execute();
        } catch(PDOException $e) {
            error_log("Error al insertar configuración por defecto: " . $e->getMessage());
            return false;
        }
    }

    /**
     * Obtener configuración actual
     * @return array|false
     */
    public function getConfig() {
        $query = "SELECT * FROM " . $this->table_name . " WHERE id = 1 LIMIT 1";

        try {
            $stmt = $this->conn->prepare($query);
            $stmt->execute();
            return $stmt->fetch(PDO::FETCH_ASSOC);
        } catch(PDOException $e) {
            error_log("Error al obtener configuración: " . $e->getMessage());
            return false;
        }
    }

    /**
     * Actualizar configuración
     * @param array $data - Datos de configuración
     * @return bool
     */
    public function updateConfig($data) {
        $query = "UPDATE " . $this->table_name . " 
                  SET 
                    company_name = :company_name,
                    company_logo = :company_logo,
                    company_address = :company_address,
                    company_phone = :company_phone,
                    company_email = :company_email,
                    report_footer_text = :report_footer_text,
                    updated_at = NOW()
                  WHERE id = 1";

        try {
            $stmt = $this->conn->prepare($query);
            
            // Sanitizar datos
            $company_name = htmlspecialchars(strip_tags($data['company_name'] ?? 'GreenTech'));
            $company_logo = htmlspecialchars(strip_tags($data['company_logo'] ?? ''));
            $company_address = htmlspecialchars(strip_tags($data['company_address'] ?? ''));
            $company_phone = htmlspecialchars(strip_tags($data['company_phone'] ?? ''));
            $company_email = htmlspecialchars(strip_tags($data['company_email'] ?? ''));
            $report_footer_text = htmlspecialchars(strip_tags($data['report_footer_text'] ?? ''));

            $stmt->bindParam(':company_name', $company_name);
            $stmt->bindParam(':company_logo', $company_logo);
            $stmt->bindParam(':company_address', $company_address);
            $stmt->bindParam(':company_phone', $company_phone);
            $stmt->bindParam(':company_email', $company_email);
            $stmt->bindParam(':report_footer_text', $report_footer_text);

            return $stmt->execute();
        } catch(PDOException $e) {
            error_log("Error al actualizar configuración: " . $e->getMessage());
            return false;
        }
    }

    /**
     * Subir logo de la empresa
     * @param array $file - Archivo subido
     * @return array - Resultado de la subida
     */
    public function uploadLogo($file) {
        $upload_dir = '/src/assets/images/logos/';
        
        // Crear directorio si no existe
        if (!file_exists($upload_dir)) {
            mkdir($upload_dir, 0755, true);
        }

        // Validar archivo
        $allowed_types = ['image/jpeg', 'image/png', 'image/gif', 'image/svg+xml'];
        $max_size = 2 * 1024 * 1024; // 2MB

        if (!in_array($file['type'], $allowed_types)) {
            return [
                'success' => false,
                'message' => 'Tipo de archivo no permitido. Solo se permiten JPG, PNG, GIF y SVG.'
            ];
        }

        if ($file['size'] > $max_size) {
            return [
                'success' => false,
                'message' => 'El archivo es demasiado grande. Máximo 2MB.'
            ];
        }

        // Generar nombre único
        $extension = pathinfo($file['name'], PATHINFO_EXTENSION);
        $filename = 'company_logo_' . time() . '.' . $extension;
        $filepath = $upload_dir . $filename;

        // Mover archivo
        if (move_uploaded_file($file['tmp_name'], $filepath)) {
            // Actualizar configuración con nueva ruta del logo
            $this->updateConfig(['company_logo' => 'assets/images/logos/' . $filename]);
            
            return [
                'success' => true,
                'filename' => $filename,
                'path' => 'assets/images/logos/' . $filename,
                'message' => 'Logo subido exitosamente'
            ];
        } else {
            return [
                'success' => false,
                'message' => 'Error al subir el archivo'
            ];
        }
    }

    /**
     * Eliminar logo actual
     * @return bool
     */
    public function deleteLogo() {
        $config = $this->getConfig();
        
        if ($config && !empty($config['company_logo'])) {
            $logo_path = '../../' . $config['company_logo'];
            
            // Eliminar archivo físico
            if (file_exists($logo_path)) {
                unlink($logo_path);
            }
            
            // Actualizar configuración
            return $this->updateConfig(['company_logo' => '']);
        }
        
        return true;
    }

    /**
     * Obtener configuración para reportes
     * @return array
     */
    public function getReportConfig() {
        $config = $this->getConfig();
        
        if (!$config) {
            // Retornar configuración por defecto
            return [
                'company_name' => 'GreenTech',
                'company_logo' => '',
                'company_address' => 'Sistema de Gestión de Proyectos Ecológicos',
                'company_phone' => '',
                'company_email' => '',
                'report_footer_text' => 'Reporte generado automáticamente por GreenTech'
            ];
        }
        
        return $config;
    }

    /**
     * Resetear configuración a valores por defecto
     * @return bool
     */
    public function resetToDefault() {
        $query = "UPDATE " . $this->table_name . " 
                  SET 
                    company_name = 'GreenTech',
                    company_logo = NULL,
                    company_address = 'Sistema de Gestión de Proyectos Ecológicos',
                    company_phone = NULL,
                    company_email = NULL,
                    report_footer_text = 'Reporte generado automáticamente por GreenTech',
                    updated_at = NOW()
                  WHERE id = 1";

        try {
            $stmt = $this->conn->prepare($query);
            return $stmt->execute();
        } catch(PDOException $e) {
            error_log("Error al resetear configuración: " . $e->getMessage());
            return false;
        }
    }
}
?>
