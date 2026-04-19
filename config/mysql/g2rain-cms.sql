CREATE DATABASE  IF NOT EXISTS `g2rain_cms` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `g2rain_cms`;
-- MySQL dump 10.13  Distrib 8.0.41, for macos15 (arm64)
--
-- Host: 43.138.13.145    Database: g2rain_cms
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
-- Table structure for table `article`
--

DROP TABLE IF EXISTS `article`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `article` (
  `id` bigint NOT NULL COMMENT '文章标识',
  `organ_id` bigint NOT NULL COMMENT '机构标识',
  `space_id` bigint NOT NULL COMMENT '空间标识',
  `category_id` bigint NOT NULL COMMENT '分类标识',
  `source_application_id` bigint DEFAULT NULL COMMENT '来源应用标识',
  `source_trace_id` varchar(128) DEFAULT NULL COMMENT '来源追踪ID',
  `title` varchar(255) NOT NULL COMMENT '标题',
  `summary` varchar(512) DEFAULT NULL COMMENT '摘要',
  `cover` varchar(255) DEFAULT NULL COMMENT '封面',
  `content_type` varchar(32) NOT NULL COMMENT '内容类型[MARKDOWN:Markdown, HTML:HTML]',
  `content` longtext COMMENT '内容',
  `author` varchar(128) DEFAULT NULL COMMENT '作者',
  `status` varchar(32) NOT NULL DEFAULT 'DRAFT' COMMENT '状态[DRAFT:草稿, PUBLISHED:发布]',
  `publish_time` timestamp NULL DEFAULT NULL COMMENT '发布时间',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT '0' COMMENT '记录版本',
  `delete_flag` tinyint NOT NULL DEFAULT '0' COMMENT '删除标识',
  PRIMARY KEY (`id`),
  KEY `idx_space_id` (`space_id`),
  KEY `idx_category_id` (`category_id`),
  KEY `idx_app_id` (`source_application_id`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='文章表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `article`
--

LOCK TABLES `article` WRITE;
/*!40000 ALTER TABLE `article` DISABLE KEYS */;
/*!40000 ALTER TABLE `article` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `article_category`
--

DROP TABLE IF EXISTS `article_category`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `article_category` (
  `id` bigint NOT NULL COMMENT '分类标识',
  `organ_id` bigint NOT NULL COMMENT '机构标识',
  `space_id` bigint NOT NULL COMMENT '空间标识',
  `category_name` varchar(128) NOT NULL COMMENT '分类名称',
  `category_code` varchar(64) DEFAULT NULL COMMENT '分类编码',
  `status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'ENABLED' COMMENT '状态[ACTIVE:启用, INACTIVE:禁用]',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT '0' COMMENT '记录版本',
  `delete_flag` tinyint NOT NULL DEFAULT '0' COMMENT '删除标识[0:未删除, 1:已删除]',
  PRIMARY KEY (`id`),
  KEY `idx_space_id` (`space_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='文章分类表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `article_category`
--

LOCK TABLES `article_category` WRITE;
/*!40000 ALTER TABLE `article_category` DISABLE KEYS */;
/*!40000 ALTER TABLE `article_category` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `article_tag_relation`
--

DROP TABLE IF EXISTS `article_tag_relation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `article_tag_relation` (
  `id` bigint NOT NULL COMMENT '主键标识',
  `article_id` bigint NOT NULL COMMENT '文章标识',
  `tag_id` bigint NOT NULL COMMENT '标签标识',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT '0' COMMENT '记录版本',
  `delete_flag` tinyint NOT NULL DEFAULT '0' COMMENT '删除标识',
  PRIMARY KEY (`id`),
  KEY `idx_article_tag` (`article_id`,`tag_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='文章标签关系表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `article_tag_relation`
--

LOCK TABLES `article_tag_relation` WRITE;
/*!40000 ALTER TABLE `article_tag_relation` DISABLE KEYS */;
/*!40000 ALTER TABLE `article_tag_relation` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `channel`
--

DROP TABLE IF EXISTS `channel`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `channel` (
  `id` bigint NOT NULL COMMENT '栏目标识',
  `organ_id` bigint NOT NULL COMMENT '机构标识',
  `space_id` bigint NOT NULL COMMENT '空间标识',
  `site_id` bigint NOT NULL COMMENT '站点标识',
  `parent_id` bigint DEFAULT '0' COMMENT '父栏目标识',
  `channel_name` varchar(128) NOT NULL COMMENT '栏目名称',
  `channel_code` varchar(64) DEFAULT NULL COMMENT '栏目编码',
  `channel_type` varchar(32) NOT NULL COMMENT '栏目类型[LIST:列表, PAGE:页面, LINK:外链]',
  `path` varchar(255) DEFAULT NULL COMMENT '访问路径',
  `category_id` bigint DEFAULT NULL COMMENT '分类标识',
  `page_id` bigint DEFAULT NULL COMMENT '页面标识',
  `link_url` varchar(255) DEFAULT NULL COMMENT '外链URL',
  `sort_order` int NOT NULL DEFAULT '0' COMMENT '排序',
  `visible` tinyint NOT NULL DEFAULT '1' COMMENT '是否显示[0:否, 1:是]',
  `status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'ACTIVE' COMMENT '状态[ACTIVE:启用, INACTIVE:禁用]',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT '0' COMMENT '记录版本',
  `delete_flag` tinyint NOT NULL DEFAULT '0' COMMENT '删除标识',
  PRIMARY KEY (`id`),
  KEY `idx_space_id` (`space_id`),
  KEY `idx_parent_id` (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='栏目表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `channel`
--

LOCK TABLES `channel` WRITE;
/*!40000 ALTER TABLE `channel` DISABLE KEYS */;
/*!40000 ALTER TABLE `channel` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `page`
--

DROP TABLE IF EXISTS `page`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `page` (
  `id` bigint NOT NULL COMMENT '页面标识',
  `organ_id` bigint NOT NULL COMMENT '机构标识',
  `space_id` bigint NOT NULL COMMENT '空间标识',
  `page_name` varchar(128) NOT NULL COMMENT '页面名称',
  `page_code` varchar(64) DEFAULT NULL COMMENT '页面编码',
  `path` varchar(255) DEFAULT NULL COMMENT '访问路径',
  `content` longtext COMMENT '页面内容',
  `status` varchar(32) NOT NULL DEFAULT 'DRAFT' COMMENT '状态[DRAFT:草稿, PUBLISHED:发布]',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT '0' COMMENT '记录版本',
  `delete_flag` tinyint NOT NULL DEFAULT '0' COMMENT '删除标识',
  `content_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '内容类型[MARKDOWN:Markdown, HTML:HTML]',
  PRIMARY KEY (`id`),
  KEY `idx_space_id` (`space_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='页面表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `page`
--

LOCK TABLES `page` WRITE;
/*!40000 ALTER TABLE `page` DISABLE KEYS */;
/*!40000 ALTER TABLE `page` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `space`
--

DROP TABLE IF EXISTS `space`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `space` (
  `id` bigint NOT NULL COMMENT '空间标识',
  `organ_id` bigint NOT NULL COMMENT '机构标识',
  `space_name` varchar(128) NOT NULL COMMENT '空间名称',
  `space_code` varchar(64) NOT NULL COMMENT '空间编码',
  `space_type` varchar(32) NOT NULL COMMENT '空间类型[WEBSITE:官网, KNOWLEDGE:知识库, INTERNAL:内部]',
  `status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'ACTIVE' COMMENT '状态[ACTIVE:启用, INACTIVE:禁用]',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT '0' COMMENT '记录版本',
  `delete_flag` tinyint NOT NULL DEFAULT '0' COMMENT '删除标识[0:未删除, 1:已删除]',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_organ_code` (`organ_id`,`space_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='内容空间表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `space`
--

LOCK TABLES `space` WRITE;
/*!40000 ALTER TABLE `space` DISABLE KEYS */;
/*!40000 ALTER TABLE `space` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tag`
--

DROP TABLE IF EXISTS `tag`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tag` (
  `id` bigint NOT NULL COMMENT '标签标识',
  `organ_id` bigint NOT NULL COMMENT '机构标识',
  `tag_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '标签编码',
  `tag_name` varchar(128) NOT NULL COMMENT '标签名称',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT '0' COMMENT '记录版本',
  `delete_flag` tinyint NOT NULL DEFAULT '0' COMMENT '删除标识',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='标签表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tag`
--

LOCK TABLES `tag` WRITE;
/*!40000 ALTER TABLE `tag` DISABLE KEYS */;
INSERT INTO `tag` VALUES (8006,4002,'TEST','测试','2026-04-18 10:14:41','2026-04-18 10:20:35',0,0);
/*!40000 ALTER TABLE `tag` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `web_site`
--

DROP TABLE IF EXISTS `web_site`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `web_site` (
  `id` bigint NOT NULL COMMENT '站点标识',
  `organ_id` bigint NOT NULL COMMENT '机构标识',
  `site_name` varchar(128) NOT NULL COMMENT '站点名称',
  `site_code` varchar(64) NOT NULL COMMENT '站点编码',
  `domain` varchar(255) DEFAULT NULL COMMENT '站点域名（多个用逗号分隔）',
  `description` varchar(512) DEFAULT NULL COMMENT '站点描述',
  `status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'ACTIVE' COMMENT '状态[ACTIVE:启用, INACTIVE:禁用]',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT '0' COMMENT '记录版本',
  `delete_flag` tinyint NOT NULL DEFAULT '0' COMMENT '删除标识[0:未删除, 1:已删除]',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_organ_code` (`organ_id`,`site_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='站点表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `web_site`
--

LOCK TABLES `web_site` WRITE;
/*!40000 ALTER TABLE `web_site` DISABLE KEYS */;
/*!40000 ALTER TABLE `web_site` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping routines for database 'g2rain_cms'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-04-19 21:01:51
