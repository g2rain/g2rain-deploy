CREATE DATABASE  IF NOT EXISTS `g2rain_infra` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `g2rain_infra`;
-- MySQL dump 10.13  Distrib 8.0.41, for macos15 (arm64)
--
-- Host: 43.138.13.145    Database: g2rain_infra
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
-- Table structure for table `dictionary_item`
--

DROP TABLE IF EXISTS `dictionary_item`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `dictionary_item` (
  `id` bigint NOT NULL COMMENT '主键标识',
  `parent_id` bigint DEFAULT NULL COMMENT '父节点ID,用于 tree 结构字典',
  `dictionary_usage_id` bigint NOT NULL COMMENT '字典用途主键标识',
  `code` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '字典项编码,用于系统标识',
  `name` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '字典名称(默认语言)',
  `description` varchar(512) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '业务描述',
  `sort_index` int DEFAULT NULL COMMENT '字典排序',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT '0' COMMENT '记录版本',
  `delete_flag` tinyint NOT NULL DEFAULT '0' COMMENT '删除标识[0:未删除, 1:已删除]',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='字典明细表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dictionary_item`
--

LOCK TABLES `dictionary_item` WRITE;
/*!40000 ALTER TABLE `dictionary_item` DISABLE KEYS */;
INSERT INTO `dictionary_item` VALUES (4160,0,4146,'test','测试','测试',0,'2026-04-12 14:17:49','2026-04-12 14:17:49',0,0),(6002,4160,4146,'child_test','子节点测试','子节点测试',0,'2026-04-13 01:23:44','2026-04-13 01:23:44',0,0),(8002,0,8001,'MARKDOWN','Markdown','MD格式',1,'2026-04-16 14:54:48','2026-04-16 14:54:48',0,0),(8003,0,8001,'HTML','HTML','网页',2,'2026-04-16 14:55:08','2026-04-16 14:55:08',0,0),(8008,0,8007,'WEBSITE','网站','网站',2,'2026-04-18 10:42:12','2026-04-18 10:42:12',0,0),(8009,0,8007,'KNOWLEDGE','知识库','知识库',4,'2026-04-18 10:42:26','2026-04-18 10:42:26',0,0),(8010,0,8007,'INTERNAL','内部信息','内部信息',6,'2026-04-18 10:42:56','2026-04-18 10:42:56',0,0),(8012,0,8011,'ACTIVE','有效','启用|有效|激活相关状态',1,'2026-04-18 10:56:46','2026-04-18 14:07:58',2,0),(8013,0,8011,'INACTIVE','无效','禁用|无效|冻结等相关状态',2,'2026-04-18 10:56:59','2026-04-18 14:08:18',2,0);
/*!40000 ALTER TABLE `dictionary_item` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dictionary_usage`
--

DROP TABLE IF EXISTS `dictionary_usage`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `dictionary_usage` (
  `id` bigint NOT NULL COMMENT '主键标识',
  `usage_code` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '字典用途代码',
  `usage_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '字典用途名称',
  `description` varchar(512) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '业务描述',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT '0' COMMENT '记录版本',
  `delete_flag` tinyint NOT NULL DEFAULT '0' COMMENT '删除标识[0:未删除, 1:已删除]',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='字典用途表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dictionary_usage`
--

LOCK TABLES `dictionary_usage` WRITE;
/*!40000 ALTER TABLE `dictionary_usage` DISABLE KEYS */;
INSERT INTO `dictionary_usage` VALUES (4146,'test','测试','测试','2026-04-12 11:49:56','2026-04-12 11:49:56',0,0),(8001,'CMS_ARTICLE_CONTENT_TYPE','CMS文章内容类型','内容管理系统中文章的内容类型，MARKDOWN:Markdown, HTML:HTML','2026-04-16 14:49:02','2026-04-16 14:49:02',0,0),(8007,'CMS_SPACE_SPACE_TYPE','CMS空间类型','空间类型[WEBSITE:官网, KNOWLEDGE:知识库, INTERNAL:内部]','2026-04-18 10:41:43','2026-04-18 10:41:43',0,0),(8011,'STATUS','通用状态','状态[ENABLED:启用, DISABLED:禁用]','2026-04-18 10:56:13','2026-04-18 10:56:13',0,0);
/*!40000 ALTER TABLE `dictionary_usage` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `g2rain_raindrop`
--

DROP TABLE IF EXISTS `g2rain_raindrop`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `g2rain_raindrop` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键标识',
  `biz_tag` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '业务标识,每个业务对应一行',
  `max_id` bigint NOT NULL DEFAULT '1' COMMENT '当前分配到的最大ID',
  `step` int NOT NULL DEFAULT '0' COMMENT '分配步长,用于批量预分配ID',
  `description` varchar(256) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '业务描述',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT '0' COMMENT '记录版本',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_biz_tag` (`biz_tag`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='全局唯一ID管理表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `g2rain_raindrop`
--

LOCK TABLES `g2rain_raindrop` WRITE;
/*!40000 ALTER TABLE `g2rain_raindrop` DISABLE KEYS */;
INSERT INTO `g2rain_raindrop` VALUES (1,'COMMON',10001,1000,'全局共用号段','2026-01-03 09:37:29','2026-04-19 08:54:27',10);
/*!40000 ALTER TABLE `g2rain_raindrop` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `i18n_message`
--

DROP TABLE IF EXISTS `i18n_message`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `i18n_message` (
  `id` bigint NOT NULL COMMENT '主键标识',
  `message_usage_id` bigint NOT NULL COMMENT '用途标识',
  `language_code` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '语言编码,如 zh',
  `region_code` varchar(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '国家/地区编码,如 CN',
  `message_code` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '国际化消息编码(唯一)',
  `message_text` text COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '国际化内容文本',
  `extend_field` json DEFAULT NULL COMMENT '扩展字段,存储额外格式化内容',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT '0' COMMENT '记录版本',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='国际化信息表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `i18n_message`
--

LOCK TABLES `i18n_message` WRITE;
/*!40000 ALTER TABLE `i18n_message` DISABLE KEYS */;
/*!40000 ALTER TABLE `i18n_message` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `i18n_message_usage`
--

DROP TABLE IF EXISTS `i18n_message_usage`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `i18n_message_usage` (
  `id` bigint NOT NULL COMMENT '主键标识',
  `usage_code` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '用途编码,用于在代码中标识用途:DICTIONARY 字典, ERROR_CODE 错误码为固定用途',
  `name` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '用途名称',
  `remark` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '业务描述',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT '0' COMMENT '记录版本',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='国际化信息用途表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `i18n_message_usage`
--

LOCK TABLES `i18n_message_usage` WRITE;
/*!40000 ALTER TABLE `i18n_message_usage` DISABLE KEYS */;
/*!40000 ALTER TABLE `i18n_message_usage` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `locale_setting`
--

DROP TABLE IF EXISTS `locale_setting`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `locale_setting` (
  `id` bigint NOT NULL COMMENT '主键标识',
  `language_code` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '语言编码,如 zh',
  `region_code` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '国家/地区编码,如 CN',
  `code` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '区域标识,如 zh-CN',
  `name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '区域名称,如 中国-简体中文',
  `description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '语言描述',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT '0' COMMENT '记录版本',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='地域-语言设置表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `locale_setting`
--

LOCK TABLES `locale_setting` WRITE;
/*!40000 ALTER TABLE `locale_setting` DISABLE KEYS */;
/*!40000 ALTER TABLE `locale_setting` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `route_definition`
--

DROP TABLE IF EXISTS `route_definition`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `route_definition` (
  `id` bigint NOT NULL COMMENT '路由标识',
  `name` varchar(128) NOT NULL COMMENT '路由名称',
  `endpoint_host` varchar(256) NOT NULL COMMENT '终端主机',
  `endpoint_path` varchar(256) DEFAULT NULL COMMENT '终端路径',
  `context` varchar(128) NOT NULL COMMENT '转发路径',
  `path` varchar(256) NOT NULL COMMENT '请求路径',
  `method` varchar(32) DEFAULT NULL COMMENT '请求方法',
  `header_parameters` varchar(512) DEFAULT NULL COMMENT '请求头参',
  `content_type` varchar(64) DEFAULT NULL COMMENT '内容类型',
  `description` varchar(512) DEFAULT NULL COMMENT '业务说明',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT '0' COMMENT '记录版本',
  `delete_flag` tinyint NOT NULL DEFAULT '0' COMMENT '删除标识[0:未删除, 1:已删除]',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='网关路由表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `route_definition`
--

LOCK TABLES `route_definition` WRITE;
/*!40000 ALTER TABLE `route_definition` DISABLE KEYS */;
INSERT INTO `route_definition` VALUES (1,'基础支撑接口请求','lb://g2rain-infra/',NULL,'infra','/**','GET',NULL,NULL,'基础支撑接口请求','2025-12-24 03:34:33','2025-12-24 03:34:33',1,0),(2,'基础支撑接口提交','lb://g2rain-infra/',NULL,'infra','/**','POST',NULL,NULL,'基础支撑接口提交','2025-12-24 03:34:33','2025-12-24 03:34:33',1,0),(3,'基础支撑接口修改','lb://g2rain-infra/',NULL,'infra','/**','PUT',NULL,NULL,'基础支撑接口修改','2025-12-24 03:34:33','2025-12-24 03:34:33',1,0),(4,'基础支撑接口删除','lb://g2rain-infra/',NULL,'infra','/**','DELETE',NULL,NULL,'基础支撑接口删除','2025-12-24 03:34:33','2025-12-24 03:34:33',1,0),(5,'系统支撑接口请求','lb://g2rain-basis/',NULL,'basis','/**','GET',NULL,NULL,'系统支撑接口请求','2025-12-24 03:34:33','2025-12-24 03:34:33',1,0),(6,'系统支撑接口提交','lb://g2rain-basis/',NULL,'basis','/**','POST',NULL,NULL,'系统支撑接口提交','2025-12-24 03:34:33','2025-12-24 03:34:33',1,0),(7,'系统支撑接口修改','lb://g2rain-basis/',NULL,'basis','/**','PUT',NULL,NULL,'系统支撑接口修改','2025-12-24 03:34:33','2025-12-24 03:34:33',1,0),(8,'系统支撑接口删除','lb://g2rain-basis/',NULL,'basis','/**','DELETE',NULL,NULL,'系统支撑接口删除','2025-12-24 03:34:33','2025-12-24 03:34:33',1,0),(9,'健康服务接口请求','lb://g2rain-health/',NULL,'heal','/**','GET',NULL,NULL,'健康服务接口请求','2026-04-01 12:19:25','2026-04-02 11:53:52',0,0),(10,'健康服务接口提交','lb://g2rain-health/',NULL,'heal','/**','POST',NULL,NULL,'健康服务接口提交','2026-04-01 12:21:06','2026-04-19 09:12:32',1,0),(11,'健康服务接口更新','lb://g2rain-health/',NULL,'heal','/**','PUT',NULL,NULL,'健康服务接口更新','2026-04-01 12:21:37','2026-04-02 11:53:52',0,0),(12,'健康服务接口删除','lb://g2rain-health/',NULL,'heal','/**','DELETE',NULL,NULL,'健康服务接口删除','2026-04-01 12:22:07','2026-04-02 11:53:52',0,0),(7002,'CMS内容服务接口请求','lb://g2rain-cms/','','cms','/**','GET','','','CMS内容服务接口请求','2026-04-14 15:44:47','2026-04-14 15:44:47',0,0),(7003,'CMS内容服务接口修改','lb://g2rain-cms/','','cms','/**','PUT','','','CMS内容服务接口修改','2026-04-14 15:46:03','2026-04-14 15:47:28',1,0),(7004,'CMS内容服务接口提交','lb://g2rain-cms/','','cms','/**','POST','','','CMS内容服务接口提交','2026-04-14 15:47:16','2026-04-14 15:47:16',0,0),(7005,'CMS内容服务接口删除','lb://g2rain-cms/','','cms','/**','DELETE','','','CMS内容服务接口删除','2026-04-14 15:48:17','2026-04-14 15:48:17',0,0);
/*!40000 ALTER TABLE `route_definition` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping routines for database 'g2rain_infra'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-04-19 21:02:04
