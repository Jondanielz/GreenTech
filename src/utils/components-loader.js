/**
 * Components Loader
 * Carga y configura los componentes comunes (navbar, sidebar, footer)
 */

import AuthService from "../services/auth.js";

export class ComponentsLoader {
  /**
   * Obtener iniciales del nombre
   * @param {string} name - Nombre completo
   * @returns {string} Iniciales
   */
  static getInitials(name) {
    if (!name) return "U";

    const words = name.trim().split(" ");
    if (words.length === 1) {
      return words[0].charAt(0).toUpperCase();
    }

    return (
      words[0].charAt(0) + words[words.length - 1].charAt(0)
    ).toUpperCase();
  }

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

    // Actualizar avatar en navbar
    const navbarUserAvatar = document.getElementById("navbarUserAvatar");
    if (navbarUserAvatar) {
      const initials = this.getInitials(userData.name || userData.username);
      navbarUserAvatar.textContent = initials;
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

    // Actualizar avatar en sidebar
    const sidebarUserAvatar = document.getElementById("sidebarUserAvatar");
    if (sidebarUserAvatar) {
      const initials = this.getInitials(userData.name || userData.username);
      sidebarUserAvatar.textContent = initials;
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

      let html = await response.text();
      const container = document.querySelector(targetSelector);

      if (container) {
        // Ajustar rutas de imágenes para navbar si es necesario
        if (componentPath.includes("_navbar.html")) {
          // Remover la etiqueta <nav> y sus clases para evitar duplicación
          html = html.replace(
            /<nav[^>]*class="navbar default-layout-navbar[^"]*"[^>]*>/,
            ""
          );
          html = html.replace("</nav>", "");

          // Ajustar rutas de imágenes y enlaces según la ubicación del archivo
          const currentPath = window.location.pathname;
          const currentUrl = window.location.href;

          // Detectar si estamos en una vista dentro de src/views/
          const isInViews =
            currentPath.includes("/views/") || currentUrl.includes("/views/");

          if (isInViews) {
            // Calcular la profundidad de la subcarpeta
            const pathParts = currentPath
              .split("/")
              .filter((part) => part !== "");
            const viewsIndex = pathParts.findIndex((part) => part === "views");

            if (viewsIndex !== -1) {
              // Contar cuántas carpetas hay después de 'views'
              const depth = pathParts.length - viewsIndex - 2; // -2 para excluir 'views' y el archivo actual

              console.log(`🔍 Debug - Path: ${currentPath}`);
              console.log(`🔍 Debug - PathParts: ${JSON.stringify(pathParts)}`);
              console.log(`🔍 Debug - ViewsIndex: ${viewsIndex}`);
              console.log(`🔍 Debug - Depth: ${depth}`);

              // Ajustar rutas de imágenes según la profundidad
              if (depth > 0) {
                // Para subcarpetas como views/projects/, necesitamos ../../assets/
                // depth=1 significa que necesitamos 2 niveles hacia arriba: ../../assets/
                const assetPath = "../".repeat(depth + 1) + "assets/";
                html = html.replace(/\.\.\/assets\//g, assetPath);
                console.log(
                  `📁 Ajustando rutas para subcarpeta (profundidad: ${depth}): ${assetPath}`
                );
              } else {
                // Para vistas directamente en src/views/, las rutas ya están correctas (../assets/)
                console.log("📁 Rutas ya correctas para vista en src/views/");
              }

              // Ajustar enlaces del logo según la profundidad
              const logoPath = "../".repeat(depth + 1) + "index.html";
              html = html.replace(/href="index\.html"/g, `href="${logoPath}"`);
              console.log(`📁 Ajustando enlaces del logo: ${logoPath}`);
            } else {
              console.log("⚠️ No se encontró 'views' en el path");
            }
          } else {
            // Para index.html raíz, ajustar rutas de imágenes
            html = html.replace(/\.\.\/assets\//g, "src/assets/");
            console.log("📁 Ajustando rutas para index.html raíz");
          }
        }

        // Ajustar rutas de imágenes para footer si es necesario
        if (componentPath.includes("_footer.html")) {
          const currentPath = window.location.pathname;
          const currentUrl = window.location.href;

          // Detectar si estamos en una vista dentro de src/views/
          const isInViews =
            currentPath.includes("/views/") || currentUrl.includes("/views/");

          if (isInViews) {
            // Calcular la profundidad de la subcarpeta
            const pathParts = currentPath
              .split("/")
              .filter((part) => part !== "");
            const viewsIndex = pathParts.findIndex((part) => part === "views");

            if (viewsIndex !== -1) {
              // Contar cuántas carpetas hay después de 'views'
              const depth = pathParts.length - viewsIndex - 2; // -2 para excluir 'views' y el archivo actual

              console.log(`🔍 Debug Footer - Path: ${currentPath}`);
              console.log(`🔍 Debug Footer - Depth: ${depth}`);

              // Ajustar rutas de imágenes según la profundidad
              if (depth > 0) {
                // Para subcarpetas como views/projects/, necesitamos ../../assets/
                // depth=1 significa que necesitamos 2 niveles hacia arriba: ../../assets/
                const assetPath = "../".repeat(depth + 1) + "assets/";
                html = html.replace(/\.\.\/assets\//g, assetPath);
                console.log(
                  `📁 Ajustando rutas de footer para subcarpeta (profundidad: ${depth}): ${assetPath}`
                );
              } else {
                // Para vistas directamente en src/views/, las rutas ya están correctas (../assets/)
                console.log(
                  "📁 Rutas de footer ya correctas para vista en src/views/"
                );
              }
            } else {
              console.log("⚠️ No se encontró 'views' en el path del footer");
            }
          } else {
            // Para index.html raíz, ajustar rutas
            html = html.replace(/\.\.\/assets\//g, "src/assets/");
            console.log("📁 Ajustando rutas de footer para index.html raíz");
          }
        }

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
      basePath: "../../components/",
    };

    const settings = { ...defaults, ...config };
    const finalBasePath = settings.basePath;

    console.log(`🔍 Usando basePath: ${finalBasePath}`);

    try {
      // Cargar navbar
      if (settings.navbar) {
        await this.loadComponent(
          `${finalBasePath}_navbar.html`,
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
          `${finalBasePath}${sidebarFile}`,
          "#sidebar-container"
        );
      }

      // Cargar footer
      if (settings.footer) {
        await this.loadComponent(
          `${finalBasePath}_footer.html`,
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
