/**
 * Hoverable Collapse
 * Funcionalidad para colapsar elementos al hacer hover
 */

(function () {
  "use strict";

  // Inicializar cuando el DOM esté listo
  document.addEventListener("DOMContentLoaded", function () {
    initHoverableCollapse();
  });

  function initHoverableCollapse() {
    // Buscar elementos con la clase hoverable-collapse
    const hoverableElements = document.querySelectorAll(".hoverable-collapse");

    hoverableElements.forEach(function (element) {
      element.addEventListener("mouseenter", function () {
        this.classList.add("show");
      });

      element.addEventListener("mouseleave", function () {
        this.classList.remove("show");
      });
    });

    // Funcionalidad para dropdowns
    const dropdownToggles = document.querySelectorAll(
      '[data-toggle="dropdown"]'
    );

    dropdownToggles.forEach(function (toggle) {
      toggle.addEventListener("click", function (e) {
        e.preventDefault();
        e.stopPropagation();

        const dropdown = this.nextElementSibling;
        if (dropdown) {
          // Cerrar otros dropdowns abiertos
          const openDropdowns = document.querySelectorAll(
            ".dropdown-menu.show"
          );
          openDropdowns.forEach(function (openDropdown) {
            if (openDropdown !== dropdown) {
              openDropdown.classList.remove("show");
            }
          });

          // Toggle del dropdown actual
          dropdown.classList.toggle("show");
        }
      });
    });

    // Cerrar dropdowns al hacer clic fuera
    document.addEventListener("click", function (e) {
      if (
        !e.target.matches('[data-toggle="dropdown"]') &&
        !e.target.closest(".dropdown-menu")
      ) {
        const openDropdowns = document.querySelectorAll(".dropdown-menu.show");
        openDropdowns.forEach(function (dropdown) {
          dropdown.classList.remove("show");
        });
      }
    });
  }

  // Exportar para uso global si es necesario
  window.HoverableCollapse = {
    init: initHoverableCollapse,
  };
})();
