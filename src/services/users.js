/**
 * Servicio para gestión de usuarios
 * Maneja todas las operaciones relacionadas con usuarios
 */

import APIClient from '../utils/api-client.js';

class UserService {
    constructor() {
        // No necesitamos instanciar ApiClient ya que usa métodos estáticos
    }

    /**
     * Obtener todos los usuarios (solo administradores)
     * @returns {Promise<Object>} Respuesta de la API
     */
    async getUsers() {
        try {
            const response = await APIClient.get('/users');
            return response;
        } catch (error) {
            console.error('Error al obtener usuarios:', error);
            return {
                success: false,
                message: 'Error de conexión con el servidor'
            };
        }
    }

    /**
     * Obtener solo participantes (coordinadores y administradores)
     * @returns {Promise<Object>} Respuesta de la API
     */
    async getParticipants() {
        try {
            const response = await APIClient.get('/users/participants');
            return response;
        } catch (error) {
            console.error('Error al obtener participantes:', error);
            return {
                success: false,
                message: 'Error de conexión con el servidor'
            };
        }
    }

    /**
     * Obtener usuario por ID
     * @param {number} id - ID del usuario
     * @returns {Promise<Object>} Respuesta de la API
     */
    async getUserById(id) {
        try {
            const response = await APIClient.get(`/users/${id}`);
            return response;
        } catch (error) {
            console.error('Error al obtener usuario:', error);
            return {
                success: false,
                message: 'Error de conexión con el servidor'
            };
        }
    }

    /**
     * Crear nuevo usuario (solo administradores)
     * @param {Object} userData - Datos del usuario
     * @returns {Promise<Object>} Respuesta de la API
     */
    async createUser(userData) {
        try {
            const response = await APIClient.post('/users/create', userData);
            return response;
        } catch (error) {
            console.error('Error al crear usuario:', error);
            return {
                success: false,
                message: 'Error de conexión con el servidor'
            };
        }
    }

    /**
     * Actualizar usuario (solo administradores)
     * @param {number} id - ID del usuario
     * @param {Object} userData - Datos a actualizar
     * @returns {Promise<Object>} Respuesta de la API
     */
    async updateUser(id, userData) {
        try {
            const response = await APIClient.put(`/users/${id}`, userData);
            return response;
        } catch (error) {
            console.error('Error al actualizar usuario:', error);
            return {
                success: false,
                message: 'Error de conexión con el servidor'
            };
        }
    }

    /**
     * Eliminar usuario (solo administradores)
     * @param {number} id - ID del usuario
     * @returns {Promise<Object>} Respuesta de la API
     */
    async deleteUser(id) {
        try {
            const response = await APIClient.delete(`/users/${id}`);
            return response;
        } catch (error) {
            console.error('Error al eliminar usuario:', error);
            return {
                success: false,
                message: 'Error de conexión con el servidor'
            };
        }
    }

    /**
     * Obtener estadísticas de usuarios (solo administradores)
     * @returns {Promise<Object>} Respuesta de la API
     */
    async getUserStats() {
        try {
            const response = await APIClient.get('/users/stats');
            return response;
        } catch (error) {
            console.error('Error al obtener estadísticas:', error);
            return {
                success: false,
                message: 'Error de conexión con el servidor'
            };
        }
    }

    /**
     * Obtener proyectos asignados a un usuario
     * @param {number} userId - ID del usuario
     * @returns {Promise<Object>} Respuesta de la API
     */
    async getUserProjects(userId) {
        try {
            const response = await APIClient.get(`/users/${userId}/projects`);
            return response;
        } catch (error) {
            console.error('Error al obtener proyectos del usuario:', error);
            return {
                success: false,
                message: 'Error de conexión con el servidor'
            };
        }
    }

    /**
     * Obtener tareas asignadas a un usuario
     * @param {number} userId - ID del usuario
     * @returns {Promise<Object>} Respuesta de la API
     */
    async getUserTasks(userId) {
        try {
            const response = await APIClient.get(`/users/${userId}/tasks`);
            return response;
        } catch (error) {
            console.error('Error al obtener tareas del usuario:', error);
            return {
                success: false,
                message: 'Error de conexión con el servidor'
            };
        }
    }

    /**
     * Formatear fecha para mostrar
     * @param {string} dateString - Fecha en formato ISO
     * @returns {string} Fecha formateada
     */
    formatDate(dateString) {
        if (!dateString) return 'N/A';
        
        const date = new Date(dateString);
        return date.toLocaleDateString('es-ES', {
            year: 'numeric',
            month: 'long',
            day: 'numeric'
        });
    }

    /**
     * Formatear fecha y hora para mostrar
     * @param {string} dateString - Fecha en formato ISO
     * @returns {string} Fecha y hora formateada
     */
    formatDateTime(dateString) {
        if (!dateString) return 'Nunca';
        
        const date = new Date(dateString);
        return date.toLocaleString('es-ES', {
            year: 'numeric',
            month: 'short',
            day: 'numeric',
            hour: '2-digit',
            minute: '2-digit'
        });
    }

    /**
     * Obtener clase CSS para el rol
     * @param {number} roleId - ID del rol
     * @returns {string} Clase CSS
     */
    getRoleClass(roleId) {
        switch (roleId) {
            case 1:
                return 'role-admin';
            case 2:
                return 'role-coordinator';
            case 3:
                return 'role-participant';
            default:
                return 'role-participant';
        }
    }

    /**
     * Obtener nombre del rol
     * @param {number} roleId - ID del rol
     * @returns {string} Nombre del rol
     */
    getRoleName(roleId) {
        switch (roleId) {
            case 1:
                return 'Administrador';
            case 2:
                return 'Coordinador';
            case 3:
                return 'Participante';
            default:
                return 'Sin rol';
        }
    }

    /**
     * Obtener clase CSS para el estado
     * @param {number} active - Estado del usuario (1 = activo, 0 = inactivo)
     * @returns {string} Clase CSS
     */
    getStatusClass(active) {
        return active == 1 ? 'status-active' : 'status-inactive';
    }

    /**
     * Obtener texto del estado
     * @param {number} active - Estado del usuario (1 = activo, 0 = inactivo)
     * @returns {string} Texto del estado
     */
    getStatusText(active) {
        return active == 1 ? 'Activo' : 'Inactivo';
    }

    /**
     * Validar datos de usuario
     * @param {Object} userData - Datos del usuario
     * @param {boolean} isUpdate - Si es una actualización
     * @returns {Object} Resultado de la validación
     */
    validateUserData(userData, isUpdate = false) {
        const errors = [];

        // Validar nombre
        if (!userData.name || userData.name.trim().length < 2) {
            errors.push('El nombre debe tener al menos 2 caracteres');
        }

        // Validar email
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!userData.email || !emailRegex.test(userData.email)) {
            errors.push('El email no tiene un formato válido');
        }

        // Validar username
        if (!userData.user || userData.user.trim().length < 3) {
            errors.push('El nombre de usuario debe tener al menos 3 caracteres');
        }

        // Validar contraseña (solo si no es actualización o si se proporciona)
        if (!isUpdate || userData.password) {
            if (!userData.password || userData.password.length < 4) {
                errors.push('La contraseña debe tener al menos 4 caracteres');
            }
        }

        // Validar rol
        if (!userData.role_id || ![1, 2, 3].includes(parseInt(userData.role_id))) {
            errors.push('Debe seleccionar un rol válido');
        }

        return {
            isValid: errors.length === 0,
            errors: errors
        };
    }

    /**
     * Generar avatar aleatorio
     * @param {string} name - Nombre del usuario
     * @returns {string} URL del avatar
     */
    generateRandomAvatar(name) {
        const seed = name.split('').reduce((acc, char) => acc + char.charCodeAt(0), 0);
        const avatarId = (seed % 70) + 1;
        return `https://i.pravatar.cc/150?img=${avatarId}`;
    }

    /**
     * Obtener iniciales del nombre
     * @param {string} name - Nombre completo
     * @returns {string} Iniciales
     */
    getInitials(name) {
        if (!name) return '?';
        
        const words = name.trim().split(' ');
        if (words.length === 1) {
            return words[0].charAt(0).toUpperCase();
        }
        
        return (words[0].charAt(0) + words[words.length - 1].charAt(0)).toUpperCase();
    }

    /**
     * Filtrar usuarios por criterios
     * @param {Array} users - Lista de usuarios
     * @param {Object} filters - Criterios de filtrado
     * @returns {Array} Usuarios filtrados
     */
    filterUsers(users, filters) {
        return users.filter(user => {
            // Filtro por rol
            if (filters.role && user.role_id != filters.role) {
                return false;
            }

            // Filtro por estado
            if (filters.status !== undefined && user.active != filters.status) {
                return false;
            }

            // Filtro por búsqueda
            if (filters.search) {
                const searchTerm = filters.search.toLowerCase();
                const searchableFields = [
                    user.name,
                    user.email,
                    user.user,
                    user.position_name || ''
                ];
                
                const matchesSearch = searchableFields.some(field => 
                    field.toLowerCase().includes(searchTerm)
                );
                
                if (!matchesSearch) {
                    return false;
                }
            }

            return true;
        });
    }

    /**
     * Ordenar usuarios por criterio
     * @param {Array} users - Lista de usuarios
     * @param {string} sortBy - Campo por el cual ordenar
     * @param {string} sortOrder - Orden (asc/desc)
     * @returns {Array} Usuarios ordenados
     */
    sortUsers(users, sortBy = 'created_at', sortOrder = 'desc') {
        return users.sort((a, b) => {
            let aValue = a[sortBy];
            let bValue = b[sortBy];

            // Manejar valores nulos
            if (aValue === null || aValue === undefined) aValue = '';
            if (bValue === null || bValue === undefined) bValue = '';

            // Convertir a string para comparación
            aValue = String(aValue).toLowerCase();
            bValue = String(bValue).toLowerCase();

            if (sortOrder === 'asc') {
                return aValue.localeCompare(bValue);
            } else {
                return bValue.localeCompare(aValue);
            }
        });
    }
}

export default new UserService();
