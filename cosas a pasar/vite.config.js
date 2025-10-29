import { defineConfig } from "vite";

export default defineConfig({
  // Configuración del servidor de desarrollo
  server: {
    port: 3000,
    open: "/", // ← Abrir en index.html (dashboard) - redirige a login si no está autenticado
    host: true,
    cors: true,
    hmr: {
      overlay: true,
    },
    // Configurar proxy para las rutas de la API
    proxy: {
      '/api': {
        target: '/api',
        changeOrigin: true,
        secure: false,
        rewrite: (path) => path.replace(/^\/api/, ''),
        configure: (proxy, options) => {
          proxy.on('proxyReq', (proxyReq, req, res) => {
            // Mantener todos los headers originales
            console.log('🔍 Proxy - Original headers:', req.headers);
          });
          proxy.on('proxyRes', (proxyRes, req, res) => {
            console.log('🔍 Proxy - Response status:', proxyRes.statusCode);
          });
        }
      }
    }
  },

  // Configuración de build
  build: {
    outDir: "dist",
    assetsDir: "assets",
    sourcemap: false, // Desactivado para evitar advertencias
    rollupOptions: {
      input: {
        // Rutas públicas
        login: "src/views/auth/login.html",
        register: "src/views/auth/register.html",

        // Dashboard (protegido)
        main: "/src/index.html",

        // Otras páginas protegidas
        buttons: "src/views/ui-features/buttons.html",
        dropdowns: "src/views/ui-features/dropdowns.html",
        typography: "src/views/ui-features/typography.html",
        forms: "src/views/forms/basic_elements.html",
        charts: "src/views/charts/chartjs.html",
        tables: "src/views/tables/basic-table.html",
        icons: "src/views/icons/font-awesome.html",

        // Páginas de error
        error404: "src/views/samples/error-404.html",
        error500: "src/views/samples/error-500.html",
      },
      onwarn(warning, warn) {
        // Ignorar advertencias de source maps faltantes
        if (warning.code === "SOURCEMAP_ERROR") return;
        if (warning.message.includes("source map")) return;
        warn(warning);
      },
    },
  },

  // Configuración de assets
  assetsInclude: [
    "**/*.svg",
    "**/*.png",
    "**/*.jpg",
    "**/*.jpeg",
    "**/*.gif",
    "**/*.ico",
  ],

  // Configuración de CSS
  css: {
    devSourcemap: false, // Desactivado para evitar errores de .map faltantes
  },

  // Configuración de optimización
  optimizeDeps: {
    include: ["jquery", "bootstrap", "chart.js"],
  },

  // Nivel de logging (warn = solo advertencias críticas)
  logLevel: "warn",

  // Configuración de plugins
  plugins: [
    {
      name: "html-transform",
      transformIndexHtml(html) {
        return html.replace(
          /<script type="module" src="\/src\/main\.js"><\/script>/,
          '<script type="module" src="/src/main.js"></script>'
        );
      },
    },
    // Plugin para suprimir errores de source maps en desarrollo
    {
      name: "suppress-sourcemap-warnings",
      configureServer(server) {
        server.middlewares.use((req, res, next) => {
          const originalWrite = res.write;
          const originalEnd = res.end;

          // Suprimir mensajes de error de source maps en la consola
          res.write = function (...args) {
            const message = args[0]?.toString() || "";
            if (
              message.includes("source map") ||
              message.includes("SOURCEMAP_ERROR")
            ) {
              return true;
            }
            return originalWrite.apply(res, args);
          };

          res.end = function (...args) {
            const message = args[0]?.toString() || "";
            if (
              message.includes("source map") ||
              message.includes("SOURCEMAP_ERROR")
            ) {
              return res;
            }
            return originalEnd.apply(res, args);
          };

          next();
        });
      },
    },
  ],
});
