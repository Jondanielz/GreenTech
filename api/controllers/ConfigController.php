<?php
/**
 * Controlador de Configuración
 * Maneja la configuración del sistema, especialmente para reportes
 */

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../models/ReportConfig.php';

class ConfigController {
    private $db;
    private $reportConfig;

    /**
     * Constructor - Inicializa conexión y modelo
     */
    public function __construct() {
        $database = new Database();
        $this->db = $database->getConnection();
        $this->reportConfig = new ReportConfig($this->db);
        
        // Crear tabla si no existe
        $this->reportConfig->createTable();
    }

    /**
     * Obtener configuración actual
     * @return array - Respuesta JSON con configuración
     */
    public function getConfig() {
        try {
            $config = $this->reportConfig->getConfig();
            
            if (!$config) {
                return [
                    'success' => false,
                    'message' => 'No se pudo obtener la configuración'
                ];
            }

            return [
                'success' => true,
                'data' => $config
            ];
        } catch (Exception $e) {
            error_log("Error en getConfig: " . $e->getMessage());
            return [
                'success' => false,
                'message' => 'Error al obtener configuración: ' . $e->getMessage()
            ];
        }
    }

    /**
     * Actualizar configuración
     * @param array $data - Datos de configuración
     * @return array - Respuesta JSON
     */
    public function updateConfig($data) {
        try {
            // Validar datos requeridos
            if (empty($data['company_name'])) {
                return [
                    'success' => false,
                    'message' => 'El nombre de la empresa es requerido'
                ];
            }

            // Validar email si se proporciona
            if (!empty($data['company_email']) && !filter_var($data['company_email'], FILTER_VALIDATE_EMAIL)) {
                return [
                    'success' => false,
                    'message' => 'El formato del email no es válido'
                ];
            }

            $result = $this->reportConfig->updateConfig($data);
            
            if ($result) {
                return [
                    'success' => true,
                    'message' => 'Configuración actualizada exitosamente',
                    'data' => $this->reportConfig->getConfig()
                ];
            } else {
                return [
                    'success' => false,
                    'message' => 'Error al actualizar la configuración'
                ];
            }
        } catch (Exception $e) {
            error_log("Error en updateConfig: " . $e->getMessage());
            return [
                'success' => false,
                'message' => 'Error al actualizar configuración: ' . $e->getMessage()
            ];
        }
    }

    /**
     * Subir logo de la empresa
     * @param array $file - Archivo subido
     * @return array - Respuesta JSON
     */
    public function uploadLogo($file) {
        try {
            // Validar que se haya subido un archivo
            if (!isset($file) || $file['error'] !== UPLOAD_ERR_OK) {
                return [
                    'success' => false,
                    'message' => 'No se ha subido ningún archivo o hay un error en la subida'
                ];
            }

            $result = $this->reportConfig->uploadLogo($file);
            
            if ($result['success']) {
                return [
                    'success' => true,
                    'message' => $result['message'],
                    'data' => [
                        'logo_path' => $result['path'],
                        'logo_filename' => $result['filename']
                    ]
                ];
            } else {
                return [
                    'success' => false,
                    'message' => $result['message']
                ];
            }
        } catch (Exception $e) {
            error_log("Error en uploadLogo: " . $e->getMessage());
            return [
                'success' => false,
                'message' => 'Error al subir logo: ' . $e->getMessage()
            ];
        }
    }

    /**
     * Eliminar logo actual
     * @return array - Respuesta JSON
     */
    public function deleteLogo() {
        try {
            $result = $this->reportConfig->deleteLogo();
            
            if ($result) {
                return [
                    'success' => true,
                    'message' => 'Logo eliminado exitosamente'
                ];
            } else {
                return [
                    'success' => false,
                    'message' => 'Error al eliminar el logo'
                ];
            }
        } catch (Exception $e) {
            error_log("Error en deleteLogo: " . $e->getMessage());
            return [
                'success' => false,
                'message' => 'Error al eliminar logo: ' . $e->getMessage()
            ];
        }
    }

    /**
     * Resetear configuración a valores por defecto
     * @return array - Respuesta JSON
     */
    public function resetConfig() {
        try {
            $result = $this->reportConfig->resetToDefault();
            
            if ($result) {
                return [
                    'success' => true,
                    'message' => 'Configuración reseteada a valores por defecto',
                    'data' => $this->reportConfig->getConfig()
                ];
            } else {
                return [
                    'success' => false,
                    'message' => 'Error al resetear la configuración'
                ];
            }
        } catch (Exception $e) {
            error_log("Error en resetConfig: " . $e->getMessage());
            return [
                'success' => false,
                'message' => 'Error al resetear configuración: ' . $e->getMessage()
            ];
        }
    }

    /**
     * Obtener configuración para reportes
     * @return array - Respuesta JSON
     */
    public function getReportConfig() {
        try {
            $config = $this->reportConfig->getReportConfig();
            
            return [
                'success' => true,
                'data' => $config
            ];
        } catch (Exception $e) {
            error_log("Error en getReportConfig: " . $e->getMessage());
            return [
                'success' => false,
                'message' => 'Error al obtener configuración de reportes: ' . $e->getMessage()
            ];
        }
    }

    /**
     * Validar datos de configuración
     * @param array $data - Datos a validar
     * @return array - Errores encontrados
     */
    private function validateConfigData($data) {
        $errors = [];

        if (empty($data['company_name'])) {
            $errors[] = 'El nombre de la empresa es requerido';
        }

        if (!empty($data['company_email']) && !filter_var($data['company_email'], FILTER_VALIDATE_EMAIL)) {
            $errors[] = 'El formato del email no es válido';
        }

        if (!empty($data['company_phone']) && !preg_match('/^[\d\s\-\+\(\)]+$/', $data['company_phone'])) {
            $errors[] = 'El formato del teléfono no es válido';
        }

        return $errors;
    }

    /**
     * Obtener estadísticas de configuración
     * @return array - Respuesta JSON
     */
    public function getConfigStats() {
        try {
            $config = $this->reportConfig->getConfig();
            
            $stats = [
                'has_logo' => !empty($config['company_logo']),
                'has_address' => !empty($config['company_address']),
                'has_phone' => !empty($config['company_phone']),
                'has_email' => !empty($config['company_email']),
                'has_footer' => !empty($config['report_footer_text']),
                'last_updated' => $config['updated_at'] ?? null
            ];

            return [
                'success' => true,
                'data' => $stats
            ];
        } catch (Exception $e) {
            error_log("Error en getConfigStats: " . $e->getMessage());
            return [
                'success' => false,
                'message' => 'Error al obtener estadísticas de configuración: ' . $e->getMessage()
            ];
        }
    }
}
?>
