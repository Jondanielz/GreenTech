// Guard para proteger rutas
export function checkAuth() {
  // Verificar si existe un token en localStorage o sessionStorage
  const token = localStorage.getItem("authToken");
  const isAuthenticated = !!token; // Por ahora solo verifica existencia

  return isAuthenticated;
}

export function requireAuth() {
  if (!checkAuth()) {
    // Redirigir a login si no está autenticado
    window.location.href =
      "/src/views/auth/login.html";
    return false;
  }
  return true;
}

export function redirectIfAuthenticated() {
  if (checkAuth()) {
    // Si ya está autenticado, redirigir al dashboard
    window.location.href = "/";
    return true;
  }
  return false;
}
