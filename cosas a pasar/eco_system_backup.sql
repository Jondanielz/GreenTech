-- MariaDB dump 10.19  Distrib 10.4.32-MariaDB, for Win64 (AMD64)
--
-- Host: localhost    Database: eco_system
-- ------------------------------------------------------
-- Server version	10.4.32-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `attachments`
--

DROP TABLE IF EXISTS `attachments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `attachments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `size` int(11) NOT NULL,
  `type` varchar(100) NOT NULL,
  `file_path` varchar(500) NOT NULL,
  `comment_id` int(11) DEFAULT NULL,
  `project_id` int(11) DEFAULT NULL,
  `uploaded_by` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_comment` (`comment_id`),
  KEY `idx_project` (`project_id`),
  KEY `idx_uploaded_by` (`uploaded_by`),
  CONSTRAINT `attachments_ibfk_1` FOREIGN KEY (`comment_id`) REFERENCES `comments` (`id`) ON DELETE CASCADE,
  CONSTRAINT `attachments_ibfk_2` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`) ON DELETE CASCADE,
  CONSTRAINT `attachments_ibfk_3` FOREIGN KEY (`uploaded_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `attachments`
--

LOCK TABLES `attachments` WRITE;
/*!40000 ALTER TABLE `attachments` DISABLE KEYS */;
/*!40000 ALTER TABLE `attachments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `budgets`
--

DROP TABLE IF EXISTS `budgets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `budgets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `project_id` int(11) NOT NULL,
  `total_amount` decimal(15,2) NOT NULL,
  `allocated_amount` decimal(15,2) NOT NULL,
  `spent_amount` decimal(15,2) DEFAULT 0.00,
  `remaining_amount` decimal(15,2) GENERATED ALWAYS AS (`allocated_amount` - `spent_amount`) STORED,
  `currency` varchar(3) DEFAULT 'USD',
  `status` enum('active','inactive','completed') DEFAULT 'active',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_project` (`project_id`),
  KEY `idx_status` (`status`),
  CONSTRAINT `budgets_ibfk_1` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `budgets`
--

LOCK TABLES `budgets` WRITE;
/*!40000 ALTER TABLE `budgets` DISABLE KEYS */;
INSERT INTO `budgets` VALUES (1,1,50000.00,45000.00,12500.00,32500.00,'USD','active','2025-09-23 02:45:43','2025-09-23 02:45:43'),(2,2,75000.00,70000.00,28000.00,42000.00,'USD','active','2025-09-23 02:45:43','2025-09-23 02:45:43'),(3,3,30000.00,25000.00,5000.00,20000.00,'USD','active','2025-09-23 02:45:43','2025-09-23 02:45:43');
/*!40000 ALTER TABLE `budgets` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `comments`
--

DROP TABLE IF EXISTS `comments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `comments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `project_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `content` text NOT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_project` (`project_id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_parent` (`parent_id`),
  CONSTRAINT `comments_ibfk_1` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`) ON DELETE CASCADE,
  CONSTRAINT `comments_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `comments_ibfk_3` FOREIGN KEY (`parent_id`) REFERENCES `comments` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `comments`
--

LOCK TABLES `comments` WRITE;
/*!40000 ALTER TABLE `comments` DISABLE KEYS */;
/*!40000 ALTER TABLE `comments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `expense_categories`
--

DROP TABLE IF EXISTS `expense_categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `expense_categories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `icon` varchar(10) DEFAULT NULL,
  `color` varchar(7) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `expense_categories`
--

LOCK TABLES `expense_categories` WRITE;
/*!40000 ALTER TABLE `expense_categories` DISABLE KEYS */;
INSERT INTO `expense_categories` VALUES (1,'Equipos de Medici├│n','­ƒôè','#2196f3','Sensores y equipos de monitoreo','2025-09-23 02:45:43'),(2,'Materiales Sustentables','­ƒî▒','#4caf50','Materiales ecol├│gicos y sostenibles','2025-09-23 02:45:43'),(3,'Certificaciones Ambientales','­ƒÅå','#ff9800','Certificaciones y auditor├¡as','2025-09-23 02:45:43'),(4,'Consultor├¡a Especializada','­ƒæÑ','#9c27b0','Servicios de consultor├¡a','2025-09-23 02:45:43'),(5,'Transporte Ecol├│gico','­ƒÜù','#00bcd4','Transporte sostenible','2025-09-23 02:45:43'),(6,'Energ├¡a Renovable','ÔÜí','#ffeb3b','Sistemas de energ├¡a renovable','2025-09-23 02:45:43'),(7,'An├ílisis de Laboratorio','­ƒº¬','#e91e63','Servicios de laboratorio','2025-09-23 02:45:43'),(8,'Sensores IoT','­ƒôí','#795548','Tecnolog├¡a IoT y sensores','2025-09-23 02:45:43'),(9,'Capacitaci├│n','­ƒÄô','#607d8b','Formaci├│n y capacitaci├│n','2025-09-23 02:45:43'),(10,'Otros','­ƒôª','#9e9e9e','Otros gastos diversos','2025-09-23 02:45:43');
/*!40000 ALTER TABLE `expense_categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `expense_details`
--

DROP TABLE IF EXISTS `expense_details`;
/*!50001 DROP VIEW IF EXISTS `expense_details`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `expense_details` AS SELECT
 1 AS `id`,
  1 AS `amount`,
  1 AS `description`,
  1 AS `date`,
  1 AS `status`,
  1 AS `vendor`,
  1 AS `receipt_number`,
  1 AS `project_name`,
  1 AS `category_name`,
  1 AS `category_icon`,
  1 AS `category_color`,
  1 AS `budget_total`,
  1 AS `budget_spent`,
  1 AS `approved_by_name`,
  1 AS `created_at` */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `expenses`
--

DROP TABLE IF EXISTS `expenses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `expenses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
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
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `task_id` (`task_id`),
  KEY `category_id` (`category_id`),
  KEY `approved_by` (`approved_by`),
  KEY `idx_budget` (`budget_id`),
  KEY `idx_project` (`project_id`),
  KEY `idx_status` (`status`),
  KEY `idx_date` (`date`),
  KEY `idx_expenses_project_status` (`project_id`,`status`),
  CONSTRAINT `expenses_ibfk_1` FOREIGN KEY (`budget_id`) REFERENCES `budgets` (`id`),
  CONSTRAINT `expenses_ibfk_2` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`) ON DELETE CASCADE,
  CONSTRAINT `expenses_ibfk_3` FOREIGN KEY (`task_id`) REFERENCES `tasks` (`id`),
  CONSTRAINT `expenses_ibfk_4` FOREIGN KEY (`category_id`) REFERENCES `expense_categories` (`id`),
  CONSTRAINT `expenses_ibfk_5` FOREIGN KEY (`approved_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `expenses`
--

LOCK TABLES `expenses` WRITE;
/*!40000 ALTER TABLE `expenses` DISABLE KEYS */;
INSERT INTO `expenses` VALUES (1,1,1,NULL,2500.00,1,'Compra de sensores de CO2 para medici├│n de emisiones','2024-11-15',1,'approved','EcoSensors Corp','INV-001-2024','2025-09-23 02:45:43','2025-09-23 02:45:43'),(2,1,1,NULL,1200.00,7,'An├ílisis de laboratorio para muestras de aire','2024-11-20',1,'approved','LabGreen Solutions','LAB-002-2024','2025-09-23 02:45:43','2025-09-23 02:45:43'),(3,2,2,NULL,8500.00,2,'Materiales sustentables para pared verde','2024-11-25',2,'approved','GreenMaterials Inc','MAT-003-2024','2025-09-23 02:45:43','2025-09-23 02:45:43');
/*!40000 ALTER TABLE `expenses` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `update_budget_spent_on_expense_approval` AFTER UPDATE ON `expenses` FOR EACH ROW BEGIN

    IF NEW.status = 'approved' AND OLD.status != 'approved' THEN

        UPDATE budgets 

        SET spent_amount = spent_amount + NEW.amount,

            updated_at = CURRENT_TIMESTAMP

        WHERE id = NEW.budget_id;

    END IF;

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `financial_reports`
--

DROP TABLE IF EXISTS `financial_reports`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `financial_reports` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `project_id` int(11) NOT NULL,
  `period` varchar(20) NOT NULL,
  `total_budget` decimal(15,2) NOT NULL,
  `total_spent` decimal(15,2) NOT NULL,
  `variance` decimal(15,2) GENERATED ALWAYS AS (`total_budget` - `total_spent`) STORED,
  `efficiency_metrics` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`efficiency_metrics`)),
  `generated_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `generated_by` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `generated_by` (`generated_by`),
  KEY `idx_project` (`project_id`),
  KEY `idx_period` (`period`),
  CONSTRAINT `financial_reports_ibfk_1` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`) ON DELETE CASCADE,
  CONSTRAINT `financial_reports_ibfk_2` FOREIGN KEY (`generated_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `financial_reports`
--

LOCK TABLES `financial_reports` WRITE;
/*!40000 ALTER TABLE `financial_reports` DISABLE KEYS */;
/*!40000 ALTER TABLE `financial_reports` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `indicator_readings`
--

DROP TABLE IF EXISTS `indicator_readings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `indicator_readings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `project_indicator_id` int(11) NOT NULL,
  `period_date` date NOT NULL,
  `period_label` varchar(20) DEFAULT NULL,
  `value` decimal(18,4) NOT NULL,
  `source` varchar(200) DEFAULT NULL,
  `comments` text DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_pi_period` (`project_indicator_id`,`period_date`),
  KEY `idx_created_by` (`created_by`),
  CONSTRAINT `fk_ir_created_by` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_ir_project_indicator` FOREIGN KEY (`project_indicator_id`) REFERENCES `project_indicators` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `indicator_readings`
--

LOCK TABLES `indicator_readings` WRITE;
/*!40000 ALTER TABLE `indicator_readings` DISABLE KEYS */;
/*!40000 ALTER TABLE `indicator_readings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `indicators`
--

DROP TABLE IF EXISTS `indicators`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `indicators` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(200) NOT NULL,
  `description` text DEFAULT NULL,
  `category` varchar(50) DEFAULT 'general',
  `unit_id` int(11) NOT NULL,
  `direction` enum('Sube','Baja') DEFAULT 'Sube',
  `type` enum('Absoluto','Relativo') DEFAULT 'Absoluto',
  `frequency` enum('Mensual','Trimestral','Anual') DEFAULT 'Mensual',
  `active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_unit` (`unit_id`),
  KEY `idx_category` (`category`),
  KEY `idx_active` (`active`),
  CONSTRAINT `fk_indicators_unit` FOREIGN KEY (`unit_id`) REFERENCES `units` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `indicators`
--

LOCK TABLES `indicators` WRITE;
/*!40000 ALTER TABLE `indicators` DISABLE KEYS */;
INSERT INTO `indicators` VALUES (1,'Consumo energ├®tico','Consumo total de energ├¡a','Energia',1,'Sube','Absoluto','Mensual',1,'2025-10-13 11:47:45'),(2,'Emisiones de CO2e','Emisiones equivalentes de CO2','Clima',2,'Baja','Relativo','Trimestral',1,'2025-10-13 11:47:45'),(3,'% Energ├¡a renovable','Proporci├│n de energ├¡a proveniente de fuentes renovables','Energia',3,'Sube','Absoluto','Anual',1,'2025-10-13 11:47:45'),(4,'Limpieza del lago','LIMPIEZA','General',4,'Baja','Relativo','Mensual',1,'2025-10-13 12:56:27');
/*!40000 ALTER TABLE `indicators` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `metric_details`
--

DROP TABLE IF EXISTS `metric_details`;
/*!50001 DROP VIEW IF EXISTS `metric_details`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `metric_details` AS SELECT
 1 AS `id`,
  1 AS `name`,
  1 AS `unit`,
  1 AS `target_value`,
  1 AS `current_value`,
  1 AS `description`,
  1 AS `project_name`,
  1 AS `project_status`,
  1 AS `metric_type_name`,
  1 AS `category`,
  1 AS `created_at` */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `metric_history`
--

DROP TABLE IF EXISTS `metric_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `metric_history` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `metric_id` int(11) NOT NULL,
  `value` decimal(15,2) NOT NULL,
  `recorded_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `recorded_by` int(11) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `recorded_by` (`recorded_by`),
  KEY `idx_metric` (`metric_id`),
  KEY `idx_recorded_at` (`recorded_at`),
  CONSTRAINT `metric_history_ibfk_1` FOREIGN KEY (`metric_id`) REFERENCES `metrics` (`id`) ON DELETE CASCADE,
  CONSTRAINT `metric_history_ibfk_2` FOREIGN KEY (`recorded_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `metric_history`
--

LOCK TABLES `metric_history` WRITE;
/*!40000 ALTER TABLE `metric_history` DISABLE KEYS */;
/*!40000 ALTER TABLE `metric_history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `metric_types`
--

DROP TABLE IF EXISTS `metric_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `metric_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `unit` varchar(50) NOT NULL,
  `category` varchar(50) NOT NULL,
  `description` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `metric_types`
--

LOCK TABLES `metric_types` WRITE;
/*!40000 ALTER TABLE `metric_types` DISABLE KEYS */;
INSERT INTO `metric_types` VALUES (1,'Emisiones CO2','toneladas','Carbono','Medici├│n de emisiones de di├│xido de carbono','2025-09-23 02:45:43'),(2,'Consumo Energ├®tico','kWh','Energ├¡a','Consumo de energ├¡a el├®ctrica','2025-09-23 02:45:43'),(3,'Consumo de Agua','litros','Agua','Consumo de recursos h├¡dricos','2025-09-23 02:45:43'),(4,'Residuos Generados','kg','Residuos','Cantidad de residuos producidos','2025-09-23 02:45:43'),(5,'├ürea Verde','m┬▓','Biodiversidad','Superficie de ├íreas verdes','2025-09-23 02:45:43');
/*!40000 ALTER TABLE `metric_types` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `metrics`
--

DROP TABLE IF EXISTS `metrics`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `metrics` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(200) NOT NULL,
  `project_id` int(11) NOT NULL,
  `metric_type_id` int(11) DEFAULT NULL,
  `unit` varchar(50) NOT NULL,
  `target_value` decimal(15,2) DEFAULT NULL,
  `current_value` decimal(15,2) DEFAULT 0.00,
  `description` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_project` (`project_id`),
  KEY `idx_type` (`metric_type_id`),
  CONSTRAINT `metrics_ibfk_1` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`) ON DELETE CASCADE,
  CONSTRAINT `metrics_ibfk_2` FOREIGN KEY (`metric_type_id`) REFERENCES `metric_types` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `metrics`
--

LOCK TABLES `metrics` WRITE;
/*!40000 ALTER TABLE `metrics` DISABLE KEYS */;
INSERT INTO `metrics` VALUES (1,'Reducci├│n de Emisiones CO2',1,1,'kg CO2',1200.00,340.00,'Meta de reducci├│n de emisiones de carbono del proyecto','2025-09-23 02:45:43','2025-09-23 02:45:43'),(2,'Eficiencia Energ├®tica',1,2,'kWh',5000.00,1850.00,'Ahorro energ├®tico esperado del proyecto','2025-09-23 02:45:43','2025-09-23 02:45:43'),(3,'Presupuesto Utilizado',1,NULL,'Ôé¼',15000.00,8500.00,'Presupuesto ejecutado vs presupuesto total','2025-09-23 02:45:43','2025-09-23 02:45:43'),(4,'Progreso del Proyecto',1,NULL,'%',100.00,65.00,'Porcentaje de avance del proyecto','2025-09-23 02:45:43','2025-09-23 02:45:43'),(5,'Absorci├│n de CO2',2,1,'kg CO2',800.00,0.00,'CO2 absorbido por las plantas instaladas','2025-09-23 02:45:43','2025-09-23 02:45:43'),(6,'Consumo El├®ctrico',2,2,'kWh',2000.00,0.00,'Consumo energ├®tico del sistema de riego','2025-09-23 02:45:43','2025-09-23 02:45:43'),(7,'Inversi├│n Total',2,NULL,'Ôé¼',25000.00,3200.00,'Inversi├│n total en la pared verde','2025-09-23 02:45:43','2025-09-23 02:45:43'),(8,'Avance de Implementaci├│n',2,NULL,'%',100.00,15.00,'Porcentaje de implementaci├│n de la pared verde','2025-09-23 02:45:43','2025-09-23 02:45:43');
/*!40000 ALTER TABLE `metrics` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `milestones`
--

DROP TABLE IF EXISTS `milestones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `milestones` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(200) NOT NULL,
  `description` text DEFAULT NULL,
  `date` date NOT NULL,
  `project_id` int(11) NOT NULL,
  `task_id` int(11) DEFAULT NULL,
  `completed` tinyint(1) DEFAULT 0,
  `completed_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `task_id` (`task_id`),
  KEY `idx_project` (`project_id`),
  KEY `idx_date` (`date`),
  KEY `idx_completed` (`completed`),
  CONSTRAINT `milestones_ibfk_1` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`) ON DELETE CASCADE,
  CONSTRAINT `milestones_ibfk_2` FOREIGN KEY (`task_id`) REFERENCES `tasks` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `milestones`
--

LOCK TABLES `milestones` WRITE;
/*!40000 ALTER TABLE `milestones` DISABLE KEYS */;
INSERT INTO `milestones` VALUES (1,'Nombre del evento aprobado','Hito clave: Nombre oficial del evento definido y aprobado','2025-09-06',1,1,1,NULL,'2025-09-23 02:45:43'),(2,'Presupuesto finalizado','Hito financiero: Presupuesto completo aprobado','2025-09-07',1,2,0,NULL,'2025-09-23 02:45:43'),(3,'Sensores instalados','Hito t├®cnico: Sistema de sensores completamente instalado','2025-09-20',2,5,0,NULL,'2025-09-23 02:45:43');
/*!40000 ALTER TABLE `milestones` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notifications`
--

DROP TABLE IF EXISTS `notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `notifications` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type` varchar(50) NOT NULL,
  `title` varchar(200) NOT NULL,
  `message` text NOT NULL,
  `user_id` int(11) NOT NULL,
  `project_id` int(11) DEFAULT NULL,
  `task_id` int(11) DEFAULT NULL,
  `priority` enum('low','normal','high','urgent') DEFAULT 'normal',
  `is_read` tinyint(1) DEFAULT 0,
  `sender_name` varchar(100) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `project_id` (`project_id`),
  KEY `task_id` (`task_id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_read` (`is_read`),
  KEY `idx_type` (`type`),
  KEY `idx_priority` (`priority`),
  KEY `idx_notifications_user_read` (`user_id`,`is_read`),
  CONSTRAINT `notifications_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `notifications_ibfk_2` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`) ON DELETE CASCADE,
  CONSTRAINT `notifications_ibfk_3` FOREIGN KEY (`task_id`) REFERENCES `tasks` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notifications`
--

LOCK TABLES `notifications` WRITE;
/*!40000 ALTER TABLE `notifications` DISABLE KEYS */;
/*!40000 ALTER TABLE `notifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `project_details`
--

DROP TABLE IF EXISTS `project_details`;
/*!50001 DROP VIEW IF EXISTS `project_details`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `project_details` AS SELECT
 1 AS `id`,
  1 AS `name`,
  1 AS `description`,
  1 AS `start_date`,
  1 AS `end_date`,
  1 AS `status`,
  1 AS `budget`,
  1 AS `progress`,
  1 AS `priority`,
  1 AS `coordinator_name`,
  1 AS `coordinator_email`,
  1 AS `participant_count`,
  1 AS `created_at` */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `project_files`
--

DROP TABLE IF EXISTS `project_files`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `project_files` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `project_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `size` int(11) NOT NULL,
  `type` varchar(100) NOT NULL,
  `file_path` varchar(500) NOT NULL,
  `uploaded_by` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_project` (`project_id`),
  KEY `idx_uploaded_by` (`uploaded_by`),
  CONSTRAINT `project_files_ibfk_1` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`) ON DELETE CASCADE,
  CONSTRAINT `project_files_ibfk_2` FOREIGN KEY (`uploaded_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `project_files`
--

LOCK TABLES `project_files` WRITE;
/*!40000 ALTER TABLE `project_files` DISABLE KEYS */;
/*!40000 ALTER TABLE `project_files` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `project_indicators`
--

DROP TABLE IF EXISTS `project_indicators`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `project_indicators` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `project_id` int(11) NOT NULL,
  `indicator_id` int(11) NOT NULL,
  `baseline` decimal(18,4) DEFAULT NULL,
  `target` decimal(18,4) DEFAULT NULL,
  `target_date` date DEFAULT NULL,
  `method` varchar(200) DEFAULT NULL,
  `frequency` enum('mensual','trimestral','anual') DEFAULT NULL,
  `responsible_user_id` int(11) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_project_indicator` (`project_id`,`indicator_id`),
  KEY `idx_indicator` (`indicator_id`),
  KEY `idx_responsible_user` (`responsible_user_id`),
  CONSTRAINT `fk_pi_indicator` FOREIGN KEY (`indicator_id`) REFERENCES `indicators` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_pi_project` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_pi_responsible` FOREIGN KEY (`responsible_user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `project_indicators`
--

LOCK TABLES `project_indicators` WRITE;
/*!40000 ALTER TABLE `project_indicators` DISABLE KEYS */;
/*!40000 ALTER TABLE `project_indicators` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `project_users`
--

DROP TABLE IF EXISTS `project_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `project_users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `project_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `assigned_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `assigned_by` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_project_user` (`project_id`,`user_id`),
  KEY `assigned_by` (`assigned_by`),
  KEY `idx_project` (`project_id`),
  KEY `idx_user` (`user_id`),
  CONSTRAINT `project_users_ibfk_1` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`) ON DELETE CASCADE,
  CONSTRAINT `project_users_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `project_users_ibfk_3` FOREIGN KEY (`assigned_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `project_users`
--

LOCK TABLES `project_users` WRITE;
/*!40000 ALTER TABLE `project_users` DISABLE KEYS */;
INSERT INTO `project_users` VALUES (1,1,3,'2025-09-23 02:45:43',2),(2,1,4,'2025-09-23 02:45:43',2),(3,2,3,'2025-09-23 02:45:43',2),(4,2,4,'2025-09-23 02:45:43',2),(5,3,3,'2025-09-23 02:45:43',2),(6,3,4,'2025-09-23 02:45:43',2),(8,4,6,'2025-10-13 04:41:34',NULL);
/*!40000 ALTER TABLE `project_users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `projects`
--

DROP TABLE IF EXISTS `projects`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `projects` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(200) NOT NULL,
  `description` text DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `status` enum('Planificaci├│n','En progreso','Completado','Cancelado','En pausa') DEFAULT 'Planificaci├│n',
  `creator_id` int(11) NOT NULL,
  `budget` decimal(15,2) DEFAULT 0.00,
  `progress` int(11) DEFAULT 0,
  `priority` enum('Baja','Media','Alta','Cr├¡tica') DEFAULT 'Media',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_status` (`status`),
  KEY `idx_creator` (`creator_id`),
  KEY `idx_dates` (`start_date`,`end_date`),
  CONSTRAINT `projects_ibfk_1` FOREIGN KEY (`creator_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `projects`
--

LOCK TABLES `projects` WRITE;
/*!40000 ALTER TABLE `projects` DISABLE KEYS */;
INSERT INTO `projects` VALUES (1,'Tesis Huella de Carbono','Investigaci├│n sobre la huella de carbono en procesos industriales','2025-08-01','2025-12-31','En progreso',2,50000.00,65,'Media','2025-09-23 02:45:43','2025-09-23 02:45:43'),(2,'Pared Verde Sustentable','Implementaci├│n de muros verdes para reducir la temperatura urbana','2025-09-01','2026-02-28','En progreso',2,75000.00,30,'Media','2025-09-23 02:45:43','2025-09-23 02:45:43'),(3,'Tesis Huella H├¡drica','An├ílisis del consumo de agua en la agricultura local','2025-10-01','2026-03-31','Planificaci├│n',2,30000.00,10,'Media','2025-09-23 02:45:43','2025-09-23 02:45:43'),(4,'PROYECTO NUEVO','PROYECTO NUEVO DE PRUEBA','2025-10-12','2025-10-29','Cancelado',1,3213123.00,NULL,NULL,'2025-10-12 22:35:45','2025-10-12 22:46:51'),(5,'ABC','ASDSADASDASDASD','2025-10-13','2025-10-30','Cancelado',1,NULL,NULL,NULL,'2025-10-13 14:07:49','2025-10-13 14:08:11');
/*!40000 ALTER TABLE `projects` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `resource_allocations`
--

DROP TABLE IF EXISTS `resource_allocations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `resource_allocations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `project_id` int(11) NOT NULL,
  `resource_type` varchar(100) NOT NULL,
  `allocated_amount` decimal(15,2) NOT NULL,
  `used_amount` decimal(15,2) DEFAULT 0.00,
  `cost_per_unit` decimal(10,2) DEFAULT NULL,
  `efficiency_rating` decimal(5,2) DEFAULT NULL,
  `allocation_date` date NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_project` (`project_id`),
  KEY `idx_resource_type` (`resource_type`),
  CONSTRAINT `resource_allocations_ibfk_1` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `resource_allocations`
--

LOCK TABLES `resource_allocations` WRITE;
/*!40000 ALTER TABLE `resource_allocations` DISABLE KEYS */;
/*!40000 ALTER TABLE `resource_allocations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `roles`
--

DROP TABLE IF EXISTS `roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `roles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `permissions` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`permissions`)),
  `description` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `roles`
--

LOCK TABLES `roles` WRITE;
/*!40000 ALTER TABLE `roles` DISABLE KEYS */;
INSERT INTO `roles` VALUES (1,'Administrador','[\"all\"]','Acceso completo al sistema','2025-09-23 02:45:43','2025-09-23 02:45:43'),(2,'Coordinador','[\"manage_projects\", \"manage_tasks\", \"view_metrics\"]','Gesti├│n de proyectos y tareas','2025-09-23 02:45:43','2025-09-23 02:45:43'),(3,'Participante','[\"view_tasks\", \"update_task_status\"]','Participaci├│n en proyectos','2025-09-23 02:45:43','2025-09-23 02:45:43');
/*!40000 ALTER TABLE `roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `task_assignments`
--

DROP TABLE IF EXISTS `task_assignments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `task_assignments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `task_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `assigned_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `assigned_by` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_task_user` (`task_id`,`user_id`),
  KEY `assigned_by` (`assigned_by`),
  KEY `idx_task` (`task_id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_tasks_user_status` (`user_id`,`task_id`),
  CONSTRAINT `task_assignments_ibfk_1` FOREIGN KEY (`task_id`) REFERENCES `tasks` (`id`) ON DELETE CASCADE,
  CONSTRAINT `task_assignments_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `task_assignments_ibfk_3` FOREIGN KEY (`assigned_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `task_assignments`
--

LOCK TABLES `task_assignments` WRITE;
/*!40000 ALTER TABLE `task_assignments` DISABLE KEYS */;
INSERT INTO `task_assignments` VALUES (1,1,3,'2025-09-23 02:45:43',2),(2,2,4,'2025-09-23 02:45:43',2),(3,3,3,'2025-09-23 02:45:43',2),(4,4,3,'2025-09-23 02:45:43',2),(5,4,4,'2025-09-23 02:45:43',2),(6,5,3,'2025-09-23 02:45:43',2);
/*!40000 ALTER TABLE `task_assignments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `task_dependencies`
--

DROP TABLE IF EXISTS `task_dependencies`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `task_dependencies` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `from_task_id` int(11) NOT NULL,
  `to_task_id` int(11) NOT NULL,
  `dependency_type` enum('finish-to-start','start-to-start','finish-to-finish','start-to-finish') DEFAULT 'finish-to-start',
  `description` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_from_task` (`from_task_id`),
  KEY `idx_to_task` (`to_task_id`),
  CONSTRAINT `task_dependencies_ibfk_1` FOREIGN KEY (`from_task_id`) REFERENCES `tasks` (`id`) ON DELETE CASCADE,
  CONSTRAINT `task_dependencies_ibfk_2` FOREIGN KEY (`to_task_id`) REFERENCES `tasks` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `task_dependencies`
--

LOCK TABLES `task_dependencies` WRITE;
/*!40000 ALTER TABLE `task_dependencies` DISABLE KEYS */;
/*!40000 ALTER TABLE `task_dependencies` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `task_details`
--

DROP TABLE IF EXISTS `task_details`;
/*!50001 DROP VIEW IF EXISTS `task_details`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `task_details` AS SELECT
 1 AS `id`,
  1 AS `title`,
  1 AS `description`,
  1 AS `status`,
  1 AS `priority`,
  1 AS `due_date`,
  1 AS `progress`,
  1 AS `estimated_hours`,
  1 AS `actual_hours`,
  1 AS `project_name`,
  1 AS `project_status`,
  1 AS `created_by_name`,
  1 AS `assigned_users`,
  1 AS `created_at` */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `tasks`
--

DROP TABLE IF EXISTS `tasks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tasks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(200) NOT NULL,
  `description` text DEFAULT NULL,
  `status` enum('Pendiente','En progreso','Completada','Cancelada') DEFAULT 'Pendiente',
  `priority` enum('Baja','Media','Alta','Cr├¡tica') DEFAULT 'Media',
  `due_date` date DEFAULT NULL,
  `project_id` int(11) NOT NULL,
  `created_by` int(11) NOT NULL,
  `progress` int(11) DEFAULT 0,
  `estimated_hours` int(11) DEFAULT 0,
  `actual_hours` int(11) DEFAULT 0,
  `tags` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`tags`)),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `created_by` (`created_by`),
  KEY `idx_project` (`project_id`),
  KEY `idx_status` (`status`),
  KEY `idx_priority` (`priority`),
  KEY `idx_due_date` (`due_date`),
  KEY `idx_tasks_project_status` (`project_id`,`status`),
  CONSTRAINT `tasks_ibfk_1` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`) ON DELETE CASCADE,
  CONSTRAINT `tasks_ibfk_2` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tasks`
--

LOCK TABLES `tasks` WRITE;
/*!40000 ALTER TABLE `tasks` DISABLE KEYS */;
INSERT INTO `tasks` VALUES (1,'Finalizar nombre del evento','Definir y aprobar el nombre final para el evento de sostenibilidad','Completada','Alta','2025-08-15',1,2,100,8,8,'[\"branding\", \"evento\"]','2025-09-23 02:45:43','2025-09-23 02:45:43'),(2,'Finalizar presupuesto del evento','Completar el presupuesto detallado para todas las actividades del evento','En progreso','Cr├¡tica','2025-09-20',1,2,75,16,12,'[\"finanzas\", \"evento\"]','2025-09-23 02:45:43','2025-10-13 14:48:29'),(3,'Proponer 3 ideas de keynote para conferencia','Desarrollar y presentar tres propuestas de temas principales para la conferencia','En progreso','Alta','2025-10-15',1,2,60,12,7,'[\"contenido\", \"conferencia\"]','2025-09-23 02:45:43','2025-09-23 02:45:43'),(4,'An├ílisis de Emisiones CO2','Realizar medici├│n y an├ílisis de las emisiones de carbono del proyecto','En progreso','Alta','2025-10-20',2,2,45,24,11,'[\"an├ílisis\", \"emisiones\", \"CO2\"]','2025-09-23 02:45:43','2025-09-23 02:45:43'),(5,'Instalaci├│n de Sensores','Colocar sensores de monitoreo ambiental en las ubicaciones designadas','Pendiente','Media','2025-11-25',2,2,10,NULL,3,'[\"instalaci├│n\", \"sensores\", \"hardware\"]','2025-09-23 02:45:43','2025-10-13 14:18:57'),(6,'aaa','eeee','Pendiente','Media','2025-10-30',1,2,0,0,0,NULL,'2025-10-13 14:58:44','2025-10-13 14:58:44');
/*!40000 ALTER TABLE `tasks` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `update_project_progress_on_task_completion` AFTER UPDATE ON `tasks` FOR EACH ROW BEGIN

    IF NEW.status = 'Completada' AND OLD.status != 'Completada' THEN

        CALL UpdateProjectProgress(NEW.project_id);

    END IF;

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `units`
--

DROP TABLE IF EXISTS `units`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `units` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `symbol` varchar(20) NOT NULL,
  `type` varchar(50) DEFAULT NULL,
  `active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_type` (`type`),
  KEY `idx_active` (`active`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `units`
--

LOCK TABLES `units` WRITE;
/*!40000 ALTER TABLE `units` DISABLE KEYS */;
INSERT INTO `units` VALUES (1,'Kilowatt-hora','kWh','Energia',1,'2025-10-13 11:47:44'),(2,'Tonelada CO2e','tCO2e','Emisiones',1,'2025-10-13 11:47:44'),(3,'Porcentaje','%','Porcentaje',1,'2025-10-13 11:47:44'),(4,'Litros por metro cuadrado','l/m┬▓','Agua',1,'2025-10-13 12:37:43');
/*!40000 ALTER TABLE `units` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_activities`
--

DROP TABLE IF EXISTS `user_activities`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_activities` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `activity_type` varchar(50) NOT NULL,
  `details` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`details`)),
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_activity_type` (`activity_type`),
  KEY `idx_timestamp` (`timestamp`),
  KEY `idx_activities_user_timestamp` (`user_id`,`timestamp`),
  CONSTRAINT `user_activities_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=209 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_activities`
--

LOCK TABLES `user_activities` WRITE;
/*!40000 ALTER TABLE `user_activities` DISABLE KEYS */;
INSERT INTO `user_activities` VALUES (1,1,'login',NULL,'2025-09-23 04:01:28'),(2,1,'login',NULL,'2025-09-23 04:02:34'),(3,1,'login',NULL,'2025-09-23 04:04:21'),(4,1,'login',NULL,'2025-09-23 04:04:21'),(5,1,'login',NULL,'2025-09-23 04:05:37'),(6,1,'login',NULL,'2025-09-23 04:07:42'),(7,1,'login',NULL,'2025-09-23 04:12:06'),(8,1,'login',NULL,'2025-09-23 04:12:41'),(9,1,'login',NULL,'2025-09-23 04:12:49'),(10,1,'login',NULL,'2025-09-23 04:13:02'),(11,1,'login',NULL,'2025-09-23 04:13:26'),(12,1,'login',NULL,'2025-09-23 04:13:51'),(13,3,'login',NULL,'2025-09-23 04:14:11'),(14,1,'login',NULL,'2025-09-23 04:14:21'),(15,1,'login',NULL,'2025-09-23 04:19:44'),(16,2,'login',NULL,'2025-09-23 04:25:47'),(17,1,'login',NULL,'2025-09-24 01:25:39'),(18,1,'login',NULL,'2025-09-24 01:30:44'),(19,3,'login',NULL,'2025-09-24 01:31:14'),(20,1,'login',NULL,'2025-09-24 01:34:02'),(21,1,'login',NULL,'2025-09-24 01:46:27'),(22,1,'login',NULL,'2025-10-01 00:22:39'),(23,1,'login',NULL,'2025-10-01 00:23:36'),(24,1,'login',NULL,'2025-10-01 00:25:59'),(25,3,'login',NULL,'2025-10-01 00:26:32'),(26,1,'login',NULL,'2025-10-01 00:26:42'),(27,1,'login',NULL,'2025-10-01 00:26:59'),(28,3,'login',NULL,'2025-10-01 00:32:05'),(29,1,'login',NULL,'2025-10-01 00:32:34'),(30,1,'login',NULL,'2025-10-01 00:35:04'),(31,1,'login',NULL,'2025-10-01 00:48:26'),(32,1,'login',NULL,'2025-10-01 00:54:40'),(33,3,'login',NULL,'2025-10-01 00:55:21'),(34,1,'login',NULL,'2025-10-01 00:58:54'),(35,3,'login',NULL,'2025-10-01 00:59:04'),(36,1,'login',NULL,'2025-10-01 00:59:08'),(37,1,'login',NULL,'2025-10-01 01:03:19'),(38,1,'login',NULL,'2025-10-01 01:03:31'),(39,1,'login',NULL,'2025-10-01 01:11:32'),(40,2,'login',NULL,'2025-10-01 01:11:37'),(41,1,'login',NULL,'2025-10-01 01:12:07'),(42,1,'login',NULL,'2025-10-01 01:12:20'),(43,1,'login',NULL,'2025-10-01 01:16:45'),(44,1,'login',NULL,'2025-10-01 01:16:51'),(45,1,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT; Windows NT 10.0; es-ES) WindowsPowerShell\\/5.1.26100.4202\"}','2025-10-04 21:36:06'),(46,1,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-04 21:37:28'),(47,1,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-04 21:37:53'),(48,1,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT; Windows NT 10.0; es-ES) WindowsPowerShell\\/5.1.26100.4202\"}','2025-10-04 21:38:45'),(49,1,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT; Windows NT 10.0; es-ES) WindowsPowerShell\\/5.1.26100.4202\"}','2025-10-04 21:59:34'),(50,1,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-04 22:00:33'),(51,1,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-04 22:00:34'),(52,1,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-04 22:00:35'),(53,1,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-04 22:00:35'),(54,1,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-04 22:00:39'),(55,1,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-04 22:37:42'),(56,1,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT; Windows NT 10.0; es-ES) WindowsPowerShell\\/5.1.26100.4202\"}','2025-10-04 22:39:04'),(57,1,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-04 22:40:48'),(58,1,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-04 22:41:03'),(59,1,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT; Windows NT 10.0; es-ES) WindowsPowerShell\\/5.1.26100.4202\"}','2025-10-04 23:11:51'),(60,1,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-04 23:14:35'),(61,1,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-04 23:15:05'),(62,1,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-04 23:15:09'),(63,1,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-04 23:15:58'),(64,1,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-04 23:22:57'),(65,1,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-04 23:25:49'),(66,1,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-04 23:25:52'),(67,1,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-04 23:26:10'),(68,1,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-04 23:28:24'),(69,1,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-04 23:32:29'),(70,1,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-04 23:32:51'),(71,2,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-04 23:34:36'),(72,1,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-04 23:38:40'),(73,1,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-04 23:39:27'),(74,1,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-04 23:57:26'),(75,1,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-05 00:07:11'),(76,1,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-05 00:14:42'),(77,2,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-05 00:14:55'),(78,1,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-05 00:15:36'),(79,1,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT; Windows NT 10.0; es-ES) WindowsPowerShell\\/5.1.26100.4202\"}','2025-10-05 00:22:59'),(80,1,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-05 00:28:10'),(81,2,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-05 00:28:43'),(82,2,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-05 00:28:56'),(83,1,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-05 00:29:05'),(84,1,'login','{\"ip\":\"unknown\",\"user_agent\":\"unknown\"}','2025-10-05 00:33:59'),(85,1,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-05 00:43:45'),(86,1,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-05 00:55:58'),(87,1,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-05 00:59:03'),(88,1,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-05 01:16:59'),(89,1,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-05 01:23:56'),(90,1,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-05 21:41:53'),(91,1,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-05 22:00:44'),(92,1,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-05 22:01:15'),(93,1,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-05 22:02:37'),(94,1,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-05 22:04:14'),(95,1,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-05 22:27:19'),(96,1,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-05 22:27:21'),(97,1,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-05 22:36:07'),(98,1,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-05 22:38:14'),(99,1,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-05 22:38:30'),(100,1,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-05 22:38:45'),(101,1,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-05 22:42:53'),(102,1,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-05 22:49:02'),(103,1,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-05 22:52:17'),(104,1,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-05 22:52:21'),(105,1,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-05 23:10:52'),(106,1,'login','{\"ip\":\"unknown\",\"user_agent\":\"unknown\"}','2025-10-05 23:24:14'),(107,1,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-05 23:25:38'),(108,1,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-05 23:25:56'),(109,1,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-05 23:28:28'),(110,1,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-05 23:41:37'),(111,1,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-05 23:44:33'),(112,1,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-05 23:45:39'),(113,1,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-05 23:49:03'),(114,1,'login','{\"ip\":\"unknown\",\"user_agent\":\"unknown\"}','2025-10-05 23:51:12'),(115,1,'login','{\"ip\":\"unknown\",\"user_agent\":\"unknown\"}','2025-10-05 23:51:26'),(116,1,'login','{\"ip\":\"unknown\",\"user_agent\":\"unknown\"}','2025-10-05 23:52:24'),(117,1,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-05 23:53:26'),(118,2,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-05 23:54:46'),(119,2,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-05 23:55:15'),(120,1,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-05 23:57:08'),(121,1,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-05 23:57:36'),(122,2,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-05 23:57:50'),(123,2,'logout','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-06 00:06:54'),(124,1,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-06 00:06:55'),(125,1,'logout','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-06 00:07:01'),(126,1,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-06 00:08:35'),(127,1,'logout','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-06 00:08:41'),(128,2,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-06 00:08:46'),(129,2,'logout','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-06 00:08:49'),(130,1,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-06 00:16:06'),(131,1,'logout','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-06 00:16:10'),(132,2,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-06 00:16:13'),(133,2,'logout','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-06 00:21:26'),(134,1,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-06 00:21:27'),(135,1,'logout','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-06 00:21:31'),(136,2,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-06 00:21:37'),(137,2,'logout','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-06 00:21:55'),(138,1,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-06 00:21:58'),(139,1,'logout','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-06 00:22:27'),(140,3,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-06 00:22:36'),(141,3,'logout','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-06 00:23:28'),(142,2,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-06 00:23:34'),(143,2,'logout','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-06 00:28:57'),(144,1,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-06 00:28:59'),(145,1,'logout','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-06 00:29:06'),(146,3,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-06 00:29:11'),(147,3,'logout','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-06 00:29:21'),(148,3,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-06 00:29:27'),(149,3,'logout','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-06 00:29:34'),(150,2,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-06 00:29:39'),(151,2,'logout','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-06 00:31:06'),(152,1,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-06 00:31:19'),(153,1,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-07 00:42:34'),(154,1,'logout','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-07 01:02:41'),(155,1,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-07 01:02:42'),(156,1,'logout','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-07 01:13:17'),(157,2,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-07 01:13:23'),(158,2,'logout','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-07 01:13:45'),(159,3,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-07 01:13:51'),(160,3,'logout','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-07 01:14:28'),(161,1,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-07 01:14:43'),(162,1,'logout','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-07 01:22:31'),(163,1,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-07 01:22:35'),(164,1,'logout','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-07 01:22:37'),(165,1,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-07 01:22:57'),(166,1,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-07 02:30:03'),(167,1,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-12 17:09:34'),(168,1,'logout','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-12 22:47:00'),(169,3,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-12 22:47:45'),(170,3,'logout','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-12 22:50:51'),(171,1,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-12 22:50:56'),(172,1,'logout','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-13 02:10:54'),(173,2,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-13 02:11:20'),(174,2,'logout','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-13 02:17:37'),(175,1,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-13 02:17:41'),(176,1,'logout','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-13 04:05:09'),(177,2,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-13 04:05:21'),(178,2,'logout','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-13 04:14:43'),(179,1,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-13 04:16:50'),(180,1,'logout','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-13 04:36:05'),(181,1,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-13 04:40:11'),(182,1,'logout','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-13 04:42:25'),(183,2,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-13 04:42:46'),(184,2,'logout','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-13 04:43:27'),(185,1,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-13 04:43:34'),(186,1,'logout','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-13 04:43:50'),(187,1,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-13 04:50:51'),(188,1,'logout','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-13 04:51:03'),(189,2,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-13 04:51:08'),(190,2,'logout','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-13 04:55:59'),(191,1,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-13 04:56:02'),(192,1,'logout','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-13 05:08:19'),(193,2,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-13 05:08:33'),(194,2,'logout','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-13 05:08:49'),(195,1,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-13 05:19:33'),(196,1,'logout','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-13 05:33:37'),(197,2,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-13 05:33:54'),(198,2,'logout','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-13 05:41:17'),(199,3,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-13 05:41:41'),(200,3,'logout','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-13 05:44:31'),(201,1,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-13 05:44:58'),(202,1,'logout','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-13 14:19:14'),(203,2,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-13 14:20:01'),(204,2,'logout','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-13 15:03:17'),(205,3,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-13 15:04:16'),(206,3,'logout','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-13 15:10:33'),(207,1,'login','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-13 15:24:06'),(208,1,'logout','{\"ip\":\"::1\",\"user_agent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/141.0.0.0 Safari\\/537.36\"}','2025-10-13 15:24:48');
/*!40000 ALTER TABLE `user_activities` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_sessions`
--

DROP TABLE IF EXISTS `user_sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_sessions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `token` varchar(255) NOT NULL,
  `expires_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_token` (`token`),
  KEY `idx_user` (`user_id`),
  CONSTRAINT `user_sessions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_sessions`
--

LOCK TABLES `user_sessions` WRITE;
/*!40000 ALTER TABLE `user_sessions` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_sessions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `user` varchar(15) NOT NULL,
  `password` varchar(255) NOT NULL,
  `role_id` int(11) NOT NULL,
  `position` varchar(200) DEFAULT NULL,
  `avatar` varchar(255) DEFAULT NULL,
  `active` tinyint(1) DEFAULT 1,
  `last_login` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  KEY `idx_email` (`email`),
  KEY `idx_role` (`role_id`),
  KEY `idx_active` (`active`),
  CONSTRAINT `users_ibfk_1` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'Andrea Rodr├¡guez','admin@eco.com','admin','827ccb0eea8a706c4c34a16891f84e7b',1,NULL,'https://i.pravatar.cc/150?img=1',1,'2025-10-13 15:24:06','2025-09-23 02:45:43','2025-10-13 15:24:06'),(2,'Carlos Mendoza','coordinator@eco.com','coord','ca58303368b17874228d4c6e4d57c0d6',2,NULL,'https://i.pravatar.cc/150?img=2',1,'2025-10-13 14:20:01','2025-09-23 02:45:43','2025-10-13 14:20:01'),(3,'Elena Silva','participant@eco.com','part','$2y$10$405gnwmD0p78vZRB4mDJguJcc/dOyo0XnYqaqtwf2smcU39oyNAxi',3,NULL,'https://i.pravatar.cc/150?img=3',1,'2025-10-13 15:04:16','2025-09-23 02:45:43','2025-10-13 15:04:16'),(4,'Miguel Torres','miguel@eco.com','mtorres','$2y$10$CGSssAjDYolMbVtmo1ieY.5MoK/FQzk9XfnOhxLcNAg34uf90YdPG',3,NULL,'https://i.pravatar.cc/150?img=4',1,NULL,'2025-09-23 02:45:43','2025-10-13 02:34:16'),(6,'Jean Villalobos','jeancavc09@gmail.com','JeancaVC09','$2y$10$GwWz9FaJqyfpl/AywfG5DO/u7juWe3fQtB2XQsMX.T931oWdtNdtG',1,'LIMPIAVIDRIOS','',0,NULL,'2025-10-13 02:53:19','2025-10-13 03:00:06');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping routines for database 'eco_system'
--
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GenerateFinancialReport` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GenerateFinancialReport`(IN `project_id` INT, IN `period` VARCHAR(20))
BEGIN

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

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `UpdateProjectProgress` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateProjectProgress`(IN `project_id` INT)
BEGIN

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

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Final view structure for view `expense_details`
--

/*!50001 DROP VIEW IF EXISTS `expense_details`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `expense_details` AS select `e`.`id` AS `id`,`e`.`amount` AS `amount`,`e`.`description` AS `description`,`e`.`date` AS `date`,`e`.`status` AS `status`,`e`.`vendor` AS `vendor`,`e`.`receipt_number` AS `receipt_number`,`p`.`name` AS `project_name`,`ec`.`name` AS `category_name`,`ec`.`icon` AS `category_icon`,`ec`.`color` AS `category_color`,`b`.`total_amount` AS `budget_total`,`b`.`spent_amount` AS `budget_spent`,`u`.`name` AS `approved_by_name`,`e`.`created_at` AS `created_at` from ((((`expenses` `e` left join `projects` `p` on(`e`.`project_id` = `p`.`id`)) left join `expense_categories` `ec` on(`e`.`category_id` = `ec`.`id`)) left join `budgets` `b` on(`e`.`budget_id` = `b`.`id`)) left join `users` `u` on(`e`.`approved_by` = `u`.`id`)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `metric_details`
--

/*!50001 DROP VIEW IF EXISTS `metric_details`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `metric_details` AS select `m`.`id` AS `id`,`m`.`name` AS `name`,`m`.`unit` AS `unit`,`m`.`target_value` AS `target_value`,`m`.`current_value` AS `current_value`,`m`.`description` AS `description`,`p`.`name` AS `project_name`,`p`.`status` AS `project_status`,`mt`.`name` AS `metric_type_name`,`mt`.`category` AS `category`,`m`.`created_at` AS `created_at` from ((`metrics` `m` left join `projects` `p` on(`m`.`project_id` = `p`.`id`)) left join `metric_types` `mt` on(`m`.`metric_type_id` = `mt`.`id`)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `project_details`
--

/*!50001 DROP VIEW IF EXISTS `project_details`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `project_details` AS select `p`.`id` AS `id`,`p`.`name` AS `name`,`p`.`description` AS `description`,`p`.`start_date` AS `start_date`,`p`.`end_date` AS `end_date`,`p`.`status` AS `status`,`p`.`budget` AS `budget`,`p`.`progress` AS `progress`,`p`.`priority` AS `priority`,`u`.`name` AS `coordinator_name`,`u`.`email` AS `coordinator_email`,count(`pu`.`user_id`) AS `participant_count`,`p`.`created_at` AS `created_at` from ((`projects` `p` left join `users` `u` on(`p`.`creator_id` = `u`.`id`)) left join `project_users` `pu` on(`p`.`id` = `pu`.`project_id`)) group by `p`.`id` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `task_details`
--

/*!50001 DROP VIEW IF EXISTS `task_details`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `task_details` AS select `t`.`id` AS `id`,`t`.`title` AS `title`,`t`.`description` AS `description`,`t`.`status` AS `status`,`t`.`priority` AS `priority`,`t`.`due_date` AS `due_date`,`t`.`progress` AS `progress`,`t`.`estimated_hours` AS `estimated_hours`,`t`.`actual_hours` AS `actual_hours`,`p`.`name` AS `project_name`,`p`.`status` AS `project_status`,`u`.`name` AS `created_by_name`,group_concat(`ta_users`.`name` separator ', ') AS `assigned_users`,`t`.`created_at` AS `created_at` from ((((`tasks` `t` left join `projects` `p` on(`t`.`project_id` = `p`.`id`)) left join `users` `u` on(`t`.`created_by` = `u`.`id`)) left join `task_assignments` `ta` on(`t`.`id` = `ta`.`task_id`)) left join `users` `ta_users` on(`ta`.`user_id` = `ta_users`.`id`)) group by `t`.`id` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-10-13 11:27:43
