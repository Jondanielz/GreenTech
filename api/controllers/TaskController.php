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
     * Obtener tareas de un usuario
     */
    public function getMyTasks($userData) {
        // Verificar que el usuario esté autenticado
        if (!$userData) {
            return [
                'success' => false,
                'message' => 'No autorizado'
            ];
        }

        try {
            $tasks = $this->task->getTasksByUser($userData['user_id']);
            
            if ($tasks !== false) {
                return [
                    'success' => true,
                    'data' => $tasks
                ];
            } else {
                return [
                    'success' => false,
                    'message' => 'Error al obtener tareas'
                ];
            }
        } catch (Exception $e) {
            error_log("Error en getMyTasks: " . $e->getMessage());
            return [
                'success' => false,
                'message' => 'Error interno del servidor'
            ];
        }
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
        // Log para debugging
        error_log("TaskController::createTask - Datos recibidos: " . json_encode($data));
        error_log("TaskController::createTask - UserData: " . json_encode($userData));
        
        // Solo admin y coordinador pueden crear tareas
        if ($userData['role_id'] != 1 && $userData['role_id'] != 2) {
            error_log("TaskController::createTask - Usuario sin permisos: role_id=" . $userData['role_id']);
            return [
                'success' => false,
                'message' => 'No tienes permisos para crear tareas'
            ];
        }

        // Validar datos requeridos
        if (empty($data['project_id']) || empty($data['title'])) {
            error_log("TaskController::createTask - Datos requeridos faltantes: project_id=" . (isset($data['project_id']) ? $data['project_id'] : 'NULL') . ", title=" . (isset($data['title']) ? $data['title'] : 'NULL'));
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

        // Agregar created_by (usuario que crea la tarea)
        $data['created_by'] = $userData['user_id'];
        
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
        if (empty($data['progress'])) {
            $data['progress'] = 0;
        }
        if (empty($data['estimated_hours'])) {
            $data['estimated_hours'] = 0;
        }
        if (empty($data['actual_hours'])) {
            $data['actual_hours'] = 0;
        }

        error_log("TaskController::createTask - Datos finales para crear: " . json_encode($data));
        
        $task_id = $this->task->create($data);
        error_log("TaskController::createTask - Task ID resultante: " . ($task_id ? $task_id : 'FALSE'));

        if ($task_id) {
            // Si hay usuarios asignados, agregarlos
            if (!empty($data['assignees']) && is_array($data['assignees'])) {
                foreach ($data['assignees'] as $user_id) {
                    $this->task->assignUser($task_id, $user_id);
                }
            }

            error_log("TaskController::createTask - Tarea creada exitosamente con ID: " . $task_id);
            return [
                'success' => true,
                'message' => 'Tarea creada exitosamente',
                'task_id' => $task_id
            ];
        }

        error_log("TaskController::createTask - Error al crear tarea en el modelo");
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

        // Valores por defecto para campos opcionales
        if (!isset($data['progress'])) {
            $data['progress'] = $task['progress'];
        }
        if (!isset($data['actual_hours'])) {
            $data['actual_hours'] = $task['actual_hours'];
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
        // Verificar autenticación
        if (!$userData) {
            return [
                'success' => false,
                'message' => 'No autenticado'
            ];
        }

        $assigned_by = $userData['id'];

        try {
            $result = $this->task->assignUserToTask($task_id, $user_id, $assigned_by);
            
            if ($result) {
                return [
                    'success' => true,
                    'message' => 'Usuario asignado exitosamente'
                ];
            } else {
                return [
                    'success' => false,
                    'message' => 'Error al asignar usuario'
                ];
            }
        } catch (Exception $e) {
            error_log("Error en assignUserToTask: " . $e->getMessage());
            return [
                'success' => false,
                'message' => 'Error interno del servidor'
            ];
        }
    }

    /**
     * Obtener todas las tareas (solo administradores)
     */
    public function getAllTasks($userData) {
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
            $tasks = $this->task->getAllTasks();
            
            if ($tasks !== false) {
                return [
                    'success' => true,
                    'data' => $tasks
                ];
            } else {
                return [
                    'success' => false,
                    'message' => 'Error al obtener tareas'
                ];
            }
        } catch (Exception $e) {
            error_log("Error en getAllTasks: " . $e->getMessage());
            return [
                'success' => false,
                'message' => 'Error interno del servidor'
            ];
        }
    }

    /**
     * Obtener asignaciones de una tarea
     */
    public function getTaskAssignments($task_id) {
        try {
            $assignments = $this->task->getTaskAssignments($task_id);
            
            if ($assignments !== false) {
                return [
                    'success' => true,
                    'data' => $assignments
                ];
            } else {
                return [
                    'success' => false,
                    'message' => 'Error al obtener asignaciones'
                ];
            }
        } catch (Exception $e) {
            error_log("Error en getTaskAssignments: " . $e->getMessage());
            return [
                'success' => false,
                'message' => 'Error interno del servidor'
            ];
        }
    }


    /**
     * Desasignar usuario de tarea
     */
    public function unassignUserFromTask($task_id, $user_id, $userData) {
        // Verificar autenticación
        if (!$userData) {
            return [
                'success' => false,
                'message' => 'No autenticado'
            ];
        }

        try {
            $result = $this->task->unassignUserFromTask($task_id, $user_id);
            
            if ($result) {
                return [
                    'success' => true,
                    'message' => 'Usuario desasignado exitosamente'
                ];
            } else {
                return [
                    'success' => false,
                    'message' => 'Error al desasignar usuario'
                ];
            }
        } catch (Exception $e) {
            error_log("Error en unassignUserFromTask: " . $e->getMessage());
            return [
                'success' => false,
                'message' => 'Error interno del servidor'
            ];
        }
    }

}
?>

