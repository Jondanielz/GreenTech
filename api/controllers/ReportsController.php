<?php
/**
 * Controlador de Reportes
 * Maneja la generación de reportes del sistema
 */

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../models/User.php';
require_once __DIR__ . '/../models/Project.php';
require_once __DIR__ . '/../models/Task.php';
require_once __DIR__ . '/../models/ReportConfig.php';

class ReportsController {
    private $db;
    private $user;
    private $project;
    private $task;
    private $reportConfig;

    /**
     * Constructor - Inicializa conexión y modelos
     */
    public function __construct() {
        $database = new Database();
        $this->db = $database->getConnection();
        $this->user = new User($this->db);
        $this->project = new Project($this->db);
        $this->task = new Task($this->db);
        $this->reportConfig = new ReportConfig($this->db);
    }

    /**
     * Generar reporte de usuarios del sistema
     * @return array - Respuesta JSON con datos de usuarios
     */
    public function generateUsersReport() {
        try {
            $users = $this->user->getAllUsers();
            
            // Agregar estadísticas adicionales para cada usuario
            $usersWithStats = [];
            foreach ($users as $user) {
                $userProjects = $this->user->getUserProjects($user['id']);
                $userTasks = $this->user->getUserTasks($user['id']);
                
                $user['projects_count'] = count($userProjects);
                $user['tasks_count'] = count($userTasks);
                $user['completed_tasks'] = count(array_filter($userTasks, function($task) {
                    return $task['status'] === 'Completada';
                }));
                
                $usersWithStats[] = $user;
            }

            // Obtener configuración personalizada
            $config = $this->reportConfig->getReportConfig();

            return [
                'success' => true,
                'data' => [
                    'users' => $usersWithStats,
                    'total_users' => count($usersWithStats),
                    'active_users' => count(array_filter($usersWithStats, function($user) {
                        return $user['active'] == 1;
                    })),
                    'generated_at' => date('Y-m-d H:i:s'),
                    'config' => $config
                ]
            ];
        } catch (Exception $e) {
            error_log("Error en generateUsersReport: " . $e->getMessage());
            return [
                'success' => false,
                'message' => 'Error al generar reporte de usuarios: ' . $e->getMessage()
            ];
        }
    }

    /**
     * Generar reporte de usuarios por proyecto
     * @param int $project_id - ID del proyecto (opcional)
     * @return array - Respuesta JSON con datos de usuarios por proyecto
     */
    public function generateUsersByProjectReport($project_id = null) {
        try {
            if ($project_id) {
                // Reporte para un proyecto específico
                $project = $this->project->getById($project_id);
                if (!$project) {
                    return [
                        'success' => false,
                        'message' => 'Proyecto no encontrado'
                    ];
                }
                
                $members = $this->project->getProjectMembers($project_id);
                $projectData = [$project];
            } else {
                // Reporte para todos los proyectos
                $projectData = $this->project->getAll();
            }

            $projectsWithUsers = [];
            foreach ($projectData as $project) {
                $members = $this->project->getProjectMembers($project['id']);
                
                // Agregar estadísticas de tareas para cada miembro
                $membersWithStats = [];
                foreach ($members as $member) {
                    $userTasks = $this->task->getTasksByUser($member['user_id']);
                    $projectTasks = array_filter($userTasks, function($task) use ($project) {
                        return $task['project_id'] == $project['id'];
                    });
                    
                    $member['project_tasks_count'] = count($projectTasks);
                    $member['completed_project_tasks'] = count(array_filter($projectTasks, function($task) {
                        return $task['status'] === 'Completada';
                    }));
                    
                    $membersWithStats[] = $member;
                }
                
                $project['members'] = $membersWithStats;
                $project['total_members'] = count($membersWithStats);
                $projectsWithUsers[] = $project;
            }

            // Obtener configuración personalizada
            $config = $this->reportConfig->getReportConfig();

            return [
                'success' => true,
                'data' => [
                    'projects' => $projectsWithUsers,
                    'total_projects' => count($projectsWithUsers),
                    'generated_at' => date('Y-m-d H:i:s'),
                    'config' => $config
                ]
            ];
        } catch (Exception $e) {
            error_log("Error en generateUsersByProjectReport: " . $e->getMessage());
            return [
                'success' => false,
                'message' => 'Error al generar reporte de usuarios por proyecto: ' . $e->getMessage()
            ];
        }
    }

    /**
     * Generar reporte de tareas por proyecto
     * @param int $project_id - ID del proyecto (opcional)
     * @return array - Respuesta JSON con datos de tareas por proyecto
     */
    public function generateTasksByProjectReport($project_id = null) {
        try {
            if ($project_id) {
                // Reporte para un proyecto específico
                $project = $this->project->getById($project_id);
                if (!$project) {
                    return [
                        'success' => false,
                        'message' => 'Proyecto no encontrado'
                    ];
                }
                
                $tasks = $this->task->getByProject($project_id);
                $projectData = [$project];
            } else {
                // Reporte para todos los proyectos
                $projectData = $this->project->getAll();
                $tasks = $this->task->getAllTasks();
            }

            $projectsWithTasks = [];
            foreach ($projectData as $project) {
                $projectTasks = $project_id ? $tasks : array_filter($tasks, function($task) use ($project) {
                    return $task['project_id'] == $project['id'];
                });
                
                // Agregar información de asignaciones para cada tarea
                $tasksWithAssignments = [];
                foreach ($projectTasks as $task) {
                    $assignments = $this->task->getTaskAssignments($task['id']);
                    $task['assignments'] = $assignments;
                    $task['assigned_users_count'] = count($assignments);
                    $tasksWithAssignments[] = $task;
                }
                
                // Estadísticas del proyecto
                $totalTasks = count($tasksWithAssignments);
                $completedTasks = count(array_filter($tasksWithAssignments, function($task) {
                    return $task['status'] === 'Completada';
                }));
                $inProgressTasks = count(array_filter($tasksWithAssignments, function($task) {
                    return $task['status'] === 'En progreso';
                }));
                $pendingTasks = count(array_filter($tasksWithAssignments, function($task) {
                    return $task['status'] === 'Pendiente';
                }));
                
                $project['tasks'] = $tasksWithAssignments;
                $project['task_stats'] = [
                    'total' => $totalTasks,
                    'completed' => $completedTasks,
                    'in_progress' => $inProgressTasks,
                    'pending' => $pendingTasks,
                    'completion_percentage' => $totalTasks > 0 ? round(($completedTasks / $totalTasks) * 100, 2) : 0
                ];
                
                $projectsWithTasks[] = $project;
            }

            // Obtener configuración personalizada
            $config = $this->reportConfig->getReportConfig();

            return [
                'success' => true,
                'data' => [
                    'projects' => $projectsWithTasks,
                    'total_projects' => count($projectsWithTasks),
                    'generated_at' => date('Y-m-d H:i:s'),
                    'config' => $config
                ]
            ];
        } catch (Exception $e) {
            error_log("Error en generateTasksByProjectReport: " . $e->getMessage());
            return [
                'success' => false,
                'message' => 'Error al generar reporte de tareas por proyecto: ' . $e->getMessage()
            ];
        }
    }

    /**
     * Generar reporte completo del sistema
     * @return array - Respuesta JSON con todos los reportes
     */
    public function generateCompleteReport() {
        try {
            $usersReport = $this->generateUsersReport();
            $usersByProjectReport = $this->generateUsersByProjectReport();
            $tasksByProjectReport = $this->generateTasksByProjectReport();

            // Obtener configuración personalizada
            $config = $this->reportConfig->getReportConfig();

            return [
                'success' => true,
                'data' => [
                    'users_report' => $usersReport['data'],
                    'users_by_project_report' => $usersByProjectReport['data'],
                    'tasks_by_project_report' => $tasksByProjectReport['data'],
                    'generated_at' => date('Y-m-d H:i:s'),
                    'config' => $config
                ]
            ];
        } catch (Exception $e) {
            error_log("Error en generateCompleteReport: " . $e->getMessage());
            return [
                'success' => false,
                'message' => 'Error al generar reporte completo: ' . $e->getMessage()
            ];
        }
    }

    /**
     * Exportar reporte a CSV
     * @param string $reportType - Tipo de reporte (users, users_by_project, tasks_by_project)
     * @param int $project_id - ID del proyecto (opcional)
     * @return array - Respuesta JSON con datos CSV
     */
    public function exportToCSV($reportType, $project_id = null) {
        try {
            $reportData = null;
            
            switch ($reportType) {
                case 'users':
                    $reportData = $this->generateUsersReport();
                    break;
                case 'users_by_project':
                    $reportData = $this->generateUsersByProjectReport($project_id);
                    break;
                case 'tasks_by_project':
                    $reportData = $this->generateTasksByProjectReport($project_id);
                    break;
                default:
                    return [
                        'success' => false,
                        'message' => 'Tipo de reporte no válido'
                    ];
            }

            if (!$reportData['success']) {
                return $reportData;
            }

            $csvData = $this->convertToCSV($reportData['data'], $reportType);
            
            return [
                'success' => true,
                'data' => [
                    'csv_content' => $csvData,
                    'filename' => $this->generateFilename($reportType, $project_id),
                    'generated_at' => date('Y-m-d H:i:s')
                ]
            ];
        } catch (Exception $e) {
            error_log("Error en exportToCSV: " . $e->getMessage());
            return [
                'success' => false,
                'message' => 'Error al exportar reporte: ' . $e->getMessage()
            ];
        }
    }

    /**
     * Convertir datos a formato CSV
     * @param array $data - Datos a convertir
     * @param string $reportType - Tipo de reporte
     * @return string - Contenido CSV
     */
    private function convertToCSV($data, $reportType) {
        $csv = '';
        
        // Agregar encabezado personalizado si hay configuración
        if (isset($data['config'])) {
            $config = $data['config'];
            $csv .= $this->generateCSVHeader($config, $reportType);
        }
        
        switch ($reportType) {
            case 'users':
                $csv .= "ID,Nombre,Email,Usuario,Rol,Posición,Activo,Último Login,Proyectos,Tareas,Tareas Completadas,Fecha Creación\n";
                foreach ($data['users'] as $user) {
                    $csv .= sprintf("%d,%s,%s,%s,%s,%s,%s,%s,%d,%d,%d,%s\n",
                        $user['id'],
                        $user['name'],
                        $user['email'],
                        $user['user'],
                        $user['role_name'] ?? 'N/A',
                        $user['position'] ?? 'N/A',
                        $user['active'] ? 'Sí' : 'No',
                        $user['last_login'] ?? 'Nunca',
                        $user['projects_count'],
                        $user['tasks_count'],
                        $user['completed_tasks'],
                        $user['created_at']
                    );
                }
                break;
                
            case 'users_by_project':
                $csv .= "Proyecto ID,Nombre Proyecto,Descripción,Estado,Usuario ID,Nombre Usuario,Email Usuario,Rol,Tareas en Proyecto,Tareas Completadas,Fecha Asignación\n";
                foreach ($data['projects'] as $project) {
                    foreach ($project['members'] as $member) {
                        $csv .= sprintf("%d,%s,%s,%s,%d,%s,%s,%s,%d,%d,%s\n",
                            $project['id'],
                            $project['name'],
                            $project['description'],
                            $project['status'],
                            $member['user_id'],
                            $member['name'],
                            $member['email'],
                            $member['role_name'] ?? 'N/A',
                            $member['project_tasks_count'],
                            $member['completed_project_tasks'],
                            $member['assigned_at']
                        );
                    }
                }
                break;
                
            case 'tasks_by_project':
                $csv .= "Proyecto ID,Nombre Proyecto,Tarea ID,Título Tarea,Descripción,Estado,Prioridad,Progreso,Usuarios Asignados,Fecha Creación,Fecha Vencimiento\n";
                foreach ($data['projects'] as $project) {
                    foreach ($project['tasks'] as $task) {
                        $assignedUsers = array_map(function($assignment) {
                            return $assignment['user_name'];
                        }, $task['assignments']);
                        
                        $csv .= sprintf("%d,%s,%d,%s,%s,%s,%s,%d%%,%s,%s,%s\n",
                            $project['id'],
                            $project['name'],
                            $task['id'],
                            $task['title'],
                            $task['description'],
                            $task['status'],
                            $task['priority'],
                            $task['progress'],
                            implode('; ', $assignedUsers),
                            $task['created_at'],
                            $task['due_date']
                        );
                    }
                }
                break;
        }
        
        return $csv;
    }

    /**
     * Generar encabezado personalizado para CSV
     * @param array $config - Configuración de la empresa
     * @param string $reportType - Tipo de reporte
     * @return string - Encabezado CSV
     */
    private function generateCSVHeader($config, $reportType) {
        $header = '';
        
        // Nombre de la empresa
        $header .= $config['company_name'] . "\n";
        
        // Dirección si existe
        if (!empty($config['company_address'])) {
            $header .= $config['company_address'] . "\n";
        }
        
        // Teléfono y email si existen
        $contactInfo = [];
        if (!empty($config['company_phone'])) {
            $contactInfo[] = "Tel: " . $config['company_phone'];
        }
        if (!empty($config['company_email'])) {
            $contactInfo[] = "Email: " . $config['company_email'];
        }
        if (!empty($contactInfo)) {
            $header .= implode(" | ", $contactInfo) . "\n";
        }
        
        // Título del reporte
        $reportTitles = [
            'users' => 'REPORTE DE USUARIOS DEL SISTEMA',
            'users_by_project' => 'REPORTE DE USUARIOS POR PROYECTO',
            'tasks_by_project' => 'REPORTE DE TAREAS POR PROYECTO',
            'complete' => 'REPORTE COMPLETO DEL SISTEMA'
        ];
        
        $header .= "\n" . ($reportTitles[$reportType] ?? 'REPORTE') . "\n";
        $header .= "Generado el: " . date('d/m/Y H:i:s') . "\n";
        $header .= str_repeat("=", 50) . "\n\n";
        
        return $header;
    }

    /**
     * Generar nombre de archivo para exportación
     * @param string $reportType - Tipo de reporte
     * @param int $project_id - ID del proyecto (opcional)
     * @return string - Nombre del archivo
     */
    private function generateFilename($reportType, $project_id = null) {
        $timestamp = date('Y-m-d_H-i-s');
        $projectSuffix = $project_id ? "_proyecto_{$project_id}" : '';
        
        return "reporte_{$reportType}{$projectSuffix}_{$timestamp}.csv";
    }
}
?>
