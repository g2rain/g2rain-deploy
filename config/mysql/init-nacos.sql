CREATE DATABASE IF NOT EXISTS `nacos` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Ensure Nacos DB user exists and is compatible with MySQL 8 auth (avoid: Public Key Retrieval is not allowed)
CREATE USER IF NOT EXISTS 'nacos'@'%' IDENTIFIED BY 'g2rain_nacos';
ALTER USER 'nacos'@'%' IDENTIFIED WITH mysql_native_password BY 'g2rain_nacos';
GRANT ALL PRIVILEGES ON `nacos`.* TO 'nacos'@'%';
FLUSH PRIVILEGES;

USE `nacos`;
SET NAMES utf8mb4;

--
-- Table structure for table `config_info`
--

DROP TABLE IF EXISTS `config_info`;
CREATE TABLE `config_info`
(
    `id`                 bigint                                                 NOT NULL AUTO_INCREMENT COMMENT 'id',
    `data_id`            varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT 'data_id',
    `group_id`           varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
    `content`            longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin     NOT NULL COMMENT 'content',
    `md5`                varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin  DEFAULT NULL COMMENT 'md5',
    `gmt_create`         datetime                                               NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `gmt_modified`       datetime                                               NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '修改时间',
    `src_user`           text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin         COMMENT 'source user',
    `src_ip`             varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin  DEFAULT NULL COMMENT 'source ip',
    `app_name`           varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
    `tenant_id`          varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '' COMMENT '租户字段',
    `c_desc`             varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
    `c_use`              varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin  DEFAULT NULL,
    `effect`             varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin  DEFAULT NULL,
    `type`               varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin  DEFAULT NULL,
    `c_schema`           text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
    `encrypted_data_key` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin         NOT NULL COMMENT '秘钥',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_configinfo_datagrouptenant` (`data_id`,`group_id`,`tenant_id`)
) ENGINE=InnoDB AUTO_INCREMENT=101 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='config_info';

INSERT INTO `config_info`
VALUES (1, 'g2rain-gateway.yml', 'g2rain-gateway', 'spring:\n  # 配置R2DBC连接配置\n  r2dbc:\n    url: r2dbc:mysql://localhost:3306/g2rain_infra?useSSL=false&serverTimezone=Asia/Shanghai\n    username: root\n    password: 1qaZXsw2\n    pool: # 连接池配置\n      initial-size: 10                      # 连接池的初始连接数\n      max-size: 50                          # 连接池的最大连接数\n      max-idle-time: 30s                    # 最大空闲时间, 超过则释放连接\n      max-acquire-time: 1000ms              # 获取连接的最大超时时间\n      max-create-connection-time: 1000ms    # 创建新连接的最大等待时间\n      max-lifetime: 30m                     # 连接池连接的最大生命周期\n      validation-query: SELECT 1 FROM DUAL  # 校验查询语句\n      validation-depth: LOCAL               # 验证的深度\n      acquire-retry: 3                      # 获取连接时的重试次数\n\ngateway-white-list:\n  global:\n    pattern-paths:\n      - /v2/api-docs\n  filters:\n    GatewayAuthFilter:\n      context-paths:\n        - /auth\n    PrincipalForwardFilter:\n      context-paths:\n        - /auth\n    SignVerificationFilter:\n      context-paths:\n        - /auth\n    TraceLoggingFilter:\n      context-paths:\n        - /auth\n    ResponseAdjustFilter:\n      context-paths:\n        - /auth', 'a3e228e43464fb13c0217ee45065df22', '2025-11-08 15:45:04', '2025-12-29 22:44:46', 'nacos', '1.203.173.140', '', 'g2rain-dev', '', '', '', 'yaml', '', ''),
       (2, 'g2rain-token-keypair.yml', 'g2rain', 'token:\n  keys:\n    - key-id: yEMzeGLlhMpK5GxQKP5Fhg7JH9eALB7BK2BkadTOUxw\n      algorithm: ES256\n      active: true\n      public-key: |\n        -----BEGIN PUBLIC KEY-----\n        MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEDwZbuQCoqp/oUrv4uWRgCW329J5A\n        a5HpunjEjttgwHFZicDa6fUJNi7Djj8eZ8TdFotc0II0mLc1BVDdEkN8MA==\n        -----END PUBLIC KEY-----\n      private-key: |\n        -----BEGIN PRIVATE KEY-----\n        MEECAQAwEwYHKoZIzj0CAQYIKoZIzj0DAQcEJzAlAgEBBCC41ZiW3UJ946ZSuqy6\n        WfOJB45cXeoji3tqcgAoZqki2Q==\n        -----END PRIVATE KEY-----', 'e24e4a7794ea5e3df33912a7dcf9a008', '2025-11-08 15:45:04', '2025-11-08 15:45:04', NULL, '120.245.114.127', '', 'g2rain-dev', '', NULL, NULL, 'yaml', NULL, ''),
       (3, 'g2rain-iam.yml', 'g2rain-iam', 'spring:\n  # 非关系型数据库配置\n  data:\n    # redis配置\n    redis:\n      # 主机地址\n      host: localhost\n      # 端口\n      port: 6379\n      #密码\n      password: 123456\n      # redis的数据库\n      database: 0\n      # 超时\n      timeout: 10s\n      # 连接池\n      lettuce:\n        pool:\n          # 最大活跃数量\n          max-active: 8\n          # 最大空闲数量\n          max-idle: 8\n          # 最小空闲数量\n          min-idle: 0\n          # 最大等待周期\n          max-wait: -1ms\ng2rain:\n  iam:\n    base-url: ${BASE_URL:https://43.138.13.145}\n    dingtalk:\n      callback-path: /auth/dingtalk/callback\n      login-page-bind-mode: INTERNAL\n      internal:\n        client-id: ding5hizxhet7mcbmyrl\n        client-secret: xd0gaXRAT81F-esZVik4OfSN-qjZFNjWZHEY-rMN5y85z36u3lu_vdnlQCva4cXV\n        corp-id: dingd811aa986e79945224f2f5cc6abecb85\n      third-party:\n        client-id: ${DINGTALK_THIRD_PARTY_CLIENT_ID:}\n        client-secret: ${DINGTALK_THIRD_PARTY_CLIENT_SECRET:}\n    auth-policy:\n      default:\n        login-methods:\n          - PASSWORD\n        allow-register: true\n      applications:\n        g2rain-admin-shell:\n          login-methods:\n            - PASSWORD\n            - DINGTALK\n          ding-talk-bind-mode: INTERNAL   # 或省略，回退 g2rain.iam.dingtalk.login-page-bind-mode\n          allow-register: true', 'c8c2876038a4085d763231af24b41bbb', '2025-11-08 15:45:05', '2026-10-03 15:04:54', 'nacos', '120.245.114.207', '', 'g2rain-dev', '', '', '', 'yaml', '', ''),
       (4, 'g2rain-gateway.yml', 'g2rain-gateway', 'gateway-white-list:\n  global:\n    exact-paths:\n      - /infra/locale_setting/code_name_map\n      - /infra/i18n_message/locale\n      - /favicon.ico\n    pattern-paths:\n      - /*/v3/api-docs/**\n\nspring:\n  # 非关系型数据库配置\n  data:\n    # redis 配置\n    redis:\n      # 主机地址\n      host: 10.0.0.2\n      # 端口\n      port: 6379\n      #密码\n      password: g2rain_redis_11050826\n      # redis 数据库\n      database: 0\n      # 读写超时\n      timeout: 5s\n      # 连接超时\n      connect-timeout: 2s\n      # 连接池\n      lettuce:\n        pool:\n          # 最大活跃数量\n          max-active: 8\n          # 最大空闲数量\n          max-idle: 8\n          # 最小空闲数量\n          min-idle: 0\n          # 最大等待周期\n          max-wait: -1ms', 'fa4cd3982e707888325da1429b5e9886', '2025-11-08 15:45:13', '2026-10-18 16:52:39', 'nacos', '114.248.12.33', '', 'g2rain-test', '', '', '', 'yaml', '', ''),
       (5, 'g2rain-token-keypair.yml', 'g2rain', 'token:\n  keys:\n    - key-id: yEMzeGLlhMpK5GxQKP5Fhg7JH9eALB7BK2BkadTOUxw\n      algorithm: ES256\n      active: true\n      public-key: |\n        -----BEGIN PUBLIC KEY-----\n        MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEDwZbuQCoqp/oUrv4uWRgCW329J5A\n        a5HpunjEjttgwHFZicDa6fUJNi7Djj8eZ8TdFotc0II0mLc1BVDdEkN8MA==\n        -----END PUBLIC KEY-----\n      private-key: |\n        -----BEGIN PRIVATE KEY-----\n        MEECAQAwEwYHKoZIzj0CAQYIKoZIzj0DAQcEJzAlAgEBBCC41ZiW3UJ946ZSuqy6\n        WfOJB45cXeoji3tqcgAoZqki2Q==\n        -----END PRIVATE KEY-----', 'e24e4a7794ea5e3df33912a7dcf9a008', '2025-11-08 15:45:13', '2025-11-08 15:45:13', NULL, '120.245.114.127', '', 'g2rain-test', '', NULL, NULL, 'yaml', NULL, ''),
       (6, 'g2rain-iam.yml', 'g2rain-iam', 'spring:\n  # 非关系型数据库配置\n  data:\n    # redis配置\n    redis:\n      # 主机地址\n      host: 10.0.0.2\n      # 端口\n      port: 6379\n      #密码\n      password: g2rain_redis_11050826\n      # redis的数据库\n      database: 0\n      # 超时\n      timeout: 10s\n      # 连接池\n      lettuce:\n        pool:\n          # 最大活跃数量\n          max-active: 8\n          # 最大空闲数量\n          max-idle: 8\n          # 最小空闲数量\n          min-idle: 0\n          # 最大等待周期\n          max-wait: -1ms\ng2rain:\n  iam:\n    base-url: ${BASE_URL:https://43.138.13.145}\n    dingtalk:\n      callback-path: /auth/dingtalk/callback\n      login-page-bind-mode: INTERNAL\n      internal:\n        client-id: ding5hizxhet7mcbmyrl\n        client-secret: xd0gaXRAT81F-esZVik4OfSN-qjZFNjWZHEY-rMN5y85z36u3lu_vdnlQCva4cXV\n        corp-id: dingd811aa986e79945224f2f5cc6abecb85\n      third-party:\n        client-id: ${DINGTALK_THIRD_PARTY_CLIENT_ID:}\n        client-secret: ${DINGTALK_THIRD_PARTY_CLIENT_SECRET:}\n    wecom:\n      login-page-bind-mode: INTERNAL\n      internal:\n        corp-id: ww10db0c313fb39c4d\n        agent-id: 1000002\n        secret: P1gQU5o07sc0tVvQr6xu1c8dmKLGqiCYThH2e_InhFg\n    auth-policy:\n      default:\n        login-methods:\n          - PASSWORD\n        allow-register: true\n      applications:\n        g2rain-admin-shell:\n          login-methods:\n            - PASSWORD\n            - DINGTALK\n          ding-talk-bind-mode: INTERNAL   # 或省略，回退 g2rain.iam.dingtalk.login-page-bind-mode\n          allow-register: true', '14983c1ba5ad1f1f334e57447b22e77f', '2025-11-08 15:45:13', '2026-11-01 22:54:50', 'nacos', '1.203.173.224', '', 'g2rain-test', '', '', '', 'yaml', '', ''),
       (12, 'g2rain-infra.yml', 'g2rain-infra', 'spring:\n  # 非关系型数据库配置\n  data:\n    # redis 配置\n    redis:\n      # 主机地址\n      host: 10.0.0.2\n      # 端口\n      port: 6379\n      #密码\n      password: g2rain_redis_11050826\n      # redis 数据库\n      database: 0\n      # 读写超时\n      timeout: 5s\n      # 连接超时\n      connect-timeout: 2s\n      # 连接池\n      lettuce:\n        pool:\n          # 最大活跃数量\n          max-active: 8\n          # 最大空闲数量\n          max-idle: 8\n          # 最小空闲数量\n          min-idle: 0\n          # 最大等待周期\n          max-wait: -1ms\n\n\n  datasource:\n    url: jdbc:mysql://10.0.0.2:3306/g2rain_infra?useUnicode=true&characterEncoding=utf-8&useSSL=true&zeroDateTimeBehavior=convertToNull&serverTimezone=GMT%2B8\n    username: root\n    password: g2rain123456\n    driver-class-name: com.mysql.cj.jdbc.Driver\n    hikari:\n      connection-timeout: 30000\n      validation-timeout: 3000\n      idle-timeout: 30000\n      max-lifetime: 300000\n      minimum-idle: 1\n      maximum-pool-size: 10\n      connection-test-query: select 1', '15ad6f43fc3ca6588fcf55497d5e7a7e', '2026-01-03 17:44:06', '2026-10-18 16:53:20', 'nacos', '114.248.12.33', '', 'g2rain-test', '', '', '', 'yaml', '', ''),
       (13, 'g2rain-basis.yml', 'g2rain-basis', 'spring:\n  # 非关系型数据库配置\n  data:\n    # redis 配置\n    redis:\n      # 主机地址\n      host: 10.0.0.2\n      # 端口\n      port: 6379\n      #密码\n      password: g2rain_redis_11050826\n      # redis 数据库\n      database: 0\n      # 读写超时\n      timeout: 5s\n      # 连接超时\n      connect-timeout: 2s\n      # 连接池\n      lettuce:\n        pool:\n          # 最大活跃数量\n          max-active: 8\n          # 最大空闲数量\n          max-idle: 8\n          # 最小空闲数量\n          min-idle: 0\n          # 最大等待周期\n          max-wait: -1ms\n\n\n  datasource:\n    url: jdbc:mysql://10.0.0.2:3306/g2rain_basis?useUnicode=true&characterEncoding=utf-8&useSSL=true&zeroDateTimeBehavior=convertToNull&serverTimezone=GMT%2B8\n    username: root\n    password: g2rain123456\n    driver-class-name: com.mysql.cj.jdbc.Driver\n    hikari:\n      connection-timeout: 30000\n      validation-timeout: 3000\n      idle-timeout: 30000\n      max-lifetime: 300000\n      minimum-idle: 1\n      maximum-pool-size: 10\n      connection-test-query: select 1', 'f2f4e1d98b2f79d10803c1e658521024', '2026-01-03 17:45:00', '2026-10-18 16:53:41', 'nacos', '114.248.12.33', '', 'g2rain-test', '', '', '', 'yaml', '', ''),
       (22, 'g2rain-basis.yml', 'g2rain-basis', 'spring:\r\n  # 非关系型数据库配置\r\n  data:\r\n    # redis 配置\r\n    redis:\r\n      # 主机地址\r\n      host: 43.138.13.145\r\n      # 端口\r\n      port: 6379\r\n      #密码\r\n      password: g2rain_redis_11050826\r\n      # redis 数据库\r\n      database: 0\r\n      # 读写超时\r\n      timeout: 5s\r\n      # 连接超时\r\n      connect-timeout: 2s\r\n      # 连接池\r\n      lettuce:\r\n        pool:\r\n          # 最大活跃数量\r\n          max-active: 8\r\n          # 最大空闲数量\r\n          max-idle: 8\r\n          # 最小空闲数量\r\n          min-idle: 0\r\n          # 最大等待周期\r\n          max-wait: -1ms\r\n\r\n\r\n  datasource:\r\n    url: jdbc:mysql://43.138.13.145:3306/g2rain_basis?useUnicode=true&characterEncoding=utf-8&useSSL=true&zeroDateTimeBehavior=convertToNull&serverTimezone=GMT%2B8\r\n    username: root\r\n    password: g2rain123456\r\n    driver-class-name: com.mysql.cj.jdbc.Driver\r\n    hikari:\r\n      connection-timeout: 30000\r\n      validation-timeout: 3000\r\n      idle-timeout: 30000\r\n      max-lifetime: 300000\r\n      minimum-idle: 1\r\n      maximum-pool-size: 10\r\n      connection-test-query: select 1', '8e92dcd9c0142adeda77d851b2ca56a8', '2026-03-22 23:35:09', '2026-03-22 23:35:09', 'nacos', '120.245.115.4', '', 'g2rain-dev', NULL, NULL, NULL, 'yaml', NULL, ''),
       (29, 'g2rain-cms.yml', 'g2rain-cms', 'spring:\n  # 非关系型数据库配置\n  data:\n    # redis 配置\n    redis:\n      # 主机地址\n      host: 43.138.13.145\n      # 端口\n      port: 6379\n      #密码\n      password: g2rain_redis_11050826\n      # redis 数据库\n      database: 0\n      # 读写超时\n      timeout: 5s\n      # 连接超时\n      connect-timeout: 2s\n      # 连接池\n      lettuce:\n        pool:\n          # 最大活跃数量\n          max-active: 8\n          # 最大空闲数量\n          max-idle: 8\n          # 最小空闲数量\n          min-idle: 0\n          # 最大等待周期\n          max-wait: -1ms\n\n\n  datasource:\n    url: jdbc:mysql://43.138.13.145:3306/g2rain_cms?useUnicode=true&characterEncoding=utf-8&useSSL=true&zeroDateTimeBehavior=convertToNull&serverTimezone=GMT%2B8\n    username: root\n    password: g2rain123456\n    driver-class-name: com.mysql.cj.jdbc.Driver\n    hikari:\n      connection-timeout: 30000\n      validation-timeout: 3000\n      idle-timeout: 30000\n      max-lifetime: 300000\n      minimum-idle: 1\n      maximum-pool-size: 10\n      connection-test-query: select 1', '0c4141d7870f3972b9276e638b584c41', '2026-04-14 21:14:35', '2026-04-14 21:20:03', 'nacos', '120.245.114.39', '', 'g2rain-dev', '', '', '', 'yaml', '', ''),
       (30, 'g2rain-cms.yml', 'g2rain-cms', 'spring:\n  # 非关系型数据库配置\n  data:\n    # redis 配置\n    redis:\n      # 主机地址\n      host: 10.0.0.2\n      # 端口\n      port: 6379\n      #密码\n      password: g2rain_redis_11050826\n      # redis 数据库\n      database: 0\n      # 读写超时\n      timeout: 5s\n      # 连接超时\n      connect-timeout: 2s\n      # 连接池\n      lettuce:\n        pool:\n          # 最大活跃数量\n          max-active: 8\n          # 最大空闲数量\n          max-idle: 8\n          # 最小空闲数量\n          min-idle: 0\n          # 最大等待周期\n          max-wait: -1ms\n\n\n  datasource:\n    url: jdbc:mysql://10.0.0.2:3306/g2rain_cms?useUnicode=true&characterEncoding=utf-8&useSSL=true&zeroDateTimeBehavior=convertToNull&serverTimezone=GMT%2B8\n    username: root\n    password: g2rain123456\n    driver-class-name: com.mysql.cj.jdbc.Driver\n    hikari:\n      connection-timeout: 30000\n      validation-timeout: 3000\n      idle-timeout: 30000\n      max-lifetime: 300000\n      minimum-idle: 1\n      maximum-pool-size: 10\n      connection-test-query: select 1', '03af4bf4a56e22cd59dbe4716261bdf3', '2026-04-14 21:15:08', '2026-10-18 16:53:55', 'nacos', '114.248.12.33', '', 'g2rain-test', '', '', '', 'yaml', '', ''),
       (53, 'g2rain-department.yml', 'g2rain-department', 'spring:\n  # 非关系型数据库配置\n  data:\n    # redis 配置\n    redis:\n      # 主机地址\n      host: 10.0.0.2\n      # 端口\n      port: 6379\n      #密码\n      password: g2rain_redis_11050826\n      # redis 数据库\n      database: 0\n      # 读写超时\n      timeout: 5s\n      # 连接超时\n      connect-timeout: 2s\n      # 连接池\n      lettuce:\n        pool:\n          # 最大活跃数量\n          max-active: 8\n          # 最大空闲数量\n          max-idle: 8\n          # 最小空闲数量\n          min-idle: 0\n          # 最大等待周期\n          max-wait: -1ms\n\n\n  datasource:\n    url: jdbc:mysql://10.0.0.2:3306/g2rain_department?useUnicode=true&characterEncoding=utf-8&useSSL=true&zeroDateTimeBehavior=convertToNull&serverTimezone=GMT%2B8\n    username: root\n    password: g2rain123456\n    driver-class-name: com.mysql.cj.jdbc.Driver\n    hikari:\n      connection-timeout: 30000\n      validation-timeout: 3000\n      idle-timeout: 30000\n      max-lifetime: 300000\n      minimum-idle: 1\n      maximum-pool-size: 10\n      connection-test-query: select 1', '094eb8b3c22c0062ed9b2d7bb3799abd', '2026-06-03 10:25:24', '2026-10-18 16:54:11', 'nacos', '114.248.12.33', '', 'g2rain-test', '', '', '', 'yaml', '', ''),
       (55, 'g2rain-department.yml', 'g2rain-department', 'spring:\n  # 非关系型数据库配置\n  data:\n    # redis 配置\n    redis:\n      # 主机地址\n      host: redis\n      # 端口\n      port: 6379\n      #密码\n      password: g2rain_redis_11050826\n      # redis 数据库\n      database: 0\n      # 读写超时\n      timeout: 5s\n      # 连接超时\n      connect-timeout: 2s\n      # 连接池\n      lettuce:\n        pool:\n          # 最大活跃数量\n          max-active: 8\n          # 最大空闲数量\n          max-idle: 8\n          # 最小空闲数量\n          min-idle: 0\n          # 最大等待周期\n          max-wait: -1ms\n\n\n  datasource:\n    url: jdbc:mysql://mysql:3306/g2rain_department?useUnicode=true&characterEncoding=utf-8&useSSL=true&zeroDateTimeBehavior=convertToNull&serverTimezone=GMT%2B8\n    username: root\n    password: g2rain123456\n    driver-class-name: com.mysql.cj.jdbc.Driver\n    hikari:\n      connection-timeout: 30000\n      validation-timeout: 3000\n      idle-timeout: 30000\n      max-lifetime: 300000\n      minimum-idle: 1\n      maximum-pool-size: 10\n      connection-test-query: select 1', 'e88fbb8a18321555943406e6b5166b7f', '2026-07-22 23:07:28', '2026-07-22 23:54:41', 'nacos', '120.245.114.86', '', 'g2rain-dev', '', '', '', 'yaml', '', ''),
       (59, 'g2rain-member.yml', 'g2rain-member', 'spring:\r\n  # 非关系型数据库配置\r\n  data:\r\n    # redis 配置\r\n    redis:\r\n      # 主机地址\r\n      host: 43.138.13.145\r\n      # 端口\r\n      port: 6379\r\n      #密码\r\n      password: g2rain_redis_11050826\r\n      # redis 数据库\r\n      database: 0\r\n      # 读写超时\r\n      timeout: 5s\r\n      # 连接超时\r\n      connect-timeout: 2s\r\n      # 连接池\r\n      lettuce:\r\n        pool:\r\n          # 最大活跃数量\r\n          max-active: 8\r\n          # 最大空闲数量\r\n          max-idle: 8\r\n          # 最小空闲数量\r\n          min-idle: 0\r\n          # 最大等待周期\r\n          max-wait: -1ms\r\n\r\n\r\n  datasource:\r\n    url: jdbc:mysql://43.138.13.145:3306/g2rain_member?useUnicode=true&characterEncoding=utf-8&useSSL=true&zeroDateTimeBehavior=convertToNull&serverTimezone=GMT%2B8\r\n    username: root\r\n    password: g2rain123456\r\n    driver-class-name: com.mysql.cj.jdbc.Driver\r\n    hikari:\r\n      connection-timeout: 30000\r\n      validation-timeout: 3000\r\n      idle-timeout: 30000\r\n      max-lifetime: 300000\r\n      minimum-idle: 1\r\n      maximum-pool-size: 10\r\n      connection-test-query: select 1', '2dc2d8bbdadb0638e2715c86a67542c0', '2026-08-20 23:25:06', '2026-08-20 23:25:06', 'nacos', '120.245.114.102', '', 'g2rain-dev', '会员系统', NULL, NULL, 'yaml', NULL, ''),
       (60, 'g2rain-member.yml', 'g2rain-member', 'spring:\n  # 非关系型数据库配置\n  data:\n    # redis 配置\n    redis:\n      # 主机地址\n      host: 10.0.0.2\n      # 端口\n      port: 6379\n      #密码\n      password: g2rain_redis_11050826\n      # redis 数据库\n      database: 0\n      # 读写超时\n      timeout: 5s\n      # 连接超时\n      connect-timeout: 2s\n      # 连接池\n      lettuce:\n        pool:\n          # 最大活跃数量\n          max-active: 8\n          # 最大空闲数量\n          max-idle: 8\n          # 最小空闲数量\n          min-idle: 0\n          # 最大等待周期\n          max-wait: -1ms\n\n\n  datasource:\n    url: jdbc:mysql://10.0.0.2:3306/g2rain_member?useUnicode=true&characterEncoding=utf-8&useSSL=true&zeroDateTimeBehavior=convertToNull&serverTimezone=GMT%2B8\n    username: root\n    password: g2rain123456\n    driver-class-name: com.mysql.cj.jdbc.Driver\n    hikari:\n      connection-timeout: 30000\n      validation-timeout: 3000\n      idle-timeout: 30000\n      max-lifetime: 300000\n      minimum-idle: 1\n      maximum-pool-size: 10\n      connection-test-query: select 1', 'dac24a2ac1d20bd94502d4a322d465af', '2026-09-17 19:52:55', '2026-10-18 16:54:29', 'nacos', '114.248.12.33', '', 'g2rain-test', '', '', '', 'yaml', '', ''),
       (61, 'g2rain-member.yaml', 'g2rain-member', 'spring:\n  # 非关系型数据库配置\n  data:\n    # redis 配置\n    redis:\n      # 主机地址\n      host: 10.0.0.2\n      # 端口\n      port: 6379\n      #密码\n      password: g2rain_redis_11050826\n      # redis 数据库\n      database: 0\n      # 读写超时\n      timeout: 5s\n      # 连接超时\n      connect-timeout: 2s\n      # 连接池\n      lettuce:\n        pool:\n          # 最大活跃数量\n          max-active: 8\n          # 最大空闲数量\n          max-idle: 8\n          # 最小空闲数量\n          min-idle: 0\n          # 最大等待周期\n          max-wait: -1ms\n\n\n  datasource:\n    url: jdbc:mysql://10.0.0.2:3306/g2rain_member?useUnicode=true&characterEncoding=utf-8&useSSL=true&zeroDateTimeBehavior=convertToNull&serverTimezone=GMT%2B8\n    username: root\n    password: g2rain123456\n    driver-class-name: com.mysql.cj.jdbc.Driver\n    hikari:\n      connection-timeout: 30000\n      validation-timeout: 3000\n      idle-timeout: 30000\n      max-lifetime: 300000\n      minimum-idle: 1\n      maximum-pool-size: 10\n      connection-test-query: select 1', 'dac24a2ac1d20bd94502d4a322d465af', '2026-09-17 20:32:07', '2026-10-18 16:55:05', 'nacos', '114.248.12.33', '', 'g2rain-test', '', '', '', 'yaml', '', ''),
       (64, 'g2rain-model-nexus.yml', 'g2rain-model-nexus', 'spring:\n  # 非关系型数据库配置\n  data:\n    # redis 配置\n    redis:\n      # 主机地址\n      host: 10.0.0.2\n      # 端口\n      port: 6379\n      #密码\n      password: g2rain_redis_11050826\n      # redis 数据库\n      database: 0\n      # 读写超时\n      timeout: 5s\n      # 连接超时\n      connect-timeout: 2s\n      # 连接池\n      lettuce:\n        pool:\n          # 最大活跃数量\n          max-active: 8\n          # 最大空闲数量\n          max-idle: 8\n          # 最小空闲数量\n          min-idle: 0\n          # 最大等待周期\n          max-wait: -1ms\n\n\n  datasource:\n    url: jdbc:mysql://10.0.0.2:3306/g2rain_model_nexus?useUnicode=true&characterEncoding=utf-8&useSSL=true&zeroDateTimeBehavior=convertToNull&serverTimezone=GMT%2B8\n    username: root\n    password: g2rain123456\n    driver-class-name: com.mysql.cj.jdbc.Driver\n    hikari:\n      connection-timeout: 30000\n      validation-timeout: 3000\n      idle-timeout: 30000\n      max-lifetime: 300000\n      minimum-idle: 1\n      maximum-pool-size: 10\n      connection-test-query: select 1\n\nlogging:\n  level:\n    com.g2rain.model.nexus.protocol.openai.UpstreamTrace: debug', 'ea536dcc1319bc0b134e96ba5eb2185f', '2026-10-09 09:14:39', '2026-10-23 18:12:57', 'nacos', '1.203.173.224', '', 'g2rain-test', '', '', '', 'yaml', '', ''),
       (65, 'g2rain-mcp-registry.yml', 'g2rain-mcp-registry', 'spring:\n  # 非关系型数据库配置\n  data:\n    # redis 配置\n    redis:\n      # 主机地址\n      host: 10.0.0.2\n      # 端口\n      port: 6379\n      #密码\n      password: g2rain_redis_11050826\n      # redis 数据库\n      database: 0\n      # 读写超时\n      timeout: 5s\n      # 连接超时\n      connect-timeout: 2s\n      # 连接池\n      lettuce:\n        pool:\n          # 最大活跃数量\n          max-active: 8\n          # 最大空闲数量\n          max-idle: 8\n          # 最小空闲数量\n          min-idle: 0\n          # 最大等待周期\n          max-wait: -1ms\n\n\n  datasource:\n    url: jdbc:mysql://10.0.0.2:3306/g2rain_mcp_registry?useUnicode=true&characterEncoding=utf-8&useSSL=true&zeroDateTimeBehavior=convertToNull&serverTimezone=GMT%2B8\n    username: root\n    password: g2rain123456\n    driver-class-name: com.mysql.cj.jdbc.Driver\n    hikari:\n      connection-timeout: 30000\n      validation-timeout: 3000\n      idle-timeout: 30000\n      max-lifetime: 300000\n      minimum-idle: 1\n      maximum-pool-size: 10\n      connection-test-query: select 1', '68f873a76514d7eb36f32d41032f13dd', '2026-10-09 09:14:39', '2026-10-18 16:55:29', 'nacos', '114.248.12.33', '', 'g2rain-test', '', '', '', 'yaml', '', ''),
       (66, 'g2rain-agent-runtime.yml', 'g2rain-agent-runtime', 'spring:\n  # 非关系型数据库配置\n  data:\n    # redis 配置\n    redis:\n      # 主机地址\n      host: 10.0.0.2\n      # 端口\n      port: 6379\n      #密码\n      password: g2rain_redis_11050826\n      # redis 数据库\n      database: 0\n      # 读写超时\n      timeout: 5s\n      # 连接超时\n      connect-timeout: 2s\n      # 连接池\n      lettuce:\n        pool:\n          # 最大活跃数量\n          max-active: 8\n          # 最大空闲数量\n          max-idle: 8\n          # 最小空闲数量\n          min-idle: 0\n          # 最大等待周期\n          max-wait: -1ms\n\n\n  datasource:\n    url: jdbc:mysql://10.0.0.2:3306/g2rain_agent_runtime?useUnicode=true&characterEncoding=utf-8&useSSL=true&zeroDateTimeBehavior=convertToNull&serverTimezone=GMT%2B8\n    username: root\n    password: g2rain123456\n    driver-class-name: com.mysql.cj.jdbc.Driver\n    hikari:\n      connection-timeout: 30000\n      validation-timeout: 3000\n      idle-timeout: 30000\n      max-lifetime: 300000\n      minimum-idle: 1\n      maximum-pool-size: 10\n      connection-test-query: select 1\n\nredisson:\n  config: |\n    singleServerConfig:\n      address: \"redis://redis:6379\"\n      password: \"g2rain_redis_11050826\"\n      database: 0\n      connectionMinimumIdleSize: 1\n      connectionPoolSize: 10\n      timeout: 3000\n      connectTimeout: 2000', '201890eb1d59e652dc44c31a94a17be2', '2026-10-09 09:14:39', '2026-10-18 16:55:42', 'nacos', '114.248.12.33', '', 'g2rain-test', '', '', '', 'yaml', '', ''),
       (67, 'g2rain-agent-studio.yml', 'g2rain-agent-studio', 'spring:\n  # 非关系型数据库配置\n  data:\n    # redis 配置\n    redis:\n      # 主机地址\n      host: 10.0.0.2\n      # 端口\n      port: 6379\n      #密码\n      password: g2rain_redis_11050826\n      # redis 数据库\n      database: 0\n      # 读写超时\n      timeout: 5s\n      # 连接超时\n      connect-timeout: 2s\n      # 连接池\n      lettuce:\n        pool:\n          # 最大活跃数量\n          max-active: 8\n          # 最大空闲数量\n          max-idle: 8\n          # 最小空闲数量\n          min-idle: 0\n          # 最大等待周期\n          max-wait: -1ms\n\n\n  datasource:\n    url: jdbc:mysql://10.0.0.2:3306/g2rain_agent_studio?useUnicode=true&characterEncoding=utf-8&useSSL=true&zeroDateTimeBehavior=convertToNull&serverTimezone=GMT%2B8\n    username: root\n    password: g2rain123456\n    driver-class-name: com.mysql.cj.jdbc.Driver\n    hikari:\n      connection-timeout: 30000\n      validation-timeout: 3000\n      idle-timeout: 30000\n      max-lifetime: 300000\n      minimum-idle: 1\n      maximum-pool-size: 10\n      connection-test-query: select 1', 'b119c6d6f261eba11ee72e4ec5a41b78', '2026-10-09 09:14:39', '2026-10-18 16:55:54', 'nacos', '114.248.12.33', '', 'g2rain-test', '', '', '', 'yaml', '', ''),
       (73, 'g2rain-knowledge.yml', 'g2rain-knowledge', 'spring:\n  # 非关系型数据库配置\n  data:\n    # redis 配置\n    redis:\n      # 主机地址\n      host: 10.0.0.2\n      # 端口\n      port: 6379\n      #密码\n      password: g2rain_redis_11050826\n      # redis 数据库\n      database: 0\n      # 读写超时\n      timeout: 5s\n      # 连接超时\n      connect-timeout: 2s\n      # 连接池\n      lettuce:\n        pool:\n          # 最大活跃数量\n          max-active: 8\n          # 最大空闲数量\n          max-idle: 8\n          # 最小空闲数量\n          min-idle: 0\n          # 最大等待周期\n          max-wait: -1ms\n\n\n  datasource:\n    url: jdbc:mysql://10.0.0.2:3306/g2rain_knowledge?useUnicode=true&characterEncoding=utf-8&useSSL=true&zeroDateTimeBehavior=convertToNull&serverTimezone=GMT%2B8\n    username: root\n    password: g2rain123456\n    driver-class-name: com.mysql.cj.jdbc.Driver\n    hikari:\n      connection-timeout: 30000\n      validation-timeout: 3000\n      idle-timeout: 30000\n      max-lifetime: 300000\n      minimum-idle: 1\n      maximum-pool-size: 10\n      connection-test-query: select 1\ng2rain:\n  knowledge:\n    embedding:\n      url: http://g2rain-model-nexus:8080/v1/embeddings\n      model-name: Qwen3-Embedding-8B\n      dimension: 4096\n      encoding-format: float\n    milvus:\n      uri: http://10.0.0.2:19530\n    answer:\n      url: http://g2rain-model-nexus:8080/v1/chat/completions\n      model-name: Qwen3-8B-BW\n    rerank:\n      enabled: false\n      url: http://g2rain-model-nexus:8080/v1/rerank\n      model-name: bge-reranker-v2-m3', '9069df9d20b999c5854e0bc28c334fec', '2026-10-14 23:29:14', '2026-10-23 06:39:39', 'nacos', '120.245.114.207', '', 'g2rain-test', '知识库服务配置', '', '', 'yaml', '', '');

--
-- Table structure for table `config_info_aggr`
--

DROP TABLE IF EXISTS `config_info_aggr`;
CREATE TABLE `config_info_aggr`
(
    `id`           bigint                                                 NOT NULL AUTO_INCREMENT COMMENT 'id',
    `data_id`      varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT 'data_id',
    `group_id`     varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT 'group_id',
    `datum_id`     varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT 'datum_id',
    `content`      longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin     NOT NULL COMMENT '内容',
    `gmt_modified` datetime                                               NOT NULL COMMENT '修改时间',
    `app_name`     varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
    `tenant_id`    varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '' COMMENT '租户字段',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_configinfoaggr_datagrouptenantdatum` (`data_id`,`group_id`,`tenant_id`,`datum_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='增加租户字段';

--
-- Table structure for table `config_info_beta`
--

DROP TABLE IF EXISTS `config_info_beta`;
CREATE TABLE `config_info_beta`
(
    `id`                 bigint                                                  NOT NULL AUTO_INCREMENT COMMENT 'id',
    `data_id`            varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin  NOT NULL COMMENT 'data_id',
    `group_id`           varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin  NOT NULL COMMENT 'group_id',
    `app_name`           varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin  DEFAULT NULL COMMENT 'app_name',
    `content`            longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin      NOT NULL COMMENT 'content',
    `beta_ips`           varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'betaIps',
    `md5`                varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin   DEFAULT NULL COMMENT 'md5',
    `gmt_create`         datetime                                                NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `gmt_modified`       datetime                                                NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '修改时间',
    `src_user`           text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin          COMMENT 'source user',
    `src_ip`             varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin   DEFAULT NULL COMMENT 'source ip',
    `tenant_id`          varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin  DEFAULT '' COMMENT '租户字段',
    `encrypted_data_key` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin          NOT NULL COMMENT '秘钥',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_configinfobeta_datagrouptenant` (`data_id`,`group_id`,`tenant_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='config_info_beta';

--
-- Table structure for table `config_info_tag`
--

DROP TABLE IF EXISTS `config_info_tag`;
CREATE TABLE `config_info_tag`
(
    `id`           bigint                                                 NOT NULL AUTO_INCREMENT COMMENT 'id',
    `data_id`      varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT 'data_id',
    `group_id`     varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT 'group_id',
    `tenant_id`    varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '' COMMENT 'tenant_id',
    `tag_id`       varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT 'tag_id',
    `app_name`     varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'app_name',
    `content`      longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin     NOT NULL COMMENT 'content',
    `md5`          varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin  DEFAULT NULL COMMENT 'md5',
    `gmt_create`   datetime                                               NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `gmt_modified` datetime                                               NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '修改时间',
    `src_user`     text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin         COMMENT 'source user',
    `src_ip`       varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin  DEFAULT NULL COMMENT 'source ip',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_configinfotag_datagrouptenanttag` (`data_id`,`group_id`,`tenant_id`,`tag_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='config_info_tag';

--
-- Table structure for table `config_tags_relation`
--

DROP TABLE IF EXISTS `config_tags_relation`;
CREATE TABLE `config_tags_relation`
(
    `id`        bigint                                                 NOT NULL COMMENT 'id',
    `tag_name`  varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT 'tag_name',
    `tag_type`  varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin  DEFAULT NULL COMMENT 'tag_type',
    `data_id`   varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT 'data_id',
    `group_id`  varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT 'group_id',
    `tenant_id` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '' COMMENT 'tenant_id',
    `nid`       bigint                                                 NOT NULL AUTO_INCREMENT,
    PRIMARY KEY (`nid`),
    UNIQUE KEY `uk_configtagrelation_configidtag` (`id`,`tag_name`,`tag_type`),
    KEY `idx_tenant_id` (`tenant_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='config_tag_relation';

--
-- Table structure for table `group_capacity`
--

DROP TABLE IF EXISTS `group_capacity`;
CREATE TABLE `group_capacity`
(
    `id`                bigint unsigned                                        NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `group_id`          varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '' COMMENT 'Group ID，空字符表示整个集群',
    `quota`             int unsigned                                           NOT NULL DEFAULT '0' COMMENT '配额，0表示使用默认值',
    `usage`             int unsigned                                           NOT NULL DEFAULT '0' COMMENT '使用量',
    `max_size`          int unsigned                                           NOT NULL DEFAULT '0' COMMENT '单个配置大小上限，单位为字节，0表示使用默认值',
    `max_aggr_count`    int unsigned                                           NOT NULL DEFAULT '0' COMMENT '聚合子配置最大个数，，0表示使用默认值',
    `max_aggr_size`     int unsigned                                           NOT NULL DEFAULT '0' COMMENT '单个聚合数据的子配置大小上限，单位为字节，0表示使用默认值',
    `max_history_count` int unsigned                                           NOT NULL DEFAULT '0' COMMENT '最大变更历史数量',
    `gmt_create`        datetime                                               NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `gmt_modified`      datetime                                               NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '修改时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_group_id` (`group_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='集群、各Group容量信息表';

--
-- Table structure for table `his_config_info`
--

DROP TABLE IF EXISTS `his_config_info`;
CREATE TABLE `his_config_info`
(
    `id`                 bigint unsigned                                        NOT NULL,
    `nid`                bigint unsigned                                        NOT NULL AUTO_INCREMENT,
    `data_id`            varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
    `group_id`           varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
    `app_name`           varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'app_name',
    `content`            longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin     NOT NULL COMMENT 'content',
    `md5`                varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin  DEFAULT NULL COMMENT 'md5',
    `gmt_create`         datetime                                               NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `gmt_modified`       datetime                                               NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '修改时间',
    `src_user`           text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin         COMMENT 'source user',
    `src_ip`             varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin  DEFAULT NULL COMMENT 'source ip',
    `op_type`            char(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin     DEFAULT NULL COMMENT 'operation type',
    `tenant_id`          varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '' COMMENT '租户字段',
    `encrypted_data_key` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin         NOT NULL COMMENT '秘钥',
    PRIMARY KEY (`nid`),
    KEY `idx_gmt_create` (`gmt_create`),
    KEY `idx_gmt_modified` (`gmt_modified`),
    KEY `idx_did` (`data_id`)
) ENGINE=InnoDB AUTO_INCREMENT=102 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='多租户改造';

--
-- Table structure for table `permissions`
--

DROP TABLE IF EXISTS `permissions`;
CREATE TABLE `permissions`
(
    `role`     varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci  NOT NULL,
    `resource` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
    `action`   varchar(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci   NOT NULL,
    UNIQUE KEY `uk_role_permission` (`role`,`resource`,`action`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `roles`
--

DROP TABLE IF EXISTS `roles`;
CREATE TABLE `roles`
(
    `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
    `role`     varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
    UNIQUE KEY `idx_user_role` (`username`,`role`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `roles`
VALUES ('nacos', 'ROLE_ADMIN');

--
-- Table structure for table `tenant_capacity`
--

DROP TABLE IF EXISTS `tenant_capacity`;
CREATE TABLE `tenant_capacity`
(
    `id`                bigint unsigned                                        NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `tenant_id`         varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '' COMMENT 'Tenant ID',
    `quota`             int unsigned                                           NOT NULL DEFAULT '0' COMMENT '配额，0表示使用默认值',
    `usage`             int unsigned                                           NOT NULL DEFAULT '0' COMMENT '使用量',
    `max_size`          int unsigned                                           NOT NULL DEFAULT '0' COMMENT '单个配置大小上限，单位为字节，0表示使用默认值',
    `max_aggr_count`    int unsigned                                           NOT NULL DEFAULT '0' COMMENT '聚合子配置最大个数',
    `max_aggr_size`     int unsigned                                           NOT NULL DEFAULT '0' COMMENT '单个聚合数据的子配置大小上限，单位为字节，0表示使用默认值',
    `max_history_count` int unsigned                                           NOT NULL DEFAULT '0' COMMENT '最大变更历史数量',
    `gmt_create`        datetime                                               NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `gmt_modified`      datetime                                               NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '修改时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_tenant_id` (`tenant_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='租户容量信息表';

--
-- Table structure for table `tenant_info`
--

DROP TABLE IF EXISTS `tenant_info`;
CREATE TABLE `tenant_info`
(
    `id`            bigint                                                 NOT NULL AUTO_INCREMENT COMMENT 'id',
    `kp`            varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT 'kp',
    `tenant_id`     varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '' COMMENT 'tenant_id',
    `tenant_name`   varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '' COMMENT 'tenant_name',
    `tenant_desc`   varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'tenant_desc',
    `create_source` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin  DEFAULT NULL COMMENT 'create_source',
    `gmt_create`    bigint                                                 NOT NULL COMMENT '创建时间',
    `gmt_modified`  bigint                                                 NOT NULL COMMENT '修改时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_tenant_info_kptenantid` (`kp`,`tenant_id`),
    KEY `idx_tenant_id` (`tenant_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='tenant_info';

INSERT INTO `tenant_info`
VALUES (1, '1', 'g2rain-test', 'g2rain-test', '服务器测试环境', 'nacos', 1762587865705, 1762587865705),
       (2, '1', 'g2rain-dev', 'g2rain-dev', '开发环境', 'nacos', 1762587881896, 1762587881896);

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
CREATE TABLE `users`
(
    `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci  NOT NULL,
    `password` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
    `enabled`  tinyint(1)                                                    NOT NULL,
    PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `users`
VALUES ('nacos', '$2a$10$.8EiLDx5Uv51C/1AVUpfKeo74Ue2DRhIary4Zh1PevBhyTP/i8GNy', 1);
