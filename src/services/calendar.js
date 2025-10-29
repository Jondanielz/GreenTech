/**
 * Servicio de Calendario
 * Maneja las operaciones relacionadas con el calendario y diagrama Gantt
 */

import APIClient from "/src/utils/api-client.js";

export class CalendarService {
  /**
   * Obtener datos del calendario según el rol del usuario
   * @returns {Promise<object>} - Datos del calendario
   */
  static async getCalendarData() {
    try {
      const response = await APIClient.get("/calendar");

      if (response.success) {
        return {
          success: true,
          data: response.data,
        };
      }

      return {
        success: false,
        message: response.message || "Error al cargar los datos del calendario",
      };
    } catch (error) {
      console.error("Error al obtener datos del calendario:", error);
      return {
        success: false,
        message: "Error al cargar los datos del calendario",
      };
    }
  }

  /**
   * Obtener tareas para el calendario según el rol
   * @returns {Promise<Array>} - Lista de tareas
   */
  static async getTasksForCalendar() {
    try {
      const response = await APIClient.get("/tasks/my");

      if (response.success) {
        return response.data || [];
      }

      return [];
    } catch (error) {
      console.error("Error al obtener tareas para calendario:", error);
      return [];
    }
  }

  /**
   * Obtener proyectos para el calendario según el rol
   * @returns {Promise<Array>} - Lista de proyectos
   */
  static async getProjectsForCalendar() {
    try {
      const response = await APIClient.get("/projects/my");

      if (response.success) {
        return response.data || [];
      }

      return [];
    } catch (error) {
      console.error("Error al obtener proyectos para calendario:", error);
      return [];
    }
  }

  /**
   * Obtener estadísticas del calendario
   * @returns {Promise<object>} - Estadísticas del calendario
   */
  static async getCalendarStats() {
    try {
      const response = await APIClient.get("/dashboard/stats");

      if (response.success) {
        return {
          success: true,
          data: response.data,
        };
      }

      return {
        success: false,
        message: "Error al obtener estadísticas",
      };
    } catch (error) {
      console.error("Error al obtener estadísticas del calendario:", error);
      return {
        success: false,
        message: "Error al cargar estadísticas",
      };
    }
  }

  /**
   * Filtrar tareas por criterios
   * @param {Array} tasks - Lista de tareas
   * @param {object} filters - Criterios de filtrado
   * @returns {Array} - Tareas filtradas
   */
  static filterTasks(tasks, filters = {}) {
    return tasks.filter((task) => {
      const statusMatch = !filters.status || task.status === filters.status;
      const priorityMatch =
        !filters.priority || task.priority === filters.priority;
      const projectMatch =
        !filters.project || task.project_name === filters.project;
      const dateMatch =
        !filters.date || this.isTaskInDateRange(task, filters.date);

      return statusMatch && priorityMatch && projectMatch && dateMatch;
    });
  }

  /**
   * Filtrar proyectos por criterios
   * @param {Array} projects - Lista de proyectos
   * @param {object} filters - Criterios de filtrado
   * @returns {Array} - Proyectos filtrados
   */
  static filterProjects(projects, filters = {}) {
    return projects.filter((project) => {
      const statusMatch = !filters.status || project.status === filters.status;
      const projectMatch = !filters.project || project.name === filters.project;
      const dateMatch =
        !filters.date || this.isProjectInDateRange(project, filters.date);

      return statusMatch && projectMatch && dateMatch;
    });
  }

  /**
   * Verificar si una tarea está en el rango de fechas
   * @param {object} task - Tarea
   * @param {object} dateRange - Rango de fechas
   * @returns {boolean}
   */
  static isTaskInDateRange(task, dateRange) {
    if (!task.due_date || !dateRange.start || !dateRange.end) {
      return true;
    }

    const taskDate = new Date(task.due_date);
    const startDate = new Date(dateRange.start);
    const endDate = new Date(dateRange.end);

    return taskDate >= startDate && taskDate <= endDate;
  }

  /**
   * Verificar si un proyecto está en el rango de fechas
   * @param {object} project - Proyecto
   * @param {object} dateRange - Rango de fechas
   * @returns {boolean}
   */
  static isProjectInDateRange(project, dateRange) {
    if (!project.end_date || !dateRange.start || !dateRange.end) {
      return true;
    }

    const projectDate = new Date(project.end_date);
    const startDate = new Date(dateRange.start);
    const endDate = new Date(dateRange.end);

    return projectDate >= startDate && projectDate <= endDate;
  }

  /**
   * Generar datos para el diagrama Gantt
   * @param {Array} tasks - Lista de tareas
   * @param {Array} projects - Lista de proyectos
   * @param {Date} startDate - Fecha de inicio
   * @param {Date} endDate - Fecha de fin
   * @returns {object} - Datos del Gantt
   */
  static generateGanttData(tasks, projects, startDate, endDate) {
    const ganttData = {
      tasks: [],
      projects: [],
      timeline: this.generateTimeline(startDate, endDate),
    };

    // Procesar tareas
    tasks.forEach((task) => {
      if (task.due_date) {
        ganttData.tasks.push({
          id: task.id,
          title: task.title,
          status: task.status,
          priority: task.priority,
          progress: task.progress || 0,
          startDate: new Date(task.created_at),
          endDate: new Date(task.due_date),
          projectName: task.project_name,
          assignees: task.assignees || [],
        });
      }
    });

    // Procesar proyectos
    projects.forEach((project) => {
      if (project.end_date) {
        ganttData.projects.push({
          id: project.id,
          title: project.name,
          status: project.status,
          progress: project.progress || 0,
          startDate: new Date(project.start_date || project.created_at),
          endDate: new Date(project.end_date),
          budget: project.budget,
          creator: project.creator_name,
        });
      }
    });

    return ganttData;
  }

  /**
   * Generar timeline para el Gantt
   * @param {Date} startDate - Fecha de inicio
   * @param {Date} endDate - Fecha de fin
   * @returns {Array} - Timeline
   */
  static generateTimeline(startDate, endDate) {
    const timeline = [];
    const currentDate = new Date(startDate);

    while (currentDate <= endDate) {
      const weekStart = new Date(currentDate);
      const weekEnd = new Date(currentDate);
      weekEnd.setDate(weekEnd.getDate() + 6);

      timeline.push({
        start: new Date(weekStart),
        end: new Date(weekEnd),
        weekNumber:
          Math.ceil((currentDate - startDate) / (7 * 24 * 60 * 60 * 1000)) + 1,
        label: `Semana ${
          Math.ceil((currentDate - startDate) / (7 * 24 * 60 * 60 * 1000)) + 1
        }`,
      });

      currentDate.setDate(currentDate.getDate() + 7);
    }

    return timeline;
  }

  /**
   * Calcular métricas del calendario
   * @param {Array} tasks - Lista de tareas
   * @param {Array} projects - Lista de proyectos
   * @returns {object} - Métricas calculadas
   */
  static calculateCalendarMetrics(tasks, projects) {
    const now = new Date();

    // Métricas de tareas
    const taskMetrics = {
      total: tasks.length,
      completed: tasks.filter((t) => t.status === "Completada").length,
      inProgress: tasks.filter((t) => t.status === "En progreso").length,
      pending: tasks.filter((t) => t.status === "Pendiente").length,
      overdue: tasks.filter((t) => {
        if (!t.due_date) return false;
        return new Date(t.due_date) < now && t.status !== "Completada";
      }).length,
      critical: tasks.filter((t) => t.priority === "Crítica").length,
    };

    // Métricas de proyectos
    const projectMetrics = {
      total: projects.length,
      active: projects.filter((p) => p.status === "En progreso").length,
      completed: projects.filter((p) => p.status === "Completado").length,
      planning: projects.filter((p) => p.status === "Planificación").length,
      overdue: projects.filter((p) => {
        if (!p.end_date) return false;
        return new Date(p.end_date) < now && p.status !== "Completado";
      }).length,
    };

    // Progreso promedio
    const avgTaskProgress =
      tasks.length > 0
        ? tasks.reduce((sum, t) => sum + (t.progress || 0), 0) / tasks.length
        : 0;

    const avgProjectProgress =
      projects.length > 0
        ? projects.reduce((sum, p) => sum + (p.progress || 0), 0) /
          projects.length
        : 0;

    return {
      tasks: taskMetrics,
      projects: projectMetrics,
      averages: {
        taskProgress: Math.round(avgTaskProgress),
        projectProgress: Math.round(avgProjectProgress),
      },
      summary: {
        totalItems: taskMetrics.total + projectMetrics.total,
        completedItems: taskMetrics.completed + projectMetrics.completed,
        overdueItems: taskMetrics.overdue + projectMetrics.overdue,
      },
    };
  }

  /**
   * Exportar datos del calendario
   * @param {Array} tasks - Lista de tareas
   * @param {Array} projects - Lista de proyectos
   * @param {string} format - Formato de exportación (json, csv)
   * @returns {string} - Datos exportados
   */
  static exportCalendarData(tasks, projects, format = "json") {
    const data = {
      tasks: tasks.map((task) => ({
        id: task.id,
        title: task.title,
        status: task.status,
        priority: task.priority,
        progress: task.progress,
        due_date: task.due_date,
        project_name: task.project_name,
        created_at: task.created_at,
      })),
      projects: projects.map((project) => ({
        id: project.id,
        name: project.name,
        status: project.status,
        progress: project.progress,
        start_date: project.start_date,
        end_date: project.end_date,
        budget: project.budget,
        created_at: project.created_at,
      })),
      exported_at: new Date().toISOString(),
    };

    if (format === "csv") {
      return this.convertToCSV(data);
    }

    return JSON.stringify(data, null, 2);
  }

  /**
   * Convertir datos a CSV
   * @param {object} data - Datos a convertir
   * @returns {string} - CSV
   */
  static convertToCSV(data) {
    const headers = [
      "ID",
      "Título",
      "Tipo",
      "Estado",
      "Prioridad",
      "Progreso",
      "Fecha Vencimiento",
      "Proyecto",
      "Fecha Creación",
    ];

    const rows = [];

    // Agregar tareas
    data.tasks.forEach((task) => {
      rows.push([
        task.id,
        task.title,
        "Tarea",
        task.status,
        task.priority,
        task.progress,
        task.due_date,
        task.project_name,
        task.created_at,
      ]);
    });

    // Agregar proyectos
    data.projects.forEach((project) => {
      rows.push([
        project.id,
        project.name,
        "Proyecto",
        project.status,
        "N/A",
        project.progress,
        project.end_date,
        "N/A",
        project.created_at,
      ]);
    });

    const csvContent = [headers, ...rows]
      .map((row) => row.map((field) => `"${field}"`).join(","))
      .join("\n");

    return csvContent;
  }
}

export default CalendarService;
