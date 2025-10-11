// Importar estilos CSS
import "./assets/css/style.css";

// Importar dependencias JavaScript
import "jquery";
import "bootstrap";
import "chart.js";
import "bootstrap-datepicker";
import "select2";
import "perfect-scrollbar";

// Importar utilidades de Vite
import viteHelpers from "./utils/vite-helpers.js";

// Importar scripts personalizados
import "./assets/js/off-canvas.js";
import "./assets/js/misc.js";
import "./assets/js/settings.js";
import "./assets/js/todolist.js";
import "./assets/js/jquery.cookie.js";
import "./assets/js/dashboard.js";

// Inicializar componentes cuando el DOM esté listo
document.addEventListener("DOMContentLoaded", function () {
  try {
    // Usar utilidades de Vite para inicializar componentes
    viteHelpers.initComponents();

    // Inicializar Perfect Scrollbar
    if (typeof PerfectScrollbar !== "undefined") {
      const ps = new PerfectScrollbar(".sidebar-fixed .nav", {
        wheelSpeed: 2,
        wheelPropagation: false,
        minScrollbarLength: 20,
      });
    }

    // Precargar assets importantes
    viteHelpers.preloadAssets([
      "/src/assets/css/style.css",
      "/src/assets/js/dashboard.js",
    ]);

    console.log("Purple Admin inicializado correctamente con Vite");
  } catch (error) {
    viteHelpers.handleLoadError(error, "inicialización de componentes");
  }
});
