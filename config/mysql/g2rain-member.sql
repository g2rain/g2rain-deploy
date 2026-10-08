-- =============================================
-- g2rain_member 数据库表结构
-- MySQL 8.0.13+
-- 仅用于首次初始化；脚本会删除并重建会员表，禁止在已有会员数据的环境重复执行
-- 数据库及表统一使用大小写敏感排序规则 utf8mb4_0900_as_cs
-- =============================================

CREATE DATABASE IF NOT EXISTS `g2rain_member`
    DEFAULT CHARACTER SET utf8mb4
    COLLATE utf8mb4_0900_as_cs;

USE `g2rain_member`;

-- =============================================
-- 1. 会员表（member）
-- organ 内的会员主体，不关联 passport
-- =============================================
DROP TABLE IF EXISTS `member_identity`;
DROP TABLE IF EXISTS `member`;

CREATE TABLE `member` (
    `id` BIGINT NOT NULL COMMENT '会员标识',
    `organ_id` BIGINT NOT NULL COMMENT '机构标识，关联 g2rain_basis.organ.id，会员归属租户',
    `member_no` VARCHAR(64) NOT NULL COMMENT '会员编号，机构内唯一，由系统生成',
    `name` VARCHAR(128) DEFAULT NULL COMMENT '会员名称',
    `avatar` VARCHAR(512) DEFAULT NULL COMMENT '会员头像地址',
    `mobile` VARCHAR(32) DEFAULT NULL COMMENT '会员手机号，仅作为资料字段，登录身份以 member_identity 为准',
    `status` VARCHAR(32) NOT NULL DEFAULT 'NORMAL' COMMENT '会员状态[NORMAL:正常, FROZEN:冻结]',
    `create_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `version` INT NOT NULL DEFAULT 0 COMMENT '记录版本',
    `delete_flag` TINYINT NOT NULL DEFAULT 0 COMMENT '删除标识[0:未删除, 1:已删除]',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_organ_member_no` (`organ_id`, `member_no`),
    INDEX `idx_organ_status_del` (`organ_id`, `status`, `delete_flag`),
    INDEX `idx_organ_mobile_del` (`organ_id`, `mobile`, `delete_flag`)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_0900_as_cs
  COMMENT='会员表';

-- =============================================
-- 2. 会员身份表（member_identity）
-- 当前支持企业微信，后续可扩展手机号等身份
-- =============================================
CREATE TABLE `member_identity` (
    `id` BIGINT NOT NULL COMMENT '会员身份标识',
    `organ_id` BIGINT NOT NULL COMMENT '机构标识，关联 g2rain_basis.organ.id，身份归属租户',
    `member_id` BIGINT NOT NULL COMMENT '会员标识，关联 member.id',
    `identity_type` VARCHAR(32) NOT NULL COMMENT '身份类型[WECHAT_WORK:企业微信, MOBILE:手机号]',
    `identity_value` VARCHAR(256) NOT NULL COMMENT '身份值；企业微信为 external_userid，手机号为标准化后的手机号',
    `verified` TINYINT NOT NULL DEFAULT 0 COMMENT '验证标识[0:未验证, 1:已验证]',
    `raw_profile` JSON DEFAULT NULL COMMENT '外部身份原始资料，JSON 格式',
    `create_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `version` INT NOT NULL DEFAULT 0 COMMENT '记录版本',
    `delete_flag` TINYINT NOT NULL DEFAULT 0 COMMENT '删除标识[0:未删除, 1:已删除]',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_organ_identity` (`organ_id`, `identity_type`, `identity_value`),
    UNIQUE KEY `uk_organ_member_type` (`organ_id`, `member_id`, `identity_type`),
    INDEX `idx_organ_member_del` (`organ_id`, `member_id`, `delete_flag`)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_0900_as_cs
  COMMENT='会员身份表';
