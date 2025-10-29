import { requireAuth, redirectIfAuthenticated } from "./auth-guard.js";

// Rutas públicas
const publicRoutes = [
  "/src/views/auth/login.html",
  "/src/views/auth/register.html",
  "/src/views/auth/forgot-password.html",
  "/src/views/samples/error-404.html",
  "/src/views/samples/error-500.html",
];

// Verificar si la ruta actual es pública
function isPublicRoute() {
  const currentPath = window.location.pathname;
  return publicRoutes.some((route) => currentPath.includes(route));
}

// Inicializar router
export function initRouter() {
  // Si está en una ruta pública (login/register)
  if (isPublicRoute()) {
    // Redirigir al dashboard si ya está autenticado
    redirectIfAuthenticated();
  } else {
    // Si está en una ruta protegida, verificar autenticación
    requireAuth();
  }
}
