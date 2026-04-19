CREATE DATABASE  IF NOT EXISTS `g2rain_basis` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `g2rain_basis`;
-- MySQL dump 10.13  Distrib 8.0.41, for macos15 (arm64)
--
-- Host: 43.138.13.145    Database: g2rain_basis
-- ------------------------------------------------------
-- Server version	8.0.45

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `api_endpoint`
--

DROP TABLE IF EXISTS `api_endpoint`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `api_endpoint` (
  `id` bigint NOT NULL COMMENT '接口标识',
  `api_name` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '接口名称',
  `api_url` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '接口路径',
  `request_method` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '请求方法',
  `api_tag` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '接口标签, 接口分类',
  `description` varchar(512) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '业务说明',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT '0' COMMENT '记录版本',
  `delete_flag` tinyint NOT NULL DEFAULT '0' COMMENT '删除标识[0:未删除, 1:已删除]',
  PRIMARY KEY (`id`),
  KEY `uk_api_url_method` (`api_url`,`request_method`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='接口地址表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `api_endpoint`
--

LOCK TABLES `api_endpoint` WRITE;
/*!40000 ALTER TABLE `api_endpoint` DISABLE KEYS */;
INSERT INTO `api_endpoint` VALUES (123,'字典新增','/dict/save','POST','字典','e312','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0);
/*!40000 ALTER TABLE `api_endpoint` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `application`
--

DROP TABLE IF EXISTS `application`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `application` (
  `id` bigint NOT NULL COMMENT '应用标识',
  `organ_id` bigint NOT NULL COMMENT '机构标识',
  `application_name` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '应用名称',
  `application_code` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '应用编码',
  `can_integrate` tinyint NOT NULL DEFAULT '0' COMMENT '是否具备集成功能[0:否, 1:是]',
  `landing` tinyint NOT NULL DEFAULT '0' COMMENT '默认数据[0:否, 1:是]',
  `application_type` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '应用类型[SUPPORT:支撑, SYSTEM:系统提供, PUBLIC:第三方提供, PRIVATE:私有]',
  `public_key_algorithm` varchar(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '应用公钥算法',
  `public_key_format` varchar(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '应用公钥格式',
  `public_key` text COLLATE utf8mb4_unicode_ci COMMENT '应用公钥内容',
  `access_token_expires_in` int NOT NULL COMMENT '访问令牌生存时间(秒)',
  `refresh_token_expires_in` int NOT NULL COMMENT '刷新访问令牌生存时间(秒)',
  `endpoint_url` varchar(512) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '访问地址',
  `context_path` varchar(512) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '应用路径',
  `status` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'UNPUBLISHED' COMMENT '应用状态[PUBLISHED:已发布, UNPUBLISHED:未发布]',
  `description` varchar(512) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '业务说明',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT '0' COMMENT '记录版本',
  `delete_flag` tinyint NOT NULL DEFAULT '0' COMMENT '删除标识[0:未删除, 1:已删除]',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='应用表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `application`
--

LOCK TABLES `application` WRITE;
/*!40000 ALTER TABLE `application` DISABLE KEYS */;
INSERT INTO `application` VALUES (8,2,'综合管理平台','g2rain-main-shell',1,1,'SUPPORT','EC','PEM','-----BEGIN PUBLIC KEY-----\nMFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEXmlg1y2fUD9KJj4WB6DrRZU+iVwA\nyzz60AxRoFb2yDnBvYiiK9JR1p5QUw2jkR9RPvkZez1Kx2BqxwyOoWRV/A==\n-----END PUBLIC KEY-----\n',3600,86400,'http://127.0.0.1:3000','/main/','PUBLISHED','管理平台入口','2026-02-01 01:12:28','2026-02-08 12:09:48',0,0),(9,2,'支撑管理平台','g2rain-manager-app',0,1,'SUPPORT','EC','PEM','-----BEGIN PUBLIC KEY-----\nMFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEXGDOn5B+GFE42lcMd5u47r6na9iE\nH1AzxAU49KiWBz17su0M1vPZ+s57bvMlYvbcPG2nfWcJvJzRuKUakrUhsA==\n-----END PUBLIC KEY-----\n',3600,86400,'//43.138.13.145','/manager/','PUBLISHED','系统支撑功能','2026-02-01 01:12:28','2026-03-25 13:25:37',0,0),(4016,2,'健康管理应用','g2rain-health-app',0,0,'PUBLIC','EC','PEM','-----BEGIN PUBLIC KEY-----\r\nMFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEIySBrMJs3HJ0pNFPul1Az0onfD7+\r\nAW8APjyv5cDCNOUxiOJK1HrB3gQzMCg2BkMns2h6IjnQ849a6z9k5l9oKQ==\r\n-----END PUBLIC KEY-----',3600,86400,'//43.138.13.145','/h-app','PUBLISHED','','2026-04-01 14:00:15','2026-04-08 01:03:47',1,0),(4033,2,'技术支撑平台','g2rain-infra-app',0,0,'SUPPORT','EC','PEM','-----BEGIN PUBLIC KEY----- MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEAcmLmXDroj3aJiTFxP6oy5Q+3Tawz1LFg0BY1a5CRNynqpVvG+/wVGUhXf7KOJ7/nA2OO/H+IQaHryS+SXtnOA== -----END PUBLIC KEY-----',3600,86400,'//43.138.13.145','/infra','PUBLISHED','用于管理字典，路由转发等功能','2026-04-03 01:12:34','2026-04-11 04:03:39',0,0),(7006,2,'内容管理系统','g2rain-cms-app',0,0,'SYSTEM','EC','PEM','-----BEGIN PUBLIC KEY----- MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAE4z6oYfk8k/TTCzwhCMtzi6le8JTIg+dwCZECyLetKhkV8sVkjihmtEL6ak6i6W4tVYr8jcwY9Jm2q7AoscnO/g== -----END PUBLIC KEY-----',3600,86400,'//43.138.13.145','/cms','UNPUBLISHED','','2026-04-16 00:30:25','2026-04-16 00:34:17',1,0);
/*!40000 ALTER TABLE `application` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `application_authorization`
--

DROP TABLE IF EXISTS `application_authorization`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `application_authorization` (
  `id` bigint NOT NULL COMMENT '应用授权标识',
  `organ_id` bigint NOT NULL COMMENT '机构标识',
  `application_id` bigint NOT NULL COMMENT '应用标识',
  `control_domain_id` bigint NOT NULL COMMENT '控制域标识',
  `subscription_id` bigint DEFAULT NULL COMMENT '订阅标识',
  `status` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'ACTIVATED' COMMENT '应用授权状态[ACTIVATED:激活, DEACTIVATED:关停]',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT '0' COMMENT '记录版本',
  `delete_flag` tinyint NOT NULL DEFAULT '0' COMMENT '删除标识[0:未删除, 1:已删除]',
  PRIMARY KEY (`id`),
  KEY `idx_application_id` (`application_id`),
  KEY `idx_control_domain_id` (`control_domain_id`),
  KEY `idx_organ_st_del_app` (`organ_id`,`status`,`delete_flag`,`application_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='应用授权记录表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `application_authorization`
--

LOCK TABLES `application_authorization` WRITE;
/*!40000 ALTER TABLE `application_authorization` DISABLE KEYS */;
INSERT INTO `application_authorization` VALUES (4042,4020,4016,4040,NULL,'ACTIVATED','2026-04-08 12:14:32','2026-04-08 12:15:50',0,0),(4063,4002,4016,4040,NULL,'ACTIVATED','2026-04-09 15:07:45','2026-04-09 15:07:45',0,0),(4065,2027,4016,4040,NULL,'ACTIVATED','2026-04-09 15:08:39','2026-04-09 15:08:39',0,0),(4067,3009,4016,4040,NULL,'ACTIVATED','2026-04-09 15:09:00','2026-04-09 15:09:00',0,0),(4080,2,4033,4078,NULL,'ACTIVATED','2026-04-11 04:18:40','2026-04-11 04:18:40',0,0),(8095,4002,7006,8004,NULL,'ACTIVATED','2026-04-19 08:16:51','2026-04-19 08:16:51',0,0);
/*!40000 ALTER TABLE `application_authorization` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `application_suite`
--

DROP TABLE IF EXISTS `application_suite`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `application_suite` (
  `id` bigint NOT NULL COMMENT '主键标识',
  `application_id` bigint NOT NULL COMMENT '应用标识',
  `master_application_id` bigint NOT NULL COMMENT '主应用标识',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT '0' COMMENT '记录版本',
  `delete_flag` tinyint NOT NULL DEFAULT '0' COMMENT '删除标识[0:未删除, 1:已删除]',
  PRIMARY KEY (`id`),
  KEY `uk_application_id` (`application_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='应用归类关系表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `application_suite`
--

LOCK TABLES `application_suite` WRITE;
/*!40000 ALTER TABLE `application_suite` DISABLE KEYS */;
INSERT INTO `application_suite` VALUES (10,9,8,'2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(6001,4033,8,'2026-04-13 01:20:22','2026-04-13 01:20:22',0,0),(7007,7006,8,'2026-04-16 00:30:41','2026-04-16 00:30:41',0,0);
/*!40000 ALTER TABLE `application_suite` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `control_domain`
--

DROP TABLE IF EXISTS `control_domain`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `control_domain` (
  `id` bigint NOT NULL COMMENT '控制域标识',
  `application_id` bigint NOT NULL COMMENT '应用标识',
  `control_domain_name` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '控制域名称',
  `control_domain_type` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '控制域类型[TRADE("交易开通"), APPLICATION("应用授权开通")]',
  `control_domain_scope` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '交付范围[CUSTOMER("客户交付"), OPERATION("平台运营")]',
  `description` text COLLATE utf8mb4_unicode_ci COMMENT '业务说明',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT '0' COMMENT '记录版本',
  `delete_flag` tinyint NOT NULL DEFAULT '0' COMMENT '删除标识[0:未删除, 1:已删除]',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='控制域表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `control_domain`
--

LOCK TABLES `control_domain` WRITE;
/*!40000 ALTER TABLE `control_domain` DISABLE KEYS */;
INSERT INTO `control_domain` VALUES (4040,4016,'C端业务能力','APPLICATION','CUSTOMER','健康管理相关C端业务能力','2026-04-08 11:56:10','2026-04-08 11:56:10',0,0),(4078,4033,'平台技术配置','APPLICATION','OPERATION','本业务主要用于支撑平台技术相关设置','2026-04-11 04:17:46','2026-04-11 04:17:46',0,0),(8004,7006,'内容管理','APPLICATION','CUSTOMER','内容管理平台','2026-04-17 00:40:59','2026-04-17 00:40:59',0,0);
/*!40000 ALTER TABLE `control_domain` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `control_domain_control_unit_relation`
--

DROP TABLE IF EXISTS `control_domain_control_unit_relation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `control_domain_control_unit_relation` (
  `id` bigint NOT NULL COMMENT '主键标识',
  `control_domain_id` bigint NOT NULL COMMENT '控制域标识',
  `control_unit_id` bigint NOT NULL COMMENT '控制单元标识',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT '0' COMMENT '记录版本',
  `delete_flag` tinyint NOT NULL DEFAULT '0' COMMENT '删除标识[0:未删除, 1:已删除]',
  PRIMARY KEY (`id`),
  KEY `idx_control_domain_unit` (`control_domain_id`,`control_unit_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='控制域控制单元关联表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `control_domain_control_unit_relation`
--

LOCK TABLES `control_domain_control_unit_relation` WRITE;
/*!40000 ALTER TABLE `control_domain_control_unit_relation` DISABLE KEYS */;
INSERT INTO `control_domain_control_unit_relation` VALUES (4041,4040,4039,'2026-04-08 11:58:36','2026-04-08 11:58:36',0,0),(4079,4078,4069,'2026-04-11 04:18:27','2026-04-11 04:18:27',0,0),(8094,8004,8005,'2026-04-19 08:10:26','2026-04-19 08:10:26',0,0);
/*!40000 ALTER TABLE `control_domain_control_unit_relation` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `control_unit`
--

DROP TABLE IF EXISTS `control_unit`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `control_unit` (
  `id` bigint NOT NULL COMMENT '控制单元标识',
  `application_id` bigint NOT NULL COMMENT '应用标识',
  `control_unit_name` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '控制单元名称',
  `control_unit_scope` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '控制单元类型[OPERATION("运营功能"), CUSTOMER("客户功能"), PERPETUAL("永久有效功能")]',
  `landing` tinyint NOT NULL DEFAULT '0' COMMENT '默认数据[0:否, 1:是]',
  `status` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'UNPUBLISHED' COMMENT '控制单元状态[PUBLISHED:已发布, UNPUBLISHED:未发布]',
  `description` varchar(512) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '业务说明',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT '0' COMMENT '记录版本',
  `delete_flag` tinyint NOT NULL DEFAULT '0' COMMENT '删除标识[0:未删除, 1:已删除]',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='控制单元表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `control_unit`
--

LOCK TABLES `control_unit` WRITE;
/*!40000 ALTER TABLE `control_unit` DISABLE KEYS */;
INSERT INTO `control_unit` VALUES (11,8,'盘古','PERPETUAL',1,'PUBLISHED','平台准入基础能力','2026-02-01 01:12:28','2026-04-08 12:11:13',2,0),(12,9,'燧人氏','OPERATION',1,'PUBLISHED','核心运营支撑组件','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(15,9,'女娲','CUSTOMER',1,'PUBLISHED','租户空间构建逻辑','2026-02-01 01:12:28','2026-04-08 12:12:10',1,0),(4039,4016,'C端用户权限','CUSTOMER',0,'PUBLISHED','C端用户访问权限','2026-04-08 11:55:26','2026-04-08 11:58:28',1,0),(4069,4033,'后羿','OPERATION',0,'PUBLISHED','主要保障平台技术相关能力','2026-04-11 04:05:27','2026-04-13 14:49:54',4,0),(8005,7006,'内容管理全功能','CUSTOMER',0,'PUBLISHED','','2026-04-17 00:41:25','2026-04-19 08:10:17',2,0);
/*!40000 ALTER TABLE `control_unit` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `control_unit_resource_relation`
--

DROP TABLE IF EXISTS `control_unit_resource_relation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `control_unit_resource_relation` (
  `id` bigint NOT NULL COMMENT '主键标识',
  `control_unit_id` bigint NOT NULL COMMENT '控制单元标识',
  `resource_id` bigint NOT NULL COMMENT '资源标识',
  `resource_type` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '资源类型[MENU:菜单, PAGE:页面, PAGE_ELEMENT:页面元素, API_ENDPOINT:接口地址]',
  `status` varchar(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '激活状态[VISIBLE:显示, ENABLED:可用]',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT '0' COMMENT '记录版本',
  `delete_flag` tinyint NOT NULL DEFAULT '0' COMMENT '删除标识[0:未删除, 1:已删除]',
  PRIMARY KEY (`id`),
  KEY `idx_cu_type_del_res` (`control_unit_id`,`resource_type`,`delete_flag`,`resource_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='控制单元资源关联表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `control_unit_resource_relation`
--

LOCK TABLES `control_unit_resource_relation` WRITE;
/*!40000 ALTER TABLE `control_unit_resource_relation` DISABLE KEYS */;
INSERT INTO `control_unit_resource_relation` VALUES (120,11,17,'MENU',NULL,'2026-02-01 01:12:28','2026-03-25 12:56:46',1,1),(121,11,18,'MENU',NULL,'2026-02-01 01:12:28','2026-03-25 12:56:46',1,1),(122,12,19,'MENU',NULL,'2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(123,12,20,'MENU',NULL,'2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(125,12,21,'MENU',NULL,'2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(126,12,22,'MENU',NULL,'2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(127,12,23,'MENU',NULL,'2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(128,12,25,'MENU',NULL,'2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(129,12,26,'MENU',NULL,'2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(130,12,27,'MENU',NULL,'2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(131,12,28,'MENU',NULL,'2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(132,12,29,'MENU',NULL,'2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(133,12,30,'MENU',NULL,'2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(135,12,31,'MENU',NULL,'2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(136,12,32,'MENU',NULL,'2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(137,12,33,'MENU',NULL,'2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(138,12,35,'MENU',NULL,'2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(139,12,36,'MENU',NULL,'2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(150,12,37,'MENU',NULL,'2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(151,15,19,'MENU',NULL,'2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(152,15,20,'MENU',NULL,'2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(153,15,21,'MENU',NULL,'2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(155,15,22,'MENU',NULL,'2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(156,15,23,'MENU',NULL,'2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(157,15,25,'MENU',NULL,'2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(158,15,32,'MENU',NULL,'2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(159,11,38,'PAGE',NULL,'2026-02-01 01:12:28','2026-03-25 12:56:55',1,1),(160,12,39,'PAGE',NULL,'2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(161,12,50,'PAGE',NULL,'2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(162,12,51,'PAGE',NULL,'2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(163,12,52,'PAGE',NULL,'2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(165,12,53,'PAGE',NULL,'2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(166,12,55,'PAGE',NULL,'2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(167,12,56,'PAGE',NULL,'2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(168,12,57,'PAGE',NULL,'2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(169,12,58,'PAGE',NULL,'2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(170,12,59,'PAGE',NULL,'2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(171,12,60,'PAGE',NULL,'2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(172,12,61,'PAGE',NULL,'2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(173,12,62,'PAGE',NULL,'2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(175,15,39,'PAGE',NULL,'2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(176,15,50,'PAGE',NULL,'2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(177,15,51,'PAGE',NULL,'2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(178,15,52,'PAGE',NULL,'2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(179,15,60,'PAGE',NULL,'2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(180,11,63,'PAGE_ELEMENT','ENABLED','2026-02-01 01:12:28','2026-03-25 12:56:55',1,1),(181,12,65,'PAGE_ELEMENT','ENABLED','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(182,12,66,'PAGE_ELEMENT','ENABLED','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(183,12,67,'PAGE_ELEMENT','ENABLED','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(185,12,68,'PAGE_ELEMENT','ENABLED','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(186,12,69,'PAGE_ELEMENT','ENABLED','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(187,12,70,'PAGE_ELEMENT','ENABLED','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(188,12,71,'PAGE_ELEMENT','ENABLED','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(189,12,72,'PAGE_ELEMENT','ENABLED','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(190,12,73,'PAGE_ELEMENT','ENABLED','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(191,12,75,'PAGE_ELEMENT','ENABLED','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(192,12,76,'PAGE_ELEMENT','ENABLED','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(193,12,77,'PAGE_ELEMENT','ENABLED','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(195,12,78,'PAGE_ELEMENT','ENABLED','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(196,12,79,'PAGE_ELEMENT','ENABLED','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(197,12,80,'PAGE_ELEMENT','ENABLED','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(198,12,81,'PAGE_ELEMENT','ENABLED','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(199,12,82,'PAGE_ELEMENT','ENABLED','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(200,12,83,'PAGE_ELEMENT','ENABLED','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(201,12,85,'PAGE_ELEMENT','ENABLED','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(202,12,86,'PAGE_ELEMENT','ENABLED','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(203,12,87,'PAGE_ELEMENT','ENABLED','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(205,12,88,'PAGE_ELEMENT','ENABLED','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(206,12,89,'PAGE_ELEMENT','ENABLED','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(207,12,90,'PAGE_ELEMENT','ENABLED','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(208,12,91,'PAGE_ELEMENT','ENABLED','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(209,12,92,'PAGE_ELEMENT','ENABLED','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(210,12,93,'PAGE_ELEMENT','ENABLED','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(211,12,95,'PAGE_ELEMENT','ENABLED','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(212,12,96,'PAGE_ELEMENT','ENABLED','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(213,12,97,'PAGE_ELEMENT','ENABLED','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(215,12,98,'PAGE_ELEMENT','ENABLED','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(216,12,99,'PAGE_ELEMENT','ENABLED','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(217,12,100,'PAGE_ELEMENT','ENABLED','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(218,12,101,'PAGE_ELEMENT','ENABLED','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(219,12,102,'PAGE_ELEMENT','ENABLED','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(220,12,103,'PAGE_ELEMENT','ENABLED','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(221,12,105,'PAGE_ELEMENT','ENABLED','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(222,12,106,'PAGE_ELEMENT','ENABLED','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(223,12,107,'PAGE_ELEMENT','ENABLED','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(225,12,108,'PAGE_ELEMENT','ENABLED','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(226,12,109,'PAGE_ELEMENT','ENABLED','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(227,12,110,'PAGE_ELEMENT','ENABLED','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(228,12,111,'PAGE_ELEMENT','ENABLED','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(229,12,112,'PAGE_ELEMENT','ENABLED','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(230,12,113,'PAGE_ELEMENT','ENABLED','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(231,12,115,'PAGE_ELEMENT','ENABLED','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(232,12,116,'PAGE_ELEMENT','ENABLED','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(233,12,117,'PAGE_ELEMENT','ENABLED','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(235,12,118,'PAGE_ELEMENT','ENABLED','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(236,12,119,'PAGE_ELEMENT','ENABLED','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(237,15,65,'PAGE_ELEMENT','ENABLED','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(238,15,66,'PAGE_ELEMENT','ENABLED','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(239,15,67,'PAGE_ELEMENT','ENABLED','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(260,15,68,'PAGE_ELEMENT','ENABLED','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(261,15,69,'PAGE_ELEMENT','ENABLED','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(262,15,70,'PAGE_ELEMENT','ENABLED','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(263,15,71,'PAGE_ELEMENT','ENABLED','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(265,15,72,'PAGE_ELEMENT','ENABLED','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(266,15,73,'PAGE_ELEMENT','ENABLED','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(267,15,75,'PAGE_ELEMENT','ENABLED','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(268,15,76,'PAGE_ELEMENT','ENABLED','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(269,15,77,'PAGE_ELEMENT','ENABLED','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(270,15,78,'PAGE_ELEMENT','ENABLED','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(271,15,110,'PAGE_ELEMENT','ENABLED','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(4089,4069,4070,'MENU',NULL,'2026-04-11 07:25:33','2026-04-12 11:01:19',1,1),(4090,4069,4071,'MENU',NULL,'2026-04-11 07:25:33','2026-04-11 07:25:33',0,0),(4091,4069,4072,'MENU',NULL,'2026-04-11 07:25:33','2026-04-12 11:01:19',1,1),(4092,4069,4073,'MENU',NULL,'2026-04-11 07:25:33','2026-04-11 07:25:33',0,0),(4093,4069,4074,'MENU',NULL,'2026-04-11 07:25:33','2026-04-11 07:25:33',0,0),(4094,4069,4075,'MENU',NULL,'2026-04-11 07:25:33','2026-04-11 07:25:33',0,0),(4095,4069,4076,'MENU',NULL,'2026-04-11 07:25:33','2026-04-11 07:25:33',0,0),(4096,4069,4077,'MENU',NULL,'2026-04-11 07:25:33','2026-04-11 07:25:33',0,0),(4097,4069,4082,'PAGE',NULL,'2026-04-11 07:25:44','2026-04-11 07:25:44',0,0),(4098,4069,4083,'PAGE',NULL,'2026-04-11 07:25:44','2026-04-12 11:01:29',1,1),(4099,4069,4084,'PAGE',NULL,'2026-04-11 07:25:44','2026-04-11 07:25:44',0,0),(4100,4069,4085,'PAGE',NULL,'2026-04-11 07:25:44','2026-04-11 07:25:44',0,0),(4101,4069,4086,'PAGE',NULL,'2026-04-11 07:25:44','2026-04-11 07:25:44',0,0),(4102,4069,4087,'PAGE',NULL,'2026-04-11 07:25:44','2026-04-11 07:25:44',0,0),(4103,4069,4088,'PAGE',NULL,'2026-04-11 07:25:44','2026-04-11 07:25:44',0,0),(4125,4069,4113,'PAGE_ELEMENT','ENABLED','2026-04-11 14:22:41','2026-04-11 14:22:41',0,0),(4126,4069,4114,'PAGE_ELEMENT','ENABLED','2026-04-11 14:22:41','2026-04-11 14:22:41',0,0),(4127,4069,4115,'PAGE_ELEMENT','ENABLED','2026-04-11 14:22:41','2026-04-11 14:22:41',0,0),(4128,4069,4107,'PAGE_ELEMENT','ENABLED','2026-04-11 14:22:41','2026-04-12 11:01:29',1,1),(4129,4069,4108,'PAGE_ELEMENT','ENABLED','2026-04-11 14:22:41','2026-04-12 11:01:29',1,1),(4130,4069,4109,'PAGE_ELEMENT','ENABLED','2026-04-11 14:22:41','2026-04-12 11:01:29',1,1),(4131,4069,4110,'PAGE_ELEMENT','ENABLED','2026-04-11 14:22:41','2026-04-11 14:22:41',0,0),(4132,4069,4111,'PAGE_ELEMENT','ENABLED','2026-04-11 14:22:41','2026-04-11 14:22:41',0,0),(4133,4069,4112,'PAGE_ELEMENT','ENABLED','2026-04-11 14:22:41','2026-04-11 14:22:41',0,0),(4134,4069,4122,'PAGE_ELEMENT','ENABLED','2026-04-11 14:22:41','2026-04-11 14:22:41',0,0),(4135,4069,4123,'PAGE_ELEMENT','ENABLED','2026-04-11 14:22:41','2026-04-11 14:22:41',0,0),(4136,4069,4124,'PAGE_ELEMENT','ENABLED','2026-04-11 14:22:41','2026-04-11 14:22:41',0,0),(4137,4069,4119,'PAGE_ELEMENT','ENABLED','2026-04-11 14:22:41','2026-04-11 14:22:41',0,0),(4138,4069,4120,'PAGE_ELEMENT','ENABLED','2026-04-11 14:22:41','2026-04-11 14:22:41',0,0),(4139,4069,4121,'PAGE_ELEMENT','ENABLED','2026-04-11 14:22:41','2026-04-11 14:22:41',0,0),(4140,4069,4116,'PAGE_ELEMENT','ENABLED','2026-04-11 14:22:41','2026-04-11 14:22:41',0,0),(4141,4069,4117,'PAGE_ELEMENT','ENABLED','2026-04-11 14:22:41','2026-04-11 14:22:41',0,0),(4142,4069,4118,'PAGE_ELEMENT','ENABLED','2026-04-11 14:22:41','2026-04-11 14:22:41',0,0),(4143,4069,4104,'PAGE_ELEMENT','ENABLED','2026-04-11 14:22:41','2026-04-11 14:22:41',0,0),(4144,4069,4105,'PAGE_ELEMENT','ENABLED','2026-04-11 14:22:41','2026-04-11 14:22:41',0,0),(4145,4069,4106,'PAGE_ELEMENT','ENABLED','2026-04-11 14:22:41','2026-04-11 14:22:41',0,0),(4154,4069,4148,'PAGE_ELEMENT','ENABLED','2026-04-12 14:14:05','2026-04-12 14:15:14',1,1),(4155,4069,4149,'PAGE_ELEMENT','ENABLED','2026-04-12 14:14:05','2026-04-12 14:14:05',0,0),(4156,4069,4150,'PAGE_ELEMENT','ENABLED','2026-04-12 14:14:05','2026-04-12 14:14:05',0,0),(4157,4069,4151,'PAGE_ELEMENT','ENABLED','2026-04-12 14:14:05','2026-04-12 14:14:05',0,0),(4158,4069,4152,'PAGE_ELEMENT','ENABLED','2026-04-12 14:14:05','2026-04-12 14:14:05',0,0),(4159,4069,4153,'PAGE_ELEMENT','ENABLED','2026-04-12 14:14:05','2026-04-12 14:14:05',0,0),(7001,4069,4070,'MENU',NULL,'2026-04-13 14:40:47','2026-04-13 14:40:47',0,0),(8054,8005,8046,'MENU',NULL,'2026-04-19 08:09:28','2026-04-19 08:09:28',0,0),(8055,8005,8047,'MENU',NULL,'2026-04-19 08:09:28','2026-04-19 08:09:28',0,0),(8056,8005,8048,'MENU',NULL,'2026-04-19 08:09:28','2026-04-19 08:09:28',0,0),(8057,8005,8049,'MENU',NULL,'2026-04-19 08:09:28','2026-04-19 08:09:28',0,0),(8058,8005,8051,'MENU',NULL,'2026-04-19 08:09:28','2026-04-19 08:09:28',0,0),(8059,8005,8050,'MENU',NULL,'2026-04-19 08:09:28','2026-04-19 08:09:28',0,0),(8060,8005,8052,'MENU',NULL,'2026-04-19 08:09:28','2026-04-19 08:09:28',0,0),(8061,8005,8053,'MENU',NULL,'2026-04-19 08:09:28','2026-04-19 08:09:28',0,0),(8062,8005,8014,'PAGE',NULL,'2026-04-19 08:09:28','2026-04-19 08:09:28',0,0),(8063,8005,8015,'PAGE',NULL,'2026-04-19 08:09:28','2026-04-19 08:09:28',0,0),(8064,8005,8016,'PAGE',NULL,'2026-04-19 08:09:28','2026-04-19 08:09:28',0,0),(8065,8005,8017,'PAGE',NULL,'2026-04-19 08:09:28','2026-04-19 08:09:28',0,0),(8066,8005,8018,'PAGE',NULL,'2026-04-19 08:09:28','2026-04-19 08:09:28',0,0),(8067,8005,8019,'PAGE',NULL,'2026-04-19 08:09:28','2026-04-19 08:09:28',0,0),(8068,8005,8020,'PAGE',NULL,'2026-04-19 08:09:28','2026-04-19 08:09:28',0,0),(8069,8005,8021,'PAGE',NULL,'2026-04-19 08:09:28','2026-04-19 08:09:28',0,0),(8070,8005,8037,'PAGE_ELEMENT','ENABLED','2026-04-19 08:09:28','2026-04-19 08:09:28',0,0),(8071,8005,8038,'PAGE_ELEMENT','ENABLED','2026-04-19 08:09:28','2026-04-19 08:09:28',0,0),(8072,8005,8039,'PAGE_ELEMENT','ENABLED','2026-04-19 08:09:28','2026-04-19 08:09:28',0,0),(8073,8005,8031,'PAGE_ELEMENT','ENABLED','2026-04-19 08:09:28','2026-04-19 08:09:28',0,0),(8074,8005,8032,'PAGE_ELEMENT','ENABLED','2026-04-19 08:09:28','2026-04-19 08:09:28',0,0),(8075,8005,8033,'PAGE_ELEMENT','ENABLED','2026-04-19 08:09:28','2026-04-19 08:09:28',0,0),(8076,8005,8028,'PAGE_ELEMENT','ENABLED','2026-04-19 08:09:28','2026-04-19 08:09:28',0,0),(8077,8005,8029,'PAGE_ELEMENT','ENABLED','2026-04-19 08:09:28','2026-04-19 08:09:28',0,0),(8078,8005,8030,'PAGE_ELEMENT','ENABLED','2026-04-19 08:09:28','2026-04-19 08:09:28',0,0),(8079,8005,8034,'PAGE_ELEMENT','ENABLED','2026-04-19 08:09:28','2026-04-19 08:09:28',0,0),(8080,8005,8035,'PAGE_ELEMENT','ENABLED','2026-04-19 08:09:28','2026-04-19 08:09:28',0,0),(8081,8005,8036,'PAGE_ELEMENT','ENABLED','2026-04-19 08:09:28','2026-04-19 08:09:28',0,0),(8082,8005,8040,'PAGE_ELEMENT','ENABLED','2026-04-19 08:09:28','2026-04-19 08:09:28',0,0),(8083,8005,8041,'PAGE_ELEMENT','ENABLED','2026-04-19 08:09:28','2026-04-19 08:09:28',0,0),(8084,8005,8042,'PAGE_ELEMENT','ENABLED','2026-04-19 08:09:28','2026-04-19 08:09:28',0,0),(8085,8005,8025,'PAGE_ELEMENT','ENABLED','2026-04-19 08:09:28','2026-04-19 08:09:28',0,0),(8086,8005,8026,'PAGE_ELEMENT','ENABLED','2026-04-19 08:09:28','2026-04-19 08:09:28',0,0),(8087,8005,8027,'PAGE_ELEMENT','ENABLED','2026-04-19 08:09:28','2026-04-19 08:09:28',0,0),(8088,8005,8043,'PAGE_ELEMENT','ENABLED','2026-04-19 08:09:28','2026-04-19 08:09:28',0,0),(8089,8005,8044,'PAGE_ELEMENT','ENABLED','2026-04-19 08:09:28','2026-04-19 08:09:28',0,0),(8090,8005,8045,'PAGE_ELEMENT','ENABLED','2026-04-19 08:09:28','2026-04-19 08:09:28',0,0),(8091,8005,8022,'PAGE_ELEMENT','ENABLED','2026-04-19 08:09:28','2026-04-19 08:09:28',0,0),(8092,8005,8023,'PAGE_ELEMENT','ENABLED','2026-04-19 08:09:28','2026-04-19 08:09:28',0,0),(8093,8005,8024,'PAGE_ELEMENT','ENABLED','2026-04-19 08:09:28','2026-04-19 08:09:28',0,0);
/*!40000 ALTER TABLE `control_unit_resource_relation` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `login_token`
--

DROP TABLE IF EXISTS `login_token`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `login_token` (
  `id` bigint NOT NULL COMMENT '主键标识',
  `session_type` varchar(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '会话类型',
  `organ_id` bigint DEFAULT NULL COMMENT '机构标识',
  `organ_type` varchar(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '机构类型',
  `admin_company` tinyint NOT NULL DEFAULT '0' COMMENT '运营标记[0:否, 1:是]',
  `passport_id` bigint DEFAULT NULL COMMENT '账号标识',
  `user_id` bigint DEFAULT NULL COMMENT '用户标识',
  `real_name` varchar(128) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '真实姓名',
  `admin_user` tinyint NOT NULL DEFAULT '0' COMMENT '管理员标记[0:否, 1:是]',
  `application_id` bigint DEFAULT NULL COMMENT '应用标识',
  `application_organ_id` bigint DEFAULT NULL COMMENT '应用组织标识',
  `client_id` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '客户端ID',
  `lastest_refresh_time` timestamp NULL DEFAULT NULL COMMENT '最近一次刷新时间',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT '0' COMMENT '记录版本',
  `delete_flag` tinyint NOT NULL DEFAULT '0' COMMENT '删除标识[0:未删除, 1:已删除]',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='登录信息表, 记录了当前登录状态的相关信息';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `login_token`
--

LOCK TABLES `login_token` WRITE;
/*!40000 ALTER TABLE `login_token` DISABLE KEYS */;
/*!40000 ALTER TABLE `login_token` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `organ`
--

DROP TABLE IF EXISTS `organ`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `organ` (
  `id` bigint NOT NULL COMMENT '机构标识',
  `organ_name` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '机构名称',
  `organ_type` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '机构类型[服务商、渠道、公司、租户]',
  `status` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'ACTIVE' COMMENT '机构状态[ACTIVE:有效, INACTIVE:无效]',
  `admin` tinyint NOT NULL DEFAULT '0' COMMENT '运营标记[0:否, 1:是]',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT '0' COMMENT '记录版本',
  `delete_flag` tinyint NOT NULL DEFAULT '0' COMMENT '删除标识[0:未删除, 1:已删除]',
  PRIMARY KEY (`id`),
  KEY `idx_organ_name` (`organ_name`),
  KEY `idx_organ_type` (`organ_type`),
  KEY `idx_organ_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='机构表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `organ`
--

LOCK TABLES `organ` WRITE;
/*!40000 ALTER TABLE `organ` DISABLE KEYS */;
INSERT INTO `organ` VALUES (2,'平台机构','COMPANY','ACTIVE',1,'2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(2021,'爱国统一战线','COMPANY','ACTIVE',0,'2026-02-06 08:57:34','2026-02-06 08:57:34',0,0),(2027,'铁血救国会','TENANT','ACTIVE',0,'2026-02-06 09:00:56','2026-04-19 08:54:27',1,0),(3002,'test','TENANT','ACTIVE',0,'2026-03-17 11:59:22','2026-03-17 11:59:22',0,0),(3009,'测试租户2','TENANT','ACTIVE',0,'2026-03-18 14:27:30','2026-03-18 14:27:30',0,0),(3015,'测试003','TENANT','ACTIVE',0,'2026-03-18 14:31:38','2026-03-18 14:31:38',0,0),(3022,'测试004','TENANT','ACTIVE',0,'2026-03-19 00:15:49','2026-03-19 00:15:49',0,0),(3028,'测试0031','TENANT','ACTIVE',0,'2026-03-19 00:24:40','2026-03-19 00:24:40',0,0),(4002,'sun001测试-cms验证','TENANT','ACTIVE',0,'2026-03-25 14:47:08','2026-04-19 09:08:09',1,0),(4010,'AI智能问问','TENANT','ACTIVE',0,'2026-03-30 06:21:18','2026-03-30 06:21:18',0,0),(4020,'H001','TENANT','ACTIVE',0,'2026-04-02 12:49:30','2026-04-02 12:49:30',0,0),(4027,'孙豪杰测试','TENANT','ACTIVE',0,'2026-04-03 00:25:03','2026-04-03 00:25:03',0,0);
/*!40000 ALTER TABLE `organ` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `organ_closure`
--

DROP TABLE IF EXISTS `organ_closure`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `organ_closure` (
  `id` bigint NOT NULL COMMENT '主键标识',
  `ancestor_id` bigint NOT NULL COMMENT '祖先机构标识[上级]',
  `descendant_id` bigint NOT NULL COMMENT '后代机构标识[下级]',
  `descendant_type` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '后代机构类型[服务商、渠道、公司、租户]',
  `relation_type` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '关系类型[SELF_ASSOCIATION:自身关联, DIRECT_SUBORDINATE:直属, INDIRECT_SUBORDINATE:从属]',
  `path_count` int NOT NULL DEFAULT '1' COMMENT '路径引用次数[用于DAG交叉挂载维护]',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT '0' COMMENT '记录版本',
  `delete_flag` tinyint NOT NULL DEFAULT '0' COMMENT '删除标识[0:未删除, 1:已删除]',
  PRIMARY KEY (`id`),
  KEY `idx_ancestor_id` (`ancestor_id`),
  KEY `idx_descendant_id` (`descendant_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='机构路径关系表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `organ_closure`
--

LOCK TABLES `organ_closure` WRITE;
/*!40000 ALTER TABLE `organ_closure` DISABLE KEYS */;
INSERT INTO `organ_closure` VALUES (3,2,2,'COMPANY','SELF_ASSOCIATION',1,'2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(2022,2021,2021,'COMPANY','SELF_ASSOCIATION',1,'2026-02-06 08:57:34','2026-02-06 08:57:34',0,0),(2028,2027,2027,'TENANT','SELF_ASSOCIATION',1,'2026-02-06 09:00:56','2026-02-06 09:00:56',0,0),(2029,2021,2027,'TENANT','DIRECT_SUBORDINATE',1,'2026-02-06 09:00:56','2026-02-06 09:00:56',0,0),(3003,3002,3002,'TENANT','SELF_ASSOCIATION',1,'2026-03-17 11:59:22','2026-03-17 11:59:22',0,0),(3010,3009,3009,'TENANT','SELF_ASSOCIATION',1,'2026-03-18 14:27:30','2026-03-18 14:27:30',0,0),(3016,3015,3015,'TENANT','SELF_ASSOCIATION',1,'2026-03-18 14:31:38','2026-03-18 14:31:38',0,0),(3023,3022,3022,'TENANT','SELF_ASSOCIATION',1,'2026-03-19 00:15:49','2026-03-19 00:15:49',0,0),(3029,3028,3028,'TENANT','SELF_ASSOCIATION',1,'2026-03-19 00:24:40','2026-03-19 00:24:40',0,0),(4003,4002,4002,'TENANT','SELF_ASSOCIATION',1,'2026-03-25 14:47:08','2026-03-25 14:47:08',0,0),(4011,4010,4010,'TENANT','SELF_ASSOCIATION',1,'2026-03-30 06:21:18','2026-03-30 06:21:18',0,0),(4021,4020,4020,'TENANT','SELF_ASSOCIATION',1,'2026-04-02 12:49:30','2026-04-02 12:49:30',0,0),(4028,4027,4027,'TENANT','SELF_ASSOCIATION',1,'2026-04-03 00:25:03','2026-04-03 00:25:03',0,0);
/*!40000 ALTER TABLE `organ_closure` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `passport`
--

DROP TABLE IF EXISTS `passport`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `passport` (
  `id` bigint NOT NULL COMMENT '账号标识',
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '登录用户',
  `password` varchar(256) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT '登录密码',
  `real_name` varchar(128) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '真实姓名',
  `sex` varchar(12) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '性别[MALE:男性, FEMALE:女性]',
  `birthday` varchar(16) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '生日',
  `id_no` varchar(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '身份证号',
  `mobile` varchar(32) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '手机号码',
  `email` varchar(128) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '邮箱地址',
  `status` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'NORMAL' COMMENT '状态[NORMAL:正常, FROZEN:冻结]',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT '0' COMMENT '记录版本',
  `delete_flag` tinyint NOT NULL DEFAULT '0' COMMENT '删除标识[0:未删除, 1:已删除]',
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  KEY `idx_username` (`username`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='账号表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `passport`
--

LOCK TABLES `passport` WRITE;
/*!40000 ALTER TABLE `passport` DISABLE KEYS */;
INSERT INTO `passport` VALUES (1,'admin','PBKDF2WithHmacSHA256$65536$YSskABrEQZiuRcM3GMl6gQ==$Hl9gA9UnYmS1BoY3Ov3XY2qYQpUKF1Sl0QneYZ5zc7k=','平台超管','MALE','2026-03-01','','','','NORMAL','2026-02-01 01:12:28','2026-03-12 00:56:52',1,0),(2020,'alpha','PBKDF2WithHmacSHA256$65536$YXfMO73+s4QDNhQrykQdwA==$SAMS54bJpTOA0W3oxxeq2GEl9MGwkOpuNGr+31lhRJw=','alpha','MALE','','','','','NORMAL','2026-02-06 08:56:30','2026-02-06 08:56:30',0,0),(3001,'test','PBKDF2WithHmacSHA256$65536$pnnIyOjRT72rve+xIKv9lg==$WrLk3CWCcaabexydGRjTQOIbRW1T1gGfpKVQkCtTGaU=','测试','MALE','','','','','NORMAL','2026-03-17 11:25:38','2026-03-17 11:25:38',0,0),(3008,'test2','PBKDF2WithHmacSHA256$65536$thM3eiYNJho7Plk6CVwInA==$/SICKuekgw0888BjTEJx+eti0I0Gx66kifYE+oK5bu8=','测试2','MALE','','','','','NORMAL','2026-03-18 14:26:49','2026-03-18 14:26:49',0,0),(3021,'test003','PBKDF2WithHmacSHA256$65536$ju92FLVaOEvY6Cpd/ecTDg==$oCAjWGcRIgqTpYosrmlt4wKqX1z5k5vXgLJZiMfcO0Q=','孙豪杰','','','','','','NORMAL','2026-03-19 00:14:41','2026-03-19 00:14:41',0,0),(3034,'test004','PBKDF2WithHmacSHA256$65536$SR6e6s7pV4WFJDddWHuDCA==$63IDb6R5nZHNazUoBFJED8eUUAkuNfAEsVodNft7owI=','孙豪杰','MALE','','','','','NORMAL','2026-03-19 12:50:26','2026-03-19 12:50:26',0,0),(4001,'sun001','PBKDF2WithHmacSHA256$65536$LquSju4+DXHAe4H9OP8pYg==$sEkYMziTGnhLrmAnNNDFOmkvUnKdeV6ESSm2PVkcmmY=','孙豪杰','','','','','','NORMAL','2026-03-25 14:39:21','2026-03-25 14:39:21',0,0),(4008,'huige','PBKDF2WithHmacSHA256$65536$7L+s5tczfydc9UDNPBFycQ==$bkrTn9EBLH0i2O5T95UGhIni880+COO7EVw+uj32urU=','郭俊辉','MALE','','','','','NORMAL','2026-03-25 22:27:53','2026-03-25 22:27:53',0,0),(4009,'mrbing','PBKDF2WithHmacSHA256$65536$GbGGB7o4palelM1rw6LVjw==$4tgmXSJWuu/QfNG4bW74zeicslvBQ6d5cGwe0406eLc=','xuebing','MALE','','','','','NORMAL','2026-03-27 08:21:59','2026-03-27 08:21:59',0,0),(4019,'h001','PBKDF2WithHmacSHA256$65536$iv3cb4J52bgmWim/AYvzrA==$usPUnNtioSXbGSx0o1493Gh3y/Is1rrLO7VkAm0SZJk=','孙豪杰','MALE','','','','','NORMAL','2026-04-02 12:48:45','2026-04-02 12:48:45',0,0),(4026,'H002','PBKDF2WithHmacSHA256$65536$Jp4fnmFwzUkoI6nEWb+GlA==$XG4T5EWvT/KBISd5jPOFxYtyMSQejDHmFOFg7UNaE6I=','孙豪杰','','','','','','NORMAL','2026-04-03 00:23:06','2026-04-03 00:23:06',0,0),(4034,'hhhh','PBKDF2WithHmacSHA256$65536$mT5B2M9STO9KU9T9kC7JQg==$4i40L7Pe75KuBsEZ1bGqSILqXY556NEOYCab8JuNHO0=','哈哈','','','','','','NORMAL','2026-04-03 04:26:59','2026-04-03 04:26:59',0,0),(4035,'linbuda','PBKDF2WithHmacSHA256$65536$ApuF1LuBC3QXsi9yXt0aWg==$Evj5ZtZJyjlDf9JoYvFsTw/b0e46CbfZ7sgeWff/AH4=','安君逸','MALE','1995-03-03','','','','NORMAL','2026-04-03 04:32:04','2026-04-03 04:32:04',0,0),(4038,'test1','PBKDF2WithHmacSHA256$65536$xo9GcqyyTzxYguBwZ+Z/jA==$vCMdJoR+MYoAnsrvU85Llcnz63kFQDtymJxciTeKTRE=','测试','','','','','','NORMAL','2026-04-08 00:27:20','2026-04-08 00:27:20',0,0);
/*!40000 ALTER TABLE `passport` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `resource_api_endpoint`
--

DROP TABLE IF EXISTS `resource_api_endpoint`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `resource_api_endpoint` (
  `id` bigint NOT NULL COMMENT '接口标识',
  `application_id` bigint NOT NULL COMMENT '应用标识',
  `api_endpoint_id` bigint NOT NULL COMMENT '接口地址标识',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT '0' COMMENT '记录版本',
  `delete_flag` tinyint NOT NULL DEFAULT '0' COMMENT '删除标识[0:未删除, 1:已删除]',
  PRIMARY KEY (`id`),
  KEY `idx_app_api_del` (`application_id`,`api_endpoint_id`,`delete_flag`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='应用资源接口地址表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `resource_api_endpoint`
--

LOCK TABLES `resource_api_endpoint` WRITE;
/*!40000 ALTER TABLE `resource_api_endpoint` DISABLE KEYS */;
INSERT INTO `resource_api_endpoint` VALUES (567,8,10028,'2026-02-01 01:12:28','2026-02-01 01:12:28',0,0);
/*!40000 ALTER TABLE `resource_api_endpoint` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `resource_menu`
--

DROP TABLE IF EXISTS `resource_menu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `resource_menu` (
  `id` bigint NOT NULL COMMENT '菜单标识',
  `parent_id` bigint DEFAULT NULL COMMENT '父菜单标识',
  `application_id` bigint NOT NULL COMMENT '应用标识',
  `menu_name` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '菜单名称',
  `menu_code` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '菜单编码',
  `link_path` varchar(128) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '链接路径',
  `icon` varchar(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '展示图标',
  `menu_sort_order` int NOT NULL DEFAULT '0' COMMENT '菜单排序',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT '0' COMMENT '记录版本',
  `delete_flag` tinyint NOT NULL DEFAULT '0' COMMENT '删除标识[0:未删除, 1:已删除]',
  PRIMARY KEY (`id`),
  KEY `idx_app_del_id` (`application_id`,`delete_flag`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='应用资源菜单表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `resource_menu`
--

LOCK TABLES `resource_menu` WRITE;
/*!40000 ALTER TABLE `resource_menu` DISABLE KEYS */;
INSERT INTO `resource_menu` VALUES (17,NULL,8,'账号开通','tenant-provision-menu','','',1,'2026-02-01 01:12:28','2026-03-25 12:57:15',1,1),(18,17,8,'开通设置','provision-settings-menu','/tenant-provision','',1,'2026-02-01 01:12:28','2026-03-25 12:57:10',1,1),(19,NULL,9,'系统管理','system-management-menu','','',10000,'2026-02-01 01:12:28','2026-04-19 08:02:38',1,0),(20,19,9,'机构管理','organ-management-menu','/organ','',1,'2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(21,19,9,'用户管理','user-management-menu','/user','',2,'2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(22,19,9,'角色管理','role-management-menu','/role','',3,'2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(23,NULL,9,'应用管理','application-management-menu','','',10001,'2026-02-01 01:12:28','2026-04-19 08:02:44',1,0),(25,23,9,'应用配置','application-config-menu','/application','',1,'2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(26,23,9,'资源配置','resource-settings-menu','/resource-settings','',2,'2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(27,23,9,'资源菜单','resource-menu-menu','/resource-menu','',3,'2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(28,23,9,'资源页面','resource-page-menu','/resource-page','',5,'2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(29,23,9,'资源接口','resource-api-endpoint-menu','/resource-api-endpoint','',6,'2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(30,23,9,'功能权限','control-unit-menu','/control-unit','',7,'2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(31,23,9,'业务能力','control-domain-menu','/control-domain','',8,'2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(32,23,9,'授权记录','application-authorization-menu','/application-authorization','',9,'2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(33,NULL,9,'平台配置','platform-settings-menu','','',10002,'2026-02-01 01:12:28','2026-04-19 08:02:50',1,0),(35,33,9,'后端接口','backend-api-endpoint-menu','/api-endpoint','',1,'2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(36,NULL,9,'平台运营','platform-operations-menu','','',10003,'2026-02-01 01:12:28','2026-04-19 08:02:56',1,0),(37,36,9,'账号管理','passport-management-menu','/passport','',1,'2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(4070,NULL,4033,'平台技术','infra','','',10004,'2026-04-11 04:06:57','2026-04-19 08:03:01',2,0),(4071,4070,4033,'网关路由配置','route-definition','/route_definition','',1,'2026-04-11 04:09:02','2026-04-11 04:11:06',2,0),(4072,4070,4033,'字典配置','dictionary-item','/dictionary_item','',2,'2026-04-11 04:10:09','2026-04-12 14:16:35',2,1),(4073,4070,4033,'字典用途场景','dictionary-usage','/dictionary_usage','',3,'2026-04-11 04:10:42','2026-04-11 04:12:57',3,0),(4074,4070,4033,'消息国际化','i18n-message','/i18n_message','',4,'2026-04-11 04:13:38','2026-04-11 04:14:39',1,0),(4075,4070,4033,'消息用途场景','i18n-message-usage','/i18n_message_usage','',5,'2026-04-11 04:14:33','2026-04-11 04:14:33',0,0),(4076,4070,4033,'地区语言设置','locale-setting','/locale_setting','',6,'2026-04-11 04:15:06','2026-04-11 04:15:06',0,0),(4077,4070,4033,'发号器','g2rain-raindrop','/g2rain_raindrop','',7,'2026-04-11 04:15:29','2026-04-11 04:15:29',0,0),(8046,NULL,7006,'内容管理','cms','','',1,'2026-04-19 08:02:19','2026-04-19 08:02:19',0,0),(8047,8046,7006,'文章列表','cms_article','/article','',1,'2026-04-19 08:04:17','2026-04-19 08:04:17',0,0),(8048,8046,7006,'文章类型','cms_article_category','/article_category','',2,'2026-04-19 08:05:20','2026-04-19 08:05:28',1,0),(8049,8046,7006,'页面列表','cms_page','/page','',3,'2026-04-19 08:06:09','2026-04-19 08:06:09',0,0),(8050,8046,7006,'站点配置','cms_tag','/tag','',5,'2026-04-19 08:06:57','2026-04-19 08:07:21',1,0),(8051,8046,7006,'文章空间','cms_space','/space','',4,'2026-04-19 08:07:49','2026-04-19 08:07:49',0,0),(8052,8046,7006,'站点配置','cms_web_site','/web_site','',6,'2026-04-19 08:08:15','2026-04-19 08:08:15',0,0),(8053,8046,7006,'站点栏目','cms_channel','/channel','',7,'2026-04-19 08:08:56','2026-04-19 08:08:56',0,0);
/*!40000 ALTER TABLE `resource_menu` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `resource_page`
--

DROP TABLE IF EXISTS `resource_page`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `resource_page` (
  `id` bigint NOT NULL COMMENT '页面标识',
  `application_id` bigint NOT NULL COMMENT '应用标识',
  `page_name` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '页面名称',
  `page_code` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '页面编码',
  `link_path` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '链接路径',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT '0' COMMENT '记录版本',
  `delete_flag` tinyint NOT NULL DEFAULT '0' COMMENT '删除标识[0:未删除, 1:已删除]',
  PRIMARY KEY (`id`),
  KEY `idx_app_del_id` (`application_id`,`delete_flag`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='应用资源页面表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `resource_page`
--

LOCK TABLES `resource_page` WRITE;
/*!40000 ALTER TABLE `resource_page` DISABLE KEYS */;
INSERT INTO `resource_page` VALUES (38,8,'账号开通界面','tenant-provision','/tenant-provision','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(39,9,'机构管理界面','organ','/organ','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(50,9,'用户管理界面','user','/user','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(51,9,'角色管理界面','role','/role','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(52,9,'应用配置界面','application','/application','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(53,9,'资源配置界面','resource-settings','/resource-settings','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(55,9,'资源菜单界面','resource-menu','/resource-menu','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(56,9,'资源页面界面','resource-page','/resource-page','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(57,9,'资源接口界面','resource-api-endpoint','/resource-api-endpoint','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(58,9,'功能权限界面','control-unit','/control-unit','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(59,9,'业务能力界面','control-domain','/control-domain','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(60,9,'授权记录界面','application-authorization','/application-authorization','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(61,9,'后端接口界面','api-endpoint','/api-endpoint','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(62,9,'账号管理界面','passport','/passport','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(4082,4033,'网关路由配置','route_definition','/route_definition','2026-04-11 07:20:54','2026-04-11 07:20:54',0,0),(4083,4033,'字典管理','dictionary_item','/dictionary_item','2026-04-11 07:21:45','2026-04-12 11:02:20',1,1),(4084,4033,'字典用途场景','dictionary_usage','/dictionary_usage','2026-04-11 07:22:01','2026-04-11 07:22:01',0,0),(4085,4033,'消息国际化','i18n_message','/i18n_message','2026-04-11 07:22:16','2026-04-11 07:22:31',1,0),(4086,4033,'消息国际化用途','i18n_message_usage','/i18n_message_usage','2026-04-11 07:22:48','2026-04-11 07:22:48',0,0),(4087,4033,'地区语言配置','locale_setting','/locale_setting','2026-04-11 07:23:02','2026-04-11 07:23:02',0,0),(4088,4033,'发号器配置','g2rain_raindrop','/g2rain_raindrop','2026-04-11 07:23:17','2026-04-11 07:23:17',0,0),(8014,7006,'space','space','/space','2026-04-19 08:00:02','2026-04-19 08:00:02',0,0),(8015,7006,'channel','channel','/channel','2026-04-19 08:00:02','2026-04-19 08:00:02',0,0),(8016,7006,'article','article','/article','2026-04-19 08:00:02','2026-04-19 08:00:02',0,0),(8017,7006,'page','page','/page','2026-04-19 08:00:02','2026-04-19 08:00:02',0,0),(8018,7006,'tag','tag','/tag','2026-04-19 08:00:02','2026-04-19 08:00:02',0,0),(8019,7006,'article_tag_relation','article_tag_relation','/article_tag_relation','2026-04-19 08:00:02','2026-04-19 08:00:02',0,0),(8020,7006,'web_site','web_site','/web_site','2026-04-19 08:00:02','2026-04-19 08:00:02',0,0),(8021,7006,'article_category','article_category','/article_category','2026-04-19 08:00:02','2026-04-19 08:00:02',0,0);
/*!40000 ALTER TABLE `resource_page` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `resource_page_element`
--

DROP TABLE IF EXISTS `resource_page_element`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `resource_page_element` (
  `id` bigint NOT NULL COMMENT '页面元素标识',
  `application_id` bigint NOT NULL COMMENT '应用标识',
  `page_code` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '页面编码',
  `page_element_name` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '页面元素名称',
  `page_element_code` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '页面元素编码',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT '0' COMMENT '记录版本',
  `delete_flag` tinyint NOT NULL DEFAULT '0' COMMENT '删除标识[0:未删除, 1:已删除]',
  PRIMARY KEY (`id`),
  KEY `idx_app_del_id` (`application_id`,`delete_flag`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='应用资源页面元素表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `resource_page_element`
--

LOCK TABLES `resource_page_element` WRITE;
/*!40000 ALTER TABLE `resource_page_element` DISABLE KEYS */;
INSERT INTO `resource_page_element` VALUES (63,8,'tenant-provision','保存按钮','tenant-provision:save','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(65,9,'organ','新增按钮','organ:add','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(66,9,'organ','修改按钮','organ:edit','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(67,9,'organ','调整归属','organ:reassign','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(68,9,'organ','修改状态','organ:status-update','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(69,9,'organ','删除按钮','organ:delete','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(70,9,'user','新增按钮','user:add','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(71,9,'user','修改按钮','user:edit','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(72,9,'user','删除按钮','user:delete','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(73,9,'role','新增按钮','role:add','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(75,9,'role','修改按钮','role:edit','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(76,9,'role','分配用户','role:users-assign','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(77,9,'role','分配权限','role:control-utils-assign','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(78,9,'role','删除按钮','role:delete','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(79,9,'application','新增按钮','application:add','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(80,9,'application','修改按钮','application:edit','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(81,9,'application','关联应用','application:integrate','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(82,9,'application','公钥配置','application:public-key-config','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(83,9,'application','修改状态','application:status:update','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(85,9,'application','删除按钮','application:delete','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(86,9,'resource-settings','导入按钮','resource-settings:upload','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(87,9,'resource-menu','新增按钮','resource-menu:add','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(88,9,'resource-menu','修改按钮','resource-menu:edit','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(89,9,'resource-menu','删除按钮','resource-menu:delete','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(90,9,'resource-page','新增按钮','resource-page:add','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(91,9,'resource-page','修改按钮','resource-page:edit','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(92,9,'resource-page','页面元素','resource-page:page-element-mgmt','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(93,9,'resource-page','删除按钮','resource-page:delete','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(95,9,'resource-api-endpoint','新增按钮','resource-api-endpoint:add','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(96,9,'resource-api-endpoint','修改按钮','resource-api-endpoint:edit','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(97,9,'resource-api-endpoint','删除按钮','resource-api-endpoint:delete','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(98,9,'control-unit','新增按钮','control-unit:add','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(99,9,'control-unit','修改按钮','control-unit:edit','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(100,9,'control-unit','配置资源','control-unit:resources-config','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(101,9,'control-unit','修改状态','control-unit:status-update','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(102,9,'control-unit','删除按钮','control-unit:delete','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(103,9,'control-domain','新增按钮','control-domain:add','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(105,9,'control-domain','修改按钮','control-domain:edit','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(106,9,'control-domain','关联权限','control-domain:control-utils-associate','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(107,9,'control-domain','开通功能','control-domain:features-activate','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(108,9,'control-domain','删除按钮','control-domain:delete','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(109,9,'application-authorization','修改状态','application-authorization:status-update','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(110,9,'application-authorization','同步能力','application-authorization:control-utils-sync','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(111,9,'api-endpoint','新增按钮','api-endpoint:add','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(112,9,'api-endpoint','修改按钮','api-endpoint:edit','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(113,9,'api-endpoint','导入按钮','api-endpoint:upload','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(115,9,'api-endpoint','删除按钮','api-endpoint:delete','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(116,9,'passport','新增按钮','passport:add','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(117,9,'passport','修改按钮','passport:edit','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(118,9,'passport','修改状态','passport:status-update','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(119,9,'passport','删除按钮','passport:delete','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(4104,4033,'g2rain_raindrop','新增','g2rain_raindrop:add','2026-04-11 14:20:20','2026-04-11 14:20:20',0,0),(4105,4033,'g2rain_raindrop','编辑','g2rain_raindrop:edit','2026-04-11 14:20:20','2026-04-11 14:20:20',0,0),(4106,4033,'g2rain_raindrop','删除','g2rain_raindrop:delete','2026-04-11 14:20:20','2026-04-11 14:20:20',0,0),(4107,4033,'dictionary_item','新增','dictionary_item:add','2026-04-11 14:20:20','2026-04-12 11:02:13',1,1),(4108,4033,'dictionary_item','编辑','dictionary_item:edit','2026-04-11 14:20:20','2026-04-12 11:02:15',1,1),(4109,4033,'dictionary_item','删除','dictionary_item:delete','2026-04-11 14:20:20','2026-04-12 11:02:16',1,1),(4110,4033,'dictionary_usage','新增','dictionary_usage:add','2026-04-11 14:20:20','2026-04-11 14:20:20',0,0),(4111,4033,'dictionary_usage','编辑','dictionary_usage:edit','2026-04-11 14:20:20','2026-04-11 14:20:20',0,0),(4112,4033,'dictionary_usage','删除','dictionary_usage:delete','2026-04-11 14:20:20','2026-04-11 14:20:20',0,0),(4113,4033,'route_definition','新增','route_definition:add','2026-04-11 14:20:20','2026-04-11 14:20:20',0,0),(4114,4033,'route_definition','编辑','route_definition:edit','2026-04-11 14:20:20','2026-04-11 14:20:20',0,0),(4115,4033,'route_definition','删除','route_definition:delete','2026-04-11 14:20:20','2026-04-11 14:20:20',0,0),(4116,4033,'locale_setting','新增','locale_setting:add','2026-04-11 14:20:20','2026-04-11 14:20:20',0,0),(4117,4033,'locale_setting','编辑','locale_setting:edit','2026-04-11 14:20:20','2026-04-11 14:20:20',0,0),(4118,4033,'locale_setting','删除','locale_setting:delete','2026-04-11 14:20:20','2026-04-11 14:20:20',0,0),(4119,4033,'i18n_message_usage','新增','i18n_message_usage:add','2026-04-11 14:20:20','2026-04-11 14:20:20',0,0),(4120,4033,'i18n_message_usage','编辑','i18n_message_usage:edit','2026-04-11 14:20:20','2026-04-11 14:20:20',0,0),(4121,4033,'i18n_message_usage','删除','i18n_message_usage:delete','2026-04-11 14:20:20','2026-04-11 14:20:20',0,0),(4122,4033,'i18n_message','新增','i18n_message:add','2026-04-11 14:20:20','2026-04-11 14:20:20',0,0),(4123,4033,'i18n_message','编辑','i18n_message:edit','2026-04-11 14:20:20','2026-04-11 14:20:20',0,0),(4124,4033,'i18n_message','删除','i18n_message:delete','2026-04-11 14:20:20','2026-04-11 14:20:20',0,0),(4147,4033,'dictionary_usage','查询','dictionary_usage:search','2026-04-12 13:58:31','2026-04-12 14:15:37',1,1),(4148,4033,'dictionary_usage','重置','dictionary_usage:reset','2026-04-12 13:58:31','2026-04-12 14:15:35',1,1),(4149,4033,'dictionary_usage','明细','dictionary_usage:detail','2026-04-12 13:58:31','2026-04-12 13:58:31',0,0),(4150,4033,'dictionary_usage','打开字典明细','dictionary_usage:items','2026-04-12 13:58:31','2026-04-12 14:12:10',1,0),(4151,4033,'dictionary_usage','新增字典','dictionary_item:add','2026-04-12 14:07:40','2026-04-12 14:11:45',1,0),(4152,4033,'dictionary_usage','删除字典','dictionary_item:delete','2026-04-12 14:07:40','2026-04-12 14:11:55',1,0),(4153,4033,'dictionary_usage','编辑字典','dictionary_item:edit','2026-04-12 14:07:40','2026-04-12 14:12:01',1,0),(8022,7006,'article_category','新增','article_category:add','2026-04-19 08:00:02','2026-04-19 08:00:02',0,0),(8023,7006,'article_category','删除','article_category:delete','2026-04-19 08:00:02','2026-04-19 08:00:02',0,0),(8024,7006,'article_category','编辑','article_category:edit','2026-04-19 08:00:02','2026-04-19 08:00:02',0,0),(8025,7006,'article_tag_relation','新增','article_tag_relation:add','2026-04-19 08:00:02','2026-04-19 08:00:02',0,0),(8026,7006,'article_tag_relation','删除','article_tag_relation:delete','2026-04-19 08:00:02','2026-04-19 08:00:02',0,0),(8027,7006,'article_tag_relation','编辑','article_tag_relation:edit','2026-04-19 08:00:02','2026-04-19 08:00:02',0,0),(8028,7006,'article','新增','article:add','2026-04-19 08:00:02','2026-04-19 08:00:02',0,0),(8029,7006,'article','删除','article:delete','2026-04-19 08:00:02','2026-04-19 08:00:02',0,0),(8030,7006,'article','编辑','article:edit','2026-04-19 08:00:02','2026-04-19 08:00:02',0,0),(8031,7006,'channel','新增','channel:add','2026-04-19 08:00:02','2026-04-19 08:00:02',0,0),(8032,7006,'channel','删除','channel:delete','2026-04-19 08:00:02','2026-04-19 08:00:02',0,0),(8033,7006,'channel','编辑','channel:edit','2026-04-19 08:00:02','2026-04-19 08:00:02',0,0),(8034,7006,'page','新增','page:add','2026-04-19 08:00:02','2026-04-19 08:00:02',0,0),(8035,7006,'page','删除','page:delete','2026-04-19 08:00:02','2026-04-19 08:00:02',0,0),(8036,7006,'page','编辑','page:edit','2026-04-19 08:00:02','2026-04-19 08:00:02',0,0),(8037,7006,'space','新增','space:add','2026-04-19 08:00:02','2026-04-19 08:00:02',0,0),(8038,7006,'space','删除','space:delete','2026-04-19 08:00:02','2026-04-19 08:00:02',0,0),(8039,7006,'space','编辑','space:edit','2026-04-19 08:00:02','2026-04-19 08:00:02',0,0),(8040,7006,'tag','新增','tag:add','2026-04-19 08:00:02','2026-04-19 08:00:02',0,0),(8041,7006,'tag','删除','tag:delete','2026-04-19 08:00:02','2026-04-19 08:00:02',0,0),(8042,7006,'tag','编辑','tag:edit','2026-04-19 08:00:02','2026-04-19 08:00:02',0,0),(8043,7006,'web_site','新增','web_site:add','2026-04-19 08:00:02','2026-04-19 08:00:02',0,0),(8044,7006,'web_site','删除','web_site:delete','2026-04-19 08:00:02','2026-04-19 08:00:02',0,0),(8045,7006,'web_site','编辑','web_site:edit','2026-04-19 08:00:02','2026-04-19 08:00:02',0,0);
/*!40000 ALTER TABLE `resource_page_element` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `role`
--

DROP TABLE IF EXISTS `role`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `role` (
  `id` bigint NOT NULL COMMENT '角色标识',
  `organ_id` bigint DEFAULT NULL COMMENT '机构标识',
  `role_name` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '角色名称',
  `role_type` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '角色类型[ADMIN:超管角色-只读, USER:用户角色]',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT '0' COMMENT '记录版本',
  `delete_flag` tinyint NOT NULL DEFAULT '0' COMMENT '删除标识[0:未删除, 1:已删除]',
  PRIMARY KEY (`id`),
  KEY `idx_organ_id_id` (`organ_id`,`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='角色表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `role`
--

LOCK TABLES `role` WRITE;
/*!40000 ALTER TABLE `role` DISABLE KEYS */;
INSERT INTO `role` VALUES (5,2,'超管角色','ADMIN','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(2023,2021,'超管角色','ADMIN','2026-02-06 08:57:34','2026-02-06 08:57:34',0,0),(2030,2027,'超管角色','ADMIN','2026-02-06 09:00:56','2026-02-06 09:00:56',0,0),(3004,3002,'超管角色','ADMIN','2026-03-17 11:59:22','2026-03-17 11:59:22',0,0),(3011,3009,'超管角色','ADMIN','2026-03-18 14:27:30','2026-03-18 14:27:30',0,0),(3017,3015,'超管角色','ADMIN','2026-03-18 14:31:38','2026-03-18 14:31:38',0,0),(3024,3022,'超管角色','ADMIN','2026-03-19 00:15:49','2026-03-19 00:15:49',0,0),(3030,3028,'超管角色','ADMIN','2026-03-19 00:24:40','2026-03-19 00:24:40',0,0),(4004,4002,'超管角色','ADMIN','2026-03-25 14:47:08','2026-03-25 14:47:08',0,0),(4012,4010,'超管角色','ADMIN','2026-03-30 06:21:18','2026-03-30 06:21:18',0,0),(4022,4020,'超管角色','ADMIN','2026-04-02 12:49:30','2026-04-02 12:49:30',0,0),(4029,4027,'超管角色','ADMIN','2026-04-03 00:25:03','2026-04-03 00:25:03',0,0),(9001,2027,'超管角色','ADMIN','2026-04-19 08:54:28','2026-04-19 08:54:28',0,0),(9003,4002,'超管角色','ADMIN','2026-04-19 09:08:09','2026-04-19 09:08:09',0,0);
/*!40000 ALTER TABLE `role` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `role_control_unit_relation`
--

DROP TABLE IF EXISTS `role_control_unit_relation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `role_control_unit_relation` (
  `id` bigint NOT NULL COMMENT '主键标识',
  `role_id` bigint NOT NULL COMMENT '角色标识',
  `control_unit_id` bigint NOT NULL COMMENT '控制单元标识',
  `application_authorization_id` bigint DEFAULT NULL COMMENT '应用授权标识',
  `status` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'ACTIVATED' COMMENT '控制单元状态[ACTIVATED:激活, DEACTIVATED:关停]',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT '0' COMMENT '记录版本',
  `delete_flag` tinyint NOT NULL DEFAULT '0' COMMENT '删除标识[0:未删除, 1:已删除]',
  PRIMARY KEY (`id`),
  KEY `idx_role_sts_del_cu` (`role_id`,`status`,`delete_flag`,`control_unit_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='角色控制单元关联表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `role_control_unit_relation`
--

LOCK TABLES `role_control_unit_relation` WRITE;
/*!40000 ALTER TABLE `role_control_unit_relation` DISABLE KEYS */;
INSERT INTO `role_control_unit_relation` VALUES (16,5,12,NULL,'ACTIVATED','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(2024,2023,15,NULL,'ACTIVATED','2026-02-06 08:57:34','2026-02-06 08:57:34',0,0),(2031,2030,15,NULL,'ACTIVATED','2026-02-06 09:00:56','2026-02-06 09:00:56',0,0),(3005,3004,15,NULL,'ACTIVATED','2026-03-17 11:59:22','2026-03-17 11:59:22',0,0),(3012,3011,15,NULL,'ACTIVATED','2026-03-18 14:27:30','2026-03-18 14:27:30',0,0),(3018,3017,15,NULL,'ACTIVATED','2026-03-18 14:31:38','2026-03-18 14:31:38',0,0),(3025,3024,15,NULL,'ACTIVATED','2026-03-19 00:15:49','2026-03-19 00:15:49',0,0),(3031,3030,15,NULL,'ACTIVATED','2026-03-19 00:24:40','2026-03-19 00:24:40',0,0),(4005,4004,15,NULL,'ACTIVATED','2026-03-25 14:47:08','2026-03-25 14:47:08',0,0),(4013,4012,15,NULL,'ACTIVATED','2026-03-30 06:21:18','2026-03-30 06:21:18',0,0),(4023,4022,15,NULL,'ACTIVATED','2026-04-02 12:49:30','2026-04-02 12:49:30',0,0),(4030,4029,15,NULL,'ACTIVATED','2026-04-03 00:25:03','2026-04-03 00:25:03',0,0),(4043,5,4039,4042,'ACTIVATED','2026-04-08 12:14:32','2026-04-08 12:14:32',0,0),(4064,4004,4039,4063,'ACTIVATED','2026-04-09 15:07:45','2026-04-09 15:07:45',0,0),(4066,2030,4039,4065,'ACTIVATED','2026-04-09 15:08:39','2026-04-09 15:08:39',0,0),(4068,3011,4039,4067,'ACTIVATED','2026-04-09 15:09:00','2026-04-09 15:09:00',0,0),(4081,5,4069,4080,'ACTIVATED','2026-04-11 04:18:40','2026-04-11 04:18:40',0,0),(8096,4004,8005,8095,'ACTIVATED','2026-04-19 08:16:51','2026-04-19 08:16:51',0,0),(9002,9001,15,NULL,'ACTIVATED','2026-04-19 08:54:28','2026-04-19 08:54:28',0,0),(9004,9003,15,NULL,'ACTIVATED','2026-04-19 09:08:09','2026-04-19 09:08:09',0,0);
/*!40000 ALTER TABLE `role_control_unit_relation` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user`
--

DROP TABLE IF EXISTS `user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user` (
  `id` bigint NOT NULL COMMENT '用户标识',
  `passport_id` bigint NOT NULL COMMENT '账号标识',
  `organ_id` bigint NOT NULL COMMENT '机构标识',
  `email` varchar(128) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '邮箱地址',
  `mobile` varchar(32) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '手机号码',
  `real_name` varchar(128) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '真实姓名',
  `admin` tinyint NOT NULL DEFAULT '0' COMMENT '管理员标记[0:否, 1:是]',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT '0' COMMENT '记录版本',
  `delete_flag` tinyint NOT NULL DEFAULT '0' COMMENT '删除标识[0:未删除, 1:已删除]',
  PRIMARY KEY (`id`),
  KEY `idx_passport_id` (`passport_id`),
  KEY `idx_organ_id` (`organ_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user`
--

LOCK TABLES `user` WRITE;
/*!40000 ALTER TABLE `user` DISABLE KEYS */;
INSERT INTO `user` VALUES (6,1,2,NULL,NULL,'平台管理员',1,'2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(2025,2020,2021,'','','重案组之虎',1,'2026-02-06 08:57:34','2026-02-06 08:57:34',0,0),(2032,2020,2027,'','','代码推土机',1,'2026-02-06 09:27:25','2026-02-06 09:27:25',0,0),(3006,3001,3002,'','','管理员',1,'2026-03-17 11:59:22','2026-03-17 11:59:22',0,0),(3013,3008,3009,'','','测试租户2管理员',1,'2026-03-18 14:27:30','2026-03-18 14:27:30',0,0),(3019,3008,3015,'','','测试003',1,'2026-03-18 14:31:38','2026-03-18 14:31:38',0,0),(3026,3021,3022,'','','管理员',1,'2026-03-19 00:15:49','2026-03-19 00:15:49',0,0),(3032,3021,3028,'','','管理员',1,'2026-03-19 00:24:40','2026-03-19 00:24:40',0,0),(4006,4001,4002,'','','孙',1,'2026-03-25 14:47:09','2026-03-25 14:47:09',0,0),(4014,4009,4010,'coderxb@163.com','18600778899','小李',1,'2026-03-30 06:21:18','2026-03-30 06:21:18',0,0),(4024,4019,4020,'','','孙',1,'2026-04-02 12:49:30','2026-04-02 12:49:30',0,0),(4031,4026,4027,'','','孙豪杰',1,'2026-04-03 00:25:03','2026-04-03 00:25:03',0,0);
/*!40000 ALTER TABLE `user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_role_relation`
--

DROP TABLE IF EXISTS `user_role_relation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_role_relation` (
  `id` bigint NOT NULL COMMENT '主键标识',
  `user_id` bigint NOT NULL COMMENT '用户标识',
  `role_id` bigint NOT NULL COMMENT '角色标识',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT '0' COMMENT '记录版本',
  `delete_flag` tinyint NOT NULL DEFAULT '0' COMMENT '删除标识[0:未删除, 1:已删除]',
  PRIMARY KEY (`id`),
  KEY `idx_organ_id_id` (`user_id`,`role_id`,`delete_flag`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户角色关联表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_role_relation`
--

LOCK TABLES `user_role_relation` WRITE;
/*!40000 ALTER TABLE `user_role_relation` DISABLE KEYS */;
INSERT INTO `user_role_relation` VALUES (7,6,5,'2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),(2026,2025,2023,'2026-02-06 08:57:34','2026-02-06 08:57:34',0,0),(2033,2032,2030,'2026-02-06 09:28:13','2026-02-06 09:28:13',0,0),(3007,3006,3004,'2026-03-17 11:59:22','2026-03-17 11:59:22',0,0),(3014,3013,3011,'2026-03-18 14:27:30','2026-03-18 14:27:30',0,0),(3020,3019,3017,'2026-03-18 14:31:38','2026-03-18 14:31:38',0,0),(3027,3026,3024,'2026-03-19 00:15:49','2026-03-19 00:15:49',0,0),(3033,3032,3030,'2026-03-19 00:24:40','2026-03-19 00:24:40',0,0),(4007,4006,4004,'2026-03-25 14:47:09','2026-03-25 14:47:09',0,0),(4015,4014,4012,'2026-03-30 06:21:18','2026-03-30 06:21:18',0,0),(4025,4024,4022,'2026-04-02 12:49:30','2026-04-02 12:49:30',0,0),(4032,4031,4029,'2026-04-03 00:25:03','2026-04-03 00:25:03',0,0);
/*!40000 ALTER TABLE `user_role_relation` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping routines for database 'g2rain_basis'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-04-19 21:01:37
