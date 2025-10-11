// Configuración de build para producción
export const buildConfig = {
  // Configuración de Vite
  vite: {
    build: {
      outDir: "dist",
      assetsDir: "assets",
      sourcemap: false,
      minify: "terser",
      rollupOptions: {
        input: {
          main: "src/index.html",
        },
        output: {
          manualChunks: {
            vendor: ["jquery", "bootstrap", "chart.js"],
            ui: ["select2", "bootstrap-datepicker", "perfect-scrollbar"],
          },
        },
      },
    },
  },

  // Configuración de Gulp (para compatibilidad)
  gulp: {
    tasks: ["clean", "copy", "sass", "js", "html", "images", "fonts"],
  },

  // Configuración de assets
  assets: {
    css: ["src/assets/css/style.css"],
    js: [
      "src/assets/js/off-canvas.js",
      "src/assets/js/misc.js",
      "src/assets/js/settings.js",
      "src/assets/js/todolist.js",
      "src/assets/js/jquery.cookie.js",
      "src/assets/js/dashboard.js",
    ],
    images: ["src/assets/images/**/*"],
    fonts: ["src/assets/fonts/**/*"],
  },
};

export default buildConfig;
