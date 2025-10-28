<?php
/**
 * Controlador de Proyectos
 * Maneja las peticiones HTTP relacionadas con proyectos
 */

require_once __DIR__ . '/../models/Project.php';

class ProjectController {
    private $db;
    private $project;

    public function __construct($db) {
        $this->db = $db;
        $this->project = new Project($db);
    }

    /**
     * Obtener todos los proyectos (solo admin)
     */
    public function getAllProjects($userData) {
        // Solo administradores pueden ver todos los proyectos
        if ($userData['role_id'] != 1) {
            return [
                'success' => false,
                'message' => 'No tienes permisos para acceder a todos los proyectos'
            ];
        }

        $projects = $this->project->getAll();

        return [
            'success' => true,
            'data' => $projects,
            'total' => count($projects)
        ];
    }

    /**
     * Obtener proyectos del usuario (coordinador/participante)
     */
    public function getUserProjects($userData) {
        $user_id = $userData['user_id'];
        $projects = $this->project->getUserProjects($user_id);

        return [
            'success' => true,
            'data' => $projects,
            'total' => count($projects)
        ];
    }

    /**
     * Obtener un proyecto por ID
     */
    public function getProjectById($id, $userData) {
        $project = $this->project->getById($id);

        if (!$project) {
            return [
                'success' => false,
                'message' => 'Proyecto no encontrado'
            ];
        }

        // Verificar permisos
        $isAdmin = $userData['role_id'] == 1;
        $isMember = $this->project->isUserMember($id, $userData['user_id']);
        $isCreator = $this->project->isUserCreator($id, $userData['user_id']);

        if (!$isAdmin && !$isMember && !$isCreator) {
            return [
                'success' => false,
                'message' => 'No tienes permisos para ver este proyecto'
            ];
        }

        // Obtener miembros del proyecto
        $members = $this->project->getProjectMembers($id);
        $project['members'] = $members;

        return [
            'success' => true,
            'data' => $project
        ];
    }

    /**
     * Crear nuevo proyecto
     */
    public function createProject($data, $userData) {
        // Solo administradores y coordinadores pueden crear proyectos
        if ($userData['role_id'] != 1 && $userData['role_id'] != 2) {
            return [
                'success' => false,
                'message' => 'No tienes permisos para crear proyectos'
            ];
        }

        // Validar datos requeridos
        if (empty($data['name']) || empty($data['description'])) {
            return [
                'success' => false,
                'message' => 'Nombre y descripción son requeridos'
            ];
        }

        // Agregar creator_id
        $data['creator_id'] = $userData['user_id'];
        
        // Valores por defecto
        if (empty($data['status'])) {
            $data['status'] = 'Planificación';
        }
        if (empty($data['budget'])) {
            $data['budget'] = 0;
        }
        if (empty($data['priority'])) {
            $data['priority'] = 'Media';
        }
        if (empty($data['progress'])) {
            $data['progress'] = 0;
        }

        $project_id = $this->project->create($data);

        if ($project_id) {
            // Asignar indicadores si se proporcionaron
            if (isset($data['indicators']) && is_array($data['indicators'])) {
                foreach ($data['indicators'] as $indicatorData) {
                    $this->project->assignIndicatorToProject($project_id, $indicatorData['indicator_id'], $indicatorData);
                }
            }
            
            return [
                'success' => true,
                'message' => 'Proyecto creado exitosamente',
                'project_id' => $project_id
            ];
        }

        return [
            'success' => false,
            'message' => 'Error al crear el proyecto'
        ];
    }

    /**
     * Actualizar proyecto
     */
    public function updateProject($id, $data, $userData) {
        $project = $this->project->getById($id);

        if (!$project) {
            return [
                'success' => false,
                'message' => 'Proyecto no encontrado'
            ];
        }

        // Solo admin o creador del proyecto pueden editarlo
        $isAdmin = $userData['role_id'] == 1;
        $isCreator = $project['creator_id'] == $userData['user_id'];

        if (!$isAdmin && !$isCreator) {
            return [
                'success' => false,
                'message' => 'No tienes permisos para editar este proyecto'
            ];
        }

        // Validar datos
        if (empty($data['name']) || empty($data['description'])) {
            return [
                'success' => false,
                'message' => 'Nombre y descripción son requeridos'
            ];
        }

        if ($this->project->update($id, $data)) {
            return [
                'success' => true,
                'message' => 'Proyecto actualizado exitosamente'
            ];
        }

        return [
            'success' => false,
            'message' => 'Error al actualizar el proyecto'
        ];
    }

    /**
     * Cancelar proyecto (solo admin)
     */
    public function cancelProject($id, $userData) {
        // Solo administradores pueden cancelar proyectos
        if ($userData['role_id'] != 1) {
            return [
                'success' => false,
                'message' => 'Solo administradores pueden cancelar proyectos'
            ];
        }

        $project = $this->project->getById($id);

        if (!$project) {
            return [
                'success' => false,
                'message' => 'Proyecto no encontrado'
            ];
        }

        if ($this->project->updateStatus($id, 'Cancelado')) {
            return [
                'success' => true,
                'message' => 'Proyecto cancelado exitosamente'
            ];
        }

        return [
            'success' => false,
            'message' => 'Error al cancelar el proyecto'
        ];
    }

    /**
     * Actualizar estado del proyecto
     */
    public function updateProjectStatus($id, $status, $userData) {
        $project = $this->project->getById($id);

        if (!$project) {
            return [
                'success' => false,
                'message' => 'Proyecto no encontrado'
            ];
        }

        // Solo admin o creador pueden cambiar el estado
        $isAdmin = $userData['role_id'] == 1;
        $isCreator = $project['creator_id'] == $userData['user_id'];

        if (!$isAdmin && !$isCreator) {
            return [
                'success' => false,
                'message' => 'No tienes permisos para cambiar el estado del proyecto'
            ];
        }

        $validStatuses = ['Planificacion', 'En progreso', 'Completado', 'Cancelado', 'En espera'];
        
        if (!in_array($status, $validStatuses)) {
            return [
                'success' => false,
                'message' => 'Estado inválido'
            ];
        }

        if ($this->project->updateStatus($id, $status)) {
            return [
                'success' => true,
                'message' => 'Estado actualizado exitosamente'
            ];
        }

        return [
            'success' => false,
            'message' => 'Error al actualizar el estado'
        ];
    }

    /**
     * Obtener usuarios disponibles para asignar a un proyecto
     */
    public function getAvailableUsers($projectId, $userData) {
        // Solo admin o coordinador pueden ver usuarios disponibles
        if ($userData['role_id'] != 1 && $userData['role_id'] != 2) {
            return [
                'success' => false,
                'message' => 'No tienes permisos para gestionar miembros'
            ];
        }

        $users = $this->project->getAvailableUsers($projectId);
        
        return [
            'success' => true,
            'data' => $users
        ];
    }

    /**
     * Asignar usuario a proyecto
     */
    public function assignUserToProject($projectId, $userId, $userData) {
        // Solo admin o coordinador pueden asignar usuarios
        if ($userData['role_id'] != 1 && $userData['role_id'] != 2) {
            return [
                'success' => false,
                'message' => 'No tienes permisos para asignar usuarios'
            ];
        }

        // Verificar que el proyecto existe
        $project = $this->project->getById($projectId);
        if (!$project) {
            return [
                'success' => false,
                'message' => 'Proyecto no encontrado'
            ];
        }

        // Los coordinadores solo pueden asignar participantes (role_id = 3)
        if ($userData['role_id'] == 2) {
            // Verificar que el usuario a asignar es participante
            $userToAssign = $this->project->getUserById($userId);
            if (!$userToAssign || $userToAssign['role_id'] != 3) {
                return [
                    'success' => false,
                    'message' => 'Los coordinadores solo pueden asignar participantes'
                ];
            }
        }

        if ($this->project->assignUserToProject($projectId, $userId)) {
            return [
                'success' => true,
                'message' => 'Usuario asignado exitosamente'
            ];
        }

        return [
            'success' => false,
            'message' => 'Error al asignar usuario al proyecto'
        ];
    }

    /**
     * Desasignar usuario del proyecto
     */
    public function unassignUserFromProject($projectId, $userId, $userData) {
        // Solo admin o coordinador pueden desasignar usuarios
        if ($userData['role_id'] != 1 && $userData['role_id'] != 2) {
            return [
                'success' => false,
                'message' => 'No tienes permisos para desasignar usuarios'
            ];
        }

        // Verificar que el proyecto existe
        $project = $this->project->getById($projectId);
        if (!$project) {
            return [
                'success' => false,
                'message' => 'Proyecto no encontrado'
            ];
        }

        // Log para debugging
        error_log("ProjectController::unassignUserFromProject called: projectId=$projectId, userId=$userId");
        
        if ($this->project->unassignUserFromProject($projectId, $userId)) {
            error_log("User $userId successfully unassigned from project $projectId");
            return [
                'success' => true,
                'message' => 'Usuario desasignado exitosamente'
            ];
        }

        error_log("Failed to unassign user $userId from project $projectId");
        return [
            'success' => false,
            'message' => 'Error al desasignar usuario del proyecto'
        ];
    }

    /**
     * Obtener indicadores de un proyecto
     */
    public function getProjectIndicators($projectId, $userData) {
        try {
            $project = $this->project->getById($projectId);

            if (!$project) {
                return [
                    'success' => false,
                    'message' => 'Proyecto no encontrado'
                ];
            }

            // Verificar permisos
            $isAdmin = $userData['role_id'] == 1;
            $isMember = $this->project->isUserMember($projectId, $userData['user_id']);
            $isCreator = $this->project->isUserCreator($projectId, $userData['user_id']);

            if (!$isAdmin && !$isMember && !$isCreator) {
                return [
                    'success' => false,
                    'message' => 'No tienes permisos para ver los indicadores de este proyecto'
                ];
            }

            $indicators = $this->project->getProjectIndicators($projectId);

            return [
                'success' => true,
                'data' => $indicators
            ];
        } catch (Exception $e) {
            error_log("Error en getProjectIndicators: " . $e->getMessage());
            return [
                'success' => false,
                'message' => 'Error interno del servidor: ' . $e->getMessage()
            ];
        }
    }

    /**
     * Asignar indicador a proyecto
     */
    public function assignIndicatorToProject($projectId, $data, $userData) {
        // Solo admin o coordinador pueden asignar indicadores
        if ($userData['role_id'] != 1 && $userData['role_id'] != 2) {
            return [
                'success' => false,
                'message' => 'No tienes permisos para asignar indicadores'
            ];
        }

        $project = $this->project->getById($projectId);
        if (!$project) {
            return [
                'success' => false,
                'message' => 'Proyecto no encontrado'
            ];
        }

        // Validar datos requeridos
        if (empty($data['indicator_id'])) {
            return [
                'success' => false,
                'message' => 'Indicador es requerido'
            ];
        }

        if ($this->project->assignIndicatorToProject($projectId, $data['indicator_id'], $data)) {
            return [
                'success' => true,
                'message' => 'Indicador asignado exitosamente'
            ];
        }

        return [
            'success' => false,
            'message' => 'Error al asignar indicador'
        ];
    }

    /**
     * Actualizar indicador del proyecto
     */
    public function updateProjectIndicator($projectIndicatorId, $data, $userData) {
        // Solo admin o coordinador pueden actualizar indicadores
        if ($userData['role_id'] != 1 && $userData['role_id'] != 2) {
            return [
                'success' => false,
                'message' => 'No tienes permisos para actualizar indicadores'
            ];
        }

        if ($this->project->updateProjectIndicator($projectIndicatorId, $data)) {
            return [
                'success' => true,
                'message' => 'Indicador actualizado exitosamente'
            ];
        }

        return [
            'success' => false,
            'message' => 'Error al actualizar indicador'
        ];
    }

    /**
     * Desasignar indicador del proyecto
     */
    public function unassignIndicatorFromProject($projectIndicatorId, $userData) {
        // Solo admin o coordinador pueden desasignar indicadores
        if ($userData['role_id'] != 1 && $userData['role_id'] != 2) {
            return [
                'success' => false,
                'message' => 'No tienes permisos para desasignar indicadores'
            ];
        }

        if ($this->project->unassignIndicatorFromProject($projectIndicatorId)) {
            return [
                'success' => true,
                'message' => 'Indicador desasignado exitosamente'
            ];
        }

        return [
            'success' => false,
            'message' => 'Error al desasignar indicador'
        ];
    }

    /**
     * Obtener lecturas de indicador
     */
    public function getIndicatorReadings($projectIndicatorId, $userData) {
        $readings = $this->project->getIndicatorReadings($projectIndicatorId);

        return [
            'success' => true,
            'data' => $readings
        ];
    }

    /**
     * Registrar lectura de indicador
     */
    public function addIndicatorReading($projectIndicatorId, $data, $userData) {
        // Solo admin, coordinador o responsable pueden registrar lecturas
        if ($userData['role_id'] != 1 && $userData['role_id'] != 2) {
            return [
                'success' => false,
                'message' => 'No tienes permisos para registrar lecturas'
            ];
        }

        // Validar datos requeridos
        if (empty($data['period_date']) || empty($data['value'])) {
            return [
                'success' => false,
                'message' => 'Fecha del período y valor son requeridos'
            ];
        }

        $data['created_by'] = $userData['user_id'];

        if ($this->project->addIndicatorReading($projectIndicatorId, $data)) {
            return [
                'success' => true,
                'message' => 'Lectura registrada exitosamente'
            ];
        }

        return [
            'success' => false,
            'message' => 'Error al registrar lectura'
        ];
    }

    /**
     * Actualizar lectura de indicador
     */
    public function updateIndicatorReading($readingId, $data, $userData) {
        // Solo admin, coordinador o quien creó la lectura pueden actualizarla
        if ($userData['role_id'] != 1 && $userData['role_id'] != 2) {
            return [
                'success' => false,
                'message' => 'No tienes permisos para actualizar lecturas'
            ];
        }

        if ($this->project->updateIndicatorReading($readingId, $data)) {
            return [
                'success' => true,
                'message' => 'Lectura actualizada exitosamente'
            ];
        }

        return [
            'success' => false,
            'message' => 'Error al actualizar lectura'
        ];
    }

    /**
     * Eliminar lectura de indicador
     */
    public function deleteIndicatorReading($readingId, $userData) {
        // Solo admin o coordinador pueden eliminar lecturas
        if ($userData['role_id'] != 1 && $userData['role_id'] != 2) {
            return [
                'success' => false,
                'message' => 'No tienes permisos para eliminar lecturas'
            ];
        }

        if ($this->project->deleteIndicatorReading($readingId)) {
            return [
                'success' => true,
                'message' => 'Lectura eliminada exitosamente'
            ];
        }

        return [
            'success' => false,
            'message' => 'Error al eliminar lectura'
        ];
    }
}
?>

