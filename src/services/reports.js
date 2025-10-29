/**
 * Servicio de Reportes
 * Maneja las llamadas a la API para generar reportes
 */

class ReportsService {
  constructor() {
    this.baseUrl = "../../api/index.php";
  }

  /**
   * Generar reporte de usuarios
   * @returns {Promise<Object>} Respuesta de la API
   */
  async generateUsersReport() {
    try {
      const response = await fetch("../../api/reports/users", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${localStorage.getItem("token")}`,
        },
      });

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      return await response.json();
    } catch (error) {
      console.error("Error al generar reporte de usuarios:", error);
      throw error;
    }
  }

  /**
   * Generar reporte de usuarios por proyecto
   * @param {number|null} projectId - ID del proyecto (opcional)
   * @returns {Promise<Object>} Respuesta de la API
   */
  async generateUsersByProjectReport(projectId = null) {
    try {
      const response = await fetch("../../api/reports/users-by-project", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${localStorage.getItem("token")}`,
        },
        body: JSON.stringify({
          project_id: projectId,
        }),
      });

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      return await response.json();
    } catch (error) {
      console.error(
        "Error al generar reporte de usuarios por proyecto:",
        error
      );
      throw error;
    }
  }

  /**
   * Generar reporte de tareas por proyecto
   * @param {number|null} projectId - ID del proyecto (opcional)
   * @returns {Promise<Object>} Respuesta de la API
   */
  async generateTasksByProjectReport(projectId = null) {
    try {
      const response = await fetch("../../api/reports/tasks-by-project", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${localStorage.getItem("token")}`,
        },
        body: JSON.stringify({
          project_id: projectId,
        }),
      });

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      return await response.json();
    } catch (error) {
      console.error("Error al generar reporte de tareas por proyecto:", error);
      throw error;
    }
  }

  /**
   * Generar reporte completo del sistema
   * @returns {Promise<Object>} Respuesta de la API
   */
  async generateCompleteReport() {
    try {
      const response = await fetch("../../api/reports/complete", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${localStorage.getItem("token")}`,
        },
      });

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      return await response.json();
    } catch (error) {
      console.error("Error al generar reporte completo:", error);
      throw error;
    }
  }

  /**
   * Exportar reporte a CSV
   * @param {string} reportType - Tipo de reporte
   * @param {number|null} projectId - ID del proyecto (opcional)
   * @returns {Promise<Object>} Respuesta de la API con datos CSV
   */
  async exportToCSV(reportType, projectId = null) {
    try {
      const response = await fetch("../../api/reports/export", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${localStorage.getItem("token")}`,
        },
        body: JSON.stringify({
          report_type: reportType,
          project_id: projectId,
        }),
      });

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      return await response.json();
    } catch (error) {
      console.error("Error al exportar reporte:", error);
      throw error;
    }
  }

  /**
   * Obtener lista de proyectos para filtros
   * @returns {Promise<Object>} Respuesta de la API con lista de proyectos
   */
  async getProjects() {
    try {
      const response = await fetch("../../api/projects", {
        method: "GET",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${localStorage.getItem("token")}`,
        },
      });

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      return await response.json();
    } catch (error) {
      console.error("Error al obtener proyectos:", error);
      throw error;
    }
  }

  /**
   * Descargar archivo CSV
   * @param {string} csvContent - Contenido del archivo CSV
   * @param {string} filename - Nombre del archivo
   */
  downloadCSV(csvContent, filename) {
    try {
      const blob = new Blob([csvContent], { type: "text/csv;charset=utf-8;" });
      const link = document.createElement("a");

      if (link.download !== undefined) {
        const url = URL.createObjectURL(blob);
        link.setAttribute("href", url);
        link.setAttribute("download", filename);
        link.style.visibility = "hidden";
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
        URL.revokeObjectURL(url);
      } else {
        // Fallback para navegadores que no soportan download
        window.open(
          "data:text/csv;charset=utf-8," + encodeURIComponent(csvContent)
        );
      }
    } catch (error) {
      console.error("Error al descargar archivo CSV:", error);
      throw error;
    }
  }

  /**
   * Mostrar notificación de éxito
   * @param {string} message - Mensaje a mostrar
   */
  showSuccess(message) {
    // Implementar notificación de éxito
    console.log("Success:", message);
    // Aquí puedes integrar con tu sistema de notificaciones
  }

  /**
   * Mostrar notificación de error
   * @param {string} message - Mensaje de error
   */
  showError(message) {
    // Implementar notificación de error
    console.error("Error:", message);
    // Aquí puedes integrar con tu sistema de notificaciones
  }
}

// Crear instancia global del servicio
window.reportsService = new ReportsService();
