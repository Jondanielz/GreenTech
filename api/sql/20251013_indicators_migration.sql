-- Migración: Indicadores (unidades, indicadores, asignación a proyectos y lecturas)
-- Fecha: 2025-10-13
-- Ejecutar en la base de datos del sistema (eco_system)

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 1;

-- =============================
-- Tabla: units (catálogo de unidades)
-- =============================
CREATE TABLE IF NOT EXISTS `units` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(100) NOT NULL,
  `symbol` VARCHAR(20) NOT NULL,
  `type` VARCHAR(50) NULL,
  `active` TINYINT(1) NOT NULL DEFAULT 1,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_units_name` (`name`),
  UNIQUE KEY `uq_units_symbol` (`symbol`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================
-- Tabla: indicators (catálogo de indicadores)
-- =============================
CREATE TABLE IF NOT EXISTS `indicators` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(150) NOT NULL,
  `description` TEXT NULL,
  `category` VARCHAR(50) NOT NULL DEFAULT 'general', -- energy | climate | general
  `unit_id` INT UNSIGNED NOT NULL,
  `direction` ENUM('up','down') NOT NULL DEFAULT 'up', -- up: mayor es mejor; down: menor es mejor
  `type` ENUM('absolute','relative') NOT NULL DEFAULT 'absolute', -- relative ~ porcentaje
  `frequency` ENUM('monthly','quarterly','yearly') NOT NULL DEFAULT 'monthly',
  `active` TINYINT(1) NOT NULL DEFAULT 1,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_indicators_name` (`name`),
  KEY `fk_indicators_unit` (`unit_id`),
  CONSTRAINT `fk_indicators_unit` FOREIGN KEY (`unit_id`) REFERENCES `units` (`id`) ON UPDATE RESTRICT ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Tabla: project_indicators (asignación a proyectos)
-- ============================================
CREATE TABLE IF NOT EXISTS `project_indicators` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `project_id` INT UNSIGNED NOT NULL,
  `indicator_id` INT UNSIGNED NOT NULL,
  `baseline` DECIMAL(18,4) NULL,
  `target` DECIMAL(18,4) NULL,
  `target_date` DATE NULL,
  `method` VARCHAR(200) NULL,
  `frequency` ENUM('monthly','quarterly','yearly') NULL,
  `responsible_user_id` INT UNSIGNED NULL,
  `notes` TEXT NULL,
  `active` TINYINT(1) NOT NULL DEFAULT 1,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_pi_project` (`project_id`),
  KEY `fk_pi_indicator` (`indicator_id`),
  KEY `fk_pi_responsible` (`responsible_user_id`),
  UNIQUE KEY `uq_project_indicator_active` (`project_id`,`indicator_id`),
  CONSTRAINT `fk_pi_project` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`) ON UPDATE RESTRICT ON DELETE CASCADE,
  CONSTRAINT `fk_pi_indicator` FOREIGN KEY (`indicator_id`) REFERENCES `indicators` (`id`) ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT `fk_pi_responsible` FOREIGN KEY (`responsible_user_id`) REFERENCES `users` (`id`) ON UPDATE RESTRICT ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ==================================
-- Tabla: indicator_readings (lecturas)
-- ==================================
CREATE TABLE IF NOT EXISTS `indicator_readings` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `project_indicator_id` INT UNSIGNED NOT NULL,
  `period_label` VARCHAR(20) NOT NULL, -- p.ej. 2025-01, 2025-Q1, 2025
  `period_date` DATE NULL,
  `value` DECIMAL(18,4) NOT NULL,
  `source` VARCHAR(200) NULL,
  `comments` TEXT NULL,
  `created_by` INT UNSIGNED NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_reading_period` (`project_indicator_id`,`period_label`),
  KEY `fk_ir_pi` (`project_indicator_id`),
  KEY `fk_ir_user` (`created_by`),
  CONSTRAINT `fk_ir_pi` FOREIGN KEY (`project_indicator_id`) REFERENCES `project_indicators` (`id`) ON UPDATE RESTRICT ON DELETE CASCADE,
  CONSTRAINT `fk_ir_user` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON UPDATE RESTRICT ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================
-- Datos semilla: units
-- =============================
INSERT INTO `units` (`name`, `symbol`, `type`, `active`)
VALUES
  ('Kilovatio-hora', 'kWh', 'energy', 1),
  ('Megavatio-hora', 'MWh', 'energy', 1),
  ('Tonelada CO2e', 'tCO2e', 'emissions', 1),
  ('Porcentaje', '%', 'ratio', 1)
ON DUPLICATE KEY UPDATE `type` = VALUES(`type`), `active` = VALUES(`active`);

-- =============================
-- Datos semilla: indicators
-- =============================
-- Nota: asume IDs de units existentes (ajustar si es necesario)
INSERT INTO `indicators` (`name`, `description`, `category`, `unit_id`, `direction`, `type`, `frequency`, `active`)
SELECT * FROM (
  SELECT 'Consumo energético', 'Consumo total de energía', 'energy', (SELECT id FROM units WHERE symbol='kWh' LIMIT 1), 'down', 'absolute', 'monthly', 1
  UNION ALL
  SELECT 'Emisiones de CO2', 'Emisiones equivalentes de CO2', 'climate', (SELECT id FROM units WHERE symbol='tCO2e' LIMIT 1), 'down', 'absolute', 'monthly', 1
  UNION ALL
  SELECT '% Energía renovable', 'Participación de energía renovable', 'energy', (SELECT id FROM units WHERE symbol='%' LIMIT 1), 'up', 'relative', 'monthly', 1
  UNION ALL
  SELECT 'Intensidad energética', 'Energía consumida por unidad de producción', 'energy', (SELECT id FROM units WHERE symbol='kWh' LIMIT 1), 'down', 'absolute', 'monthly', 1
) AS seed
ON DUPLICATE KEY UPDATE description = VALUES(description), category = VALUES(category), unit_id = VALUES(unit_id), direction = VALUES(direction), type = VALUES(type), frequency = VALUES(frequency), active = VALUES(active);


