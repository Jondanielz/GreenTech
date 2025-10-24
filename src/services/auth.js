/**
 * Servicio de Autenticación
 * Maneja todas las operaciones relacionadas con autenticación de usuarios
 * Conectado con la API PHP backend
 */

import APIClient from "../utils/api-client.js";

export class AuthService {
  /**
   * Iniciar sesión
   * @param {string} user - Nombre de usuario
   * @param {string} password - Contraseña
   * @returns {Promise<object>} - Resultado del login
   */
  static async login(user, password) {
    try {
      const response = await APIClient.post("/auth/login", {
        user,
        password,
      });

      if (response.success) {
        // Guardar token y datos del usuario en localStorage
        localStorage.setItem("authToken", response.token);
        localStorage.setItem("userData", JSON.stringify(response.user));

        console.log("✅ Login exitoso:", response.user.name);

        return {
          success: true,
          user: response.user,
          token: response.token,
        };
      }

      return {
        success: false,
        message: response.message || "Error en el login",
      };
    } catch (error) {
      console.error("❌ Error en login:", error);
      return {
        success: false,
        message: error.message || "Error de conexión con el servidor",
      };
    }
  }

  /**
   * Registrar nuevo usuario
   * @param {object} userData - Datos del usuario a registrar
   * @returns {Promise<object>} - Resultado del registro
   */
  static async register(userData) {
    try {
      const response = await APIClient.post("/auth/register", userData);

      if (response.success) {
        console.log("✅ Registro exitoso:", response.user.name);

        return {
          success: true,
          user: response.user,
          message: response.message,
        };
      }

      return {
        success: false,
        message: response.message || "Error en el registro",
      };
    } catch (error) {
      console.error("❌ Error en registro:", error);
      return {
        success: false,
        message: error.message || "Error de conexión con el servidor",
      };
    }
  }

  /**
   * Cerrar sesión
   * @returns {Promise<void>}
   */
  static async logout() {
    try {
      const userData = this.getCurrentUser();
      const token = localStorage.getItem("authToken");

      // Llamar al endpoint de logout
      if (token) {
        await APIClient.post("/auth/logout", {
          user_id: userData?.id,
          token: token,
        });
      }
    } catch (error) {
      console.error("❌ Error en logout:", error);
    } finally {
      // Limpiar localStorage siempre, incluso si falla la petición
      localStorage.removeItem("authToken");
      localStorage.removeItem("userData");

      // Redirigir al login
      window.location.href =
        "http://localhost/eco-app/GreenTech/src/views/auth/login.html";
    }
  }

  /**
   * Verificar si el usuario está autenticado
   * @returns {boolean}
   */
  static isAuthenticated() {
    const token = localStorage.getItem("authToken");
    const userData = localStorage.getItem("userData");

    return !!(token && userData);
  }

  /**
   * Obtener usuario actual del localStorage
   * @returns {object|null} - Datos del usuario o null
   */
  static getCurrentUser() {
    const userData = localStorage.getItem("userData");

    if (userData) {
      try {
        return JSON.parse(userData);
      } catch (e) {
        console.error("Error al parsear datos del usuario:", e);
        return null;
      }
    }

    return null;
  }

  /**
   * Obtener token de autenticación
   * @returns {string|null}
   */
  static getToken() {
    return localStorage.getItem("authToken");
  }

  /**
   * Verificar sesión con el servidor
   * @returns {Promise<boolean>} - true si la sesión es válida
   */
  static async verifySession() {
    const token = this.getToken();

    if (!token) {
      return false;
    }

    try {
      const response = await APIClient.post("/auth/verify", { token });
      return response.success;
    } catch (error) {
      console.error("❌ Error al verificar sesión:", error);
      return false;
    }
  }

  /**
   * Obtener información actualizada del usuario desde el servidor
   * @returns {Promise<object|null>}
   */
  static async refreshUserData() {
    try {
      const response = await APIClient.get("/auth/me");

      if (response.success && response.user) {
        // Actualizar datos en localStorage
        localStorage.setItem("userData", JSON.stringify(response.user));
        return response.user;
      }

      return null;
    } catch (error) {
      console.error("❌ Error al refrescar datos del usuario:", error);
      return null;
    }
  }

  /**
   * Verificar si el usuario tiene un rol específico
   * @param {string} roleName - Nombre del rol
   * @returns {boolean}
   */
  static hasRole(roleName) {
    const user = this.getCurrentUser();
    return user?.role_name === roleName;
  }

  /**
   * Verificar si el usuario tiene un permiso específico
   * @param {string} permission - Nombre del permiso
   * @returns {boolean}
   */
  static hasPermission(permission) {
    const user = this.getCurrentUser();

    if (!user || !user.permissions) {
      return false;
    }

    // Si tiene permiso "all", tiene todos los permisos
    if (user.permissions.includes("all")) {
      return true;
    }

    return user.permissions.includes(permission);
  }

  /**
   * Verificar si es administrador
   * @returns {boolean}
   */
  static isAdmin() {
    return this.hasRole("Administrador");
  }

  /**
   * Verificar si es coordinador
   * @returns {boolean}
   */
  static isCoordinator() {
    return this.hasRole("Coordinador");
  }

  /**
   * Verificar si es participante
   * @returns {boolean}
   */
  static isParticipant() {
    return this.hasRole("Participante");
  }
}

export default AuthService;
