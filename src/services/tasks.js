/**
 * Servicio de Tareas
 * Maneja todas las peticiones relacionadas con tareas
 */

import APIClient from "../utils/api-client.js";

class TaskService {
  /**
   * Obtener tareas de un proyecto
   */
  static async getProjectTasks(projectId) {
    try {
      const response = await APIClient.get(`/tasks/project/${projectId}`);
      return response;
    } catch (error) {
      console.error(
        `Error al obtener tareas del proyecto ${projectId}:`,
        error
      );
      throw error;
    }
  }

  /**
   * Obtener una tarea por ID
   */
  static async getTaskById(id) {
    try {
      const response = await APIClient.get(`/tasks/${id}`);
      return response;
    } catch (error) {
      console.error(`Error al obtener tarea ${id}:`, error);
      throw error;
    }
  }

  /**
   * Crear nueva tarea
   */
  static async createTask(taskData) {
    try {
      const response = await APIClient.post("/tasks", taskData);
      return response;
    } catch (error) {
      console.error("Error al crear tarea:", error);
      throw error;
    }
  }

  /**
   * Actualizar tarea
   */
  static async updateTask(id, taskData) {
    try {
      const response = await APIClient.put(`/tasks/${id}`, taskData);
      return response;
    } catch (error) {
      console.error(`Error al actualizar tarea ${id}:`, error);
      throw error;
    }
  }

  /**
   * Actualizar solo el estado de la tarea (para Kanban)
   */
  static async updateTaskStatus(id, status) {
    try {
      const response = await APIClient.patch(`/tasks/${id}`, { status });
      return response;
    } catch (error) {
      console.error(`Error al actualizar estado de tarea ${id}:`, error);
      throw error;
    }
  }

  /**
   * Eliminar tarea
   */
  static async deleteTask(id) {
    try {
      const response = await APIClient.delete(`/tasks/${id}`);
      return response;
    } catch (error) {
      console.error(`Error al eliminar tarea ${id}:`, error);
      throw error;
    }
  }

  /**
   * Obtener clase CSS según el estado de la tarea
   */
  static getStatusClass(status) {
    const statusClasses = {
      Pendiente: "warning",
      "En progreso": "info",
      Completada: "success",
    };

    return statusClasses[status] || "secondary";
  }

  /**
   * Obtener clase CSS según la prioridad de la tarea
   */
  static getPriorityClass(priority) {
    const priorityClasses = {
      Baja: "success",
      Media: "warning",
      Alta: "danger",
      Crítica: "danger",
    };

    return priorityClasses[priority] || "secondary";
  }

  /**
   * Obtener icono según la prioridad
   */
  static getPriorityIcon(priority) {
    const priorityIcons = {
      Baja: "mdi-arrow-down",
      Media: "mdi-minus",
      Alta: "mdi-arrow-up",
      Crítica: "mdi-alert-circle",
    };

    return priorityIcons[priority] || "mdi-help-circle";
  }

  /**
   * Formatear fecha
   */
  static formatDate(dateString) {
    if (!dateString) return "Sin fecha";

    const date = new Date(dateString);
    const options = { year: "numeric", month: "short", day: "numeric" };
    return date.toLocaleDateString("es-ES", options);
  }

  /**
   * Obtener días restantes hasta la fecha de vencimiento
   */
  static getDaysRemaining(dueDate) {
    if (!dueDate) return null;

    const today = new Date();
    const due = new Date(dueDate);
    const diffTime = due - today;
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));

    return diffDays;
  }

  /**
   * Verificar si la tarea está vencida
   */
  static isOverdue(dueDate, status) {
    if (status === "Completada") return false;

    const daysRemaining = this.getDaysRemaining(dueDate);
    return daysRemaining !== null && daysRemaining < 0;
  }

  /**
   * Obtener texto de días restantes
   */
  static getDaysRemainingText(dueDate, status) {
    if (status === "Completada") return "Completada";

    const days = this.getDaysRemaining(dueDate);

    if (days === null) return "Sin fecha";
    if (days < 0) return `${Math.abs(days)} días de retraso`;
    if (days === 0) return "Vence hoy";
    if (days === 1) return "1 día restante";
    return `${days} días restantes`;
  }

  /**
   * Organizar tareas para el tablero Kanban
   */
  static organizeTasksForKanban(tasks) {
    const kanban = {
      Pendiente: [],
      "En progreso": [],
      Completada: [],
    };

    if (!tasks || tasks.length === 0) {
      return kanban;
    }

    tasks.forEach((task) => {
      if (kanban[task.status]) {
        kanban[task.status].push(task);
      }
    });

    return kanban;
  }

  /**
   * Validar movimiento de tarea en Kanban
   */
  static canMoveTask(task, newStatus, userRole) {
    // Todos pueden mover tareas
    const validStatuses = ["Pendiente", "En progreso", "Completada"];
    return validStatuses.includes(newStatus);
  }

  /**
   * Obtener color de fondo según prioridad
   */
  static getPriorityColor(priority) {
    const colors = {
      Baja: "#28a745",
      Media: "#ffc107",
      Alta: "#fd7e14",
      Crítica: "#dc3545",
    };

    return colors[priority] || "#6c757d";
  }

  /**
   * Obtener estadísticas de tareas
   */
  static getTaskStats(tasks) {
    if (!tasks || tasks.length === 0) {
      return {
        total: 0,
        pending: 0,
        in_progress: 0,
        completed: 0,
        overdue: 0,
        completionRate: 0,
      };
    }

    const total = tasks.length;
    const pending = tasks.filter((t) => t.status === "Pendiente").length;
    const in_progress = tasks.filter((t) => t.status === "En progreso").length;
    const completed = tasks.filter((t) => t.status === "Completada").length;
    const overdue = tasks.filter((t) =>
      this.isOverdue(t.due_date, t.status)
    ).length;
    const completionRate =
      total > 0 ? Math.round((completed / total) * 100) : 0;

    return {
      total,
      pending,
      in_progress,
      completed,
      overdue,
      completionRate,
    };
  }

  /**
   * Obtener todas las tareas (para administradores)
   */
  static async getTasks() {
    try {
      const response = await APIClient.get("/tasks");
      return response;
    } catch (error) {
      console.error("Error al obtener tareas:", error);
      throw error;
    }
  }

  /**
   * Obtener tareas del usuario actual
   */
  static async getMyTasks() {
    try {
      const response = await APIClient.get("/tasks/my");
      return response;
    } catch (error) {
      console.error("Error al obtener mis tareas:", error);
      throw error;
    }
  }

  /**
   * Obtener todos los usuarios
   */
  static async getUsers() {
    try {
      const response = await APIClient.get("/users");
      return response;
    } catch (error) {
      console.error("Error al obtener usuarios:", error);
      throw error;
    }
  }

  /**
   * Obtener asignaciones de una tarea
   */
  static async getTaskAssignments(taskId) {
    try {
      const response = await APIClient.get(`/tasks/${taskId}/assignments`);
      return response;
    } catch (error) {
      console.error("Error al obtener asignaciones:", error);
      throw error;
    }
  }

  /**
   * Asignar usuario a tarea
   */
  static async assignUserToTask(taskId, userId) {
    try {
      const response = await APIClient.post(`/tasks/${taskId}/assign`, {
        user_id: userId,
      });
      return response;
    } catch (error) {
      console.error("Error al asignar usuario:", error);
      throw error;
    }
  }

  /**
   * Desasignar usuario de tarea
   */
  static async unassignUserFromTask(taskId, userId) {
    try {
      const response = await APIClient.delete(
        `/tasks/${taskId}/unassign/${userId}`
      );
      return response;
    } catch (error) {
      console.error("Error al desasignar usuario:", error);
      throw error;
    }
  }
}

export default TaskService;
