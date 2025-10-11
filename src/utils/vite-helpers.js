// Utilidades para Vite
export const viteHelpers = {
  // Función para cargar assets dinámicamente
  loadAsset: async (path) => {
    try {
      const module = await import(/* @vite-ignore */ path);
      return module.default || module;
    } catch (error) {
      console.warn(`No se pudo cargar el asset: ${path}`, error);
      return null;
    }
  },

  // Función para precargar recursos
  preloadAssets: (assets) => {
    assets.forEach((asset) => {
      const link = document.createElement("link");
      link.rel = "preload";
      link.href = asset;
      link.as = asset.endsWith(".css") ? "style" : "script";
      document.head.appendChild(link);
    });
  },

  // Función para inicializar componentes
  initComponents: () => {
    // Inicializar tooltips de Bootstrap
    const tooltipTriggerList = [].slice.call(
      document.querySelectorAll('[data-bs-toggle="tooltip"]')
    );
    tooltipTriggerList.map(
      (tooltipTriggerEl) => new bootstrap.Tooltip(tooltipTriggerEl)
    );

    // Inicializar popovers de Bootstrap
    const popoverTriggerList = [].slice.call(
      document.querySelectorAll('[data-bs-toggle="popover"]')
    );
    popoverTriggerList.map(
      (popoverTriggerEl) => new bootstrap.Popover(popoverTriggerEl)
    );

    // Inicializar Select2
    if (typeof $ !== "undefined" && $.fn.select2) {
      $(".select2").select2();
    }

    // Inicializar datepicker
    if (typeof $ !== "undefined" && $.fn.datepicker) {
      $(".datepicker").datepicker();
    }
  },

  // Función para manejar errores de carga
  handleLoadError: (error, context) => {
    console.error(`Error cargando ${context}:`, error);
    // Aquí puedes agregar lógica para mostrar notificaciones al usuario
  },
};

export default viteHelpers;
