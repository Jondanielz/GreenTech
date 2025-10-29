/**
 * Sidebar Loader
 * Determina y carga el sidebar correcto según el rol del usuario
 */

import AuthService from "/src/services/auth.js";

export class SidebarLoader {
  /**
   * Determinar qué sidebar cargar según el rol del usuario
   * @returns {string} - Nombre del archivo del sidebar
   */
  static getSidebarFile() {
    const userData = AuthService.getCurrentUser();

    if (!userData) {
      console.warn("⚠️ No hay datos de usuario, usando sidebar genérico");
      return "_sidebar.html";
    }

    // Obtener role_name y role_id de la base de datos
    const roleName = userData.role_name || userData.role || "";
    const roleId = userData.role_id;
    const roleNameLower = roleName.toLowerCase();

    console.log(`🔍 Determinando sidebar para:`, {
      role_name: roleName,
      role_id: roleId,
      user: userData.name,
    });

    // Mapeo de roles según la base de datos
    // ID 1 = Administrador
    // ID 2 = Coordinador
    // ID 3 = Participante

    let sidebarFile = "_sidebar.html";

    if (roleId === 1 || roleNameLower.includes("administrador")) {
      sidebarFile = "sidebar-admin.html";
    } else if (roleId === 2 || roleNameLower.includes("coordinador")) {
      sidebarFile = "sidebar-coordinador.html";
    } else if (roleId === 3 || roleNameLower.includes("participante")) {
      sidebarFile = "sidebar-participante.html";
    }

    console.log(`✅ Sidebar seleccionado: ${sidebarFile}`);
    return sidebarFile;
  }

  /**
   * Cargar el sidebar correspondiente al rol del usuario
   * @param {string} basePath - Ruta base donde están los componentes
   * @param {string} containerId - ID del contenedor donde cargar el sidebar
   */
  static async loadSidebar(
    basePath = "/src/components/",
    containerId = "#sidebar-container"
  ) {
    const sidebarFile = this.getSidebarFile();
    const sidebarPath = `${basePath}${sidebarFile}`;

    console.log(`📂 Cargando sidebar desde: ${sidebarPath}`);

    try {
      const response = await fetch(sidebarPath);

      if (!response.ok) {
        throw new Error(
          `Error al cargar sidebar: ${response.status} ${response.statusText}`
        );
      }

      const html = await response.text();
      const container = document.querySelector(containerId);

      if (!container) {
        console.error(`❌ Contenedor no encontrado: ${containerId}`);
        return false;
      }

      container.innerHTML = html;
      console.log(`✅ Sidebar cargado correctamente: ${sidebarFile}`);

      return true;
    } catch (error) {
      console.error(`❌ Error al cargar sidebar:`, error);
      return false;
    }
  }

  /**
   * Obtener información del rol del usuario
   * @returns {Object} - Información del rol
   */
  static getRoleInfo() {
    const userData = AuthService.getCurrentUser();

    if (!userData) {
      return {
        role_id: null,
        role_name: "Invitado",
        permissions: [],
        sidebar: "_sidebar.html",
      };
    }

    return {
      role_id: userData.role_id,
      role_name: userData.role_name || userData.role || "Usuario",
      permissions: userData.permissions || [],
      sidebar: this.getSidebarFile(),
      user_name: userData.name,
      user_email: userData.email,
    };
  }

  /**
   * Verificar si el usuario tiene un permiso específico
   * @param {string} permission - Permiso a verificar
   * @returns {boolean}
   */
  static hasPermission(permission) {
    const userData = AuthService.getCurrentUser();

    if (!userData || !userData.permissions) {
      return false;
    }

    const permissions = userData.permissions || [];

    // Si tiene permiso "all", tiene acceso a todo
    if (permissions.includes("all")) {
      return true;
    }

    // Verificar permiso específico
    return permissions.includes(permission);
  }

  /**
   * Verificar si el usuario es administrador
   * @returns {boolean}
   */
  static isAdmin() {
    const userData = AuthService.getCurrentUser();
    return userData && userData.role_id === 1;
  }

  /**
   * Verificar si el usuario es coordinador
   * @returns {boolean}
   */
  static isCoordinator() {
    const userData = AuthService.getCurrentUser();
    return userData && userData.role_id === 2;
  }

  /**
   * Verificar si el usuario es participante
   * @returns {boolean}
   */
  static isParticipant() {
    const userData = AuthService.getCurrentUser();
    return userData && userData.role_id === 3;
  }
}

export default SidebarLoader;
