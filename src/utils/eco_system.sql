-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 11-10-2025 a las 15:43:18
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `eco_system`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `GenerateFinancialReport` (IN `project_id` INT, IN `period` VARCHAR(20))   BEGIN
    DECLARE total_budget DECIMAL(15,2) DEFAULT 0;
    DECLARE total_spent DECIMAL(15,2) DEFAULT 0;
    DECLARE variance DECIMAL(15,2) DEFAULT 0;
    
    -- Obtener presupuesto total
    SELECT COALESCE(SUM(allocated_amount), 0) INTO total_budget
    FROM budgets 
    WHERE project_id = project_id AND status = 'active';
    
    -- Obtener gastos aprobados
    SELECT COALESCE(SUM(amount), 0) INTO total_spent
    FROM expenses 
    WHERE project_id = project_id AND status = 'approved';
    
    -- Calcular varianza
    SET variance = total_budget - total_spent;
    
    -- Insertar reporte
    INSERT INTO financial_reports (project_id, period, total_budget, total_spent, generated_by)
    VALUES (project_id, period, total_budget, total_spent, 1);
    
    -- Retornar datos del reporte
    SELECT project_id, period, total_budget, total_spent, variance;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateProjectProgress` (IN `project_id` INT)   BEGIN
    DECLARE total_tasks INT DEFAULT 0;
    DECLARE completed_tasks INT DEFAULT 0;
    DECLARE new_progress INT DEFAULT 0;
    
    -- Contar tareas totales y completadas
    SELECT COUNT(*), SUM(CASE WHEN status = 'Completada' THEN 1 ELSE 0 END)
    INTO total_tasks, completed_tasks
    FROM tasks 
    WHERE project_id = project_id;
    
    -- Calcular progreso
    IF total_tasks > 0 THEN
        SET new_progress = ROUND((completed_tasks / total_tasks) * 100);
    END IF;
    
    -- Actualizar el proyecto
    UPDATE projects 
    SET progress = new_progress, updated_at = CURRENT_TIMESTAMP
    WHERE id = project_id;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `attachments`
--

CREATE TABLE `attachments` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `size` int(11) NOT NULL,
  `type` varchar(100) NOT NULL,
  `file_path` varchar(500) NOT NULL,
  `comment_id` int(11) DEFAULT NULL,
  `project_id` int(11) DEFAULT NULL,
  `uploaded_by` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `budgets`
--

CREATE TABLE `budgets` (
  `id` int(11) NOT NULL,
  `project_id` int(11) NOT NULL,
  `total_amount` decimal(15,2) NOT NULL,
  `allocated_amount` decimal(15,2) NOT NULL,
  `spent_amount` decimal(15,2) DEFAULT 0.00,
  `remaining_amount` decimal(15,2) GENERATED ALWAYS AS (`allocated_amount` - `spent_amount`) STORED,
  `currency` varchar(3) DEFAULT 'USD',
  `status` enum('active','inactive','completed') DEFAULT 'active',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `budgets`
--

INSERT INTO `budgets` (`id`, `project_id`, `total_amount`, `allocated_amount`, `spent_amount`, `currency`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 50000.00, 45000.00, 12500.00, 'USD', 'active', '2025-09-23 02:45:43', '2025-09-23 02:45:43'),
(2, 2, 75000.00, 70000.00, 28000.00, 'USD', 'active', '2025-09-23 02:45:43', '2025-09-23 02:45:43'),
(3, 3, 30000.00, 25000.00, 5000.00, 'USD', 'active', '2025-09-23 02:45:43', '2025-09-23 02:45:43');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `comments`
--

CREATE TABLE `comments` (
  `id` int(11) NOT NULL,
  `project_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `content` text NOT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `expenses`
--

CREATE TABLE `expenses` (
  `id` int(11) NOT NULL,
  `budget_id` int(11) NOT NULL,
  `project_id` int(11) NOT NULL,
  `task_id` int(11) DEFAULT NULL,
  `amount` decimal(15,2) NOT NULL,
  `category_id` int(11) NOT NULL,
  `description` text NOT NULL,
  `date` date NOT NULL,
  `approved_by` int(11) DEFAULT NULL,
  `status` enum('pending','approved','rejected') DEFAULT 'pending',
  `vendor` varchar(200) DEFAULT NULL,
  `receipt_number` varchar(100) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `expenses`
--

INSERT INTO `expenses` (`id`, `budget_id`, `project_id`, `task_id`, `amount`, `category_id`, `description`, `date`, `approved_by`, `status`, `vendor`, `receipt_number`, `created_at`, `updated_at`) VALUES
(1, 1, 1, NULL, 2500.00, 1, 'Compra de sensores de CO2 para medición de emisiones', '2024-11-15', 1, 'approved', 'EcoSensors Corp', 'INV-001-2024', '2025-09-23 02:45:43', '2025-09-23 02:45:43'),
(2, 1, 1, NULL, 1200.00, 7, 'Análisis de laboratorio para muestras de aire', '2024-11-20', 1, 'approved', 'LabGreen Solutions', 'LAB-002-2024', '2025-09-23 02:45:43', '2025-09-23 02:45:43'),
(3, 2, 2, NULL, 8500.00, 2, 'Materiales sustentables para pared verde', '2024-11-25', 2, 'approved', 'GreenMaterials Inc', 'MAT-003-2024', '2025-09-23 02:45:43', '2025-09-23 02:45:43');

--
-- Disparadores `expenses`
--
DELIMITER $$
CREATE TRIGGER `update_budget_spent_on_expense_approval` AFTER UPDATE ON `expenses` FOR EACH ROW BEGIN
    IF NEW.status = 'approved' AND OLD.status != 'approved' THEN
        UPDATE budgets 
        SET spent_amount = spent_amount + NEW.amount,
            updated_at = CURRENT_TIMESTAMP
        WHERE id = NEW.budget_id;
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `expense_categories`
--

CREATE TABLE `expense_categories` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `icon` varchar(10) DEFAULT NULL,
  `color` varchar(7) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `expense_categories`
--

INSERT INTO `expense_categories` (`id`, `name`, `icon`, `color`, `description`, `created_at`) VALUES
(1, 'Equipos de Medición', '📊', '#2196f3', 'Sensores y equipos de monitoreo', '2025-09-23 02:45:43'),
(2, 'Materiales Sustentables', '🌱', '#4caf50', 'Materiales ecológicos y sostenibles', '2025-09-23 02:45:43'),
(3, 'Certificaciones Ambientales', '🏆', '#ff9800', 'Certificaciones y auditorías', '2025-09-23 02:45:43'),
(4, 'Consultoría Especializada', '👥', '#9c27b0', 'Servicios de consultoría', '2025-09-23 02:45:43'),
(5, 'Transporte Ecológico', '🚗', '#00bcd4', 'Transporte sostenible', '2025-09-23 02:45:43'),
(6, 'Energía Renovable', '⚡', '#ffeb3b', 'Sistemas de energía renovable', '2025-09-23 02:45:43'),
(7, 'Análisis de Laboratorio', '🧪', '#e91e63', 'Servicios de laboratorio', '2025-09-23 02:45:43'),
(8, 'Sensores IoT', '📡', '#795548', 'Tecnología IoT y sensores', '2025-09-23 02:45:43'),
(9, 'Capacitación', '🎓', '#607d8b', 'Formación y capacitación', '2025-09-23 02:45:43'),
(10, 'Otros', '📦', '#9e9e9e', 'Otros gastos diversos', '2025-09-23 02:45:43');

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `expense_details`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `expense_details` (
`id` int(11)
,`amount` decimal(15,2)
,`description` text
,`date` date
,`status` enum('pending','approved','rejected')
,`vendor` varchar(200)
,`receipt_number` varchar(100)
,`project_name` varchar(200)
,`category_name` varchar(100)
,`category_icon` varchar(10)
,`category_color` varchar(7)
,`budget_total` decimal(15,2)
,`budget_spent` decimal(15,2)
,`approved_by_name` varchar(100)
,`created_at` timestamp
);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `financial_reports`
--

CREATE TABLE `financial_reports` (
  `id` int(11) NOT NULL,
  `project_id` int(11) NOT NULL,
  `period` varchar(20) NOT NULL,
  `total_budget` decimal(15,2) NOT NULL,
  `total_spent` decimal(15,2) NOT NULL,
  `variance` decimal(15,2) GENERATED ALWAYS AS (`total_budget` - `total_spent`) STORED,
  `efficiency_metrics` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`efficiency_metrics`)),
  `generated_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `generated_by` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `metrics`
--

CREATE TABLE `metrics` (
  `id` int(11) NOT NULL,
  `name` varchar(200) NOT NULL,
  `project_id` int(11) NOT NULL,
  `metric_type_id` int(11) DEFAULT NULL,
  `unit` varchar(50) NOT NULL,
  `target_value` decimal(15,2) DEFAULT NULL,
  `current_value` decimal(15,2) DEFAULT 0.00,
  `description` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `metrics`
--

INSERT INTO `metrics` (`id`, `name`, `project_id`, `metric_type_id`, `unit`, `target_value`, `current_value`, `description`, `created_at`, `updated_at`) VALUES
(1, 'Reducción de Emisiones CO2', 1, 1, 'kg CO2', 1200.00, 340.00, 'Meta de reducción de emisiones de carbono del proyecto', '2025-09-23 02:45:43', '2025-09-23 02:45:43'),
(2, 'Eficiencia Energética', 1, 2, 'kWh', 5000.00, 1850.00, 'Ahorro energético esperado del proyecto', '2025-09-23 02:45:43', '2025-09-23 02:45:43'),
(3, 'Presupuesto Utilizado', 1, NULL, '€', 15000.00, 8500.00, 'Presupuesto ejecutado vs presupuesto total', '2025-09-23 02:45:43', '2025-09-23 02:45:43'),
(4, 'Progreso del Proyecto', 1, NULL, '%', 100.00, 65.00, 'Porcentaje de avance del proyecto', '2025-09-23 02:45:43', '2025-09-23 02:45:43'),
(5, 'Absorción de CO2', 2, 1, 'kg CO2', 800.00, 0.00, 'CO2 absorbido por las plantas instaladas', '2025-09-23 02:45:43', '2025-09-23 02:45:43'),
(6, 'Consumo Eléctrico', 2, 2, 'kWh', 2000.00, 0.00, 'Consumo energético del sistema de riego', '2025-09-23 02:45:43', '2025-09-23 02:45:43'),
(7, 'Inversión Total', 2, NULL, '€', 25000.00, 3200.00, 'Inversión total en la pared verde', '2025-09-23 02:45:43', '2025-09-23 02:45:43'),
(8, 'Avance de Implementación', 2, NULL, '%', 100.00, 15.00, 'Porcentaje de implementación de la pared verde', '2025-09-23 02:45:43', '2025-09-23 02:45:43');

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `metric_details`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `metric_details` (
`id` int(11)
,`name` varchar(200)
,`unit` varchar(50)
,`target_value` decimal(15,2)
,`current_value` decimal(15,2)
,`description` text
,`project_name` varchar(200)
,`project_status` enum('Planificación','En progreso','Completado','Cancelado','En pausa')
,`metric_type_name` varchar(100)
,`category` varchar(50)
,`created_at` timestamp
);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `metric_history`
--

CREATE TABLE `metric_history` (
  `id` int(11) NOT NULL,
  `metric_id` int(11) NOT NULL,
  `value` decimal(15,2) NOT NULL,
  `recorded_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `recorded_by` int(11) DEFAULT NULL,
  `notes` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `metric_types`
--

CREATE TABLE `metric_types` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `unit` varchar(50) NOT NULL,
  `category` varchar(50) NOT NULL,
  `description` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `metric_types`
--

INSERT INTO `metric_types` (`id`, `name`, `unit`, `category`, `description`, `created_at`) VALUES
(1, 'Emisiones CO2', 'toneladas', 'Carbono', 'Medición de emisiones de dióxido de carbono', '2025-09-23 02:45:43'),
(2, 'Consumo Energético', 'kWh', 'Energía', 'Consumo de energía eléctrica', '2025-09-23 02:45:43'),
(3, 'Consumo de Agua', 'litros', 'Agua', 'Consumo de recursos hídricos', '2025-09-23 02:45:43'),
(4, 'Residuos Generados', 'kg', 'Residuos', 'Cantidad de residuos producidos', '2025-09-23 02:45:43'),
(5, 'Área Verde', 'm²', 'Biodiversidad', 'Superficie de áreas verdes', '2025-09-23 02:45:43');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `milestones`
--

CREATE TABLE `milestones` (
  `id` int(11) NOT NULL,
  `title` varchar(200) NOT NULL,
  `description` text DEFAULT NULL,
  `date` date NOT NULL,
  `project_id` int(11) NOT NULL,
  `task_id` int(11) DEFAULT NULL,
  `completed` tinyint(1) DEFAULT 0,
  `completed_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `milestones`
--

INSERT INTO `milestones` (`id`, `title`, `description`, `date`, `project_id`, `task_id`, `completed`, `completed_at`, `created_at`) VALUES
(1, 'Nombre del evento aprobado', 'Hito clave: Nombre oficial del evento definido y aprobado', '2025-09-06', 1, 1, 1, NULL, '2025-09-23 02:45:43'),
(2, 'Presupuesto finalizado', 'Hito financiero: Presupuesto completo aprobado', '2025-09-07', 1, 2, 0, NULL, '2025-09-23 02:45:43'),
(3, 'Sensores instalados', 'Hito técnico: Sistema de sensores completamente instalado', '2025-09-20', 2, 5, 0, NULL, '2025-09-23 02:45:43');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `notifications`
--

CREATE TABLE `notifications` (
  `id` int(11) NOT NULL,
  `type` varchar(50) NOT NULL,
  `title` varchar(200) NOT NULL,
  `message` text NOT NULL,
  `user_id` int(11) NOT NULL,
  `project_id` int(11) DEFAULT NULL,
  `task_id` int(11) DEFAULT NULL,
  `priority` enum('low','normal','high','urgent') DEFAULT 'normal',
  `is_read` tinyint(1) DEFAULT 0,
  `sender_name` varchar(100) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `positions`
--

CREATE TABLE `positions` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `department` varchar(100) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `positions`
--

INSERT INTO `positions` (`id`, `name`, `description`, `department`, `created_at`, `updated_at`) VALUES
(1, 'Director Ejecutivo', 'Responsable de la dirección estratégica', 'Administración', '2025-09-23 02:45:43', '2025-09-23 02:45:43'),
(2, 'Coordinador de Proyectos', 'Gestión y coordinación de proyectos', 'Gestión de Proyectos', '2025-09-23 02:45:43', '2025-09-23 02:45:43'),
(3, 'Especialista en Energía', 'Experto en sistemas energéticos', 'Sostenibilidad', '2025-09-23 02:45:43', '2025-09-23 02:45:43'),
(4, 'Analista Ambiental', 'Análisis de impacto ambiental', 'Sostenibilidad', '2025-09-23 02:45:43', '2025-09-23 02:45:43'),
(5, 'Investigador', 'Investigación y desarrollo', 'I+D', '2025-09-23 02:45:43', '2025-09-23 02:45:43'),
(6, 'Consultor', 'Consultoría especializada', 'Consultoría', '2025-09-23 02:45:43', '2025-09-23 02:45:43');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `projects`
--

CREATE TABLE `projects` (
  `id` int(11) NOT NULL,
  `name` varchar(200) NOT NULL,
  `description` text DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `status` enum('Planificación','En progreso','Completado','Cancelado','En pausa') DEFAULT 'Planificación',
  `creator_id` int(11) NOT NULL,
  `budget` decimal(15,2) DEFAULT 0.00,
  `progress` int(11) DEFAULT 0,
  `priority` enum('Baja','Media','Alta','Crítica') DEFAULT 'Media',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `projects`
--

INSERT INTO `projects` (`id`, `name`, `description`, `start_date`, `end_date`, `status`, `creator_id`, `budget`, `progress`, `priority`, `created_at`, `updated_at`) VALUES
(1, 'Tesis Huella de Carbono', 'Investigación sobre la huella de carbono en procesos industriales', '2025-08-01', '2025-12-31', 'En progreso', 2, 50000.00, 65, 'Media', '2025-09-23 02:45:43', '2025-09-23 02:45:43'),
(2, 'Pared Verde Sustentable', 'Implementación de muros verdes para reducir la temperatura urbana', '2025-09-01', '2026-02-28', 'En progreso', 2, 75000.00, 30, 'Media', '2025-09-23 02:45:43', '2025-09-23 02:45:43'),
(3, 'Tesis Huella Hídrica', 'Análisis del consumo de agua en la agricultura local', '2025-10-01', '2026-03-31', 'Planificación', 2, 30000.00, 10, 'Media', '2025-09-23 02:45:43', '2025-09-23 02:45:43');

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `project_details`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `project_details` (
`id` int(11)
,`name` varchar(200)
,`description` text
,`start_date` date
,`end_date` date
,`status` enum('Planificación','En progreso','Completado','Cancelado','En pausa')
,`budget` decimal(15,2)
,`progress` int(11)
,`priority` enum('Baja','Media','Alta','Crítica')
,`coordinator_name` varchar(100)
,`coordinator_email` varchar(100)
,`participant_count` bigint(21)
,`created_at` timestamp
);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `project_files`
--

CREATE TABLE `project_files` (
  `id` int(11) NOT NULL,
  `project_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `size` int(11) NOT NULL,
  `type` varchar(100) NOT NULL,
  `file_path` varchar(500) NOT NULL,
  `uploaded_by` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `project_users`
--

CREATE TABLE `project_users` (
  `id` int(11) NOT NULL,
  `project_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `assigned_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `assigned_by` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `project_users`
--

INSERT INTO `project_users` (`id`, `project_id`, `user_id`, `assigned_at`, `assigned_by`) VALUES
(1, 1, 3, '2025-09-23 02:45:43', 2),
(2, 1, 4, '2025-09-23 02:45:43', 2),
(3, 2, 3, '2025-09-23 02:45:43', 2),
(4, 2, 4, '2025-09-23 02:45:43', 2),
(5, 3, 3, '2025-09-23 02:45:43', 2),
(6, 3, 4, '2025-09-23 02:45:43', 2);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `resource_allocations`
--

CREATE TABLE `resource_allocations` (
  `id` int(11) NOT NULL,
  `project_id` int(11) NOT NULL,
  `resource_type` varchar(100) NOT NULL,
  `allocated_amount` decimal(15,2) NOT NULL,
  `used_amount` decimal(15,2) DEFAULT 0.00,
  `cost_per_unit` decimal(10,2) DEFAULT NULL,
  `efficiency_rating` decimal(5,2) DEFAULT NULL,
  `allocation_date` date NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `roles`
--

CREATE TABLE `roles` (
  `id` int(11) NOT NULL,
  `name` varchar(50) NOT NULL,
  `permissions` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`permissions`)),
  `description` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `roles`
--

INSERT INTO `roles` (`id`, `name`, `permissions`, `description`, `created_at`, `updated_at`) VALUES
(1, 'Administrador', '[\"all\"]', 'Acceso completo al sistema', '2025-09-23 02:45:43', '2025-09-23 02:45:43'),
(2, 'Coordinador', '[\"manage_projects\", \"manage_tasks\", \"view_metrics\"]', 'Gestión de proyectos y tareas', '2025-09-23 02:45:43', '2025-09-23 02:45:43'),
(3, 'Participante', '[\"view_tasks\", \"update_task_status\"]', 'Participación en proyectos', '2025-09-23 02:45:43', '2025-09-23 02:45:43');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tasks`
--

CREATE TABLE `tasks` (
  `id` int(11) NOT NULL,
  `title` varchar(200) NOT NULL,
  `description` text DEFAULT NULL,
  `status` enum('Pendiente','En progreso','Completada','Cancelada') DEFAULT 'Pendiente',
  `priority` enum('Baja','Media','Alta','Crítica') DEFAULT 'Media',
  `due_date` date DEFAULT NULL,
  `project_id` int(11) NOT NULL,
  `created_by` int(11) NOT NULL,
  `progress` int(11) DEFAULT 0,
  `estimated_hours` int(11) DEFAULT 0,
  `actual_hours` int(11) DEFAULT 0,
  `tags` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`tags`)),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `tasks`
--

INSERT INTO `tasks` (`id`, `title`, `description`, `status`, `priority`, `due_date`, `project_id`, `created_by`, `progress`, `estimated_hours`, `actual_hours`, `tags`, `created_at`, `updated_at`) VALUES
(1, 'Finalizar nombre del evento', 'Definir y aprobar el nombre final para el evento de sostenibilidad', 'Completada', 'Alta', '2025-08-15', 1, 2, 100, 8, 8, '[\"branding\", \"evento\"]', '2025-09-23 02:45:43', '2025-09-23 02:45:43'),
(2, 'Finalizar presupuesto del evento', 'Completar el presupuesto detallado para todas las actividades del evento', 'En progreso', 'Crítica', '2025-09-20', 1, 2, 75, 16, 12, '[\"finanzas\", \"evento\"]', '2025-09-23 02:45:43', '2025-09-23 02:45:43'),
(3, 'Proponer 3 ideas de keynote para conferencia', 'Desarrollar y presentar tres propuestas de temas principales para la conferencia', 'En progreso', 'Alta', '2025-10-15', 1, 2, 60, 12, 7, '[\"contenido\", \"conferencia\"]', '2025-09-23 02:45:43', '2025-09-23 02:45:43'),
(4, 'Análisis de Emisiones CO2', 'Realizar medición y análisis de las emisiones de carbono del proyecto', 'En progreso', 'Alta', '2025-10-20', 2, 2, 45, 24, 11, '[\"análisis\", \"emisiones\", \"CO2\"]', '2025-09-23 02:45:43', '2025-09-23 02:45:43'),
(5, 'Instalación de Sensores', 'Colocar sensores de monitoreo ambiental en las ubicaciones designadas', 'Pendiente', 'Media', '2025-11-25', 2, 2, 10, 32, 3, '[\"instalación\", \"sensores\", \"hardware\"]', '2025-09-23 02:45:43', '2025-09-23 02:45:43');

--
-- Disparadores `tasks`
--
DELIMITER $$
CREATE TRIGGER `update_project_progress_on_task_completion` AFTER UPDATE ON `tasks` FOR EACH ROW BEGIN
    IF NEW.status = 'Completada' AND OLD.status != 'Completada' THEN
        CALL UpdateProjectProgress(NEW.project_id);
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `task_assignments`
--

CREATE TABLE `task_assignments` (
  `id` int(11) NOT NULL,
  `task_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `assigned_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `assigned_by` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `task_assignments`
--

INSERT INTO `task_assignments` (`id`, `task_id`, `user_id`, `assigned_at`, `assigned_by`) VALUES
(1, 1, 3, '2025-09-23 02:45:43', 2),
(2, 2, 4, '2025-09-23 02:45:43', 2),
(3, 3, 3, '2025-09-23 02:45:43', 2),
(4, 4, 3, '2025-09-23 02:45:43', 2),
(5, 4, 4, '2025-09-23 02:45:43', 2),
(6, 5, 3, '2025-09-23 02:45:43', 2);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `task_dependencies`
--

CREATE TABLE `task_dependencies` (
  `id` int(11) NOT NULL,
  `from_task_id` int(11) NOT NULL,
  `to_task_id` int(11) NOT NULL,
  `dependency_type` enum('finish-to-start','start-to-start','finish-to-finish','start-to-finish') DEFAULT 'finish-to-start',
  `description` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `task_details`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `task_details` (
`id` int(11)
,`title` varchar(200)
,`description` text
,`status` enum('Pendiente','En progreso','Completada','Cancelada')
,`priority` enum('Baja','Media','Alta','Crítica')
,`due_date` date
,`progress` int(11)
,`estimated_hours` int(11)
,`actual_hours` int(11)
,`project_name` varchar(200)
,`project_status` enum('Planificación','En progreso','Completado','Cancelado','En pausa')
,`created_by_name` varchar(100)
,`assigned_users` mediumtext
,`created_at` timestamp
);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `user` varchar(15) NOT NULL,
  `password` varchar(255) NOT NULL,
  `role_id` int(11) NOT NULL,
  `position_id` int(11) DEFAULT NULL,
  `avatar` varchar(255) DEFAULT NULL,
  `active` tinyint(1) DEFAULT 1,
  `last_login` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `users`
--

INSERT INTO `users` (`id`, `name`, `email`, `user`, `password`, `role_id`, `position_id`, `avatar`, `active`, `last_login`, `created_at`, `updated_at`) VALUES
(1, 'Andrea Rodríguez', 'admin@eco.com', 'admin', '827ccb0eea8a706c4c34a16891f84e7b', 1, 1, 'https://i.pravatar.cc/150?img=1', 1, '2025-10-09 04:48:54', '2025-09-23 02:45:43', '2025-10-09 04:48:54'),
(2, 'Carlos Mendoza', 'coordinator@eco.com', 'coord', 'ca58303368b17874228d4c6e4d57c0d6', 2, 2, 'https://i.pravatar.cc/150?img=2', 1, '2025-10-09 01:02:10', '2025-09-23 02:45:43', '2025-10-09 01:02:10'),
(3, 'Elena Silva', 'participant@eco.com', 'part', '$2y$10$405gnwmD0p78vZRB4mDJguJcc/dOyo0XnYqaqtwf2smcU39oyNAxi', 3, 3, 'https://i.pravatar.cc/150?img=3', 1, '2025-10-09 01:48:47', '2025-09-23 02:45:43', '2025-10-09 01:48:47'),
(4, 'Miguel Torres', 'miguel@eco.com', 'mtorres', '$2y$10$CGSssAjDYolMbVtmo1ieY.5MoK/FQzk9XfnOhxLcNAg34uf90YdPG', 3, 4, 'https://i.pravatar.cc/150?img=4', 1, NULL, '2025-09-23 02:45:43', '2025-10-04 19:36:41');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `user_activities`
--

CREATE TABLE `user_activities` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `activity_type` varchar(50) NOT NULL,
  `details` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`details`)),
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `user_activities`
--

INSERT INTO `user_activities` (`id`, `user_id`, `activity_type`, `details`, `timestamp`) VALUES
(1, 1, 'login', NULL, '2025-09-23 04:01:28'),
(2, 1, 'login', NULL, '2025-09-23 04:02:34'),
(3, 1, 'login', NULL, '2025-09-23 04:04:21'),
(4, 1, 'login', NULL, '2025-09-23 04:04:21'),
(5, 1, 'login', NULL, '2025-09-23 04:05:37'),
(6, 1, 'login', NULL, '2025-09-23 04:07:42'),
(7, 1, 'login', NULL, '2025-09-23 04:12:06'),
(8, 1, 'login', NULL, '2025-09-23 04:12:41'),
(9, 1, 'login', NULL, '2025-09-23 04:12:49'),
(10, 1, 'login', NULL, '2025-09-23 04:13:02'),
(11, 1, 'login', NULL, '2025-09-23 04:13:26'),
(12, 1, 'login', NULL, '2025-09-23 04:13:51'),
(13, 3, 'login', NULL, '2025-09-23 04:14:11'),
(14, 1, 'login', NULL, '2025-09-23 04:14:21'),
(15, 1, 'login', NULL, '2025-09-23 04:19:44'),
(16, 2, 'login', NULL, '2025-09-23 04:25:47'),
(17, 1, 'login', NULL, '2025-09-24 01:25:39'),
(18, 1, 'login', NULL, '2025-09-24 01:30:44'),
(19, 3, 'login', NULL, '2025-09-24 01:31:14'),
(20, 1, 'login', NULL, '2025-09-24 01:34:02'),
(21, 1, 'login', NULL, '2025-09-24 01:46:27'),
(22, 1, 'login', NULL, '2025-10-01 00:22:39'),
(23, 1, 'login', NULL, '2025-10-01 00:23:36'),
(24, 1, 'login', NULL, '2025-10-01 00:25:59'),
(25, 3, 'login', NULL, '2025-10-01 00:26:32'),
(26, 1, 'login', NULL, '2025-10-01 00:26:42'),
(27, 1, 'login', NULL, '2025-10-01 00:26:59'),
(28, 3, 'login', NULL, '2025-10-01 00:32:05'),
(29, 1, 'login', NULL, '2025-10-01 00:32:34'),
(30, 1, 'login', NULL, '2025-10-01 00:35:04'),
(31, 1, 'login', NULL, '2025-10-01 00:48:26'),
(32, 1, 'login', NULL, '2025-10-01 00:54:40'),
(33, 3, 'login', NULL, '2025-10-01 00:55:21'),
(34, 1, 'login', NULL, '2025-10-01 00:58:54'),
(35, 3, 'login', NULL, '2025-10-01 00:59:04'),
(36, 1, 'login', NULL, '2025-10-01 00:59:08'),
(37, 1, 'login', NULL, '2025-10-01 01:03:19'),
(38, 1, 'login', NULL, '2025-10-01 01:03:31'),
(39, 1, 'login', NULL, '2025-10-01 01:11:32'),
(40, 2, 'login', NULL, '2025-10-01 01:11:37'),
(41, 1, 'login', NULL, '2025-10-01 01:12:07'),
(42, 1, 'login', NULL, '2025-10-01 01:12:20'),
(43, 1, 'login', NULL, '2025-10-01 01:16:45'),
(44, 1, 'login', NULL, '2025-10-01 01:16:51'),
(45, 1, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT; Windows NT 10.0; es-ES) WindowsPowerShell\\/5.1.26100.4202\"}', '2025-10-04 21:36:06'),
(46, 1, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-04 21:37:28'),
(47, 1, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-04 21:37:53'),
(48, 1, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT; Windows NT 10.0; es-ES) WindowsPowerShell\\/5.1.26100.4202\"}', '2025-10-04 21:38:45'),
(49, 1, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT; Windows NT 10.0; es-ES) WindowsPowerShell\\/5.1.26100.4202\"}', '2025-10-04 21:59:34'),
(50, 1, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-04 22:00:33'),
(51, 1, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-04 22:00:34'),
(52, 1, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-04 22:00:35'),
(53, 1, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-04 22:00:35'),
(54, 1, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-04 22:00:39'),
(55, 1, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-04 22:37:42'),
(56, 1, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT; Windows NT 10.0; es-ES) WindowsPowerShell\\/5.1.26100.4202\"}', '2025-10-04 22:39:04'),
(57, 1, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-04 22:40:48'),
(58, 1, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-04 22:41:03'),
(59, 1, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT; Windows NT 10.0; es-ES) WindowsPowerShell\\/5.1.26100.4202\"}', '2025-10-04 23:11:51'),
(60, 1, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-04 23:14:35'),
(61, 1, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-04 23:15:05'),
(62, 1, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-04 23:15:09'),
(63, 1, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-04 23:15:58'),
(64, 1, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-04 23:22:57'),
(65, 1, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-04 23:25:49'),
(66, 1, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-04 23:25:52'),
(67, 1, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-04 23:26:10'),
(68, 1, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-04 23:28:24'),
(69, 1, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-04 23:32:29'),
(70, 1, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-04 23:32:51'),
(71, 2, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-04 23:34:36'),
(72, 1, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-04 23:38:40'),
(73, 1, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-04 23:39:27'),
(74, 1, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-04 23:57:26'),
(75, 1, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-05 00:07:11'),
(76, 1, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-05 00:14:42'),
(77, 2, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-05 00:14:55'),
(78, 1, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-05 00:15:36'),
(79, 1, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT; Windows NT 10.0; es-ES) WindowsPowerShell\\/5.1.26100.4202\"}', '2025-10-05 00:22:59'),
(80, 1, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-05 00:28:10'),
(81, 2, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-05 00:28:43'),
(82, 2, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-05 00:28:56'),
(83, 1, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-05 00:29:05'),
(84, 1, 'login', '{\"ip\":\"unknown\",\"user_agent\":\"unknown\"}', '2025-10-05 00:33:59'),
(85, 1, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-05 00:43:45'),
(86, 1, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-05 00:55:58'),
(87, 1, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-05 00:59:03'),
(88, 1, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-05 01:16:59'),
(89, 1, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-05 01:23:56'),
(90, 1, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-05 21:41:53'),
(91, 1, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-05 22:00:44'),
(92, 1, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-05 22:01:15'),
(93, 1, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-05 22:02:37'),
(94, 1, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-05 22:04:14'),
(95, 1, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-05 22:27:19'),
(96, 1, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-05 22:27:21'),
(97, 1, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-05 22:36:07'),
(98, 1, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-05 22:38:14'),
(99, 1, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-05 22:38:30'),
(100, 1, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-05 22:38:45'),
(101, 1, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-05 22:42:53'),
(102, 1, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-05 22:49:02'),
(103, 1, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-05 22:52:17'),
(104, 1, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-05 22:52:21'),
(105, 1, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-05 23:10:52'),
(106, 1, 'login', '{\"ip\":\"unknown\",\"user_agent\":\"unknown\"}', '2025-10-05 23:24:14'),
(107, 1, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-05 23:25:38'),
(108, 1, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-05 23:25:56'),
(109, 1, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-05 23:28:28'),
(110, 1, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-05 23:41:37'),
(111, 1, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-05 23:44:33'),
(112, 1, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-05 23:45:39'),
(113, 1, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-05 23:49:03'),
(114, 1, 'login', '{\"ip\":\"unknown\",\"user_agent\":\"unknown\"}', '2025-10-05 23:51:12'),
(115, 1, 'login', '{\"ip\":\"unknown\",\"user_agent\":\"unknown\"}', '2025-10-05 23:51:26'),
(116, 1, 'login', '{\"ip\":\"unknown\",\"user_agent\":\"unknown\"}', '2025-10-05 23:52:24'),
(117, 1, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-05 23:53:26'),
(118, 2, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-05 23:54:46'),
(119, 2, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-05 23:55:15'),
(120, 1, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-05 23:57:08'),
(121, 1, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-05 23:57:36'),
(122, 2, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-05 23:57:50'),
(123, 2, 'logout', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-06 00:06:54'),
(124, 1, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-06 00:06:55'),
(125, 1, 'logout', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-06 00:07:01'),
(126, 1, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-06 00:08:35'),
(127, 1, 'logout', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-06 00:08:41'),
(128, 2, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-06 00:08:46'),
(129, 2, 'logout', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-06 00:08:49'),
(130, 1, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-06 00:16:06'),
(131, 1, 'logout', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-06 00:16:10'),
(132, 2, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-06 00:16:13'),
(133, 2, 'logout', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-06 00:21:26'),
(134, 1, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-06 00:21:27'),
(135, 1, 'logout', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-06 00:21:31'),
(136, 2, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-06 00:21:37'),
(137, 2, 'logout', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-06 00:21:55'),
(138, 1, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-06 00:21:58'),
(139, 1, 'logout', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-06 00:22:27'),
(140, 3, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-06 00:22:36'),
(141, 3, 'logout', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-06 00:23:28'),
(142, 2, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-06 00:23:34'),
(143, 2, 'logout', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-06 00:28:57'),
(144, 1, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-06 00:28:59'),
(145, 1, 'logout', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-06 00:29:06'),
(146, 3, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-06 00:29:11'),
(147, 3, 'logout', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-06 00:29:21'),
(148, 3, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-06 00:29:27'),
(149, 3, 'logout', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-06 00:29:34'),
(150, 2, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-06 00:29:39'),
(151, 2, 'logout', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-06 00:31:06'),
(152, 1, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-06 00:31:19'),
(153, 1, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-07 00:42:34'),
(154, 1, 'logout', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-07 01:02:41'),
(155, 1, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-07 01:02:42'),
(156, 1, 'logout', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-07 01:13:17'),
(157, 2, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-07 01:13:23'),
(158, 2, 'logout', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-07 01:13:45'),
(159, 3, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-07 01:13:51'),
(160, 3, 'logout', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-07 01:14:28'),
(161, 1, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-07 01:14:43'),
(162, 1, 'logout', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-07 01:22:31'),
(163, 1, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-07 01:22:35'),
(164, 1, 'logout', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-07 01:22:37'),
(165, 1, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-07 01:22:57'),
(166, 1, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-07 02:30:03'),
(167, 1, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-07 23:42:30'),
(168, 1, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-08 01:05:42'),
(169, 1, 'logout', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-08 01:20:06'),
(170, 1, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-09 00:09:05'),
(171, 1, 'logout', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-09 00:18:52'),
(172, 1, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-09 00:18:53'),
(173, 1, 'logout', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-09 00:18:58'),
(174, 1, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-09 00:19:00'),
(175, 1, 'logout', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-09 00:19:03'),
(176, 1, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-09 00:19:16'),
(177, 1, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-09 00:26:14'),
(178, 1, 'logout', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-09 01:02:03'),
(179, 1, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-09 01:02:03'),
(180, 1, 'logout', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-09 01:02:06'),
(181, 2, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-09 01:02:10'),
(182, 1, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-09 01:47:09'),
(183, 1, 'logout', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-09 01:48:19'),
(184, 3, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-09 01:48:26'),
(185, 3, 'logout', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-09 01:48:31'),
(186, 3, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-09 01:48:47'),
(187, 1, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-09 04:19:14'),
(188, 1, 'logout', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-09 04:19:17'),
(189, 1, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-09 04:48:47'),
(190, 1, 'logout', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-09 04:48:52'),
(191, 1, 'login', '{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}', '2025-10-09 04:48:54');

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `user_details`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `user_details` (
`id` int(11)
,`name` varchar(100)
,`email` varchar(100)
,`avatar` varchar(255)
,`active` tinyint(1)
,`last_login` timestamp
,`role_name` varchar(50)
,`permissions` longtext
,`position_name` varchar(100)
,`department` varchar(100)
,`created_at` timestamp
);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `user_sessions`
--

CREATE TABLE `user_sessions` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `token` varchar(255) NOT NULL,
  `expires_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura para la vista `expense_details`
--
DROP TABLE IF EXISTS `expense_details`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `expense_details`  AS SELECT `e`.`id` AS `id`, `e`.`amount` AS `amount`, `e`.`description` AS `description`, `e`.`date` AS `date`, `e`.`status` AS `status`, `e`.`vendor` AS `vendor`, `e`.`receipt_number` AS `receipt_number`, `p`.`name` AS `project_name`, `ec`.`name` AS `category_name`, `ec`.`icon` AS `category_icon`, `ec`.`color` AS `category_color`, `b`.`total_amount` AS `budget_total`, `b`.`spent_amount` AS `budget_spent`, `u`.`name` AS `approved_by_name`, `e`.`created_at` AS `created_at` FROM ((((`expenses` `e` left join `projects` `p` on(`e`.`project_id` = `p`.`id`)) left join `expense_categories` `ec` on(`e`.`category_id` = `ec`.`id`)) left join `budgets` `b` on(`e`.`budget_id` = `b`.`id`)) left join `users` `u` on(`e`.`approved_by` = `u`.`id`)) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `metric_details`
--
DROP TABLE IF EXISTS `metric_details`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `metric_details`  AS SELECT `m`.`id` AS `id`, `m`.`name` AS `name`, `m`.`unit` AS `unit`, `m`.`target_value` AS `target_value`, `m`.`current_value` AS `current_value`, `m`.`description` AS `description`, `p`.`name` AS `project_name`, `p`.`status` AS `project_status`, `mt`.`name` AS `metric_type_name`, `mt`.`category` AS `category`, `m`.`created_at` AS `created_at` FROM ((`metrics` `m` left join `projects` `p` on(`m`.`project_id` = `p`.`id`)) left join `metric_types` `mt` on(`m`.`metric_type_id` = `mt`.`id`)) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `project_details`
--
DROP TABLE IF EXISTS `project_details`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `project_details`  AS SELECT `p`.`id` AS `id`, `p`.`name` AS `name`, `p`.`description` AS `description`, `p`.`start_date` AS `start_date`, `p`.`end_date` AS `end_date`, `p`.`status` AS `status`, `p`.`budget` AS `budget`, `p`.`progress` AS `progress`, `p`.`priority` AS `priority`, `u`.`name` AS `coordinator_name`, `u`.`email` AS `coordinator_email`, count(`pu`.`user_id`) AS `participant_count`, `p`.`created_at` AS `created_at` FROM ((`projects` `p` left join `users` `u` on(`p`.`creator_id` = `u`.`id`)) left join `project_users` `pu` on(`p`.`id` = `pu`.`project_id`)) GROUP BY `p`.`id` ;

-- --------------------------------------------------------

--
-- Estructura para la vista `task_details`
--
DROP TABLE IF EXISTS `task_details`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `task_details`  AS SELECT `t`.`id` AS `id`, `t`.`title` AS `title`, `t`.`description` AS `description`, `t`.`status` AS `status`, `t`.`priority` AS `priority`, `t`.`due_date` AS `due_date`, `t`.`progress` AS `progress`, `t`.`estimated_hours` AS `estimated_hours`, `t`.`actual_hours` AS `actual_hours`, `p`.`name` AS `project_name`, `p`.`status` AS `project_status`, `u`.`name` AS `created_by_name`, group_concat(`ta_users`.`name` separator ', ') AS `assigned_users`, `t`.`created_at` AS `created_at` FROM ((((`tasks` `t` left join `projects` `p` on(`t`.`project_id` = `p`.`id`)) left join `users` `u` on(`t`.`created_by` = `u`.`id`)) left join `task_assignments` `ta` on(`t`.`id` = `ta`.`task_id`)) left join `users` `ta_users` on(`ta`.`user_id` = `ta_users`.`id`)) GROUP BY `t`.`id` ;

-- --------------------------------------------------------

--
-- Estructura para la vista `user_details`
--
DROP TABLE IF EXISTS `user_details`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `user_details`  AS SELECT `u`.`id` AS `id`, `u`.`name` AS `name`, `u`.`email` AS `email`, `u`.`avatar` AS `avatar`, `u`.`active` AS `active`, `u`.`last_login` AS `last_login`, `r`.`name` AS `role_name`, `r`.`permissions` AS `permissions`, `p`.`name` AS `position_name`, `p`.`department` AS `department`, `u`.`created_at` AS `created_at` FROM ((`users` `u` left join `roles` `r` on(`u`.`role_id` = `r`.`id`)) left join `positions` `p` on(`u`.`position_id` = `p`.`id`)) ;

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `attachments`
--
ALTER TABLE `attachments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_comment` (`comment_id`),
  ADD KEY `idx_project` (`project_id`),
  ADD KEY `idx_uploaded_by` (`uploaded_by`);

--
-- Indices de la tabla `budgets`
--
ALTER TABLE `budgets`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_project` (`project_id`),
  ADD KEY `idx_status` (`status`);

--
-- Indices de la tabla `comments`
--
ALTER TABLE `comments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_project` (`project_id`),
  ADD KEY `idx_user` (`user_id`),
  ADD KEY `idx_parent` (`parent_id`);

--
-- Indices de la tabla `expenses`
--
ALTER TABLE `expenses`
  ADD PRIMARY KEY (`id`),
  ADD KEY `task_id` (`task_id`),
  ADD KEY `category_id` (`category_id`),
  ADD KEY `approved_by` (`approved_by`),
  ADD KEY `idx_budget` (`budget_id`),
  ADD KEY `idx_project` (`project_id`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_date` (`date`),
  ADD KEY `idx_expenses_project_status` (`project_id`,`status`);

--
-- Indices de la tabla `expense_categories`
--
ALTER TABLE `expense_categories`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `financial_reports`
--
ALTER TABLE `financial_reports`
  ADD PRIMARY KEY (`id`),
  ADD KEY `generated_by` (`generated_by`),
  ADD KEY `idx_project` (`project_id`),
  ADD KEY `idx_period` (`period`);

--
-- Indices de la tabla `metrics`
--
ALTER TABLE `metrics`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_project` (`project_id`),
  ADD KEY `idx_type` (`metric_type_id`);

--
-- Indices de la tabla `metric_history`
--
ALTER TABLE `metric_history`
  ADD PRIMARY KEY (`id`),
  ADD KEY `recorded_by` (`recorded_by`),
  ADD KEY `idx_metric` (`metric_id`),
  ADD KEY `idx_recorded_at` (`recorded_at`);

--
-- Indices de la tabla `metric_types`
--
ALTER TABLE `metric_types`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `milestones`
--
ALTER TABLE `milestones`
  ADD PRIMARY KEY (`id`),
  ADD KEY `task_id` (`task_id`),
  ADD KEY `idx_project` (`project_id`),
  ADD KEY `idx_date` (`date`),
  ADD KEY `idx_completed` (`completed`);

--
-- Indices de la tabla `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `project_id` (`project_id`),
  ADD KEY `task_id` (`task_id`),
  ADD KEY `idx_user` (`user_id`),
  ADD KEY `idx_read` (`is_read`),
  ADD KEY `idx_type` (`type`),
  ADD KEY `idx_priority` (`priority`),
  ADD KEY `idx_notifications_user_read` (`user_id`,`is_read`);

--
-- Indices de la tabla `positions`
--
ALTER TABLE `positions`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `projects`
--
ALTER TABLE `projects`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_creator` (`creator_id`),
  ADD KEY `idx_dates` (`start_date`,`end_date`);

--
-- Indices de la tabla `project_files`
--
ALTER TABLE `project_files`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_project` (`project_id`),
  ADD KEY `idx_uploaded_by` (`uploaded_by`);

--
-- Indices de la tabla `project_users`
--
ALTER TABLE `project_users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_project_user` (`project_id`,`user_id`),
  ADD KEY `assigned_by` (`assigned_by`),
  ADD KEY `idx_project` (`project_id`),
  ADD KEY `idx_user` (`user_id`);

--
-- Indices de la tabla `resource_allocations`
--
ALTER TABLE `resource_allocations`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_project` (`project_id`),
  ADD KEY `idx_resource_type` (`resource_type`);

--
-- Indices de la tabla `roles`
--
ALTER TABLE `roles`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`);

--
-- Indices de la tabla `tasks`
--
ALTER TABLE `tasks`
  ADD PRIMARY KEY (`id`),
  ADD KEY `created_by` (`created_by`),
  ADD KEY `idx_project` (`project_id`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_priority` (`priority`),
  ADD KEY `idx_due_date` (`due_date`),
  ADD KEY `idx_tasks_project_status` (`project_id`,`status`);

--
-- Indices de la tabla `task_assignments`
--
ALTER TABLE `task_assignments`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_task_user` (`task_id`,`user_id`),
  ADD KEY `assigned_by` (`assigned_by`),
  ADD KEY `idx_task` (`task_id`),
  ADD KEY `idx_user` (`user_id`),
  ADD KEY `idx_tasks_user_status` (`user_id`,`task_id`);

--
-- Indices de la tabla `task_dependencies`
--
ALTER TABLE `task_dependencies`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_from_task` (`from_task_id`),
  ADD KEY `idx_to_task` (`to_task_id`);

--
-- Indices de la tabla `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `position_id` (`position_id`),
  ADD KEY `idx_email` (`email`),
  ADD KEY `idx_role` (`role_id`),
  ADD KEY `idx_active` (`active`);

--
-- Indices de la tabla `user_activities`
--
ALTER TABLE `user_activities`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_user` (`user_id`),
  ADD KEY `idx_activity_type` (`activity_type`),
  ADD KEY `idx_timestamp` (`timestamp`),
  ADD KEY `idx_activities_user_timestamp` (`user_id`,`timestamp`);

--
-- Indices de la tabla `user_sessions`
--
ALTER TABLE `user_sessions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_token` (`token`),
  ADD KEY `idx_user` (`user_id`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `attachments`
--
ALTER TABLE `attachments`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `budgets`
--
ALTER TABLE `budgets`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `comments`
--
ALTER TABLE `comments`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `expenses`
--
ALTER TABLE `expenses`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `expense_categories`
--
ALTER TABLE `expense_categories`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT de la tabla `financial_reports`
--
ALTER TABLE `financial_reports`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `metrics`
--
ALTER TABLE `metrics`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT de la tabla `metric_history`
--
ALTER TABLE `metric_history`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `metric_types`
--
ALTER TABLE `metric_types`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `milestones`
--
ALTER TABLE `milestones`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `notifications`
--
ALTER TABLE `notifications`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `positions`
--
ALTER TABLE `positions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT de la tabla `projects`
--
ALTER TABLE `projects`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `project_files`
--
ALTER TABLE `project_files`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `project_users`
--
ALTER TABLE `project_users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT de la tabla `resource_allocations`
--
ALTER TABLE `resource_allocations`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `roles`
--
ALTER TABLE `roles`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `tasks`
--
ALTER TABLE `tasks`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `task_assignments`
--
ALTER TABLE `task_assignments`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT de la tabla `task_dependencies`
--
ALTER TABLE `task_dependencies`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `user_activities`
--
ALTER TABLE `user_activities`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=192;

--
-- AUTO_INCREMENT de la tabla `user_sessions`
--
ALTER TABLE `user_sessions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `attachments`
--
ALTER TABLE `attachments`
  ADD CONSTRAINT `attachments_ibfk_1` FOREIGN KEY (`comment_id`) REFERENCES `comments` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `attachments_ibfk_2` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `attachments_ibfk_3` FOREIGN KEY (`uploaded_by`) REFERENCES `users` (`id`);

--
-- Filtros para la tabla `budgets`
--
ALTER TABLE `budgets`
  ADD CONSTRAINT `budgets_ibfk_1` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`) ON DELETE CASCADE;

--
-- Filtros para la tabla `comments`
--
ALTER TABLE `comments`
  ADD CONSTRAINT `comments_ibfk_1` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `comments_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `comments_ibfk_3` FOREIGN KEY (`parent_id`) REFERENCES `comments` (`id`) ON DELETE CASCADE;

--
-- Filtros para la tabla `expenses`
--
ALTER TABLE `expenses`
  ADD CONSTRAINT `expenses_ibfk_1` FOREIGN KEY (`budget_id`) REFERENCES `budgets` (`id`),
  ADD CONSTRAINT `expenses_ibfk_2` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `expenses_ibfk_3` FOREIGN KEY (`task_id`) REFERENCES `tasks` (`id`),
  ADD CONSTRAINT `expenses_ibfk_4` FOREIGN KEY (`category_id`) REFERENCES `expense_categories` (`id`),
  ADD CONSTRAINT `expenses_ibfk_5` FOREIGN KEY (`approved_by`) REFERENCES `users` (`id`);

--
-- Filtros para la tabla `financial_reports`
--
ALTER TABLE `financial_reports`
  ADD CONSTRAINT `financial_reports_ibfk_1` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `financial_reports_ibfk_2` FOREIGN KEY (`generated_by`) REFERENCES `users` (`id`);

--
-- Filtros para la tabla `metrics`
--
ALTER TABLE `metrics`
  ADD CONSTRAINT `metrics_ibfk_1` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `metrics_ibfk_2` FOREIGN KEY (`metric_type_id`) REFERENCES `metric_types` (`id`);

--
-- Filtros para la tabla `metric_history`
--
ALTER TABLE `metric_history`
  ADD CONSTRAINT `metric_history_ibfk_1` FOREIGN KEY (`metric_id`) REFERENCES `metrics` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `metric_history_ibfk_2` FOREIGN KEY (`recorded_by`) REFERENCES `users` (`id`);

--
-- Filtros para la tabla `milestones`
--
ALTER TABLE `milestones`
  ADD CONSTRAINT `milestones_ibfk_1` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `milestones_ibfk_2` FOREIGN KEY (`task_id`) REFERENCES `tasks` (`id`);

--
-- Filtros para la tabla `notifications`
--
ALTER TABLE `notifications`
  ADD CONSTRAINT `notifications_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `notifications_ibfk_2` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `notifications_ibfk_3` FOREIGN KEY (`task_id`) REFERENCES `tasks` (`id`) ON DELETE CASCADE;

--
-- Filtros para la tabla `projects`
--
ALTER TABLE `projects`
  ADD CONSTRAINT `projects_ibfk_1` FOREIGN KEY (`creator_id`) REFERENCES `users` (`id`);

--
-- Filtros para la tabla `project_files`
--
ALTER TABLE `project_files`
  ADD CONSTRAINT `project_files_ibfk_1` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `project_files_ibfk_2` FOREIGN KEY (`uploaded_by`) REFERENCES `users` (`id`);

--
-- Filtros para la tabla `project_users`
--
ALTER TABLE `project_users`
  ADD CONSTRAINT `project_users_ibfk_1` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `project_users_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `project_users_ibfk_3` FOREIGN KEY (`assigned_by`) REFERENCES `users` (`id`);

--
-- Filtros para la tabla `resource_allocations`
--
ALTER TABLE `resource_allocations`
  ADD CONSTRAINT `resource_allocations_ibfk_1` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`) ON DELETE CASCADE;

--
-- Filtros para la tabla `tasks`
--
ALTER TABLE `tasks`
  ADD CONSTRAINT `tasks_ibfk_1` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `tasks_ibfk_2` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`);

--
-- Filtros para la tabla `task_assignments`
--
ALTER TABLE `task_assignments`
  ADD CONSTRAINT `task_assignments_ibfk_1` FOREIGN KEY (`task_id`) REFERENCES `tasks` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `task_assignments_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `task_assignments_ibfk_3` FOREIGN KEY (`assigned_by`) REFERENCES `users` (`id`);

--
-- Filtros para la tabla `task_dependencies`
--
ALTER TABLE `task_dependencies`
  ADD CONSTRAINT `task_dependencies_ibfk_1` FOREIGN KEY (`from_task_id`) REFERENCES `tasks` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `task_dependencies_ibfk_2` FOREIGN KEY (`to_task_id`) REFERENCES `tasks` (`id`) ON DELETE CASCADE;

--
-- Filtros para la tabla `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `users_ibfk_1` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`),
  ADD CONSTRAINT `users_ibfk_2` FOREIGN KEY (`position_id`) REFERENCES `positions` (`id`);

--
-- Filtros para la tabla `user_activities`
--
ALTER TABLE `user_activities`
  ADD CONSTRAINT `user_activities_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Filtros para la tabla `user_sessions`
--
ALTER TABLE `user_sessions`
  ADD CONSTRAINT `user_sessions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
