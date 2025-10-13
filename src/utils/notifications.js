/**
 * Sistema de notificaciones con toasts
 */
class NotificationSystem {
  constructor() {
    this.container = null;
    this.init();
  }

  init() {
    // Crear contenedor de notificaciones si no existe
    if (!document.getElementById("notification-container")) {
      this.container = document.createElement("div");
      this.container.id = "notification-container";
      this.container.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        z-index: ${this.getAppropriateZIndex()};
        max-width: 400px;
        pointer-events: none;
        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      `;
      document.body.appendChild(this.container);
      console.log("📦 Contenedor de notificaciones creado");
    } else {
      this.container = document.getElementById("notification-container");
      console.log("📦 Contenedor de notificaciones encontrado");
    }
  }

  /**
   * Mostrar notificación de éxito
   */
  success(message, duration = 4000) {
    this.show("success", message, duration);
  }

  /**
   * Mostrar notificación de error
   */
  error(message, duration = 5000) {
    this.show("error", message, duration);
  }

  /**
   * Mostrar notificación de información
   */
  info(message, duration = 4000) {
    this.show("info", message, duration);
  }

  /**
   * Mostrar notificación de advertencia
   */
  warning(message, duration = 4000) {
    this.show("warning", message, duration);
  }

  /**
   * Verificar si hay modales abiertos
   */
  hasOpenModals() {
    const modals = document.querySelectorAll(".modal.show");
    return modals.length > 0;
  }

  /**
   * Obtener z-index apropiado
   */
  getAppropriateZIndex() {
    if (this.hasOpenModals()) {
      console.log("🔍 Modal detectado, usando z-index alto");
      return 999999;
    }
    return 99999;
  }

  /**
   * Mostrar notificación
   */
  show(type, message, duration = 4000) {
    console.log(`🔔 Mostrando notificación ${type}:`, message);
    const notification = document.createElement("div");
    notification.className = `notification notification-${type}`;
    notification.style.cssText = `
      background: ${this.getBackgroundColor(type)};
      color: white;
      padding: 16px 20px;
      margin-bottom: 10px;
      border-radius: 8px;
      box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
      display: flex;
      align-items: center;
      gap: 12px;
      font-size: 14px;
      font-weight: 500;
      max-width: 100%;
      word-wrap: break-word;
      pointer-events: auto;
      transform: translateX(100%);
      transition: all 0.3s ease;
      position: relative;
      overflow: hidden;
      z-index: ${this.getAppropriateZIndex()};
    `;

    // Icono según el tipo
    const icon = this.getIcon(type);

    // Contenido de la notificación
    notification.innerHTML = `
      <div style="display: flex; align-items: center; gap: 12px; width: 100%;">
        <i class="mdi ${icon}" style="font-size: 20px; flex-shrink: 0;"></i>
        <span style="flex: 1;">${message}</span>
        <button class="notification-close" style="
          background: none;
          border: none;
          color: white;
          font-size: 18px;
          cursor: pointer;
          padding: 0;
          margin-left: 8px;
          opacity: 0.7;
          transition: opacity 0.2s;
        " onmouseover="this.style.opacity='1'" onmouseout="this.style.opacity='0.7'">
          <i class="mdi mdi-close"></i>
        </button>
      </div>
      <div class="notification-progress" style="
        position: absolute;
        bottom: 0;
        left: 0;
        height: 3px;
        background: rgba(255, 255, 255, 0.3);
        width: 100%;
        transform-origin: left;
        animation: progress ${duration}ms linear;
      "></div>
    `;

    // Agregar estilos de animación
    if (!document.getElementById("notification-styles")) {
      const style = document.createElement("style");
      style.id = "notification-styles";
      style.textContent = `
        @keyframes progress {
          from { transform: scaleX(1); }
          to { transform: scaleX(0); }
        }
        .notification-close:hover {
          opacity: 1 !important;
        }
      `;
      document.head.appendChild(style);
    }

    // Agregar al contenedor
    this.container.appendChild(notification);

    // Verificar z-index
    console.log(
      "🎯 Z-index del contenedor:",
      window.getComputedStyle(this.container).zIndex
    );
    console.log(
      "🎯 Z-index de la notificación:",
      window.getComputedStyle(notification).zIndex
    );

    // Animar entrada
    setTimeout(() => {
      notification.style.transform = "translateX(0)";
    }, 10);

    // Botón de cerrar
    const closeBtn = notification.querySelector(".notification-close");
    closeBtn.addEventListener("click", () => {
      this.remove(notification);
    });

    // Auto-remover después del tiempo especificado
    setTimeout(() => {
      this.remove(notification);
    }, duration);
  }

  /**
   * Remover notificación
   */
  remove(notification) {
    if (notification && notification.parentNode) {
      notification.style.transform = "translateX(100%)";
      notification.style.opacity = "0";

      setTimeout(() => {
        if (notification.parentNode) {
          notification.parentNode.removeChild(notification);
        }
      }, 300);
    }
  }

  /**
   * Obtener color de fondo según el tipo
   */
  getBackgroundColor(type) {
    const colors = {
      success: "#28a745",
      error: "#dc3545",
      info: "#17a2b8",
      warning: "#ffc107",
    };
    return colors[type] || colors.info;
  }

  /**
   * Obtener icono según el tipo
   */
  getIcon(type) {
    const icons = {
      success: "mdi-check-circle",
      error: "mdi-alert-circle",
      info: "mdi-information",
      warning: "mdi-alert",
    };
    return icons[type] || icons.info;
  }

  /**
   * Limpiar todas las notificaciones
   */
  clear() {
    if (this.container) {
      this.container.innerHTML = "";
    }
  }

  /**
   * Actualizar z-index del contenedor
   */
  updateZIndex() {
    if (this.container) {
      this.container.style.zIndex = this.getAppropriateZIndex();
    }
  }
}

// Instancia global
console.log("🚀 Inicializando sistema de notificaciones...");
const notifications = new NotificationSystem();
console.log("✅ Sistema de notificaciones inicializado");

// Funciones de conveniencia para uso global
function showSuccess(message, duration) {
  console.log("🔔 showSuccess llamada:", message);
  notifications.success(message, duration);
}

function showError(message, duration) {
  console.log("🔔 showError llamada:", message);
  notifications.error(message, duration);
}

function showInfo(message, duration) {
  console.log("🔔 showInfo llamada:", message);
  notifications.info(message, duration);
}

function showWarning(message, duration) {
  console.log("🔔 showWarning llamada:", message);
  notifications.warning(message, duration);
}

// Hacer las funciones disponibles globalmente
console.log("🌐 Asignando funciones al objeto window...");
window.showSuccess = showSuccess;
window.showError = showError;
window.showInfo = showInfo;
window.showWarning = showWarning;
console.log("✅ Funciones asignadas al objeto window");
console.log("🔍 Verificando funciones globales:");
console.log("window.showSuccess:", typeof window.showSuccess);
console.log("window.showError:", typeof window.showError);

// Listener para detectar cambios en modales
document.addEventListener("DOMContentLoaded", function () {
  // Observer para detectar cambios en el DOM
  const observer = new MutationObserver(function (mutations) {
    mutations.forEach(function (mutation) {
      if (
        mutation.type === "attributes" &&
        mutation.attributeName === "class"
      ) {
        const target = mutation.target;
        if (target.classList.contains("modal")) {
          if (target.classList.contains("show")) {
            console.log("🔍 Modal abierto detectado");
            notifications.updateZIndex();
          } else {
            console.log("🔍 Modal cerrado detectado");
            notifications.updateZIndex();
          }
        }
      }
    });
  });

  // Observar cambios en el body
  observer.observe(document.body, {
    attributes: true,
    subtree: true,
    attributeFilter: ["class"],
  });
});
