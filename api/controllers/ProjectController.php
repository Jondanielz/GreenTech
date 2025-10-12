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
            $data['status'] = 'Planificacion';
        }
        if (empty($data['budget'])) {
            $data['budget'] = 0;
        }
        if (empty($data['location'])) {
            $data['location'] = '';
        }
        if (empty($data['objectives'])) {
            $data['objectives'] = '';
        }

        $project_id = $this->project->create($data);

        if ($project_id) {
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
}
?>

