-- Migración: tablas base para Indicadores y Unidades
-- DB objetivo: eco_system

START TRANSACTION;

-- Unidades de medida
CREATE TABLE IF NOT EXISTS `units` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(100) NOT NULL,
  `symbol` VARCHAR(20) NOT NULL,
  `type` VARCHAR(50) DEFAULT NULL,
  `active` TINYINT(1) DEFAULT 1,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_type` (`type`),
  KEY `idx_active` (`active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Indicadores catálogo
CREATE TABLE IF NOT EXISTS `indicators` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(200) NOT NULL,
  `description` TEXT DEFAULT NULL,
  `category` VARCHAR(50) DEFAULT 'general',
  `unit_id` INT(11) NOT NULL,
  `direction` ENUM('up','down') DEFAULT 'up',
  `type` ENUM('absolute','relative') DEFAULT 'absolute',
  `frequency` ENUM('monthly','quarterly','yearly') DEFAULT 'monthly',
  `active` TINYINT(1) DEFAULT 1,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_unit` (`unit_id`),
  KEY `idx_category` (`category`),
  KEY `idx_active` (`active`),
  CONSTRAINT `fk_indicators_unit` FOREIGN KEY (`unit_id`) REFERENCES `units`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Asignación de indicadores a proyectos
CREATE TABLE IF NOT EXISTS `project_indicators` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `project_id` INT(11) NOT NULL,
  `indicator_id` INT(11) NOT NULL,
  `baseline` DECIMAL(18,4) DEFAULT NULL,
  `target` DECIMAL(18,4) DEFAULT NULL,
  `target_date` DATE DEFAULT NULL,
  `method` VARCHAR(200) DEFAULT NULL,
  `frequency` ENUM('monthly','quarterly','yearly') DEFAULT NULL,
  `responsible_user_id` INT(11) DEFAULT NULL,
  `notes` TEXT DEFAULT NULL,
  `active` TINYINT(1) DEFAULT 1,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_project_indicator` (`project_id`,`indicator_id`),
  KEY `idx_indicator` (`indicator_id`),
  KEY `idx_responsible_user` (`responsible_user_id`),
  CONSTRAINT `fk_pi_project` FOREIGN KEY (`project_id`) REFERENCES `projects`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_pi_indicator` FOREIGN KEY (`indicator_id`) REFERENCES `indicators`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_pi_responsible` FOREIGN KEY (`responsible_user_id`) REFERENCES `users`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Lecturas/avances de indicadores
CREATE TABLE IF NOT EXISTS `indicator_readings` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `project_indicator_id` INT(11) NOT NULL,
  `period_date` DATE NOT NULL,
  `period_label` VARCHAR(20) DEFAULT NULL, -- YYYY-MM, YYYY-Qn, YYYY
  `value` DECIMAL(18,4) NOT NULL,
  `source` VARCHAR(200) DEFAULT NULL,
  `comments` TEXT DEFAULT NULL,
  `created_by` INT(11) DEFAULT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_pi_period` (`project_indicator_id`,`period_date`),
  KEY `idx_created_by` (`created_by`),
  CONSTRAINT `fk_ir_project_indicator` FOREIGN KEY (`project_indicator_id`) REFERENCES `project_indicators`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_ir_created_by` FOREIGN KEY (`created_by`) REFERENCES `users`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Datos semilla mínimos
INSERT INTO `units` (`name`,`symbol`,`type`,`active`) VALUES
  ('Kilowatt-hora','kWh','energia',1),
  ('Tonelada CO2e','tCO2e','emisiones',1),
  ('Porcentaje','%','porcentaje',1)
ON DUPLICATE KEY UPDATE name = VALUES(name);

INSERT INTO `indicators` (`name`,`description`,`category`,`unit_id`,`direction`,`type`,`frequency`,`active`)
SELECT * FROM (
  SELECT 'Consumo energético','Consumo total de energía','energia', (SELECT id FROM units WHERE symbol='kWh' LIMIT 1), 'down','absolute','monthly',1 UNION ALL
  SELECT 'Emisiones de CO2e','Emisiones equivalentes de CO2','clima', (SELECT id FROM units WHERE symbol='tCO2e' LIMIT 1), 'down','absolute','monthly',1 UNION ALL
  SELECT '% Energía renovable','Proporción de energía proveniente de fuentes renovables','energia', (SELECT id FROM units WHERE symbol='%' LIMIT 1), 'up','relative','monthly',1
) AS seed
WHERE NOT EXISTS (SELECT 1 FROM indicators LIMIT 1);

COMMIT;


