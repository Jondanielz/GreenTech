<?php
/**
 * Controlador de Tareas
 * Maneja las peticiones HTTP relacionadas con tareas
 */

require_once __DIR__ . '/../models/Task.php';
require_once __DIR__ . '/../models/Project.php';

class TaskController {
    private $db;
    private $task;
    private $project;

    public function __construct($db) {
        $this->db = $db;
        $this->task = new Task($db);
        $this->project = new Project($db);
    }

    /**
     * Obtener tareas de un proyecto
     */
    public function getProjectTasks($project_id, $userData) {
        // Verificar que el usuario tenga acceso al proyecto
        $isAdmin = $userData['role_id'] == 1;
        $isMember = $this->project->isUserMember($project_id, $userData['user_id']);
        $isCreator = $this->project->isUserCreator($project_id, $userData['user_id']);

        if (!$isAdmin && !$isMember && !$isCreator) {
            return [
                'success' => false,
                'message' => 'No tienes permisos para ver las tareas de este proyecto'
            ];
        }

        $tasks = $this->task->getByProject($project_id);

        // Organizar tareas por estado para el Kanban
        $kanbanData = [
            'Pendiente' => [],
            'En progreso' => [],
            'Completada' => []
        ];

        foreach ($tasks as $task) {
            if (isset($kanbanData[$task['status']])) {
                $kanbanData[$task['status']][] = $task;
            }
        }

        return [
            'success' => true,
            'data' => $tasks,
            'kanban' => $kanbanData,
            'total' => count($tasks)
        ];
    }

    /**
     * Obtener una tarea por ID
     */
    public function getTaskById($id, $userData) {
        $task = $this->task->getById($id);

        if (!$task) {
            return [
                'success' => false,
                'message' => 'Tarea no encontrada'
            ];
        }

        // Verificar permisos en el proyecto
        $project_id = $task['project_id'];
        $isAdmin = $userData['role_id'] == 1;
        $isMember = $this->project->isUserMember($project_id, $userData['user_id']);
        $isCreator = $this->project->isUserCreator($project_id, $userData['user_id']);

        if (!$isAdmin && !$isMember && !$isCreator) {
            return [
                'success' => false,
                'message' => 'No tienes permisos para ver esta tarea'
            ];
        }

        return [
            'success' => true,
            'data' => $task
        ];
    }

    /**
     * Crear nueva tarea
     */
    public function createTask($data, $userData) {
        // Solo admin y coordinador pueden crear tareas
        if ($userData['role_id'] != 1 && $userData['role_id'] != 2) {
            return [
                'success' => false,
                'message' => 'No tienes permisos para crear tareas'
            ];
        }

        // Validar datos requeridos
        if (empty($data['project_id']) || empty($data['title'])) {
            return [
                'success' => false,
                'message' => 'ID de proyecto y título son requeridos'
            ];
        }

        // Verificar permisos en el proyecto
        $project_id = $data['project_id'];
        $isAdmin = $userData['role_id'] == 1;
        $isCreator = $this->project->isUserCreator($project_id, $userData['user_id']);

        if (!$isAdmin && !$isCreator) {
            return [
                'success' => false,
                'message' => 'No tienes permisos para crear tareas en este proyecto'
            ];
        }

        // Valores por defecto
        if (empty($data['description'])) {
            $data['description'] = '';
        }
        if (empty($data['status'])) {
            $data['status'] = 'Pendiente';
        }
        if (empty($data['priority'])) {
            $data['priority'] = 'Media';
        }
        if (empty($data['estimated_hours'])) {
            $data['estimated_hours'] = 0;
        }

        $task_id = $this->task->create($data);

        if ($task_id) {
            // Si hay usuarios asignados, agregarlos
            if (!empty($data['assignees']) && is_array($data['assignees'])) {
                foreach ($data['assignees'] as $user_id) {
                    $this->task->assignUser($task_id, $user_id);
                }
            }

            return [
                'success' => true,
                'message' => 'Tarea creada exitosamente',
                'task_id' => $task_id
            ];
        }

        return [
            'success' => false,
            'message' => 'Error al crear la tarea'
        ];
    }

    /**
     * Actualizar tarea
     */
    public function updateTask($id, $data, $userData) {
        $task = $this->task->getById($id);

        if (!$task) {
            return [
                'success' => false,
                'message' => 'Tarea no encontrada'
            ];
        }

        // Solo admin y coordinador pueden editar tareas
        if ($userData['role_id'] != 1 && $userData['role_id'] != 2) {
            return [
                'success' => false,
                'message' => 'No tienes permisos para editar tareas'
            ];
        }

        // Verificar permisos en el proyecto
        $project_id = $task['project_id'];
        $isAdmin = $userData['role_id'] == 1;
        $isCreator = $this->project->isUserCreator($project_id, $userData['user_id']);

        if (!$isAdmin && !$isCreator) {
            return [
                'success' => false,
                'message' => 'No tienes permisos para editar esta tarea'
            ];
        }

        if ($this->task->update($id, $data)) {
            return [
                'success' => true,
                'message' => 'Tarea actualizada exitosamente'
            ];
        }

        return [
            'success' => false,
            'message' => 'Error al actualizar la tarea'
        ];
    }

    /**
     * Actualizar estado de tarea (para drag & drop en Kanban)
     */
    public function updateTaskStatus($id, $status, $userData) {
        $task = $this->task->getById($id);

        if (!$task) {
            return [
                'success' => false,
                'message' => 'Tarea no encontrada'
            ];
        }

        // Verificar permisos en el proyecto
        $project_id = $task['project_id'];
        $isAdmin = $userData['role_id'] == 1;
        $isMember = $this->project->isUserMember($project_id, $userData['user_id']);
        $isCreator = $this->project->isUserCreator($project_id, $userData['user_id']);

        // Todos los miembros del proyecto pueden mover tareas
        if (!$isAdmin && !$isMember && !$isCreator) {
            return [
                'success' => false,
                'message' => 'No tienes permisos para actualizar esta tarea'
            ];
        }

        $validStatuses = ['Pendiente', 'En progreso', 'Completada'];
        
        if (!in_array($status, $validStatuses)) {
            return [
                'success' => false,
                'message' => 'Estado inválido'
            ];
        }

        if ($this->task->updateStatus($id, $status)) {
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
     * Eliminar tarea
     */
    public function deleteTask($id, $userData) {
        $task = $this->task->getById($id);

        if (!$task) {
            return [
                'success' => false,
                'message' => 'Tarea no encontrada'
            ];
        }

        // Solo admin y coordinador pueden eliminar tareas
        if ($userData['role_id'] != 1 && $userData['role_id'] != 2) {
            return [
                'success' => false,
                'message' => 'No tienes permisos para eliminar tareas'
            ];
        }

        // Verificar permisos en el proyecto
        $project_id = $task['project_id'];
        $isAdmin = $userData['role_id'] == 1;
        $isCreator = $this->project->isUserCreator($project_id, $userData['user_id']);

        if (!$isAdmin && !$isCreator) {
            return [
                'success' => false,
                'message' => 'No tienes permisos para eliminar esta tarea'
            ];
        }

        if ($this->task->delete($id)) {
            return [
                'success' => true,
                'message' => 'Tarea eliminada exitosamente'
            ];
        }

        return [
            'success' => false,
            'message' => 'Error al eliminar la tarea'
        ];
    }

    /**
     * Asignar usuario a tarea
     */
    public function assignUserToTask($task_id, $user_id, $userData) {
        // Solo admin y coordinador pueden asignar usuarios
        if ($userData['role_id'] != 1 && $userData['role_id'] != 2) {
            return [
                'success' => false,
                'message' => 'No tienes permisos para asignar usuarios'
            ];
        }

        $task = $this->task->getById($task_id);

        if (!$task) {
            return [
                'success' => false,
                'message' => 'Tarea no encontrada'
            ];
        }

        if ($this->task->assignUser($task_id, $user_id)) {
            return [
                'success' => true,
                'message' => 'Usuario asignado exitosamente'
            ];
        }

        return [
            'success' => false,
            'message' => 'Error al asignar usuario'
        ];
    }
}
?>

