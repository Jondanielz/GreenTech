/**
 * Servicio del Dashboard
 * Maneja las peticiones HTTP a la API del dashboard
 */

import APIClient from "/src/utils/api-client.js";

export class DashboardService {
  /**
   * Obtener todos los datos del dashboard según el rol del usuario
   * @param {string} userRole - Rol del usuario (admin, coordinador, participante)
   * @returns {Promise<Object>} - Datos completos del dashboard
   */
  static async getDashboardData(userRole = "participante") {
    try {
      const response = await APIClient.get(`/dashboard?role=${userRole}`);

      if (response.success) {
        return {
          success: true,
          data: response.data,
          timestamp: response.timestamp,
        };
      }

      return {
        success: false,
        message: response.message || "Error al obtener datos del dashboard",
      };
    } catch (error) {
      console.error("Dashboard service error:", error);
      return {
        success: false,
        message: "Error de conexión con el servidor",
      };
    }
  }

  /**
   * Obtener estadísticas generales
   * @returns {Promise<Object>} - Estadísticas generales
   */
  static async getGeneralStats() {
    try {
      const response = await APIClient.get("/dashboard/stats");
      return response;
    } catch (error) {
      console.error("Stats service error:", error);
      return {
        success: false,
        message: "Error al obtener estadísticas",
      };
    }
  }

  /**
   * Obtener estadísticas financieras
   * @returns {Promise<Object>} - Estadísticas financieras
   */
  static async getFinancialStats() {
    try {
      const response = await APIClient.get("/dashboard/financial");
      return response;
    } catch (error) {
      console.error("Financial service error:", error);
      return {
        success: false,
        message: "Error al obtener estadísticas financieras",
      };
    }
  }

  /**
   * Obtener proyectos recientes
   * @param {number} limit - Número de proyectos a obtener
   * @returns {Promise<Object>} - Lista de proyectos
   */
  static async getRecentProjects(limit = 5) {
    try {
      const response = await APIClient.get(
        `/dashboard/projects?limit=${limit}`
      );
      return response;
    } catch (error) {
      console.error("Projects service error:", error);
      return {
        success: false,
        message: "Error al obtener proyectos",
      };
    }
  }

  /**
   * Obtener tareas recientes
   * @param {number} limit - Número de tareas a obtener
   * @returns {Promise<Object>} - Lista de tareas
   */
  static async getRecentTasks(limit = 10) {
    try {
      const response = await APIClient.get(`/dashboard/tasks?limit=${limit}`);
      return response;
    } catch (error) {
      console.error("Tasks service error:", error);
      return {
        success: false,
        message: "Error al obtener tareas",
      };
    }
  }

  /**
   * Obtener datos para gráficos
   * @returns {Promise<Object>} - Datos de gráficos
   */
  static async getChartsData() {
    try {
      const response = await APIClient.get("/dashboard/charts");
      return response;
    } catch (error) {
      console.error("Charts service error:", error);
      return {
        success: false,
        message: "Error al obtener datos de gráficos",
      };
    }
  }

  /**
   * Obtener actividad reciente
   * @param {number} limit - Número de actividades a obtener
   * @returns {Promise<Object>} - Lista de actividades
   */
  static async getRecentActivity(limit = 15) {
    try {
      const response = await APIClient.get(
        `/dashboard/activity?limit=${limit}`
      );
      return response;
    } catch (error) {
      console.error("Activity service error:", error);
      return {
        success: false,
        message: "Error al obtener actividad",
      };
    }
  }

  /**
   * Obtener usuarios más activos
   * @param {number} limit - Número de usuarios a obtener
   * @returns {Promise<Object>} - Lista de usuarios
   */
  static async getTopUsers(limit = 5) {
    try {
      const response = await APIClient.get(
        `/dashboard/top-users?limit=${limit}`
      );
      return response;
    } catch (error) {
      console.error("Top users service error:", error);
      return {
        success: false,
        message: "Error al obtener usuarios activos",
      };
    }
  }

  /**
   * Formatear números con separador de miles
   * @param {number} num - Número a formatear
   * @returns {string} - Número formateado
   */
  static formatNumber(num) {
    return new Intl.NumberFormat("es-MX").format(num);
  }

  /**
   * Formatear moneda
   * @param {number} amount - Cantidad a formatear
   * @param {string} currency - Código de moneda (default: MXN)
   * @returns {string} - Cantidad formateada
   */
  static formatCurrency(amount, currency = "MXN") {
    return new Intl.NumberFormat("es-MX", {
      style: "currency",
      currency: currency,
    }).format(amount);
  }

  /**
   * Formatear fecha
   * @param {string} dateString - Fecha en formato ISO
   * @param {string} format - Formato deseado (short, medium, long)
   * @returns {string} - Fecha formateada
   */
  static formatDate(dateString, format = "medium") {
    // Validar que la fecha no sea null, undefined o vacía
    if (!dateString) {
      return "Fecha no disponible";
    }

    const date = new Date(dateString);

    // Validar que la fecha sea válida
    if (isNaN(date.getTime())) {
      console.warn("Fecha inválida:", dateString);
      return "Fecha inválida";
    }

    const options = {
      short: { year: "numeric", month: "2-digit", day: "2-digit" },
      medium: { year: "numeric", month: "short", day: "numeric" },
      long: {
        year: "numeric",
        month: "long",
        day: "numeric",
        hour: "2-digit",
        minute: "2-digit",
      },
    };

    try {
      return new Intl.DateTimeFormat("es-MX", options[format]).format(date);
    } catch (error) {
      console.error("Error al formatear fecha:", error, "Fecha:", dateString);
      return "Error al formatear fecha";
    }
  }

  /**
   * Calcular porcentaje
   * @param {number} value - Valor actual
   * @param {number} total - Valor total
   * @returns {number} - Porcentaje
   */
  static calculatePercentage(value, total) {
    if (total === 0) return 0;
    return Math.round((value / total) * 100);
  }

  /**
   * Obtener clase de color según prioridad
   * @param {string} priority - Prioridad (Alta, Media, Baja)
   * @returns {string} - Clase CSS
   */
  static getPriorityClass(priority) {
    const priorities = {
      Alta: "danger",
      Media: "warning",
      Baja: "info",
    };
    return priorities[priority] || "secondary";
  }

  /**
   * Obtener clase de color según estado
   * @param {string} status - Estado del proyecto/tarea
   * @returns {string} - Clase CSS
   */
  static getStatusClass(status) {
    const statuses = {
      active: "success",
      completed: "primary",
      Completada: "success",
      "En Progreso": "info",
      Pendiente: "warning",
      Cancelada: "danger",
      pending: "warning",
      approved: "success",
      rejected: "danger",
    };
    return statuses[status] || "secondary";
  }

  /**
   * Obtener traducción de estado
   * @param {string} status - Estado en inglés
   * @returns {string} - Estado en español
   */
  static translateStatus(status) {
    const translations = {
      active: "Activo",
      completed: "Completado",
      pending: "Pendiente",
      approved: "Aprobado",
      rejected: "Rechazado",
      cancelled: "Cancelado",
    };
    return translations[status] || status;
  }

  /**
   * Obtener datos específicos para dashboard de administrador
   * @returns {Promise<Object>} - Datos del dashboard de admin
   */
  static async getAdminDashboardData() {
    try {
      const response = await APIClient.get("/dashboard/admin");
      return response;
    } catch (error) {
      console.error("Admin dashboard service error:", error);
      return {
        success: false,
        message: "Error al obtener datos del dashboard de administrador",
      };
    }
  }

  /**
   * Obtener datos específicos para dashboard de coordinador
   * @returns {Promise<Object>} - Datos del dashboard de coordinador
   */
  static async getCoordinatorDashboardData() {
    try {
      const response = await APIClient.get("/dashboard/coordinator");
      return response;
    } catch (error) {
      console.error("Coordinator dashboard service error:", error);
      return {
        success: false,
        message: "Error al obtener datos del dashboard de coordinador",
      };
    }
  }

  /**
   * Obtener datos específicos para dashboard de participante
   * @returns {Promise<Object>} - Datos del dashboard de participante
   */
  static async getParticipantDashboardData() {
    try {
      const response = await APIClient.get("/dashboard/participant");
      return response;
    } catch (error) {
      console.error("Participant dashboard service error:", error);
      return {
        success: false,
        message: "Error al obtener datos del dashboard de participante",
      };
    }
  }

  /**
   * Obtener proyectos asignados al usuario actual
   * @returns {Promise<Object>} - Lista de proyectos asignados
   */
  static async getMyProjects() {
    try {
      const response = await APIClient.get("/dashboard/my-projects");
      return response;
    } catch (error) {
      console.error("My projects service error:", error);
      return {
        success: false,
        message: "Error al obtener mis proyectos",
      };
    }
  }

  /**
   * Obtener tareas asignadas al usuario actual
   * @returns {Promise<Object>} - Lista de tareas asignadas
   */
  static async getMyTasks() {
    try {
      const response = await APIClient.get("/dashboard/my-tasks");
      return response;
    } catch (error) {
      console.error("My tasks service error:", error);
      return {
        success: false,
        message: "Error al obtener mis tareas",
      };
    }
  }

  /**
   * Obtener tareas completadas por el usuario actual
   * @returns {Promise<Object>} - Lista de tareas completadas
   */
  static async getMyCompletedTasks() {
    try {
      const response = await APIClient.get("/dashboard/my-completed-tasks");
      return response;
    } catch (error) {
      console.error("My completed tasks service error:", error);
      return {
        success: false,
        message: "Error al obtener mis tareas completadas",
      };
    }
  }
}

export default DashboardService;
