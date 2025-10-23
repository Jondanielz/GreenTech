import { requireAuth, redirectIfAuthenticated } from "./auth-guard.js";

// Rutas públicas
const publicRoutes = [
  "http://localhost/eco-app/GreenTech/src/views/auth/login.html",
  "http://localhost/eco-app/GreenTech/src/views/auth/register.html",
  "http://localhost/eco-app/GreenTech/src/views/auth/forgot-password.html",
  "http://localhost/eco-app/GreenTech/src/views/samples/error-404.html",
  "http://localhost/eco-app/GreenTech/src/views/samples/error-500.html",
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
