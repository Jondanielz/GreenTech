// Configuración del entorno
export const config = {
  development: {
    title: "Purple Admin Dashboard",
    version: "3.0.0",
    description: "Modern admin dashboard template",
    author: "BootstrapDash",
    server: {
      port: 3000,
      host: "localhost",
    },
    build: {
      sourcemap: true,
      minify: true,
    },
  },
  production: {
    title: "Purple Admin Dashboard",
    version: "3.0.0",
    description: "Modern admin dashboard template",
    author: "BootstrapDash",
    server: {
      port: 4173,
      host: "localhost",
    },
    build: {
      sourcemap: false,
      minify: true,
    },
  },
};

export default config;
