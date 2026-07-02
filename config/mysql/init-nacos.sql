CREATE DATABASE  IF NOT EXISTS `nacos` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

-- Ensure Nacos DB user exists and is compatible with MySQL 8 auth (avoid: Public Key Retrieval is not allowed)
CREATE USER IF NOT EXISTS 'nacos'@'%' IDENTIFIED BY 'g2rain_nacos';
ALTER USER 'nacos'@'%' IDENTIFIED WITH mysql_native_password BY 'g2rain_nacos';
GRANT ALL PRIVILEGES ON `nacos`.* TO 'nacos'@'%';
FLUSH PRIVILEGES;

USE
`nacos`;
-- MySQL dump 10.13  Distrib 8.0.41, for macos15 (arm64)
--
-- Host: 43.138.13.145    Database: nacos
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
-- Table structure for table `config_info`
--

DROP TABLE IF EXISTS `config_info`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `config_info`
(
    `id`                 bigint                           NOT NULL AUTO_INCREMENT COMMENT 'id',
    `data_id`            varchar(255) COLLATE utf8mb3_bin NOT NULL COMMENT 'data_id',
    `group_id`           varchar(255) COLLATE utf8mb3_bin          DEFAULT NULL,
    `content`            longtext COLLATE utf8mb3_bin     NOT NULL COMMENT 'content',
    `md5`                varchar(32) COLLATE utf8mb3_bin           DEFAULT NULL COMMENT 'md5',
    `gmt_create`         datetime                         NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `gmt_modified`       datetime                         NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '修改时间',
    `src_user`           text COLLATE utf8mb3_bin COMMENT 'source user',
    `src_ip`             varchar(50) COLLATE utf8mb3_bin           DEFAULT NULL COMMENT 'source ip',
    `app_name`           varchar(128) COLLATE utf8mb3_bin          DEFAULT NULL,
    `tenant_id`          varchar(128) COLLATE utf8mb3_bin          DEFAULT '' COMMENT '租户字段',
    `c_desc`             varchar(256) COLLATE utf8mb3_bin          DEFAULT NULL,
    `c_use`              varchar(64) COLLATE utf8mb3_bin           DEFAULT NULL,
    `effect`             varchar(64) COLLATE utf8mb3_bin           DEFAULT NULL,
    `type`               varchar(64) COLLATE utf8mb3_bin           DEFAULT NULL,
    `c_schema`           text COLLATE utf8mb3_bin,
    `encrypted_data_key` text COLLATE utf8mb3_bin         NOT NULL COMMENT '秘钥',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_configinfo_datagrouptenant` (`data_id`,`group_id`,`tenant_id`)
) ENGINE=InnoDB AUTO_INCREMENT=37 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin COMMENT='config_info';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `config_info`
--

LOCK
TABLES `config_info` WRITE;
/*!40000 ALTER TABLE `config_info` DISABLE KEYS */;
INSERT INTO `config_info`
VALUES (1, 'g2rain-gateway.yml', 'g2rain-gateway',
        'spring:\n  # 配置R2DBC连接配置\n  r2dbc:\n    url: r2dbc:mysql://localhost:3306/g2rain_infra?useSSL=false&serverTimezone=Asia/Shanghai\n    username: root\n    password: 1qaZXsw2\n    pool: # 连接池配置\n      initial-size: 10                      # 连接池的初始连接数\n      max-size: 50                          # 连接池的最大连接数\n      max-idle-time: 30s                    # 最大空闲时间, 超过则释放连接\n      max-acquire-time: 1000ms              # 获取连接的最大超时时间\n      max-create-connection-time: 1000ms    # 创建新连接的最大等待时间\n      max-lifetime: 30m                     # 连接池连接的最大生命周期\n      validation-query: SELECT 1 FROM DUAL  # 校验查询语句\n      validation-depth: LOCAL               # 验证的深度\n      acquire-retry: 3                      # 获取连接时的重试次数\n\ngateway-white-list:\n  global:\n    pattern-paths:\n      - /v2/api-docs\n  filters:\n    GatewayAuthFilter:\n      context-paths:\n        - /auth\n    PrincipalForwardFilter:\n      context-paths:\n        - /auth\n    SignVerificationFilter:\n      context-paths:\n        - /auth\n    TraceLoggingFilter:\n      context-paths:\n        - /auth\n    ResponseAdjustFilter:\n      context-paths:\n        - /auth',
        'a3e228e43464fb13c0217ee45065df22', '2025-11-08 15:45:04', '2025-12-29 22:44:46', 'nacos', '1.203.173.140', '',
        'g2rain-dev', '', '', '', 'yaml', '', ''),
       (2, 'g2rain-token-keypair.yml', 'g2rain',
        'token:\n  keys:\n    - key-id: yEMzeGLlhMpK5GxQKP5Fhg7JH9eALB7BK2BkadTOUxw\n      algorithm: ES256\n      active: true\n      public-key: |\n        -----BEGIN PUBLIC KEY-----\n        MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEDwZbuQCoqp/oUrv4uWRgCW329J5A\n        a5HpunjEjttgwHFZicDa6fUJNi7Djj8eZ8TdFotc0II0mLc1BVDdEkN8MA==\n        -----END PUBLIC KEY-----\n      private-key: |\n        -----BEGIN PRIVATE KEY-----\n        MEECAQAwEwYHKoZIzj0CAQYIKoZIzj0DAQcEJzAlAgEBBCC41ZiW3UJ946ZSuqy6\n        WfOJB45cXeoji3tqcgAoZqki2Q==\n        -----END PRIVATE KEY-----',
        'e24e4a7794ea5e3df33912a7dcf9a008', '2025-11-08 15:45:04', '2025-11-08 15:45:04', NULL, '120.245.114.127', '',
        'g2rain-dev', '', NULL, NULL, 'yaml', NULL, ''),
       (3, 'g2rain-iam.yml', 'g2rain-iam',
        'spring:\n  # 非关系型数据库配置\n  data:\n    # redis配置\n    redis:\n      # 主机地址\n      host: localhost\n      # 端口\n      port: 6379\n      #密码\n      password: 123456\n      # redis的数据库\n      database: 0\n      # 超时\n      timeout: 10s\n      # 连接池\n      lettuce:\n        pool:\n          # 最大活跃数量\n          max-active: 8\n          # 最大空闲数量\n          max-idle: 8\n          # 最小空闲数量\n          min-idle: 0\n          # 最大等待周期\n          max-wait: -1ms\ng2rain:\n  iam:\n    base-url: ${BASE_URL:https://43.138.13.145}\n    dingtalk:\n      callback-path: /auth/dingtalk/callback\n      login-page-bind-mode: INTERNAL\n      internal:\n        client-id: ding5hizxhet7mcbmyrl\n        client-secret: xd0gaXRAT81F-esZVik4OfSN-qjZFNjWZHEY-rMN5y85z36u3lu_vdnlQCva4cXV\n        corp-id: dingd811aa986e79945224f2f5cc6abecb85\n      third-party:\n        client-id: ${DINGTALK_THIRD_PARTY_CLIENT_ID:}\n        client-secret: ${DINGTALK_THIRD_PARTY_CLIENT_SECRET:}',
        '93bc214201f0a4a886fa939a76114954', '2025-11-08 15:45:05', '2026-05-28 23:05:52', 'nacos', '120.245.114.156',
        '', 'g2rain-dev', '', '', '', 'yaml', '', ''),
       (4, 'g2rain-gateway.yml', 'g2rain-gateway',
        'gateway-white-list:\n  global:\n    exact-paths:\n      - /infra/locale_setting/code_name_map\n      - /infra/i18n_message/locale\n      - /favicon.ico\n    pattern-paths:\n      - /*/v3/api-docs/**\n\nspring:\n  # 非关系型数据库配置\n  data:\n    # redis 配置\n    redis:\n      # 主机地址\n      host: redis\n      # 端口\n      port: 6379\n      #密码\n      password: g2rain_redis_11050826\n      # redis 数据库\n      database: 0\n      # 读写超时\n      timeout: 5s\n      # 连接超时\n      connect-timeout: 2s\n      # 连接池\n      lettuce:\n        pool:\n          # 最大活跃数量\n          max-active: 8\n          # 最大空闲数量\n          max-idle: 8\n          # 最小空闲数量\n          min-idle: 0\n          # 最大等待周期\n          max-wait: -1ms',
        'ef449413074773136ff9e3639707aa1d', '2025-11-08 15:45:13', '2026-05-22 18:55:34', 'nacos', '1.203.173.11', '',
        'g2rain-test', '', '', '', 'yaml', '', ''),
       (5, 'g2rain-token-keypair.yml', 'g2rain',
        'token:\n  keys:\n    - key-id: yEMzeGLlhMpK5GxQKP5Fhg7JH9eALB7BK2BkadTOUxw\n      algorithm: ES256\n      active: true\n      public-key: |\n        -----BEGIN PUBLIC KEY-----\n        MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEDwZbuQCoqp/oUrv4uWRgCW329J5A\n        a5HpunjEjttgwHFZicDa6fUJNi7Djj8eZ8TdFotc0II0mLc1BVDdEkN8MA==\n        -----END PUBLIC KEY-----\n      private-key: |\n        -----BEGIN PRIVATE KEY-----\n        MEECAQAwEwYHKoZIzj0CAQYIKoZIzj0DAQcEJzAlAgEBBCC41ZiW3UJ946ZSuqy6\n        WfOJB45cXeoji3tqcgAoZqki2Q==\n        -----END PRIVATE KEY-----',
        'e24e4a7794ea5e3df33912a7dcf9a008', '2025-11-08 15:45:13', '2025-11-08 15:45:13', NULL, '120.245.114.127', '',
        'g2rain-test', '', NULL, NULL, 'yaml', NULL, ''),
       (6, 'g2rain-iam.yml', 'g2rain-iam',
        'spring:\n  # 非关系型数据库配置\n  data:\n    # redis配置\n    redis:\n      # 主机地址\n      host: redis\n      # 端口\n      port: 6379\n      #密码\n      password: g2rain_redis_11050826\n      # redis的数据库\n      database: 0\n      # 超时\n      timeout: 10s\n      # 连接池\n      lettuce:\n        pool:\n          # 最大活跃数量\n          max-active: 8\n          # 最大空闲数量\n          max-idle: 8\n          # 最小空闲数量\n          min-idle: 0\n          # 最大等待周期\n          max-wait: -1ms\ng2rain:\n  iam:\n    base-url: ${BASE_URL:https://43.138.13.145}\n    dingtalk:\n      callback-path: /auth/dingtalk/callback\n      login-page-bind-mode: INTERNAL\n      internal:\n        client-id: ding5hizxhet7mcbmyrl\n        client-secret: xd0gaXRAT81F-esZVik4OfSN-qjZFNjWZHEY-rMN5y85z36u3lu_vdnlQCva4cXV\n        corp-id: dingd811aa986e79945224f2f5cc6abecb85\n      third-party:\n        client-id: ${DINGTALK_THIRD_PARTY_CLIENT_ID:}\n        client-secret: ${DINGTALK_THIRD_PARTY_CLIENT_SECRET:}',
        '72c6f11c0fe85c4c475dfabf7b7a28ec', '2025-11-08 15:45:13', '2026-05-28 23:05:35', 'nacos', '120.245.114.156',
        '', 'g2rain-test', '', '', '', 'yaml', '', ''),
       (12, 'g2rain-infra.yml', 'g2rain-infra',
        'spring:\n  # 非关系型数据库配置\n  data:\n    # redis 配置\n    redis:\n      # 主机地址\n      host: redis\n      # 端口\n      port: 6379\n      #密码\n      password: g2rain_redis_11050826\n      # redis 数据库\n      database: 0\n      # 读写超时\n      timeout: 5s\n      # 连接超时\n      connect-timeout: 2s\n      # 连接池\n      lettuce:\n        pool:\n          # 最大活跃数量\n          max-active: 8\n          # 最大空闲数量\n          max-idle: 8\n          # 最小空闲数量\n          min-idle: 0\n          # 最大等待周期\n          max-wait: -1ms\n\n\n  datasource:\n    url: jdbc:mysql://mysql:3306/g2rain_infra?useUnicode=true&characterEncoding=utf-8&useSSL=true&zeroDateTimeBehavior=convertToNull&serverTimezone=GMT%2B8\n    username: root\n    password: g2rain123456\n    driver-class-name: com.mysql.cj.jdbc.Driver\n    hikari:\n      connection-timeout: 30000\n      validation-timeout: 3000\n      idle-timeout: 30000\n      max-lifetime: 300000\n      minimum-idle: 1\n      maximum-pool-size: 10\n      connection-test-query: select 1',
        '5e7e7623ee80b85d4b2dce382935d1c9', '2026-01-03 17:44:06', '2026-01-03 17:44:06', 'nacos', '221.216.138.224',
        '', 'g2rain-test', NULL, NULL, NULL, 'yaml', NULL, ''),
       (13, 'g2rain-basis.yml', 'g2rain-basis',
        'spring:\n  # 非关系型数据库配置\n  data:\n    # redis 配置\n    redis:\n      # 主机地址\n      host: redis\n      # 端口\n      port: 6379\n      #密码\n      password: g2rain_redis_11050826\n      # redis 数据库\n      database: 0\n      # 读写超时\n      timeout: 5s\n      # 连接超时\n      connect-timeout: 2s\n      # 连接池\n      lettuce:\n        pool:\n          # 最大活跃数量\n          max-active: 8\n          # 最大空闲数量\n          max-idle: 8\n          # 最小空闲数量\n          min-idle: 0\n          # 最大等待周期\n          max-wait: -1ms\n\n\n  datasource:\n    url: jdbc:mysql://mysql:3306/g2rain_basis?useUnicode=true&characterEncoding=utf-8&useSSL=true&zeroDateTimeBehavior=convertToNull&serverTimezone=GMT%2B8\n    username: root\n    password: g2rain123456\n    driver-class-name: com.mysql.cj.jdbc.Driver\n    hikari:\n      connection-timeout: 30000\n      validation-timeout: 3000\n      idle-timeout: 30000\n      max-lifetime: 300000\n      minimum-idle: 1\n      maximum-pool-size: 10\n      connection-test-query: select 1',
        '694413d3f25e31e6282d92c92f287663', '2026-01-03 17:45:00', '2026-01-03 17:45:00', 'nacos', '221.216.138.224',
        '', 'g2rain-test', NULL, NULL, NULL, 'yaml', NULL, ''),
       (22, 'g2rain-basis.yml', 'g2rain-basis',
        'spring:\r\n  # 非关系型数据库配置\r\n  data:\r\n    # redis 配置\r\n    redis:\r\n      # 主机地址\r\n      host: 43.138.13.145\r\n      # 端口\r\n      port: 6379\r\n      #密码\r\n      password: g2rain_redis_11050826\r\n      # redis 数据库\r\n      database: 0\r\n      # 读写超时\r\n      timeout: 5s\r\n      # 连接超时\r\n      connect-timeout: 2s\r\n      # 连接池\r\n      lettuce:\r\n        pool:\r\n          # 最大活跃数量\r\n          max-active: 8\r\n          # 最大空闲数量\r\n          max-idle: 8\r\n          # 最小空闲数量\r\n          min-idle: 0\r\n          # 最大等待周期\r\n          max-wait: -1ms\r\n\r\n\r\n  datasource:\r\n    url: jdbc:mysql://43.138.13.145:3306/g2rain_basis?useUnicode=true&characterEncoding=utf-8&useSSL=true&zeroDateTimeBehavior=convertToNull&serverTimezone=GMT%2B8\r\n    username: root\r\n    password: g2rain123456\r\n    driver-class-name: com.mysql.cj.jdbc.Driver\r\n    hikari:\r\n      connection-timeout: 30000\r\n      validation-timeout: 3000\r\n      idle-timeout: 30000\r\n      max-lifetime: 300000\r\n      minimum-idle: 1\r\n      maximum-pool-size: 10\r\n      connection-test-query: select 1',
        '8e92dcd9c0142adeda77d851b2ca56a8', '2026-03-22 23:35:09', '2026-03-22 23:35:09', 'nacos', '120.245.115.4', '',
        'g2rain-dev', NULL, NULL, NULL, 'yaml', NULL, ''),
       (29, 'g2rain-cms.yml', 'g2rain-cms',
        'spring:\n  # 非关系型数据库配置\n  data:\n    # redis 配置\n    redis:\n      # 主机地址\n      host: 43.138.13.145\n      # 端口\n      port: 6379\n      #密码\n      password: g2rain_redis_11050826\n      # redis 数据库\n      database: 0\n      # 读写超时\n      timeout: 5s\n      # 连接超时\n      connect-timeout: 2s\n      # 连接池\n      lettuce:\n        pool:\n          # 最大活跃数量\n          max-active: 8\n          # 最大空闲数量\n          max-idle: 8\n          # 最小空闲数量\n          min-idle: 0\n          # 最大等待周期\n          max-wait: -1ms\n\n\n  datasource:\n    url: jdbc:mysql://43.138.13.145:3306/g2rain_cms?useUnicode=true&characterEncoding=utf-8&useSSL=true&zeroDateTimeBehavior=convertToNull&serverTimezone=GMT%2B8\n    username: root\n    password: g2rain123456\n    driver-class-name: com.mysql.cj.jdbc.Driver\n    hikari:\n      connection-timeout: 30000\n      validation-timeout: 3000\n      idle-timeout: 30000\n      max-lifetime: 300000\n      minimum-idle: 1\n      maximum-pool-size: 10\n      connection-test-query: select 1',
        '0c4141d7870f3972b9276e638b584c41', '2026-04-14 21:14:35', '2026-04-14 21:20:03', 'nacos', '120.245.114.39', '',
        'g2rain-dev', '', '', '', 'yaml', '', ''),
       (30, 'g2rain-cms.yml', 'g2rain-cms',
        'spring:\n  # 非关系型数据库配置\n  data:\n    # redis 配置\n    redis:\n      # 主机地址\n      host: redis\n      # 端口\n      port: 6379\n      #密码\n      password: g2rain_redis_11050826\n      # redis 数据库\n      database: 0\n      # 读写超时\n      timeout: 5s\n      # 连接超时\n      connect-timeout: 2s\n      # 连接池\n      lettuce:\n        pool:\n          # 最大活跃数量\n          max-active: 8\n          # 最大空闲数量\n          max-idle: 8\n          # 最小空闲数量\n          min-idle: 0\n          # 最大等待周期\n          max-wait: -1ms\n\n\n  datasource:\n    url: jdbc:mysql://mysql:3306/g2rain_cms?useUnicode=true&characterEncoding=utf-8&useSSL=true&zeroDateTimeBehavior=convertToNull&serverTimezone=GMT%2B8\n    username: root\n    password: g2rain123456\n    driver-class-name: com.mysql.cj.jdbc.Driver\n    hikari:\n      connection-timeout: 30000\n      validation-timeout: 3000\n      idle-timeout: 30000\n      max-lifetime: 300000\n      minimum-idle: 1\n      maximum-pool-size: 10\n      connection-test-query: select 1',
        'a6f5992932d1e12f28894bbf96265aff', '2026-04-14 21:15:08', '2026-04-14 21:19:36', 'nacos', '120.245.114.39', '',
        'g2rain-test', '', '', '', 'yaml', '', ''),
       (53, 'g2rain-department.yml', 'g2rain-department',
        'spring:\n  # 非关系型数据库配置\n  data:\n    # redis 配置\n    redis:\n      # 主机地址\n      host: redis\n      # 端口\n      port: 6379\n      #密码\n      password: g2rain_redis_11050826\n      # redis 数据库\n      database: 0\n      # 读写超时\n      timeout: 5s\n      # 连接超时\n      connect-timeout: 2s\n      # 连接池\n      lettuce:\n        pool:\n          # 最大活跃数量\n          max-active: 8\n          # 最大空闲数量\n          max-idle: 8\n          # 最小空闲数量\n          min-idle: 0\n          # 最大等待周期\n          max-wait: -1ms\n\n\n  datasource:\n    url: jdbc:mysql://mysql:3306/g2rain_department?useUnicode=true&characterEncoding=utf-8&useSSL=true&zeroDateTimeBehavior=convertToNull&serverTimezone=GMT%2B8\n    username: root\n    password: g2rain123456\n    driver-class-name: com.mysql.cj.jdbc.Driver\n    hikari:\n      connection-timeout: 30000\n      validation-timeout: 3000\n      idle-timeout: 30000\n      max-lifetime: 300000\n      minimum-idle: 1\n      maximum-pool-size: 10\n      connection-test-query: select 1',
        'e88fbb8a18321555943406e6b5166b7f', '2026-06-03 10:25:24', '2026-06-03 10:26:06', 'nacos', '219.142.145.163',
        '', 'g2rain-test', '', '', '', 'yaml', '', '');
/*!40000 ALTER TABLE `config_info` ENABLE KEYS */;
UNLOCK
TABLES;

--
-- Table structure for table `config_info_aggr`
--

DROP TABLE IF EXISTS `config_info_aggr`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `config_info_aggr`
(
    `id`           bigint                           NOT NULL AUTO_INCREMENT COMMENT 'id',
    `data_id`      varchar(255) COLLATE utf8mb3_bin NOT NULL COMMENT 'data_id',
    `group_id`     varchar(255) COLLATE utf8mb3_bin NOT NULL COMMENT 'group_id',
    `datum_id`     varchar(255) COLLATE utf8mb3_bin NOT NULL COMMENT 'datum_id',
    `content`      longtext COLLATE utf8mb3_bin     NOT NULL COMMENT '内容',
    `gmt_modified` datetime                         NOT NULL COMMENT '修改时间',
    `app_name`     varchar(128) COLLATE utf8mb3_bin DEFAULT NULL,
    `tenant_id`    varchar(128) COLLATE utf8mb3_bin DEFAULT '' COMMENT '租户字段',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_configinfoaggr_datagrouptenantdatum` (`data_id`,`group_id`,`tenant_id`,`datum_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin COMMENT='增加租户字段';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `config_info_aggr`
--

LOCK
TABLES `config_info_aggr` WRITE;
/*!40000 ALTER TABLE `config_info_aggr` DISABLE KEYS */;
/*!40000 ALTER TABLE `config_info_aggr` ENABLE KEYS */;
UNLOCK
TABLES;

--
-- Table structure for table `config_info_beta`
--

DROP TABLE IF EXISTS `config_info_beta`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `config_info_beta`
(
    `id`                 bigint                           NOT NULL AUTO_INCREMENT COMMENT 'id',
    `data_id`            varchar(255) COLLATE utf8mb3_bin NOT NULL COMMENT 'data_id',
    `group_id`           varchar(128) COLLATE utf8mb3_bin NOT NULL COMMENT 'group_id',
    `app_name`           varchar(128) COLLATE utf8mb3_bin          DEFAULT NULL COMMENT 'app_name',
    `content`            longtext COLLATE utf8mb3_bin     NOT NULL COMMENT 'content',
    `beta_ips`           varchar(1024) COLLATE utf8mb3_bin         DEFAULT NULL COMMENT 'betaIps',
    `md5`                varchar(32) COLLATE utf8mb3_bin           DEFAULT NULL COMMENT 'md5',
    `gmt_create`         datetime                         NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `gmt_modified`       datetime                         NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '修改时间',
    `src_user`           text COLLATE utf8mb3_bin COMMENT 'source user',
    `src_ip`             varchar(50) COLLATE utf8mb3_bin           DEFAULT NULL COMMENT 'source ip',
    `tenant_id`          varchar(128) COLLATE utf8mb3_bin          DEFAULT '' COMMENT '租户字段',
    `encrypted_data_key` text COLLATE utf8mb3_bin         NOT NULL COMMENT '秘钥',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_configinfobeta_datagrouptenant` (`data_id`,`group_id`,`tenant_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin COMMENT='config_info_beta';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `config_info_beta`
--

LOCK
TABLES `config_info_beta` WRITE;
/*!40000 ALTER TABLE `config_info_beta` DISABLE KEYS */;
/*!40000 ALTER TABLE `config_info_beta` ENABLE KEYS */;
UNLOCK
TABLES;

--
-- Table structure for table `config_info_tag`
--

DROP TABLE IF EXISTS `config_info_tag`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `config_info_tag`
(
    `id`           bigint                           NOT NULL AUTO_INCREMENT COMMENT 'id',
    `data_id`      varchar(255) COLLATE utf8mb3_bin NOT NULL COMMENT 'data_id',
    `group_id`     varchar(128) COLLATE utf8mb3_bin NOT NULL COMMENT 'group_id',
    `tenant_id`    varchar(128) COLLATE utf8mb3_bin          DEFAULT '' COMMENT 'tenant_id',
    `tag_id`       varchar(128) COLLATE utf8mb3_bin NOT NULL COMMENT 'tag_id',
    `app_name`     varchar(128) COLLATE utf8mb3_bin          DEFAULT NULL COMMENT 'app_name',
    `content`      longtext COLLATE utf8mb3_bin     NOT NULL COMMENT 'content',
    `md5`          varchar(32) COLLATE utf8mb3_bin           DEFAULT NULL COMMENT 'md5',
    `gmt_create`   datetime                         NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `gmt_modified` datetime                         NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '修改时间',
    `src_user`     text COLLATE utf8mb3_bin COMMENT 'source user',
    `src_ip`       varchar(50) COLLATE utf8mb3_bin           DEFAULT NULL COMMENT 'source ip',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_configinfotag_datagrouptenanttag` (`data_id`,`group_id`,`tenant_id`,`tag_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin COMMENT='config_info_tag';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `config_info_tag`
--

LOCK
TABLES `config_info_tag` WRITE;
/*!40000 ALTER TABLE `config_info_tag` DISABLE KEYS */;
/*!40000 ALTER TABLE `config_info_tag` ENABLE KEYS */;
UNLOCK
TABLES;

--
-- Table structure for table `config_tags_relation`
--

DROP TABLE IF EXISTS `config_tags_relation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `config_tags_relation`
(
    `id`        bigint                           NOT NULL COMMENT 'id',
    `tag_name`  varchar(128) COLLATE utf8mb3_bin NOT NULL COMMENT 'tag_name',
    `tag_type`  varchar(64) COLLATE utf8mb3_bin  DEFAULT NULL COMMENT 'tag_type',
    `data_id`   varchar(255) COLLATE utf8mb3_bin NOT NULL COMMENT 'data_id',
    `group_id`  varchar(128) COLLATE utf8mb3_bin NOT NULL COMMENT 'group_id',
    `tenant_id` varchar(128) COLLATE utf8mb3_bin DEFAULT '' COMMENT 'tenant_id',
    `nid`       bigint                           NOT NULL AUTO_INCREMENT,
    PRIMARY KEY (`nid`),
    UNIQUE KEY `uk_configtagrelation_configidtag` (`id`,`tag_name`,`tag_type`),
    KEY         `idx_tenant_id` (`tenant_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin COMMENT='config_tag_relation';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `config_tags_relation`
--

LOCK
TABLES `config_tags_relation` WRITE;
/*!40000 ALTER TABLE `config_tags_relation` DISABLE KEYS */;
/*!40000 ALTER TABLE `config_tags_relation` ENABLE KEYS */;
UNLOCK
TABLES;

--
-- Table structure for table `group_capacity`
--

DROP TABLE IF EXISTS `group_capacity`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `group_capacity`
(
    `id`                bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `group_id`          varchar(128) COLLATE utf8mb3_bin NOT NULL DEFAULT '' COMMENT 'Group ID，空字符表示整个集群',
    `quota`             int unsigned NOT NULL DEFAULT '0' COMMENT '配额，0表示使用默认值',
    `usage`             int unsigned NOT NULL DEFAULT '0' COMMENT '使用量',
    `max_size`          int unsigned NOT NULL DEFAULT '0' COMMENT '单个配置大小上限，单位为字节，0表示使用默认值',
    `max_aggr_count`    int unsigned NOT NULL DEFAULT '0' COMMENT '聚合子配置最大个数，，0表示使用默认值',
    `max_aggr_size`     int unsigned NOT NULL DEFAULT '0' COMMENT '单个聚合数据的子配置大小上限，单位为字节，0表示使用默认值',
    `max_history_count` int unsigned NOT NULL DEFAULT '0' COMMENT '最大变更历史数量',
    `gmt_create`        datetime                         NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `gmt_modified`      datetime                         NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '修改时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_group_id` (`group_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin COMMENT='集群、各Group容量信息表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `group_capacity`
--

LOCK
TABLES `group_capacity` WRITE;
/*!40000 ALTER TABLE `group_capacity` DISABLE KEYS */;
/*!40000 ALTER TABLE `group_capacity` ENABLE KEYS */;
UNLOCK
TABLES;

--
-- Table structure for table `his_config_info`
--

DROP TABLE IF EXISTS `his_config_info`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `his_config_info`
(
    `id`                 bigint unsigned NOT NULL,
    `nid`                bigint unsigned NOT NULL AUTO_INCREMENT,
    `data_id`            varchar(255) COLLATE utf8mb3_bin NOT NULL,
    `group_id`           varchar(128) COLLATE utf8mb3_bin NOT NULL,
    `app_name`           varchar(128) COLLATE utf8mb3_bin          DEFAULT NULL COMMENT 'app_name',
    `content`            longtext COLLATE utf8mb3_bin     NOT NULL COMMENT 'content',
    `md5`                varchar(32) COLLATE utf8mb3_bin           DEFAULT NULL COMMENT 'md5',
    `gmt_create`         datetime                         NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `gmt_modified`       datetime                         NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '修改时间',
    `src_user`           text COLLATE utf8mb3_bin COMMENT 'source user',
    `src_ip`             varchar(50) COLLATE utf8mb3_bin           DEFAULT NULL COMMENT 'source ip',
    `op_type`            char(10) COLLATE utf8mb3_bin              DEFAULT NULL COMMENT 'operation type',
    `tenant_id`          varchar(128) COLLATE utf8mb3_bin          DEFAULT '' COMMENT '租户字段',
    `encrypted_data_key` text COLLATE utf8mb3_bin         NOT NULL COMMENT '秘钥',
    PRIMARY KEY (`nid`),
    KEY                  `idx_gmt_create` (`gmt_create`),
    KEY                  `idx_gmt_modified` (`gmt_modified`),
    KEY                  `idx_did` (`data_id`)
) ENGINE=InnoDB AUTO_INCREMENT=38 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin COMMENT='多租户改造';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `his_config_info`
--

LOCK
TABLES `his_config_info` WRITE;
/*!40000 ALTER TABLE `his_config_info` DISABLE KEYS */;
/*!40000 ALTER TABLE `his_config_info` ENABLE KEYS */;
UNLOCK
TABLES;

--
-- Table structure for table `permissions`
--

DROP TABLE IF EXISTS `permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `permissions`
(
    `role`     varchar(50) COLLATE utf8mb4_unicode_ci  NOT NULL,
    `resource` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
    `action`   varchar(8) COLLATE utf8mb4_unicode_ci   NOT NULL,
    UNIQUE KEY `uk_role_permission` (`role`,`resource`,`action`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `permissions`
--

LOCK
TABLES `permissions` WRITE;
/*!40000 ALTER TABLE `permissions` DISABLE KEYS */;
/*!40000 ALTER TABLE `permissions` ENABLE KEYS */;
UNLOCK
TABLES;

--
-- Table structure for table `roles`
--

DROP TABLE IF EXISTS `roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `roles`
(
    `username` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
    `role`     varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
    UNIQUE KEY `idx_user_role` (`username`,`role`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `roles`
--

LOCK
TABLES `roles` WRITE;
/*!40000 ALTER TABLE `roles` DISABLE KEYS */;
INSERT INTO `roles`
VALUES ('nacos', 'ROLE_ADMIN');
/*!40000 ALTER TABLE `roles` ENABLE KEYS */;
UNLOCK
TABLES;

--
-- Table structure for table `tenant_capacity`
--

DROP TABLE IF EXISTS `tenant_capacity`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tenant_capacity`
(
    `id`                bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `tenant_id`         varchar(128) COLLATE utf8mb3_bin NOT NULL DEFAULT '' COMMENT 'Tenant ID',
    `quota`             int unsigned NOT NULL DEFAULT '0' COMMENT '配额，0表示使用默认值',
    `usage`             int unsigned NOT NULL DEFAULT '0' COMMENT '使用量',
    `max_size`          int unsigned NOT NULL DEFAULT '0' COMMENT '单个配置大小上限，单位为字节，0表示使用默认值',
    `max_aggr_count`    int unsigned NOT NULL DEFAULT '0' COMMENT '聚合子配置最大个数',
    `max_aggr_size`     int unsigned NOT NULL DEFAULT '0' COMMENT '单个聚合数据的子配置大小上限，单位为字节，0表示使用默认值',
    `max_history_count` int unsigned NOT NULL DEFAULT '0' COMMENT '最大变更历史数量',
    `gmt_create`        datetime                         NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `gmt_modified`      datetime                         NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '修改时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_tenant_id` (`tenant_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin COMMENT='租户容量信息表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tenant_capacity`
--

LOCK
TABLES `tenant_capacity` WRITE;
/*!40000 ALTER TABLE `tenant_capacity` DISABLE KEYS */;
/*!40000 ALTER TABLE `tenant_capacity` ENABLE KEYS */;
UNLOCK
TABLES;

--
-- Table structure for table `tenant_info`
--

DROP TABLE IF EXISTS `tenant_info`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tenant_info`
(
    `id`            bigint                           NOT NULL AUTO_INCREMENT COMMENT 'id',
    `kp`            varchar(128) COLLATE utf8mb3_bin NOT NULL COMMENT 'kp',
    `tenant_id`     varchar(128) COLLATE utf8mb3_bin DEFAULT '' COMMENT 'tenant_id',
    `tenant_name`   varchar(128) COLLATE utf8mb3_bin DEFAULT '' COMMENT 'tenant_name',
    `tenant_desc`   varchar(256) COLLATE utf8mb3_bin DEFAULT NULL COMMENT 'tenant_desc',
    `create_source` varchar(32) COLLATE utf8mb3_bin  DEFAULT NULL COMMENT 'create_source',
    `gmt_create`    bigint                           NOT NULL COMMENT '创建时间',
    `gmt_modified`  bigint                           NOT NULL COMMENT '修改时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_tenant_info_kptenantid` (`kp`,`tenant_id`),
    KEY             `idx_tenant_id` (`tenant_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin COMMENT='tenant_info';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tenant_info`
--

LOCK
TABLES `tenant_info` WRITE;
/*!40000 ALTER TABLE `tenant_info` DISABLE KEYS */;
INSERT INTO `tenant_info`
VALUES (1, '1', 'g2rain-test', 'g2rain-test', '服务器测试环境', 'nacos', 1762587865705, 1762587865705),
       (2, '1', 'g2rain-dev', 'g2rain-dev', '开发环境', 'nacos', 1762587881896, 1762587881896);
/*!40000 ALTER TABLE `tenant_info` ENABLE KEYS */;
UNLOCK
TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users`
(
    `username` varchar(50) COLLATE utf8mb4_unicode_ci  NOT NULL,
    `password` varchar(500) COLLATE utf8mb4_unicode_ci NOT NULL,
    `enabled`  tinyint(1) NOT NULL,
    PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK
TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users`
VALUES ('nacos', '$2a$10$.8EiLDx5Uv51C/1AVUpfKeo74Ue2DRhIary4Zh1PevBhyTP/i8GNy', 1);
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK
TABLES;

--
-- Dumping routines for database 'nacos'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-04-19 21:02:25
