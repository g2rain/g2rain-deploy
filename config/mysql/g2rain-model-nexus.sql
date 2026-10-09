-- =============================================
-- g2rain_model_nexus 数据库表结构
-- MySQL 8.0 版本
-- =============================================

-- 创建数据库
CREATE DATABASE IF NOT EXISTS `g2rain_model_nexus` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE `g2rain_model_nexus`;

-- =============================================
-- 1. 模型服务目录 (model_service_catalog)
-- =============================================
DROP TABLE IF EXISTS `model_service_catalog`;

CREATE TABLE `model_service_catalog` (
    `id` BIGINT NOT NULL COMMENT                                                                        '主键标识',
    `model_name` VARCHAR(128) NOT NULL COMMENT                                                          '模型调用标识',
    `model_type` VARCHAR(32) NOT NULL COMMENT                                                           '模型类型[LLM,VECTOR,RERANK]',
    `resource_type` VARCHAR(32) NOT NULL COMMENT                                                        '资源类型[MARKET:模型广场资源,CUSTOM:自定义资源]',
    `provider` VARCHAR(64) NOT NULL COMMENT                                                             '模型供应商',
    `protocol` VARCHAR(64) NOT NULL COMMENT                                                             '模型协议类型',
    `base_url` VARCHAR(255) NOT NULL COMMENT                                                            '模型服务地址',
    `api_key` VARCHAR(512) DEFAULT NULL COMMENT                                                         '访问密钥',
    `status` VARCHAR(32) NOT NULL DEFAULT 'ACTIVE' COMMENT                                              '状态[ACTIVE:启用,INACTIVE:禁用]',
    `description` VARCHAR(500) DEFAULT NULL COMMENT                                                     '说明',
    `create_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP COMMENT                                      '创建时间',
    `update_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT          '更新时间',
    `version` INT NOT NULL DEFAULT 0 COMMENT                                                            '版本号',
    `delete_flag` TINYINT NOT NULL DEFAULT 0 COMMENT                                                    '删除标识[0:未删除,1:已删除]',
    PRIMARY KEY (`id`),
    INDEX idx_resource_type (`resource_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT=                             '模型服务目录';

-- =============================================
-- 2. 模型服务配置 (model_service_profile)
-- =============================================
DROP TABLE IF EXISTS `model_service_profile`;

CREATE TABLE `model_service_profile` (
    `id` BIGINT NOT NULL COMMENT                                                                        '主键标识',
    `organ_id` BIGINT NOT NULL COMMENT                                                                  '机构标识',
    `catalog_id` BIGINT NOT NULL COMMENT                                                                '模型服务目录标识',
    `temperature` DECIMAL(4, 2) DEFAULT NULL COMMENT                                                    '采样温度',
    `top_p` DECIMAL(4, 2) DEFAULT NULL COMMENT                                                          'Top P 采样',
    `max_tokens` INT DEFAULT NULL COMMENT                                                               '最大输出 token 数',
    `timeout_ms` INT DEFAULT NULL COMMENT                                                               '请求超时毫秒数',
    `status` VARCHAR(32) NOT NULL DEFAULT 'ACTIVE' COMMENT                                              '状态[ACTIVE:启用, INACTIVE:禁用]',
    `description` VARCHAR(500) DEFAULT NULL COMMENT                                                     '模型说明',
    `create_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP COMMENT                                      '创建时间',
    `update_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT          '更新时间',
    `version` INT NOT NULL DEFAULT 0 COMMENT                                                            '记录版本',
    `delete_flag` TINYINT NOT NULL DEFAULT 0 COMMENT                                                    '删除标识[0:未删除, 1:已删除]',
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT=                             '模型服务配置';

-- =============================================
-- 3. 模型用量记录 (model_usage_record)
-- =============================================
DROP TABLE IF EXISTS `model_usage_record`;

CREATE TABLE `model_usage_record` (
    `id` BIGINT NOT NULL COMMENT                                                                        '主键标识',
    `organ_id` BIGINT NOT NULL COMMENT                                                                  '机构标识',
    `profile_id` BIGINT NOT NULL COMMENT                                                                '模型服务配置标识',
    `catalog_id` BIGINT NOT NULL COMMENT                                                                '模型服务目录标识',
    `protocol` VARCHAR(64) NOT NULL COMMENT                                                             '模型协议类型',
    `provider` VARCHAR(64) NOT NULL COMMENT                                                             '模型供应商',
    `model_name` VARCHAR(128) NOT NULL COMMENT                                                          '调用模型标识',
    `prompt_tokens` INT NOT NULL DEFAULT 0 COMMENT                                                      '输入 token 数',
    `completion_tokens` INT NOT NULL DEFAULT 0 COMMENT                                                  '输出 token 数',
    `total_tokens` INT NOT NULL DEFAULT 0 COMMENT                                                       '总 token 数',
    `create_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP COMMENT                                      '创建时间',
    `update_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT          '更新时间',
    `version` INT NOT NULL DEFAULT 0 COMMENT                                                            '记录版本',
    PRIMARY KEY (`id`),
    INDEX `idx_profile_id` (`profile_id`),
    INDEX `idx_organ_create_time` (`organ_id`, `create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT=                             '模型用量记录';

-- 本地/开发示例：先写 catalog，再写租户 organ_id=2 的 profile
INSERT INTO `model_service_catalog` (`id`, `model_name`, `model_type`, `resource_type`, `provider`, `protocol`, `base_url`, `api_key`, `status`, `description`)
VALUES (1, 'Qwen3.6-27B-bw', 'LLM', 'CUSTOM', '千问大语言模型', 'OPENAI', 'https://g2rain.com/api/model/v1', 'sk-xxx', 'ACTIVE', '千问自建大语言模型'),
       (2, '/models/Qwen3-Embedding-8B', 'VECTOR', 'CUSTOM', '千问向量模型', 'OPENAI', 'https://g2rain.com/api/model/v1', 'sk-xxx', 'ACTIVE', '千问自建向量模型'),
       (3, 'Qwen3.8-27B', 'RERANK', 'CUSTOM', '千问向量模型', 'OPENAI', 'https://g2rain.com/api/model/v1', 'sk-xxx', 'ACTIVE', '千问重排序模型');

INSERT INTO `model_service_profile` (`id`, `organ_id`, `catalog_id`, `temperature`, `top_p`, `max_tokens`, `timeout_ms`, `status`, `description`)
VALUES (4, 2, 1, 0.70, 1.00, 4096, 120000, 'ACTIVE', '千问自建大语言模型'),
       (5, 2, 2, NULL, NULL, NULL, 120000, 'ACTIVE', '千问自建向量模型'),
       (6, 2, 3, NULL, NULL, NULL, 120000, 'ACTIVE', '千问重排序模型');
