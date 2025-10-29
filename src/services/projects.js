/**
 * Servicio de Proyectos
 * Maneja todas las peticiones relacionadas con proyectos
 */

import APIClient from "/src/utils/api-client.js";

class ProjectService {
  /**
   * Obtener todos los proyectos (admin) o proyectos del usuario
   */
  static async getProjects() {
    try {
      const response = await APIClient.get("/projects");
      return response;
    } catch (error) {
      console.error("Error al obtener proyectos:", error);
      throw error;
    }
  }

  /**
   * Obtener proyectos del usuario (mis proyectos)
   */
  static async getMyProjects() {
    try {
      const response = await APIClient.get("/projects/my");
      return response;
    } catch (error) {
      console.error("Error al obtener mis proyectos:", error);
      throw error;
    }
  }

  /**
   * Obtener un proyecto por ID
   */
  static async getProjectById(id) {
    try {
      const response = await APIClient.get(`/projects/${id}`);
      return response;
    } catch (error) {
      console.error(`Error al obtener proyecto ${id}:`, error);
      throw error;
    }
  }

  /**
   * Crear nuevo proyecto
   */
  static async createProject(projectData) {
    try {
      const response = await APIClient.post("/projects", projectData);
      return response;
    } catch (error) {
      console.error("Error al crear proyecto:", error);
      throw error;
    }
  }

  /**
   * Actualizar proyecto
   */
  static async updateProject(id, projectData) {
    try {
      const response = await APIClient.put(`/projects/${id}`, projectData);
      return response;
    } catch (error) {
      console.error(`Error al actualizar proyecto ${id}:`, error);
      throw error;
    }
  }

  /**
   * Cancelar proyecto
   */
  static async cancelProject(id) {
    try {
      const response = await APIClient.delete(`/projects/${id}`);
      return response;
    } catch (error) {
      console.error(`Error al cancelar proyecto ${id}:`, error);
      throw error;
    }
  }

  /**
   * Actualizar estado del proyecto
   */
  static async updateProjectStatus(id, status) {
    try {
      const response = await APIClient.put(`/projects/${id}`, { status });
      return response;
    } catch (error) {
      console.error(`Error al actualizar estado del proyecto ${id}:`, error);
      throw error;
    }
  }

  /**
   * Calcular progreso del proyecto
   */
  static calculateProgress(project) {
    const total = parseInt(project.total_tasks) || 0;
    const completed = parseInt(project.completed_tasks) || 0;

    if (total === 0) return 0;
    return Math.round((completed / total) * 100);
  }

  /**
   * Obtener clase CSS según el estado del proyecto
   */
  static getStatusClass(status) {
    const statusClasses = {
      Planificación: "info",
      "En progreso": "info",
      Completado: "info",
      Cancelado: "danger",
      "En espera": "secondary",
    };

    return statusClasses[status] || "secondary";
  }

  /**
   * Obtener icono según el estado del proyecto
   */
  static getStatusIcon(status) {
    const statusIcons = {
      Planificacion: "mdi-clock-outline",
      "En progreso": "mdi-progress-clock",
      Completado: "mdi-check-circle",
      Cancelado: "mdi-close-circle",
      "En espera": "mdi-pause-circle",
    };

    return statusIcons[status] || "mdi-help-circle";
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
   * Formatear presupuesto
   */
  static formatBudget(amount) {
    if (!amount || amount === 0) return "Sin presupuesto";

    return new Intl.NumberFormat("es-ES", {
      style: "currency",
      currency: "USD",
      minimumFractionDigits: 0,
      maximumFractionDigits: 0,
    }).format(amount);
  }

  /**
   * Obtener días restantes hasta la fecha de finalización
   */
  static getDaysRemaining(endDate) {
    if (!endDate) return null;

    const today = new Date();
    const end = new Date(endDate);
    const diffTime = end - today;
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));

    return diffDays;
  }

  /**
   * Verificar si el proyecto está atrasado
   */
  static isOverdue(endDate, status) {
    if (status === "Completado" || status === "Cancelado") return false;

    const daysRemaining = this.getDaysRemaining(endDate);
    return daysRemaining !== null && daysRemaining < 0;
  }

  /**
   * Obtener texto de días restantes
   */
  static getDaysRemainingText(endDate, status) {
    if (status === "Completado") return "Completado";
    if (status === "Cancelado") return "Cancelado";

    const days = this.getDaysRemaining(endDate);

    if (days === null) return "Sin fecha";
    if (days < 0) return `${Math.abs(days)} días de retraso`;
    if (days === 0) return "Vence hoy";
    if (days === 1) return "1 día restante";
    return `${days} días restantes`;
  }

  /**
   * Obtener usuarios disponibles para asignar a un proyecto
   */
  static async getAvailableUsers(projectId) {
    try {
      const response = await APIClient.get(
        `/projects/${projectId}/available-users`
      );
      return response;
    } catch (error) {
      console.error(
        `Error al obtener usuarios disponibles para proyecto ${projectId}:`,
        error
      );
      throw error;
    }
  }

  /**
   * Asignar usuario a proyecto
   */
  static async assignUserToProject(projectId, userId) {
    try {
      const response = await APIClient.post(`/projects/${projectId}/members`, {
        user_id: userId,
      });
      return response;
    } catch (error) {
      console.error(
        `Error al asignar usuario ${userId} al proyecto ${projectId}:`,
        error
      );
      throw error;
    }
  }

  /**
   * Desasignar usuario del proyecto
   */
  static async unassignUserFromProject(projectId, userId) {
    try {
      const response = await APIClient.delete(
        `/projects/${projectId}/members/${userId}`
      );
      return response;
    } catch (error) {
      console.error(
        `Error al desasignar usuario ${userId} del proyecto ${projectId}:`,
        error
      );
      throw error;
    }
  }
}

export default ProjectService;
