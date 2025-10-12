/**
 * Cliente HTTP para la API PHP
 * Maneja todas las peticiones HTTP a la API backend
 */

// Configuración base de la API
const API_CONFIG = {
  // Ajustar según tu entorno
  baseURL: "http://localhost/eco-app/GreenTech/api",
  timeout: 10000, // 10 segundos
  headers: {
    "Content-Type": "application/json",
    Accept: "application/json",
  },
};

/**
 * Clase principal del cliente API
 */
export class APIClient {
  /**
   * Realizar petición HTTP
   * @param {string} endpoint - Ruta del endpoint (ej: '/auth/login')
   * @param {object} options - Opciones de la petición
   * @returns {Promise<object>} - Respuesta de la API
   */
  static async request(endpoint, options = {}) {
    const url = `${API_CONFIG.baseURL}${endpoint}`;

    const config = {
      ...options,
      headers: {
        ...API_CONFIG.headers,
        ...options.headers,
      },
      credentials: "include", // Incluir cookies
    };

    // Agregar token de autorización si existe
    const token = localStorage.getItem("authToken");
    if (token) {
      config.headers["Authorization"] = `Bearer ${token}`;
    }

    try {
      // Agregar timeout a la petición
      const controller = new AbortController();
      const timeoutId = setTimeout(
        () => controller.abort(),
        API_CONFIG.timeout
      );

      config.signal = controller.signal;

      const response = await fetch(url, config);
      clearTimeout(timeoutId);

      // Parsear respuesta JSON
      let data;
      try {
        data = await response.json();
      } catch (e) {
        // Si no es JSON, crear objeto de error
        data = {
          success: false,
          message: "Respuesta del servidor no válida",
        };
      }

      // Verificar si la respuesta es exitosa
      if (!response.ok) {
        // Si es 401, limpiar sesión
        if (response.status === 401) {
          localStorage.removeItem("authToken");
          localStorage.removeItem("userData");
        }

        throw new Error(data.message || `Error HTTP: ${response.status}`);
      }

      return data;
    } catch (error) {
      // Manejar errores de red
      if (error.name === "AbortError") {
        throw new Error("La petición ha excedido el tiempo de espera");
      }

      console.error("Error en petición API:", error);
      throw error;
    }
  }

  /**
   * Petición GET
   * @param {string} endpoint - Ruta del endpoint
   * @param {object} options - Opciones adicionales
   * @returns {Promise<object>}
   */
  static get(endpoint, options = {}) {
    return this.request(endpoint, {
      ...options,
      method: "GET",
    });
  }

  /**
   * Petición POST
   * @param {string} endpoint - Ruta del endpoint
   * @param {object} data - Datos a enviar
   * @param {object} options - Opciones adicionales
   * @returns {Promise<object>}
   */
  static post(endpoint, data, options = {}) {
    return this.request(endpoint, {
      ...options,
      method: "POST",
      body: JSON.stringify(data),
    });
  }

  /**
   * Petición PUT
   * @param {string} endpoint - Ruta del endpoint
   * @param {object} data - Datos a enviar
   * @param {object} options - Opciones adicionales
   * @returns {Promise<object>}
   */
  static put(endpoint, data, options = {}) {
    return this.request(endpoint, {
      ...options,
      method: "PUT",
      body: JSON.stringify(data),
    });
  }

  /**
   * Petición PATCH
   * @param {string} endpoint - Ruta del endpoint
   * @param {object} data - Datos a enviar
   * @param {object} options - Opciones adicionales
   * @returns {Promise<object>}
   */
  static patch(endpoint, data, options = {}) {
    return this.request(endpoint, {
      ...options,
      method: "PATCH",
      body: JSON.stringify(data),
    });
  }

  /**
   * Petición DELETE
   * @param {string} endpoint - Ruta del endpoint
   * @param {object} options - Opciones adicionales
   * @returns {Promise<object>}
   */
  static delete(endpoint, options = {}) {
    return this.request(endpoint, {
      ...options,
      method: "DELETE",
    });
  }

  /**
   * Subir archivo(s)
   * @param {string} endpoint - Ruta del endpoint
   * @param {FormData} formData - Datos del formulario con archivos
   * @param {object} options - Opciones adicionales
   * @returns {Promise<object>}
   */
  static upload(endpoint, formData, options = {}) {
    // No establecer Content-Type, el navegador lo hará automáticamente con boundary
    const uploadOptions = { ...options };
    delete uploadOptions.headers?.["Content-Type"];

    return this.request(endpoint, {
      ...uploadOptions,
      method: "POST",
      body: formData,
      headers: {
        ...uploadOptions.headers,
      },
    });
  }

  /**
   * Configurar URL base de la API
   * @param {string} baseURL - Nueva URL base
   */
  static setBaseURL(baseURL) {
    API_CONFIG.baseURL = baseURL;
  }

  /**
   * Configurar timeout
   * @param {number} timeout - Tiempo en milisegundos
   */
  static setTimeout(timeout) {
    API_CONFIG.timeout = timeout;
  }

  /**
   * Obtener configuración actual
   * @returns {object}
   */
  static getConfig() {
    return { ...API_CONFIG };
  }
}

// Exportar también como default
export default APIClient;
