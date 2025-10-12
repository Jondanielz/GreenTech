/**
 * Components Loader
 * Carga y configura los componentes comunes (navbar, sidebar, footer)
 */

import AuthService from "../services/auth.js";

export class ComponentsLoader {
  /**
   * Inicializar componentes y configurar eventos
   */
  static async init() {
    // Verificar autenticación
    if (!AuthService.isAuthenticated()) {
      console.log("⚠️ Usuario no autenticado");
      return;
    }

    // Obtener datos del usuario
    const userData = AuthService.getCurrentUser();
    if (!userData) {
      console.log("⚠️ No se encontraron datos del usuario");
      return;
    }

    console.log("✅ Inicializando componentes para:", userData.name);

    // Actualizar navbar
    this.updateNavbar(userData);

    // Actualizar sidebar
    this.updateSidebar(userData);

    // Configurar logout
    this.setupLogout();
  }

  /**
   * Actualizar información del navbar
   */
  static updateNavbar(userData) {
    // Actualizar nombre en navbar
    const navbarUserName = document.getElementById("navbarUserName");
    if (navbarUserName) {
      navbarUserName.textContent = userData.name || userData.username;
    }

    // Actualizar nombre en dropdown del navbar (index.html)
    const navProfileTexts = document.querySelectorAll(".nav-profile-text p");
    navProfileTexts.forEach((el) => {
      if (
        el.id !== "navbarUserName" &&
        el.textContent.includes("David Greymaax")
      ) {
        el.textContent = userData.name || userData.username;
      }
    });
  }

  /**
   * Actualizar información del sidebar
   */
  static updateSidebar(userData) {
    // Actualizar nombre en sidebar
    const sidebarUserName = document.getElementById("sidebarUserName");
    if (sidebarUserName) {
      sidebarUserName.textContent = userData.name || userData.username;
    }

    // Actualizar rol en sidebar
    const sidebarUserRole = document.getElementById("sidebarUserRole");
    if (sidebarUserRole) {
      // Usar role_name de la base de datos
      const roleName = userData.role_name || userData.role || "Usuario";
      sidebarUserRole.textContent = roleName;
    }

    // Actualizar nombre en sidebar (index.html)
    const sidebarNameElements = document.querySelectorAll(
      ".nav-profile-text span"
    );
    sidebarNameElements.forEach((el) => {
      if (el.id !== "sidebarUserName" && el.id !== "sidebarUserRole") {
        if (el.classList.contains("font-weight-bold")) {
          el.textContent = userData.name || userData.username;
        }
      }
    });
  }

  /**
   * Configurar eventos de logout
   */
  static setupLogout() {
    // Logout desde navbar (componente _navbar.html)
    const navbarLogoutBtn = document.getElementById("navbarLogoutBtn");
    if (navbarLogoutBtn) {
      navbarLogoutBtn.addEventListener("click", (e) => {
        e.preventDefault();
        this.showLogoutModal();
      });
    }

    // Logout desde dropdown en index.html
    const dropdownLogout = document.querySelector(
      ".dropdown-item:has(i.mdi-logout)"
    );
    if (dropdownLogout && !dropdownLogout.id) {
      dropdownLogout.addEventListener("click", (e) => {
        e.preventDefault();
        this.showLogoutModal();
      });
    }

    // Botón de poder en navbar (index.html)
    const logoutButtons = document.querySelectorAll(".nav-logout a");
    logoutButtons.forEach((btn) => {
      btn.addEventListener("click", (e) => {
        e.preventDefault();
        this.showLogoutModal();
      });
    });
  }

  /**
   * Mostrar modal de confirmación de logout
   */
  static showLogoutModal() {
    // Verificar si existe el modal de logout
    const logoutModalElement = document.getElementById("logoutModal");

    if (logoutModalElement) {
      // Usar el modal de Bootstrap que ya existe
      const logoutModal = new bootstrap.Modal(logoutModalElement);
      logoutModal.show();
    } else {
      // Si no existe el modal, usar confirm como fallback
      if (confirm("¿Estás seguro de que deseas cerrar sesión?")) {
        this.executeLogout();
      }
    }
  }

  /**
   * Ejecutar logout
   */
  static executeLogout() {
    console.log("🔒 Cerrando sesión...");
    AuthService.logout();
  }

  /**
   * Cargar componente HTML externo
   * @param {string} componentPath - Ruta al componente
   * @param {string} targetSelector - Selector del contenedor donde insertar
   */
  static async loadComponent(componentPath, targetSelector) {
    try {
      const response = await fetch(componentPath);
      if (!response.ok) {
        throw new Error(`Error cargando componente: ${componentPath}`);
      }

      const html = await response.text();
      const container = document.querySelector(targetSelector);

      if (container) {
        container.innerHTML = html;
        console.log(`✅ Componente cargado: ${componentPath}`);
      } else {
        console.warn(`⚠️ No se encontró el contenedor: ${targetSelector}`);
      }
    } catch (error) {
      console.error(`❌ Error cargando componente ${componentPath}:`, error);
    }
  }

  /**
   * Cargar componentes comunes (navbar, sidebar, footer)
   * @param {Object} config - Configuración de componentes a cargar
   */
  static async loadCommonComponents(config = {}) {
    const defaults = {
      navbar: true,
      sidebar: true,
      footer: true,
      basePath: "../components/",
    };

    const settings = { ...defaults, ...config };
    const basePath = settings.basePath;

    try {
      // Cargar navbar (usar navbar-dashboard para páginas autenticadas)
      if (settings.navbar) {
        await this.loadComponent(
          `${basePath}_navbar-dashboard.html`,
          "#navbar-container"
        );
      }

      // Cargar sidebar (puede ser específico por rol)
      if (settings.sidebar) {
        const userData = AuthService.getCurrentUser();
        let sidebarFile = "_sidebar.html";

        if (userData) {
          // Usar role_name de la base de datos
          const roleName = userData.role_name || userData.role || "";
          const roleNameLower = roleName.toLowerCase();

          // También verificar role_id para mayor seguridad
          const roleId = userData.role_id;

          console.log(
            `🎭 Cargando sidebar para rol: "${roleName}" (ID: ${roleId})`
          );

          // Determinar sidebar según role_name o role_id
          if (roleId === 1 || roleNameLower.includes("admin")) {
            sidebarFile = "sidebar-admin.html";
          } else if (roleId === 2 || roleNameLower.includes("coordinador")) {
            sidebarFile = "sidebar-coordinador.html";
          } else if (roleId === 3 || roleNameLower.includes("participante")) {
            sidebarFile = "sidebar-participante.html";
          }

          console.log(`📂 Sidebar seleccionado: ${sidebarFile}`);
        }

        await this.loadComponent(
          `${basePath}${sidebarFile}`,
          "#sidebar-container"
        );
      }

      // Cargar footer
      if (settings.footer) {
        await this.loadComponent(
          `${basePath}_footer.html`,
          "#footer-container"
        );
      }

      // Inicializar componentes después de cargarlos
      await this.init();
    } catch (error) {
      console.error("❌ Error cargando componentes comunes:", error);
    }
  }
}

export default ComponentsLoader;
