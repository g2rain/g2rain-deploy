-- =============================================
-- g2rain_basis 数据库表结构
-- MySQL 8.0 版本
-- =============================================

-- 创建数据库
CREATE DATABASE IF NOT EXISTS `g2rain_basis` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE `g2rain_basis`;

-- =============================================
-- 1. 账号表 (passport)
-- =============================================
DROP TABLE IF EXISTS `passport`;

CREATE TABLE `passport` (
    `id` BIGINT NOT NULL COMMENT 													                    '账号标识',
    `username` VARCHAR(64) NOT NULL UNIQUE COMMENT 											            '登录用户',
    `password` VARCHAR(256) NOT NULL DEFAULT '' COMMENT 												'登录密码',
    `real_name` VARCHAR(128) DEFAULT NULL COMMENT 														'真实姓名',
    `sex` VARCHAR(12) DEFAULT NULL COMMENT 															    '性别[MALE:男性, FEMALE:女性]',
    `birthday` VARCHAR(16) DEFAULT NULL COMMENT 														'生日',
    `id_no` VARCHAR(32) DEFAULT NULL COMMENT 															'身份证号',
    `mobile` VARCHAR(32) DEFAULT '' COMMENT 															'手机号码',
    `email` VARCHAR(128) DEFAULT NULL COMMENT 														    '邮箱地址',
    `status` VARCHAR(32) NOT NULL DEFAULT 'NORMAL' COMMENT 												'状态[NORMAL:正常, FROZEN:冻结]',
    `password_trusted` TINYINT NOT NULL DEFAULT 1 COMMENT                                               '密码是否可信[0:不可信/临时密码, 1:可信/用户已设置]',
    `create_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP COMMENT                                      '创建时间',
    `update_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT          '更新时间',
    `version` INT NOT NULL DEFAULT 0 COMMENT                                                            '记录版本',
    `delete_flag` TINYINT NOT NULL DEFAULT 0 COMMENT                                                    '删除标识[0:未删除, 1:已删除]',
    PRIMARY KEY (`id`),
    INDEX `idx_username` (`username`),
    INDEX `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT=                             '账号表';

-- =============================================
-- 2. 身份源绑定：passport <-> 钉钉等 IdP（不自动建 passport）
-- =============================================
DROP TABLE IF EXISTS `passport_idp_binding`;

CREATE TABLE `passport_idp_binding` (
    `id` BIGINT NOT NULL COMMENT                                                                        '主键标识',
    `passport_id` BIGINT NOT NULL COMMENT                                                               '账号标识，关联 passport.id',
    `idp_type` VARCHAR(32) NOT NULL COMMENT                                                             '身份源类型[IdpType: DINGTALK|FEISHU|WECHAT_WORK；当前 IAM 仅钉钉]',
    `idp_subject` VARCHAR(128) NOT NULL COMMENT                                                         'IdP 侧稳定主体标识，建议存钉钉 unionId',
    `corp_id` VARCHAR(64) DEFAULT NULL COMMENT                                                          '钉钉企业 corpId；企业内部模式可由 IAM 写入默认 corp',
    `idp_user_id` VARCHAR(128) DEFAULT NULL COMMENT                                                     '钉钉 userid（corp 内），可选，便于审计与运营排查',
    `idp_application_code` VARCHAR(128) NOT NULL DEFAULT '' COMMENT                                     '三方应用在 IdP 侧的应用标识（如钉钉 OAuth clientId），与 application_idp_provision.idp_application_code 对齐',
    `bind_mode` VARCHAR(32) DEFAULT NULL COMMENT                                                        '接入形态[IdpBindMode: INTERNAL企业内部应用|THIRD_PARTY第三方应用；与钉钉换票链路对应，非OAuth两跳]',
    `raw_profile` JSON DEFAULT NULL COMMENT                                                             'IdP 返回的原始用户信息快照（可选）',
    `create_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP COMMENT                                      '创建时间',
    `update_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT          '更新时间',
    `version` INT NOT NULL DEFAULT 0 COMMENT                                                            '记录版本',
    `delete_flag` TINYINT NOT NULL DEFAULT 0 COMMENT                                                    '删除标识[0:未删除, 1:已删除]',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_idp_type_subject_app` (`idp_type`, `idp_subject`, `idp_application_code`),
    KEY `idx_passport_id` (`passport_id`),
    KEY `idx_corp_idp` (`corp_id`, `idp_type`),
    KEY `idx_delete_flag` (`delete_flag`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT=                             '账号与外部身份源绑定表';

-- =============================================
-- 3. 外部身份源应用 ↔ 平台应用（换票后 access 的 g2rain application）
-- 通行证与 IdP 的关系见 passport_idp_binding（含 idp_application_code）
-- =============================================
DROP TABLE IF EXISTS `application_idp_provision`;

CREATE TABLE `application_idp_provision` (
    `id` BIGINT NOT NULL COMMENT                                                                        '主键标识',
    `application_id` BIGINT NOT NULL COMMENT                                                            '平台应用标识，关联 application.id',
    `idp_type` VARCHAR(32) NOT NULL COMMENT                                                             '身份源类型，与 IdpType 枚举名一致',
    `idp_application_code` VARCHAR(128) NOT NULL COMMENT                                                '三方应用在 IdP 侧的标识（如钉钉 OAuth clientId）',
    `remark` VARCHAR(512) DEFAULT NULL COMMENT                                                          '备注',
    `create_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP COMMENT                                      '创建时间',
    `update_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT          '更新时间',
    `version` INT NOT NULL DEFAULT 0 COMMENT                                                            '记录版本',
    `delete_flag` TINYINT NOT NULL DEFAULT 0 COMMENT                                                    '删除标识[0:未删除, 1:已删除]',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_idp_application` (`idp_type`, `idp_application_code`),
    KEY `idx_application_id` (`application_id`),
    KEY `idx_delete_flag` (`delete_flag`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT=                             '外部身份源应用与平台应用的绑定';

-- =============================================
-- 4. 用户表 (user)
-- =============================================
DROP TABLE IF EXISTS `user`;

CREATE TABLE `user` (
    `id` BIGINT NOT NULL COMMENT 													                    '用户标识',
    `passport_id` BIGINT NOT NULL COMMENT 														        '账号标识',
    `organ_id` BIGINT NOT NULL COMMENT 												                    '机构标识',
    `email` VARCHAR(128) DEFAULT NULL COMMENT 														    '邮箱地址',
    `mobile` VARCHAR(32) DEFAULT '' COMMENT 															'手机号码',
    `real_name` VARCHAR(128) DEFAULT NULL COMMENT 														'真实姓名',
    `admin` TINYINT NOT NULL DEFAULT 0 COMMENT 													        '管理员标记[0:否, 1:是]',
    `create_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP COMMENT                                      '创建时间',
    `update_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT          '更新时间',
    `version` INT NOT NULL DEFAULT 0 COMMENT                                                            '记录版本',
    `delete_flag` TINYINT NOT NULL DEFAULT 0 COMMENT                                                    '删除标识[0:未删除, 1:已删除]',
    PRIMARY KEY (`id`),
    INDEX `idx_passport_id` (`passport_id`),
    INDEX `idx_organ_id` (`organ_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT=                             '用户表';

-- =============================================
-- 5. 机构表 (organ)
-- =============================================
DROP TABLE IF EXISTS `organ`;

CREATE TABLE `organ` (
    `id` BIGINT NOT NULL COMMENT 													                    '机构标识',
    `organ_name` VARCHAR(128) NOT NULL COMMENT 															'机构名称',
    `organ_type` VARCHAR(32) NOT NULL COMMENT 															'机构类型[服务商、渠道、公司、租户]',
    `status` VARCHAR(32) NOT NULL DEFAULT 'ACTIVE' COMMENT 											    '机构状态[ACTIVE:有效, INACTIVE:无效]',
    `admin` TINYINT NOT NULL DEFAULT 0 COMMENT 													        '运营标记[0:否, 1:是]',
    `create_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP COMMENT                                      '创建时间',
    `update_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT          '更新时间',
    `version` INT NOT NULL DEFAULT 0 COMMENT                                                            '记录版本',
    `delete_flag` TINYINT NOT NULL DEFAULT 0 COMMENT                                                    '删除标识[0:未删除, 1:已删除]',
    PRIMARY KEY (`id`),
    INDEX `idx_organ_name` (`organ_name`),
    INDEX `idx_organ_type` (`organ_type`),
    INDEX `idx_organ_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT=                             '机构表';

-- =============================================
-- 6. 外部企业/租户 ↔ 平台机构（organ）多对多
-- 同一 (idp_type, enterprise_id) 可对应多个 organ_id（多租户）
-- =============================================
DROP TABLE IF EXISTS `idp_enterprise_organ`;

CREATE TABLE `idp_enterprise_organ` (
    `id` BIGINT NOT NULL COMMENT                                                                        '主键标识',
    `idp_type` VARCHAR(32) NOT NULL COMMENT                                                             '身份源类型[DINGTALK, WECHAT_WORK, FEISHU, ...]',
    `enterprise_id` VARCHAR(64) NOT NULL COMMENT                                                        '外部企业/租户标识（与 passport_idp_binding.enterprise_id 一致）',
    `organ_id` BIGINT NOT NULL COMMENT                                                                  '机构标识，关联 organ.id（业务上应为租户类型机构）',
    `status` VARCHAR(32) NOT NULL DEFAULT 'ACTIVE' COMMENT                                              '状态[ACTIVE:有效, INACTIVE:停用]',
    `remark` VARCHAR(512) DEFAULT NULL COMMENT                                                          '备注',
    `create_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP COMMENT                                      '创建时间',
    `update_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT          '更新时间',
    `version` INT NOT NULL DEFAULT 0 COMMENT                                                            '记录版本',
    `delete_flag` TINYINT NOT NULL DEFAULT 0 COMMENT                                                    '删除标识[0:未删除, 1:已删除]',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_idp_enterprise_organ` (`idp_type`, `enterprise_id`, `organ_id`),
    KEY `idx_organ_id` (`organ_id`),
    KEY `idx_idp_enterprise` (`idp_type`, `enterprise_id`),
    KEY `idx_delete_flag` (`delete_flag`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT=                             '外部企业/租户与平台机构关联表';

-- =============================================
-- 7. 机构路径关系表 (organ_closure)
-- =============================================
DROP TABLE IF EXISTS `organ_closure`;

CREATE TABLE `organ_closure` (
    `id` BIGINT NOT NULL COMMENT 													                    '主键标识',
    `ancestor_id` BIGINT NOT NULL COMMENT  													            '祖先机构标识[上级]',
    `descendant_id` BIGINT NOT NULL COMMENT   													        '后代机构标识[下级]',
    `descendant_type` VARCHAR(32) NOT NULL COMMENT 													    '后代机构类型[服务商、渠道、公司、租户]',
    `relation_type` VARCHAR(32) NOT NULL COMMENT                                                        '关系类型[SELF_ASSOCIATION:自身关联, DIRECT_SUBORDINATE:直属, INDIRECT_SUBORDINATE:从属]',
    `path_count` INT NOT NULL DEFAULT 1 COMMENT                                                         '路径引用次数[用于DAG交叉挂载维护]',
    `create_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP COMMENT                                      '创建时间',
    `update_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT          '更新时间',
    `version` INT NOT NULL DEFAULT 0 COMMENT                                                            '记录版本',
    `delete_flag` TINYINT NOT NULL DEFAULT 0 COMMENT                                                    '删除标识[0:未删除, 1:已删除]',
    PRIMARY KEY (`id`),
    INDEX idx_ancestor_id (ancestor_id),
    INDEX idx_descendant_id (descendant_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT=                             '机构路径关系表';

-- =============================================
-- 8. 服务注册表 (service_registry)
-- =============================================
DROP TABLE IF EXISTS `service_registry`;

CREATE TABLE `service_registry` (
    `id` BIGINT NOT NULL COMMENT 													                   '后端服务标识',
    `service_code` VARCHAR(64) NOT NULL COMMENT                                                         '服务逻辑编码',
    `name` VARCHAR(128) NOT NULL COMMENT                                                                '服务显示名称',
    `endpoint` VARCHAR(256) NOT NULL COMMENT                                                            '服务目标地址',
    `route_prefix` VARCHAR(128) NOT NULL COMMENT                                                        '网关路由前缀',
    `description` VARCHAR(512) DEFAULT NULL COMMENT                                                     '后端服务说明',
    `create_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP COMMENT                                      '创建时间',
    `update_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT          '更新时间',
    `version` INT NOT NULL DEFAULT 0 COMMENT                                                            '记录版本',
    `delete_flag` TINYINT NOT NULL DEFAULT 0 COMMENT                                                    '删除标识[0:未删除, 1:已删除]',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_service_code` (`service_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT=                             '服务注册表';

-- =============================================
-- 9. 资源接口表 (resource_api)
-- =============================================
DROP TABLE IF EXISTS `resource_api`;

CREATE TABLE `resource_api` (
    `id` BIGINT NOT NULL COMMENT                                                                        '资源接口标识',
    `service_code` VARCHAR(64) NOT NULL COMMENT                                                         '服务逻辑编码',
    `api_tags` VARCHAR(128) NOT NULL COMMENT                                                            '资源接口标签',
    `name` VARCHAR(128) NOT NULL COMMENT                                                                '资源接口名称',
    `method` VARCHAR(32) NOT NULL COMMENT                                                               '接口请求方法',
    `path` VARCHAR(512) NOT NULL COMMENT                                                                '接口请求路径',
    `description` VARCHAR(512) DEFAULT NULL COMMENT                                                     '资源接口说明',
    `create_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP COMMENT                                      '创建时间',
    `update_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT          '更新时间',
    `version` INT NOT NULL DEFAULT 0 COMMENT                                                            '记录版本',
    `delete_flag` TINYINT NOT NULL DEFAULT 0 COMMENT                                                    '删除标识[0:未删除, 1:已删除]',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_service_method_path` (`service_code`,`method`,`path`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT=                             '资源接口表';

-- =============================================
-- 10. 应用资源菜单表 (resource_menu)
-- =============================================
DROP TABLE IF EXISTS `resource_menu`;

CREATE TABLE `resource_menu` (
    `id` BIGINT NOT NULL COMMENT 													                    '菜单标识',
    `parent_id` BIGINT DEFAULT NULL COMMENT 												            '父菜单标识',
    `application_id` BIGINT NOT NULL COMMENT 													        '应用标识',
    `menu_name` VARCHAR(128) NOT NULL COMMENT													        '菜单名称',
    `menu_code` VARCHAR(64) NOT NULL COMMENT 														    '菜单编码',
    `link_path` VARCHAR(128) DEFAULT NULL COMMENT 													    '链接路径',
    `icon` VARCHAR(32) DEFAULT NULL COMMENT 															'展示图标',
    `menu_sort_order` INT NOT NULL DEFAULT 0 COMMENT 												    '菜单排序',
    `create_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP COMMENT                                      '创建时间',
    `update_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT          '更新时间',
    `version` INT NOT NULL DEFAULT 0 COMMENT                                                            '记录版本',
    `delete_flag` TINYINT NOT NULL DEFAULT 0 COMMENT                                                    '删除标识[0:未删除, 1:已删除]',
    PRIMARY KEY (`id`),
    INDEX `idx_app_del_id` (`application_id`, `delete_flag`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT=                             '应用资源菜单表';

-- =============================================
-- 11. 应用资源页面表 (resource_page)
-- =============================================
DROP TABLE IF EXISTS `resource_page`;

CREATE TABLE `resource_page` (
    `id` BIGINT NOT NULL COMMENT 													                    '页面标识',
    `application_id` BIGINT NOT NULL COMMENT 													        '应用标识',
    `page_name` VARCHAR(128) NOT NULL COMMENT												            '页面名称',
    `page_code` VARCHAR(128) NOT NULL COMMENT												            '页面编码',
    `link_path` VARCHAR(128) NOT NULL COMMENT 													        '链接路径',
    `create_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP COMMENT                                      '创建时间',
    `update_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT          '更新时间',
    `version` INT NOT NULL DEFAULT 0 COMMENT                                                            '记录版本',
    `delete_flag` TINYINT NOT NULL DEFAULT 0 COMMENT                                                    '删除标识[0:未删除, 1:已删除]',
    PRIMARY KEY (`id`),
    INDEX `idx_app_del_id` (`application_id`, `delete_flag`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT=                             '应用资源页面表';

-- =============================================
-- 12. 应用资源页面元素表 (resource_page_element)
-- =============================================
DROP TABLE IF EXISTS `resource_page_element`;

CREATE TABLE `resource_page_element` (
    `id` BIGINT NOT NULL COMMENT 													                    '页面元素标识',
    `application_id` BIGINT NOT NULL COMMENT 													        '应用标识',
    `page_code` VARCHAR(128) NOT NULL COMMENT														    '页面编码',
    `page_element_name` VARCHAR(128) NOT NULL COMMENT												    '页面元素名称',
    `page_element_code` VARCHAR(64) NOT NULL COMMENT												    '页面元素编码',
    `create_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP COMMENT                                      '创建时间',
    `update_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT          '更新时间',
    `version` INT NOT NULL DEFAULT 0 COMMENT                                                            '记录版本',
    `delete_flag` TINYINT NOT NULL DEFAULT 0 COMMENT                                                    '删除标识[0:未删除, 1:已删除]',
    PRIMARY KEY (`id`),
    INDEX `idx_app_del_id` (`application_id`, `delete_flag`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT=                             '应用资源页面元素表';

-- =============================================
-- 13. 控制单元表 (control_unit)
-- =============================================
DROP TABLE IF EXISTS `control_unit`;

CREATE TABLE `control_unit` (
    `id` BIGINT NOT NULL COMMENT 													                    '控制单元标识',
    `application_id` BIGINT NOT NULL COMMENT 													        '应用标识',
    `control_unit_name` VARCHAR(128) NOT NULL COMMENT                                                   '控制单元名称',
    `control_unit_scope` VARCHAR(32) NOT NULL COMMENT                                                   '控制单元类型[OPERATION("运营功能"), CUSTOMER("客户功能"), PERPETUAL("永久有效功能")]',
    `landing` TINYINT NOT NULL DEFAULT 0 COMMENT                                                        '默认数据[0:否, 1:是]',
    `status` VARCHAR(32) NOT NULL DEFAULT 'UNPUBLISHED' COMMENT 										'控制单元状态[PUBLISHED:已发布, UNPUBLISHED:未发布]',
    `description` VARCHAR(512) DEFAULT NULL COMMENT   												    '业务说明',
    `create_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP COMMENT                                      '创建时间',
    `update_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT          '更新时间',
    `version` INT NOT NULL DEFAULT 0 COMMENT                                                            '记录版本',
    `delete_flag` TINYINT NOT NULL DEFAULT 0 COMMENT                                                    '删除标识[0:未删除, 1:已删除]',
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT=                             '控制单元表';

-- =============================================
-- 14. 控制单元资源关联表 (control_unit_resource_relation)
-- =============================================
DROP TABLE IF EXISTS `control_unit_resource_relation`;

CREATE TABLE `control_unit_resource_relation` (
    `id` BIGINT NOT NULL COMMENT 													                    '主键标识',
    `control_unit_id` BIGINT NOT NULL COMMENT							    					        '控制单元标识',
    `resource_id` BIGINT NOT NULL COMMENT							    					            '资源标识',
    `resource_type` VARCHAR(32) NOT NULL COMMENT												        '资源类型[MENU:菜单, PAGE:页面, PAGE_ELEMENT:页面元素, API_ENDPOINT:接口地址]',
    `status`       VARCHAR(32) DEFAULT NULL COMMENT												        '激活状态[VISIBLE:显示, ENABLED:可用]',
    `create_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP COMMENT                                      '创建时间',
    `update_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT          '更新时间',
    `version` INT NOT NULL DEFAULT 0 COMMENT                                                            '记录版本',
    `delete_flag` TINYINT NOT NULL DEFAULT 0 COMMENT                                                    '删除标识[0:未删除, 1:已删除]',
    PRIMARY KEY (`id`),
    INDEX `idx_cu_type_del_res` (`control_unit_id`, `resource_type`, `delete_flag`, `resource_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT=                             '控制单元资源关联表';

-- =============================================
-- 15. 角色表 (role)
-- =============================================
DROP TABLE IF EXISTS `role`;

CREATE TABLE `role` (
    `id` BIGINT NOT NULL COMMENT 													                    '角色标识',
    `organ_id` BIGINT DEFAULT NULL COMMENT 														        '机构标识',
    `role_name` VARCHAR(128) NOT NULL COMMENT 														    '角色名称',
    `role_type` VARCHAR(32) NOT NULL COMMENT 													        '角色类型[ADMIN:超管角色-只读, USER:用户角色]',
    `create_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP COMMENT                                      '创建时间',
    `update_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT          '更新时间',
    `version` INT NOT NULL DEFAULT 0 COMMENT                                                            '记录版本',
    `delete_flag` TINYINT NOT NULL DEFAULT 0 COMMENT                                                    '删除标识[0:未删除, 1:已删除]',
    PRIMARY KEY (`id`),
    INDEX `idx_organ_id_id` (`organ_id`, `id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT=                             '角色表';

-- =============================================
-- 16. 用户角色关联表 (user_role_relation)
-- =============================================
DROP TABLE IF EXISTS `user_role_relation`;

CREATE TABLE `user_role_relation` (
    `id` BIGINT NOT NULL COMMENT 													                    '主键标识',
    `user_id` BIGINT NOT NULL COMMENT 															        '用户标识',
    `role_id` BIGINT NOT NULL COMMENT 															        '角色标识',
    `create_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP COMMENT                                      '创建时间',
    `update_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT          '更新时间',
    `version` INT NOT NULL DEFAULT 0 COMMENT                                                            '记录版本',
    `delete_flag` TINYINT NOT NULL DEFAULT 0 COMMENT                                                    '删除标识[0:未删除, 1:已删除]',
    PRIMARY KEY (`id`),
    INDEX `idx_organ_id_id` (`user_id`, `role_id`, `delete_flag`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT=                             '用户角色关联表';

-- =============================================
-- 17. 角色控制单元关联表 (role_control_unit_relation)
-- =============================================
DROP TABLE IF EXISTS `role_control_unit_relation`;

CREATE TABLE `role_control_unit_relation` (
    `id` BIGINT NOT NULL COMMENT 													                    '主键标识',
    `role_id` BIGINT NOT NULL COMMENT 															        '角色标识',
    `control_unit_id` BIGINT NOT NULL COMMENT 													        '控制单元标识',
    `application_authorization_id` BIGINT DEFAULT NULL COMMENT                                          '应用授权标识',
    `status` VARCHAR(32) NOT NULL DEFAULT 'ACTIVATED' COMMENT 											'控制单元状态[ACTIVATED:激活, DEACTIVATED:关停]',
    `create_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP COMMENT                                      '创建时间',
    `update_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT          '更新时间',
    `version` INT NOT NULL DEFAULT 0 COMMENT                                                            '记录版本',
    `delete_flag` TINYINT NOT NULL DEFAULT 0 COMMENT                                                    '删除标识[0:未删除, 1:已删除]',
    PRIMARY KEY (`id`),
    -- 默认索引：按角色 + 控制单元 + 状态
    INDEX `idx_role_sts_del_cu` (`role_id`, `status`, `delete_flag`, `control_unit_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT=                             '角色控制单元关联表';

-- =============================================
-- 18. 控制域表 (control_domain)
-- =============================================
DROP TABLE IF EXISTS `control_domain`;

CREATE TABLE `control_domain` (
    `id` BIGINT NOT NULL COMMENT 													                    '控制域标识',
    `application_id` BIGINT NOT NULL COMMENT 													        '应用标识',
    `control_domain_name` VARCHAR(128) NOT NULL COMMENT                                                 '控制域名称',
    `control_domain_type` VARCHAR(32) NOT NULL COMMENT                                                  '控制域类型[TRADE("交易开通"), APPLICATION("应用授权开通")]',
    `control_domain_scope` VARCHAR(32) NOT NULL COMMENT                                                 '交付范围[CUSTOMER("客户交付"), OPERATION("平台运营")]',
    `description` TEXT DEFAULT NULL COMMENT   												            '业务说明',
    `create_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP COMMENT                                      '创建时间',
    `update_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT          '更新时间',
    `version` INT NOT NULL DEFAULT 0 COMMENT                                                            '记录版本',
    `delete_flag` TINYINT NOT NULL DEFAULT 0 COMMENT                                                    '删除标识[0:未删除, 1:已删除]',
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT=                             '控制域表';

-- =============================================
-- 19. 控制域控制单元关联表 (control_domain_control_unit_relation)
-- =============================================
DROP TABLE IF EXISTS `control_domain_control_unit_relation`;

CREATE TABLE `control_domain_control_unit_relation` (
    `id` BIGINT NOT NULL COMMENT 													                    '主键标识',
    `control_domain_id` BIGINT NOT NULL COMMENT                                                         '控制域标识',
    `control_unit_id` BIGINT NOT NULL COMMENT							    					        '控制单元标识',
    `create_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP COMMENT                                      '创建时间',
    `update_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT          '更新时间',
    `version` INT NOT NULL DEFAULT 0 COMMENT                                                            '记录版本',
    `delete_flag` TINYINT NOT NULL DEFAULT 0 COMMENT                                                    '删除标识[0:未删除, 1:已删除]',
    PRIMARY KEY (`id`),
    INDEX `idx_control_domain_unit` (`control_domain_id`, `control_unit_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT=                             '控制域控制单元关联表';

-- =============================================
-- 20. 应用表 (application)
-- =============================================
DROP TABLE IF EXISTS `application`;

CREATE TABLE `application` (
    `id` BIGINT NOT NULL COMMENT 													                    '应用标识',
    `organ_id` BIGINT NOT NULL COMMENT 												                    '机构标识',
    `application_name` VARCHAR(128) NOT NULL COMMENT                                                    '应用名称',
    `application_code` VARCHAR(64) DEFAULT NULL COMMENT                                                 '应用编码',
    `can_integrate` TINYINT NOT NULL DEFAULT 0 COMMENT                                                  '是否具备集成功能[0:否, 1:是]',
    `landing` TINYINT NOT NULL DEFAULT 0 COMMENT                                                        '默认数据[0:否, 1:是]',
    `api_key_supported` TINYINT NOT NULL DEFAULT 0 COMMENT                                              '支持API密钥[0:否, 1:是]',
    `application_type` VARCHAR(32) NOT NULL COMMENT                                                     '应用类型[SUPPORT:支撑, SYSTEM:系统提供, PUBLIC:第三方提供, PRIVATE:私有]',
    `public_key_algorithm` VARCHAR(32) DEFAULT NULL COMMENT                                             '应用公钥算法',
    `public_key_format` VARCHAR(32)  DEFAULT NULL COMMENT                                               '应用公钥格式',
    `public_key` TEXT DEFAULT NULL COMMENT                                                              '应用公钥内容',
    `access_token_expires_in` INT NOT NULL COMMENT                                                      '访问令牌生存时间(秒)',
    `refresh_token_expires_in` INT NOT NULL COMMENT                                                     '刷新访问令牌生存时间(秒)',
    `endpoint_url` VARCHAR(512) NOT NULL COMMENT   												        '访问地址',
    `context_path` VARCHAR(512) DEFAULT NULL COMMENT   												    '应用路径',
    `status` VARCHAR(32) NOT NULL DEFAULT 'UNPUBLISHED' COMMENT 										'应用状态[PUBLISHED:已发布, UNPUBLISHED:未发布]',
    `description` VARCHAR(512) DEFAULT NULL COMMENT   												    '业务说明',
    `create_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP COMMENT                                      '创建时间',
    `update_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT          '更新时间',
    `version` INT NOT NULL DEFAULT 0 COMMENT                                                            '记录版本',
    `delete_flag` TINYINT NOT NULL DEFAULT 0 COMMENT                                                    '删除标识[0:未删除, 1:已删除]',
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT=                             '应用表';

-- =============================================
-- 21. 应用归类关系表 (application_suite)
-- =============================================
DROP TABLE IF EXISTS `application_suite`;

CREATE TABLE `application_suite` (
    `id` BIGINT NOT NULL COMMENT 													                    '主键标识',
    `application_id` BIGINT NOT NULL COMMENT 											                '应用标识',
    `master_application_id` BIGINT NOT NULL COMMENT                                                     '主应用标识',
    `create_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP COMMENT                                      '创建时间',
    `update_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT          '更新时间',
    `version` INT NOT NULL DEFAULT 0 COMMENT                                                            '记录版本',
    `delete_flag` TINYINT NOT NULL DEFAULT 0 COMMENT                                                    '删除标识[0:未删除, 1:已删除]',
    PRIMARY KEY (`id`),
    INDEX `uk_application_id` (`application_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT=                             '应用归类关系表';

-- =============================================
-- 22. 应用授权记录表 (application_authorization)
-- =============================================
DROP TABLE IF EXISTS `application_authorization`;

CREATE TABLE `application_authorization` (
    `id` BIGINT NOT NULL COMMENT 													                    '应用授权标识',
    `organ_id` BIGINT NOT NULL COMMENT 												                    '机构标识',
    `application_id` BIGINT NOT NULL COMMENT 													        '应用标识',
    `control_domain_id` BIGINT NOT NULL COMMENT                                                         '控制域标识',
    `subscription_id` BIGINT DEFAULT NULL COMMENT                                                       '订阅标识',
    `status` VARCHAR(32) NOT NULL DEFAULT 'ACTIVATED' COMMENT 											'应用授权状态[ACTIVATED:激活, DEACTIVATED:关停]',
    `create_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP COMMENT                                      '创建时间',
    `update_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT          '更新时间',
    `version` INT NOT NULL DEFAULT 0 COMMENT                                                            '记录版本',
    `delete_flag` TINYINT NOT NULL DEFAULT 0 COMMENT                                                    '删除标识[0:未删除, 1:已删除]',
    PRIMARY KEY (`id`),
    INDEX `idx_application_id` (`application_id`),
    INDEX `idx_control_domain_id` (`control_domain_id`),
    INDEX `idx_organ_st_del_app` (`organ_id`, `status`, `delete_flag`, `application_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT=                             '应用授权记录表';

-- =============================================
-- 23. 个人静态访问令牌表 (personal_static_access_token)
-- =============================================
DROP TABLE IF EXISTS `personal_static_access_token`;

CREATE TABLE `personal_static_access_token` (
    `id` BIGINT NOT NULL COMMENT 													                    '个人静态访问令牌标识',
    `application_authorization_id` BIGINT DEFAULT NULL COMMENT                                          '授权记录标识',
    `application_id` BIGINT NOT NULL COMMENT 													        '应用标识',
    `organ_id` BIGINT NOT NULL COMMENT 												                    '机构标识',
    `user_id` BIGINT DEFAULT NULL COMMENT 														        '用户标识',
    `name` VARCHAR(128) NOT NULL COMMENT 															    '访问令牌名称',
    `token_hash` VARCHAR(64) NOT NULL COLLATE utf8mb4_bin COMMENT 										'静态访问令牌的哈希摘要',
    `masked_token` VARCHAR(28) NOT NULL COMMENT 												        '脱敏令牌',
    `status` VARCHAR(32) NOT NULL DEFAULT 'ACTIVATED' COMMENT 										    '状态[ACTIVATED:已启用, REVOKED:已吊销]',
    `create_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP COMMENT                                      '创建时间',
    `update_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT          '更新时间',
    `version` INT NOT NULL DEFAULT 0 COMMENT                                                            '记录版本',
    `delete_flag` TINYINT NOT NULL DEFAULT 0 COMMENT                                                    '删除标识[0:未删除, 1:已删除]',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_token_hash` (`token_hash`),
    INDEX `idx_authorization_org_del` (`application_authorization_id`, `organ_id`, `delete_flag`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT=                             '个人静态访问令牌表';

-- =============================================
-- 24. 登录信息表 (login_token)
-- =============================================
DROP TABLE IF EXISTS `login_token`;

CREATE TABLE `login_token` (
    `id` BIGINT NOT NULL COMMENT 													                    '主键标识',
    `session_type` VARCHAR(32) DEFAULT NULL COMMENT 													'会话类型',
    `organ_id` BIGINT DEFAULT NULL COMMENT 														        '机构标识',
    `organ_type` VARCHAR(32) DEFAULT NULL COMMENT 													    '机构类型',
    `admin_company` TINYINT NOT NULL DEFAULT 0 COMMENT 											        '运营标记[0:否, 1:是]',
    `passport_id` BIGINT DEFAULT NULL COMMENT													        '账号标识',
    `user_id` BIGINT DEFAULT NULL COMMENT 														        '用户标识',
    `real_name` VARCHAR(128) DEFAULT NULL COMMENT 														'真实姓名',
    `admin_user` TINYINT NOT NULL DEFAULT 0 COMMENT 												    '管理员标记[0:否, 1:是]',
    `application_id` BIGINT DEFAULT NULL COMMENT 												        '应用标识',
    `application_organ_id` BIGINT DEFAULT NULL COMMENT 											        '应用组织标识',
    `client_id` VARCHAR(64) DEFAULT NULL COMMENT                                                        '客户端ID',
    `create_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP COMMENT                                      '创建时间',
    `update_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT          '更新时间',
    `version` INT NOT NULL DEFAULT 0 COMMENT                                                            '记录版本',
    `delete_flag` TINYINT NOT NULL DEFAULT 0 COMMENT                                                    '删除标识[0:未删除, 1:已删除]',
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=UTF8MB4 COLLATE=utf8mb4_0900_ai_ci COMMENT=								'登录信息表, 记录了当前登录状态的相关信息';

-- =============================================
-- 25. 审计事件表 (audit_event)
-- =============================================
DROP TABLE IF EXISTS `audit_event`;

CREATE TABLE `audit_event` (
    `id` BIGINT NOT NULL COMMENT 													                    '主键标识',
    `trace_id` VARCHAR(64) DEFAULT NULL COMMENT                                                         '网关跟踪标识',
    `client_id` VARCHAR(128) DEFAULT NULL COMMENT                                                       '客户端标识',
    `request_id` VARCHAR(64) DEFAULT NULL COMMENT                                                       '前端请求标识',
    `request_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP COMMENT                                     '前端请求时间',
    `accept_language` VARCHAR(32) DEFAULT NULL COMMENT                                                  '语言偏好',
    `path` VARCHAR(512) DEFAULT NULL COMMENT                                                            '请求路径',
    `method` VARCHAR(32) DEFAULT NULL COMMENT                                                           '请求方法',
    `user_agent` VARCHAR(512) DEFAULT NULL COMMENT                                                      '客户端标识',
    `host` VARCHAR(255) DEFAULT NULL COMMENT                                                            '请求主机',
    `x_forwarded_for` VARCHAR(1024) DEFAULT NULL COMMENT                                                '代理链IP列表',
    `x_real_ip` VARCHAR(64) DEFAULT NULL COMMENT                                                        '真实客户端IP',
    `referer` VARCHAR(2048) DEFAULT NULL COMMENT                                                        '请求来源URL',
    `session_type` VARCHAR(32) DEFAULT NULL COMMENT                                                     '会话类型',
    `passport_id` BIGINT DEFAULT NULL COMMENT                                                           '账号标识',
    `user_id` BIGINT DEFAULT NULL COMMENT                                                               '用户标识',
    `name` VARCHAR(128) DEFAULT NULL COMMENT                                                            '真实姓名',
    `admin_user` TINYINT DEFAULT 0 COMMENT                                                              '超级管理员',
    `organ_id` BIGINT DEFAULT NULL COMMENT                                                              '组织标识',
    `organ_name` VARCHAR(255) DEFAULT NULL COMMENT                                                      '组织名称',
    `organ_type` VARCHAR(32) DEFAULT NULL COMMENT                                                       '组织类型',
    `admin_company` TINYINT DEFAULT 0 COMMENT                                                           '平台运营组织',
    `application_id` BIGINT DEFAULT NULL COMMENT                                                        '请求来源应用标识',
    `application_code` VARCHAR(64) DEFAULT NULL COMMENT                                                 '请求来源应用编码',
    `application_organ_id` BIGINT DEFAULT NULL COMMENT                                                  '请求来源应用所属机构标识',
    `payload` JSON DEFAULT NULL COMMENT                                                                 '请求/响应摘要',
    `create_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP COMMENT                                      '创建时间',
    `update_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT          '更新时间',
    `version` INT NOT NULL DEFAULT 0 COMMENT                                                            '记录版本',
    PRIMARY KEY (`id`),
    INDEX `idx_trace_id` (`trace_id`),
    INDEX `idx_request_id` (`request_id`),
    INDEX `idx_client_id` (`client_id`),
    INDEX `idx_passport_id` (`passport_id`),
    INDEX `idx_user_id` (`user_id`),
    INDEX `idx_organ_id` (`organ_id`),
    INDEX `idx_application_id` (`application_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT=                             '审计事件表';

-- 账号
INSERT INTO `passport`
(`id`, `username`, `password`, `real_name`, `sex`, `birthday`, `id_no`, `mobile`, `email`, `status`, `create_time`, `update_time`)
VALUES
    (1, 'admin', 'PBKDF2WithHmacSHA256$65536$YSskABrEQZiuRcM3GMl6gQ==$Hl9gA9UnYmS1BoY3Ov3XY2qYQpUKF1Sl0QneYZ5zc7k=', '平台超管', 'MALE', NULL, NULL, NULL, NULL, 'NORMAL', '2026-02-01 09:12:28', '2026-02-01 09:12:28');

-- 机构
INSERT INTO `organ`
(`id`, `organ_name`, `organ_type`, `status`, `admin`, `create_time`, `update_time`)
VALUES
    (2, '平台机构', 'COMPANY', 'ACTIVE', 1, '2026-02-01 09:12:28', '2026-02-01 09:12:28');

-- 机构路径关系
INSERT INTO `organ_closure`
(`id`, `ancestor_id`, `descendant_id`, `descendant_type`, `relation_type`, `path_count`, `create_time`, `update_time`)
VALUES
    (3, 2, 2, 'COMPANY', 'SELF_ASSOCIATION', 1, '2026-02-01 09:12:28', '2026-02-01 09:12:28');

-- 角色
INSERT INTO `role`
(`id`, `organ_id`, `role_name`, `role_type`, `create_time`, `update_time`)
VALUES
    (4, 2, '超管角色', 'ADMIN', '2026-02-01 09:12:28', '2026-02-01 09:12:28');

-- 用户
INSERT INTO `user`
(`id`, `passport_id`, `organ_id`, `email`, `mobile`, `real_name`, `admin`, `create_time`, `update_time`)
VALUES
    (5, 1, 2, NULL, NULL, '平台管理员', 1, '2026-02-01 09:12:28', '2026-02-01 09:12:28');

-- 用户角色关联
INSERT INTO `user_role_relation`
(`id`, `user_id`, `role_id`, `create_time`, `update_time`)
VALUES
    (6, 5, 4, '2026-02-01 09:12:28', '2026-02-01 09:12:28');

-- 应用
INSERT INTO `application`
(`id`, `organ_id`, `application_name`, `application_code`, `can_integrate`, `landing`, `api_key_supported`, `application_type`, `public_key_algorithm`, `public_key_format`, `public_key`, `access_token_expires_in`, `refresh_token_expires_in`, `endpoint_url`, `context_path`, `status`, `description`, `create_time`, `update_time`)
VALUES
    (7, 2, '综合管理平台', 'g2rain-main-shell',  0, 1, 0, 'SUPPORT', 'EC', 'PEM', '-----BEGIN PUBLIC KEY----- MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEXmlg1y2fUD9KJj4WB6DrRZU+iVwA yzz60AxRoFb2yDnBvYiiK9JR1p5QUw2jkR9RPvkZez1Kx2BqxwyOoWRV/A== -----END PUBLIC KEY----- ', 3600, 86400, '//__PLATFORM_HOST__:__PLATFORM_PORT__', '/main/',    'PUBLISHED', '管理平台入口', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (8, 2, '基础支撑平台', 'g2rain-infra-app',  1, 1, 0, 'SUPPORT', 'EC', 'PEM', '-----BEGIN PUBLIC KEY----- MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEAcmLmXDroj3aJiTFxP6oy5Q+3Tawz1LFg0BY1a5CRNynqpVvG+/wVGUhXf7KOJ7/nA2OO/H+IQaHryS+SXtnOA== -----END PUBLIC KEY----- ', 3600, 86400, '//__PLATFORM_HOST__:__PLATFORM_PORT__', '/infra/',    'PUBLISHED', '字典、国际化与全局序列等公共能力前台', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (9, 2, '业务支撑平台', 'g2rain-manager-app',  1, 1, 0, 'SUPPORT', 'EC', 'PEM', '-----BEGIN PUBLIC KEY----- MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEXGDOn5B+GFE42lcMd5u47r6na9iE H1AzxAU49KiWBz17su0M1vPZ+s57bvMlYvbcPG2nfWcJvJzRuKUakrUhsA== -----END PUBLIC KEY----- ', 3600, 86400, '//__PLATFORM_HOST__:__PLATFORM_PORT__', '/manager/',    'PUBLISHED', '平台运营与租户自助管理前台', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (10, 2, '部门管理平台', 'g2rain-department-app', 1, 0, 0, 'SUPPORT', 'EC', 'PEM', '-----BEGIN PUBLIC KEY----- MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEtghefsDYicSn9s7OsNlwIoIlVTYZ DN9bBwnvKQUENpPuCXZj+qBb+kQBh5C5inokwbjzjbxP2vP360mhfovhag== -----END PUBLIC KEY----- ', 3600, 86400, '//__PLATFORM_HOST__:__PLATFORM_PORT__', '/department/', 'PUBLISHED', '部门组织与权限模型管理前台', '2026-02-01 09:12:28', '2026-02-01 09:12:28');

-- 应用归类关系
INSERT INTO `application_suite`
(`id`, `application_id`, `master_application_id`, `create_time`, `update_time`)
VALUES
    (11, 8, 7, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (12, 9, 7, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (13, 10, 7, '2026-02-01 09:12:28', '2026-02-01 09:12:28');

-- 控制单元
INSERT INTO `control_unit`
(`id`, `application_id`, `control_unit_name`, `control_unit_scope`, `landing`, `status`, `description`, `create_time`, `update_time`)
VALUES
    (14, 7, '盘古',   'PERPETUAL', 1, 'PUBLISHED', '平台准入基础能力', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (15, 8, '燧人氏', 'OPERATION', 1, 'PUBLISHED', '平台保障技术能力', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (16, 9, '女娲',   'OPERATION',  1, 'PUBLISHED', '核心运营支撑组件', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (17, 10, '颛顼',   'OPERATION',  0, 'PUBLISHED', '权限模型运营配置', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (18, 9, '有巢氏',   'CUSTOMER',  1, 'PUBLISHED', '租户空间构建逻辑', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (19, 10, '大禹',   'CUSTOMER',  0, 'PUBLISHED', '部门权限租户配置', '2026-02-01 09:12:28', '2026-02-01 09:12:28');

-- 角色控制单元关联
INSERT INTO `role_control_unit_relation`
(`id`, `role_id`, `control_unit_id`, `application_authorization_id`, `status`, `create_time`, `update_time`)
VALUES
    (20, 4, 15, NULL, 'ACTIVATED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (21, 4, 16, NULL, 'ACTIVATED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (22, 4, 17, NULL, 'ACTIVATED', '2026-02-01 09:12:28', '2026-02-01 09:12:28');

-- 控制域
INSERT INTO `control_domain`
(`id`, `application_id`, `control_domain_name`, `control_domain_type`, `control_domain_scope`, `description`, `create_time`, `update_time`)
VALUES
    (23, 10, '权限模型运营交付', 'APPLICATION', 'OPERATION', '面向平台运营的权限模型能力交付包，开通后同步权限模型运营配置等相关功能权限', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (24, 10, '部门管理平台交付', 'APPLICATION', 'CUSTOMER', '面向租户售卖的部门管理平台能力包，开通后同步部门权限租户配置等相关功能权限', '2026-02-01 09:12:28', '2026-02-01 09:12:28');

-- 控制域控制单元关联
INSERT INTO `control_domain_control_unit_relation`
(`id`, `control_domain_id`, `control_unit_id`, `create_time`, `update_time`)
VALUES
    (25, 23, 17, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (26, 24, 19, '2026-02-01 09:12:28', '2026-02-01 09:12:28');

-- 服务注册表
INSERT INTO `service_registry`
(`id`, `service_code`, `name`, `endpoint`, `route_prefix`, `description`, `create_time`, `update_time`)
VALUES
    (27, 'G2RAIN_INFRA', '基础支撑服务', 'lb://g2rain-infra', 'infra', '字典、国际化、地域语言与全局序列等基础支撑 API', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (28, 'G2RAIN_BASIS', '平台基础服务', 'lb://g2rain-basis', 'basis', '账号、机构、应用、角色、权限与控制域等平台基础能力 API', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (29, 'G2RAIN_DEPARTMENT', '部门管理服务', 'lb://g2rain-department', 'department', '部门组织与权限模型等领域 API', '2026-02-01 09:12:28', '2026-02-01 09:12:28');

-- 资源后端接口
INSERT INTO `resource_api`
(`id`, `service_code`, `api_tags`, `name`, `method`, `path`, `description`, `create_time`, `update_time`)
VALUES
    (30, 'G2RAIN_INFRA', '全局唯一序列', '新增或更新全局唯一 ID 记录', 'POST', '/g2rain_raindrop/save', '新增或更新全局唯一 ID 管理表数据', '2026-05-07 18:02:08', '2026-05-07 18:02:08'),
    (31, 'G2RAIN_INFRA', '全局唯一序列', '删除全局唯一 ID 记录', 'DELETE', '/g2rain_raindrop/{id}', '根据主键删除全局唯一 ID 管理记录', '2026-05-07 18:02:08', '2026-05-07 18:02:08'),
    (32, 'G2RAIN_INFRA', '全局唯一序列', '分页查询全局唯一 ID 记录列表', 'GET', '/g2rain_raindrop/page', '分页查询全局唯一 ID 管理记录列表', '2026-05-07 18:02:08', '2026-05-07 18:02:08'),
    (33, 'G2RAIN_INFRA', '全局唯一序列', '查询全局唯一 ID 记录列表', 'GET', '/g2rain_raindrop/list', '根据查询条件返回全局唯一 ID 管理记录列表', '2026-05-07 18:02:08', '2026-05-07 18:02:08'),
    (34, 'G2RAIN_INFRA', '全局唯一序列', '查询业务标签字典集合', 'GET', '/g2rain_raindrop/biz_tag_dict', '查询业务标签字典集合', '2026-05-07 18:02:08', '2026-05-07 18:02:08'),
    (35, 'G2RAIN_INFRA', '地域语言', '新增或更新地域语言设置', 'POST', '/locale_setting/save', '新增或更新地域与语言偏好配置', '2026-05-07 18:02:08', '2026-05-07 18:02:08'),
    (36, 'G2RAIN_INFRA', '地域语言', '删除地域语言设置记录', 'DELETE', '/locale_setting/{id}', '根据主键删除地域-语言设置记录', '2026-05-07 18:02:08', '2026-05-07 18:02:08'),
    (37, 'G2RAIN_INFRA', '地域语言', '分页查询地域语言设置列表', 'GET', '/locale_setting/page', '分页查询地域-语言设置列表', '2026-05-07 18:02:08', '2026-05-07 18:02:08'),
    (38, 'G2RAIN_INFRA', '地域语言', '获取地域语言字典', 'GET', '/locale_setting/locale_dict', '获取地域语言字典', '2026-05-07 18:02:08', '2026-05-07 18:02:08'),
    (39, 'G2RAIN_INFRA', '地域语言', '查询地域语言设置列表', 'GET', '/locale_setting/list', '根据查询条件返回地域-语言设置列表', '2026-05-07 18:02:08', '2026-05-07 18:02:08'),
    (40, 'G2RAIN_INFRA', '地域语言', '获取语言地域映射', 'GET', '/locale_setting/get_language_countries', '获取语言地域映射', '2026-05-07 18:02:08', '2026-05-07 18:02:08'),
    (41, 'G2RAIN_INFRA', '地域语言', '获取地域语言编码和名称映射集合', 'GET', '/locale_setting/code_name_map', '获取地域语言编码和名称映射集合', '2026-05-07 18:02:08', '2026-05-07 18:02:08'),
    (42, 'G2RAIN_INFRA', '字典用途', '新增或更新字典用途', 'POST', '/dictionary_usage/save', '新增或更新字典用途信息', '2026-05-07 18:02:08', '2026-05-07 18:02:08'),
    (43, 'G2RAIN_INFRA', '字典用途', '删除字典用途记录', 'DELETE', '/dictionary_usage/{id}', '根据主键删除字典用途记录', '2026-05-07 18:02:08', '2026-05-07 18:02:08'),
    (44, 'G2RAIN_INFRA', '字典用途', '分页查询字典用途列表', 'GET', '/dictionary_usage/page', '分页查询字典用途列表', '2026-05-07 18:02:08', '2026-05-07 18:02:08'),
    (45, 'G2RAIN_INFRA', '字典用途', '查询字典用途列表', 'GET', '/dictionary_usage/list', '根据查询条件返回字典用途列表', '2026-05-07 18:02:08', '2026-05-07 18:02:08'),
    (46, 'G2RAIN_INFRA', '字典明细', '新增或更新字典明细', 'POST', '/dictionary_item/save', '新增或更新字典明细信息', '2026-05-07 18:02:08', '2026-05-07 18:02:08'),
    (47, 'G2RAIN_INFRA', '字典明细', '删除字典明细记录', 'DELETE', '/dictionary_item/{id}', '根据主键删除字典明细记录', '2026-05-07 18:02:08', '2026-05-07 18:02:08'),
    (48, 'G2RAIN_INFRA', '字典明细', '分页查询字典明细列表', 'GET', '/dictionary_item/tree', '分页查询字典明细列表', '2026-05-07 18:02:08', '2026-05-07 18:02:08'),
    (49, 'G2RAIN_INFRA', '字典明细', '分页查询字典明细列表', 'GET', '/dictionary_item/page', '分页查询字典明细列表', '2026-05-07 18:02:08', '2026-05-07 18:02:08'),
    (50, 'G2RAIN_INFRA', '字典明细', '查询字典明细列表', 'GET', '/dictionary_item/list', '根据查询条件返回字典明细列表', '2026-05-07 18:02:08', '2026-05-07 18:02:08'),
    (51, 'G2RAIN_INFRA', '字典明细', '查询字典组件明细列表', 'GET', '/dictionary_item/localized_options', '查询字典组件明细列表', '2026-05-20 01:31:06', '2026-05-20 01:31:06'),
    (52, 'G2RAIN_INFRA', '国际化信息', '新增或更新国际化信息', 'POST', '/i18n_message/save', '新增或更新国际化文案信息', '2026-05-07 18:02:08', '2026-05-07 18:02:08'),
    (53, 'G2RAIN_INFRA', '国际化信息', '删除国际化信息记录', 'DELETE', '/i18n_message/{id}', '根据主键删除国际化信息记录', '2026-05-07 18:02:08', '2026-05-07 18:02:08'),
    (54, 'G2RAIN_INFRA', '国际化信息', '分页查询国际化信息列表', 'GET', '/i18n_message/page', '分页查询国际化信息列表', '2026-05-07 18:02:08', '2026-05-07 18:02:08'),
    (55, 'G2RAIN_INFRA', '国际化信息', '查询国际化信息列表', 'GET', '/i18n_message/list', '根据查询条件返回国际化信息列表', '2026-05-07 18:02:08', '2026-05-07 18:02:08'),
    (56, 'G2RAIN_INFRA', '国际化信息', '获取国际化用途集合', 'GET', '/i18n_message/i18n_message_usages', '获取国际化用途集合', '2026-05-07 18:02:08', '2026-05-07 18:02:08'),
    (57, 'G2RAIN_INFRA', '国际化信息', '查询业务标签字典集合', 'GET', '/i18n_message/tag_dict', '查询 i18n_message 表中已存在的去重业务标签，供页面选择', '2026-05-20 01:31:06', '2026-05-20 01:31:06'),
    (58, 'G2RAIN_INFRA', '国际化信息', '根据标签获取页面国际化元素', 'GET', '/i18n_message/locale', '根据标签获取页面国际化元素', '2026-05-22 11:04:01', '2026-05-22 11:04:01'),
    (59, 'G2RAIN_BASIS', '资源授权', '查询当前用户信息', 'GET', '/authority/user', '查询当前登录用户的权限相关用户信息', '2026-05-07 18:03:52', '2026-05-07 18:03:52'),
    (60, 'G2RAIN_BASIS', '资源授权', '查询资源权限信息', 'GET', '/authority/resources', '查询当前用户的资源访问权限信息', '2026-05-07 18:03:52', '2026-05-07 18:03:52'),
    (61, 'G2RAIN_BASIS', '资源授权', '查询菜单权限列表', 'GET', '/authority/menus', '查询当前用户可访问的菜单权限列表', '2026-05-07 18:03:52', '2026-05-07 18:03:52'),
    (62, 'G2RAIN_BASIS', '用户', '新增或更新用户信息', 'POST', '/user/save', '新增或更新用户基础信息', '2026-05-07 18:03:52', '2026-05-07 18:03:52'),
    (63, 'G2RAIN_BASIS', '用户', '删除用户记录', 'DELETE', '/user/{id}', '根据主键删除用户记录', '2026-05-07 18:03:52', '2026-05-07 18:03:52'),
    (64, 'G2RAIN_BASIS', '用户', '获取用户下拉选项', 'GET', '/user/user_options', '返回用于下拉选择的用户简要信息集合', '2026-05-07 18:03:52', '2026-05-07 18:03:52'),
    (65, 'G2RAIN_BASIS', '用户', '按角色查询用户列表', 'GET', '/user/role/{roleId}', '根据角色主键查询已关联用户列表', '2026-05-07 18:03:52', '2026-05-07 18:03:52'),
    (66, 'G2RAIN_BASIS', '用户', '分页查询用户列表', 'GET', '/user/page', '分页查询用户列表', '2026-05-07 18:03:52', '2026-05-07 18:03:52'),
    (67, 'G2RAIN_BASIS', '用户', '查询用户列表', 'GET', '/user/list', '根据查询条件返回用户列表', '2026-05-07 18:03:52', '2026-05-07 18:03:52'),
    (68, 'G2RAIN_BASIS', '机构', '新增或更新机构信息', 'POST', '/organ/save', '新增或更新机构基础信息', '2026-05-07 18:03:52', '2026-05-07 18:03:52'),
    (69, 'G2RAIN_BASIS', '机构', '删除机构记录', 'DELETE', '/organ/{id}', '根据主键删除机构记录', '2026-05-07 18:03:52', '2026-05-07 18:03:52'),
    (70, 'G2RAIN_BASIS', '机构', '更新机构状态', 'POST', '/organ/{id}/status', '根据主键更新机构启用状态', '2026-05-07 18:03:52', '2026-05-07 18:03:52'),
    (71, 'G2RAIN_BASIS', '机构', '调整机构层级关系', 'POST', '/organ/{descendantId}/hierarchy', '对指定机构执行挂载、迁移或卸载等层级调整操作', '2026-05-07 18:03:52', '2026-05-07 18:03:52'),
    (72, 'G2RAIN_BASIS', '机构', '搜索机构', 'GET', '/organ/search', '根据机构名称关键字模糊查询机构列表', '2026-05-07 18:03:52', '2026-05-07 18:03:52'),
    (73, 'G2RAIN_BASIS', '机构', '分页查询机构列表', 'GET', '/organ/page', '分页查询机构列表', '2026-05-07 18:03:52', '2026-05-07 18:03:52'),
    (74, 'G2RAIN_BASIS', '机构', '查询机构列表', 'GET', '/organ/list', '根据查询条件返回机构列表', '2026-05-07 18:03:52', '2026-05-07 18:03:52'),
    (75, 'G2RAIN_BASIS', '机构', '获取机构层级关系', 'GET', '/organ/hierarchy', '查询机构及其子机构的树形层级结构', '2026-05-07 18:03:52', '2026-05-07 18:03:52'),
    (76, 'G2RAIN_BASIS', '应用授权', '新增或更新应用授权记录', 'POST', '/application_authorization/save', '新增或更新应用授权记录', '2026-05-07 18:03:52', '2026-05-07 18:03:52'),
    (77, 'G2RAIN_BASIS', '应用授权', '根据主键删除应用授权记录', 'DELETE', '/application_authorization/{id}', '根据主键删除应用授权记录', '2026-05-07 18:03:52', '2026-05-07 18:03:52'),
    (78, 'G2RAIN_BASIS', '应用授权', '修改应用授权记录状态', 'POST', '/application_authorization/{id}/status', '修改应用授权记录状态', '2026-05-07 18:03:52', '2026-05-07 18:03:52'),
    (79, 'G2RAIN_BASIS', '应用授权', '分页查询应用授权记录列表', 'GET', '/application_authorization/page', '分页查询应用授权记录列表', '2026-05-07 18:03:52', '2026-05-07 18:03:52'),
    (80, 'G2RAIN_BASIS', '应用授权', '查询应用授权记录列表', 'GET', '/application_authorization/list', '根据查询条件返回应用授权记录列表', '2026-05-07 18:03:52', '2026-05-07 18:03:52'),
    (81, 'G2RAIN_BASIS', '账号', '新增或更新账号', 'POST', '/passport/save', '新增或更新账号信息', '2026-05-07 18:03:52', '2026-05-07 18:03:52'),
    (82, 'G2RAIN_BASIS', '账号', '删除账号记录', 'DELETE', '/passport/{id}', '根据主键删除账号记录', '2026-05-07 18:03:52', '2026-05-07 18:03:52'),
    (83, 'G2RAIN_BASIS', '账号', '更新账号状态', 'POST', '/passport/{id}/status', '根据主键更新账号启用状态', '2026-05-07 18:03:52', '2026-05-07 18:03:52'),
    (84, 'G2RAIN_BASIS', '账号', '更新账号密码', 'POST', '/passport/{id}/password', '根据主键更新账号登录密码', '2026-05-07 18:03:52', '2026-05-07 18:03:52'),
    (85, 'G2RAIN_BASIS', '账号', '分页查询账号列表', 'GET', '/passport/page', '分页查询账号列表', '2026-05-07 18:03:52', '2026-05-07 18:03:52'),
    (86, 'G2RAIN_BASIS', '账号', '查询账号列表', 'GET', '/passport/list', '根据查询条件返回账号列表', '2026-05-07 18:03:52', '2026-05-07 18:03:52'),
    (87, 'G2RAIN_BASIS', '账号与外部身份源绑定', '新增或更新绑定', 'POST', '/passport_idp_binding/save', '新增或更新账号与外部身份源绑定信息', '2026-05-20 01:31:01', '2026-05-20 01:31:01'),
    (88, 'G2RAIN_BASIS', '账号与外部身份源绑定', '绑定外部身份源', 'POST', '/passport_idp_binding/bind', '已登录用户扫码绑定钉钉；USER 会话且机构管理员可自动建立 idp_enterprise_organ，普通用户须已有企业-机构绑定；校验主体冲突', '2026-05-28 15:14:25', '2026-05-28 15:14:25'),
    (89, 'G2RAIN_BASIS', '账号与外部身份源绑定', '删除绑定记录', 'DELETE', '/passport_idp_binding/{id}', '根据主键删除账号与外部身份源绑定记录', '2026-05-20 01:31:01', '2026-05-20 01:31:01'),
    (90, 'G2RAIN_BASIS', '账号与外部身份源绑定', '分页查询账号与外部身份源绑定列表', 'GET', '/passport_idp_binding/page', '分页查询绑定列表', '2026-05-20 01:31:01', '2026-05-20 01:31:01'),
    (91, 'G2RAIN_BASIS', '账号与外部身份源绑定', '查询账号与外部身份源绑定列表', 'GET', '/passport_idp_binding/list', '根据查询条件返回绑定列表', '2026-05-20 01:31:01', '2026-05-20 01:31:01'),
    (92, 'G2RAIN_BASIS', '机构邀请码', '生成机构邀请码', 'POST', '/organ/invite/generate', '为指定机构生成带有效期的邀请码，并绑定加入后分配的角色。同一机构重新生成时，此前未使用的邀请码立即失效。需机构管理员或平台运营权限。', '2026-05-29 01:10:29', '2026-05-29 01:10:29'),
    (93, 'G2RAIN_BASIS', '服务注册', '新增或更新服务注册', 'POST', '/service_registry/save', '新增或更新服务注册信息', '2026-05-07 18:03:52', '2026-05-07 18:03:52'),
    (94, 'G2RAIN_BASIS', '服务注册', '删除服务注册', 'DELETE', '/service_registry/{id}', '根据主键删除服务注册记录', '2026-05-07 18:03:52', '2026-05-07 18:03:52'),
    (95, 'G2RAIN_BASIS', '服务注册', '分页查询服务注册列表', 'GET', '/service_registry/page', '分页查询服务注册列表', '2026-05-07 18:03:52', '2026-05-07 18:03:52'),
    (96, 'G2RAIN_BASIS', '服务注册', '查询服务注册列表', 'GET', '/service_registry/list', '根据查询条件返回服务注册列表', '2026-05-07 18:03:52', '2026-05-07 18:03:52'),
    (97, 'G2RAIN_BASIS', '资源接口', '批量导入资源接口', 'POST', '/resource_api/{serviceCode}/import', '批量导入资源接口信息', '2026-04-27 10:14:24', '2026-04-27 10:14:24'),
    (98, 'G2RAIN_BASIS', '资源接口', '新增或更新资源接口', 'POST', '/resource_api/save', '新增或更新资源接口信息', '2026-04-27 10:14:24', '2026-04-27 10:14:24'),
    (99, 'G2RAIN_BASIS', '资源接口', '根据主键删除资源接口记录', 'DELETE', '/resource_api/{id}', '根据主键删除资源接口记录', '2026-05-07 18:03:52', '2026-05-07 18:03:52'),
    (100, 'G2RAIN_BASIS', '资源接口', '分页查询资源接口列表', 'GET', '/resource_api/page', '分页查询资源接口列表', '2026-05-07 18:03:52', '2026-05-07 18:03:52'),
    (101, 'G2RAIN_BASIS', '资源接口', '查询资源接口列表', 'GET', '/resource_api/list', '根据查询条件返回资源接口列表', '2026-05-07 18:03:52', '2026-05-07 18:03:52'),
    (102, 'G2RAIN_BASIS', '资源上传', '上传应用资源文件', 'POST', '/resource/{applicationId}/upload', '上传并解析指定应用的资源文件内容', '2026-05-07 18:03:52', '2026-05-07 18:03:52'),
    (103, 'G2RAIN_BASIS', '资源菜单', '新增或更新资源菜单', 'POST', '/resource_menu/save', '新增或更新应用资源菜单信息', '2026-05-07 18:03:52', '2026-05-07 18:03:52'),
    (104, 'G2RAIN_BASIS', '资源菜单', '删除资源菜单记录', 'DELETE', '/resource_menu/{id}', '根据主键删除应用资源菜单记录', '2026-05-07 18:03:52', '2026-05-07 18:03:52'),
    (105, 'G2RAIN_BASIS', '资源菜单', '分页查询资源菜单列表', 'GET', '/resource_menu/page', '分页查询资源菜单列表', '2026-05-07 18:03:52', '2026-05-07 18:03:52'),
    (106, 'G2RAIN_BASIS', '资源菜单', '查询资源菜单列表', 'GET', '/resource_menu/list', '根据查询条件返回资源菜单列表', '2026-05-07 18:03:52', '2026-05-07 18:03:52'),
    (107, 'G2RAIN_BASIS', '资源页面', '新增或更新资源页面', 'POST', '/resource_page/save', '新增或更新应用资源页面信息', '2026-05-07 18:03:52', '2026-05-07 18:03:52'),
    (108, 'G2RAIN_BASIS', '资源页面', '删除资源页面记录', 'DELETE', '/resource_page/{id}', '根据主键删除应用资源页面记录', '2026-05-07 18:03:52', '2026-05-07 18:03:52'),
    (109, 'G2RAIN_BASIS', '资源页面', '分页查询资源页面列表', 'GET', '/resource_page/page', '分页查询资源页面列表', '2026-05-07 18:03:52', '2026-05-07 18:03:52'),
    (110, 'G2RAIN_BASIS', '资源页面', '查询资源页面列表', 'GET', '/resource_page/list', '根据查询条件返回资源页面列表', '2026-05-07 18:03:52', '2026-05-07 18:03:52'),
    (111, 'G2RAIN_BASIS', '资源页面元素', '新增或更新页面元素', 'POST', '/resource_page_element/save', '新增或更新应用资源页面元素信息', '2026-05-07 18:03:52', '2026-05-07 18:03:52'),
    (112, 'G2RAIN_BASIS', '资源页面元素', '删除页面元素记录', 'DELETE', '/resource_page_element/{id}', '根据主键删除应用资源页面元素记录', '2026-05-07 18:03:52', '2026-05-07 18:03:52'),
    (113, 'G2RAIN_BASIS', '资源页面元素', '分页查询资源页面元素列表', 'GET', '/resource_page_element/page', '分页查询资源页面元素列表', '2026-05-07 18:03:52', '2026-05-07 18:03:52'),
    (114, 'G2RAIN_BASIS', '资源页面元素', '查询资源页面元素列表', 'GET', '/resource_page_element/list', '根据查询条件返回资源页面元素列表', '2026-05-07 18:03:52', '2026-05-07 18:03:52'),
    (115, 'G2RAIN_BASIS', '控制单元', '新增或更新控制单元', 'POST', '/control_unit/save', '新增或更新控制单元基础信息', '2026-05-07 18:03:52', '2026-05-07 18:03:52'),
    (116, 'G2RAIN_BASIS', '控制单元', '删除控制单元记录', 'DELETE', '/control_unit/{id}', '根据主键删除控制单元记录', '2026-05-07 18:03:52', '2026-05-07 18:03:52'),
    (117, 'G2RAIN_BASIS', '控制单元', '更新控制单元状态', 'POST', '/control_unit/{id}/status', '根据主键更新控制单元启用状态', '2026-05-07 18:03:52', '2026-05-07 18:03:52'),
    (118, 'G2RAIN_BASIS', '控制单元', '分页查询控制单元列表', 'GET', '/control_unit/page', '分页查询控制单元列表', '2026-05-07 18:03:52', '2026-05-07 18:03:52'),
    (119, 'G2RAIN_BASIS', '控制单元', '查询控制单元列表', 'GET', '/control_unit/list', '根据查询条件返回控制单元列表', '2026-05-07 18:03:52', '2026-05-07 18:03:52'),
    (120, 'G2RAIN_BASIS', '权限点资源关联', '新增控制单元资源关联', 'POST', '/control_unit_resource_relation/save', '批量新增控制单元与资源关联记录', '2026-05-07 18:03:52', '2026-05-07 18:03:52'),
    (121, 'G2RAIN_BASIS', '权限点资源关联', '分页查询权限点资源关联列表', 'GET', '/control_unit_resource_relation/page', '分页查询权限点资源关联列表', '2026-05-07 18:03:52', '2026-05-07 18:03:52'),
    (122, 'G2RAIN_BASIS', '权限点资源关联', '查询权限点资源关联列表', 'GET', '/control_unit_resource_relation/list', '根据查询条件返回权限点资源关联列表', '2026-05-07 18:03:52', '2026-05-07 18:03:52'),
    (123, 'G2RAIN_BASIS', '角色', '新增或更新角色信息', 'POST', '/role/save', '新增或更新角色基础信息', '2026-05-07 18:03:52', '2026-05-07 18:03:52'),
    (124, 'G2RAIN_BASIS', '角色', '删除角色记录', 'DELETE', '/role/{id}', '根据主键删除角色记录', '2026-05-07 18:03:52', '2026-05-07 18:03:52'),
    (125, 'G2RAIN_BASIS', '角色', '分页查询角色列表', 'GET', '/role/page', '分页查询角色列表', '2026-05-07 18:03:52', '2026-05-07 18:03:52'),
    (126, 'G2RAIN_BASIS', '角色', '查询角色列表', 'GET', '/role/list', '根据查询条件返回角色列表', '2026-05-07 18:03:52', '2026-05-07 18:03:52'),
    (127, 'G2RAIN_BASIS', '用户-角色关联', '新增或更新用户角色关联', 'POST', '/user_role_relation/save', '新增或更新用户角色关联记录', '2026-05-07 18:03:52', '2026-05-07 18:03:52'),
    (128, 'G2RAIN_BASIS', '用户-角色关联', '为角色分配用户', 'POST', '/user_role_relation/assign_users', '批量为指定角色分配用户关联关系', '2026-05-07 18:03:52', '2026-05-07 18:03:52'),
    (129, 'G2RAIN_BASIS', '用户-角色关联', '分页查询用户-角色关联列表', 'GET', '/user_role_relation/page', '分页查询用户角色关联列表', '2026-05-07 18:03:52', '2026-05-07 18:03:52'),
    (130, 'G2RAIN_BASIS', '用户-角色关联', '查询用户-角色关联列表', 'GET', '/user_role_relation/list', '根据查询条件返回用户角色关联列表', '2026-05-07 18:03:52', '2026-05-07 18:03:52'),
    (131, 'G2RAIN_BASIS', '控制域', '新增或更新控制域信息', 'POST', '/control_domain/save', '新增或更新控制域基础信息', '2026-05-07 18:03:52', '2026-05-07 18:03:52'),
    (132, 'G2RAIN_BASIS', '控制域', '删除控制域记录', 'DELETE', '/control_domain/{id}', '根据主键删除控制域记录', '2026-05-07 18:03:52', '2026-05-07 18:03:52'),
    (133, 'G2RAIN_BASIS', '控制域', '分页查询控制域列表', 'GET', '/control_domain/page', '分页查询控制域列表', '2026-05-07 18:03:52', '2026-05-07 18:03:52'),
    (134, 'G2RAIN_BASIS', '控制域', '查询控制域列表', 'GET', '/control_domain/list', '根据查询条件返回控制域列表', '2026-05-07 18:03:52', '2026-05-07 18:03:52'),
    (135, 'G2RAIN_BASIS', '控制域-控制单元关联', '新增控制域控制单元关联', 'POST', '/control_domain_control_unit_relation/save', '批量新增控制域与控制单元关联记录', '2026-05-07 18:03:52', '2026-05-07 18:03:52'),
    (136, 'G2RAIN_BASIS', '控制域-控制单元关联', '分页查询控制域-控制单元关联列表', 'GET', '/control_domain_control_unit_relation/page', '分页查询控制域控制单元关联列表', '2026-05-07 18:03:52', '2026-05-07 18:03:52'),
    (137, 'G2RAIN_BASIS', '控制域-控制单元关联', '查询控制域-控制单元关联列表', 'GET', '/control_domain_control_unit_relation/list', '根据查询条件返回控制域控制单元关联列表', '2026-05-07 18:03:52', '2026-05-07 18:03:52'),
    (138, 'G2RAIN_BASIS', '应用', '新增或更新应用信息', 'POST', '/application/save', '新增或更新应用基础信息', '2026-05-07 18:03:52', '2026-05-07 18:03:52'),
    (139, 'G2RAIN_BASIS', '应用', '删除应用记录', 'DELETE', '/application/{id}', '根据主键删除应用记录', '2026-05-07 18:03:52', '2026-05-07 18:03:52'),
    (140, 'G2RAIN_BASIS', '应用', '更新应用状态', 'POST', '/application/{id}/status', '根据主键更新应用启用状态', '2026-05-07 18:03:52', '2026-05-07 18:03:52'),
    (141, 'G2RAIN_BASIS', '应用', '上传或更新应用公钥', 'POST', '/application/{id}/public_key', '上传 PEM/DER 公钥文件并更新应用公钥配置', '2026-05-07 18:03:52', '2026-05-07 18:03:52'),
    (142, 'G2RAIN_BASIS', '应用', '下载应用公钥', 'GET', '/application/{id}/public_key', '下载指定应用的 PEM 或 DER 格式公钥文件', '2026-05-07 18:03:52', '2026-05-07 18:03:52'),
    (143, 'G2RAIN_BASIS', '应用', '检查应用公钥是否存在', 'GET', '/application/{id}/has_public_key', '检查指定应用是否已配置公钥', '2026-05-07 18:03:52', '2026-05-07 18:03:52'),
    (144, 'G2RAIN_BASIS', '应用', '分页查询应用列表', 'GET', '/application/page', '分页查询应用列表', '2026-05-07 18:03:52', '2026-05-07 18:03:52'),
    (145, 'G2RAIN_BASIS', '应用', '查询应用列表', 'GET', '/application/list', '根据查询条件返回应用列表', '2026-05-07 18:03:52', '2026-05-07 18:03:52'),
    (146, 'G2RAIN_BASIS', '应用', '查询应用名称映射', 'GET', '/application/id_name_map', '根据查询条件获取应用 ID 与名称映射列表', '2026-05-07 18:03:52', '2026-05-07 18:03:52'),
    (147, 'G2RAIN_BASIS', '应用归类关系', '新增或更新应用归类关系', 'POST', '/application_suite/save', '新增或更新应用与归类的关联关系', '2026-05-07 18:03:52', '2026-05-07 18:03:52'),
    (148, 'G2RAIN_BASIS', '应用归类关系', '分页查询应用归类关系列表', 'GET', '/application_suite/page', '分页查询应用归类关系列表', '2026-05-07 18:03:52', '2026-05-07 18:03:52'),
    (149, 'G2RAIN_BASIS', '应用归类关系', '查询应用归类关系列表', 'GET', '/application_suite/list', '根据查询条件返回应用归类关系列表', '2026-05-07 18:03:52', '2026-05-07 18:03:52'),
    (150, 'G2RAIN_BASIS', '个人静态访问令牌', '新增或更新个人静态访问令牌信息', 'POST', '/personal_static_access_token/save', '新增或更新个人静态访问令牌基础信息', '2026-05-20 01:31:01', '2026-05-20 01:31:01'),
    (151, 'G2RAIN_BASIS', '个人静态访问令牌', '删除个人静态访问令牌记录', 'DELETE', '/personal_static_access_token/{id}', '根据主键删除个人静态访问令牌记录', '2026-05-20 01:31:01', '2026-05-20 01:31:01'),
    (152, 'G2RAIN_BASIS', '个人静态访问令牌', '修改个人静态访问令牌记录状态', 'POST', '/personal_static_access_token/{id}/status', '修改个人静态访问令牌记录状态', '2026-05-20 01:31:01', '2026-05-20 01:31:01'),
    (153, 'G2RAIN_BASIS', '个人静态访问令牌', '分页查询个人静态访问令牌列表', 'GET', '/personal_static_access_token/page', '分页查询个人静态访问令牌列表', '2026-05-20 01:31:01', '2026-05-20 01:31:01'),
    (154, 'G2RAIN_BASIS', '个人静态访问令牌', '查询个人静态访问令牌列表', 'GET', '/personal_static_access_token/list', '根据查询条件返回个人静态访问令牌列表', '2026-05-20 01:31:01', '2026-05-20 01:31:01'),
    (155, 'G2RAIN_BASIS', '外部企业与机构关联', '新增或更新关联', 'POST', '/idp_enterprise_organ/save', '新增或更新外部企业/租户与平台机构关联信息', '2026-05-20 01:31:01', '2026-05-20 01:31:01'),
    (156, 'G2RAIN_BASIS', '外部企业与机构关联', '删除关联记录', 'DELETE', '/idp_enterprise_organ/{id}', '根据主键删除外部企业与机构关联记录', '2026-05-20 01:31:01', '2026-05-20 01:31:01'),
    (157, 'G2RAIN_BASIS', '外部企业与机构关联', '分页查询外部企业与机构关联列表', 'GET', '/idp_enterprise_organ/page', '分页查询关联列表', '2026-05-20 01:31:01', '2026-05-20 01:31:01'),
    (158, 'G2RAIN_BASIS', '外部企业与机构关联', '查询外部企业与机构关联列表', 'GET', '/idp_enterprise_organ/list', '根据查询条件返回关联列表', '2026-05-20 01:31:01', '2026-05-20 01:31:01'),
    (159, 'G2RAIN_BASIS', '外部身份源应用与平台应用的绑定', '新增或更绑定', 'POST', '/application_idp_provision/save', '新增或更绑定', '2026-05-20 01:31:01', '2026-05-20 01:31:01'),
    (160, 'G2RAIN_BASIS', '外部身份源应用与平台应用的绑定', '删除绑定记录', 'DELETE', '/application_idp_provision/{id}', '删除绑定记录', '2026-05-20 01:31:01', '2026-05-20 01:31:01'),
    (161, 'G2RAIN_BASIS', '外部身份源应用与平台应用的绑定', '查询绑定分页', 'GET', '/application_idp_provision/page', '查询绑定分页', '2026-05-20 01:31:01', '2026-05-20 01:31:01'),
    (162, 'G2RAIN_BASIS', '外部身份源应用与平台应用的绑定', '查询绑定列表', 'GET', '/application_idp_provision/list', '查询绑定列表', '2026-05-20 01:31:01', '2026-05-20 01:31:01'),
    (163, 'G2RAIN_BASIS', '审计事件', '分页查询审计事件', 'GET', '/audit_event/page', '按条件筛选审计事件并分页，含总数与当前页数据', '2026-05-07 18:03:52', '2026-05-07 18:03:52'),
    (164, 'G2RAIN_BASIS', '审计事件', '查询审计事件列表', 'GET', '/audit_event/list', '按条件筛选审计事件，不分页返回列表', '2026-05-07 18:03:52', '2026-05-07 18:03:52'),
    (165, 'G2RAIN_BASIS', '登录令牌', '分页查询登录令牌列表', 'GET', '/login_token/page', '分页查询登录令牌列表', '2026-05-07 18:03:52', '2026-05-07 18:03:52'),
    (166, 'G2RAIN_BASIS', '登录令牌', '查询登录令牌列表', 'GET', '/login_token/list', '根据查询条件返回登录令牌列表', '2026-05-07 18:03:52', '2026-05-07 18:03:52'),
    (167, 'G2RAIN_BASIS', '角色-控制单元关联', '新增角色控制单元关联', 'POST', '/role_control_unit_relation/save', '新增角色与控制单元的关联记录', '2026-05-07 18:03:52', '2026-05-07 18:03:52'),
    (168, 'G2RAIN_BASIS', '角色-控制单元关联', '按角色查询控制单元关联', 'GET', '/role_control_unit_relation/role/{roleId}', '根据角色主键查询角色控制单元关联列表', '2026-05-07 18:03:52', '2026-05-07 18:03:52'),
    (169, 'G2RAIN_BASIS', '角色-控制单元关联', '分页查询角色-控制单元关联列表', 'GET', '/role_control_unit_relation/page', '分页查询角色控制单元关联列表', '2026-05-07 18:03:52', '2026-05-07 18:03:52'),
    (170, 'G2RAIN_BASIS', '角色-控制单元关联', '查询角色-控制单元关联列表', 'GET', '/role_control_unit_relation/list', '根据查询条件返回角色控制单元关联列表', '2026-05-07 18:03:52', '2026-05-07 18:03:52'),
    (171, 'G2RAIN_BASIS', '通行证租户入驻,租户初始化', '开通租户账号', 'POST', '/tenant_provision/provision_account', '为指定租户开通账号并初始化最小可用功能', '2026-05-07 18:03:52', '2026-05-29 01:10:29'),
    (172, 'G2RAIN_BASIS', '通行证租户入驻,租户初始化', '加入机构', 'POST', '/tenant_provision/join_organ', '已登录通行证提交机构邀请码，在目标机构下创建用户并绑定邀请码指定的角色。若当前通行证已在该机构存在用户，则幂等返回已有用户且不消耗邀请码。邀请码存储于 Redis，过期或使用后失效。', '2026-05-29 01:10:29', '2026-05-29 01:10:29'),
    (173, 'G2RAIN_DEPARTMENT', '数据权限模型全局元数据表', '新增或更新数据权限模型全局元数据表信息', 'POST', '/data_permission_model/save', '新增或更新数据权限模型全局元数据表基础信息', '2026-06-03 02:28:25', '2026-06-03 02:28:25'),
    (174, 'G2RAIN_DEPARTMENT', '数据权限模型全局元数据表', '删除数据权限模型全局元数据表记录', 'DELETE', '/data_permission_model/{id}', '根据主键删除数据权限模型全局元数据表记录', '2026-06-03 02:28:25', '2026-06-03 02:28:25'),
    (175, 'G2RAIN_DEPARTMENT', '数据权限模型全局元数据表', '分页查询数据权限模型全局元数据表列表', 'GET', '/data_permission_model/page', '分页查询数据权限模型全局元数据表列表', '2026-06-03 02:28:25', '2026-06-03 02:28:25'),
    (176, 'G2RAIN_DEPARTMENT', '数据权限模型全局元数据表', '查询数据权限模型全局元数据表列表', 'GET', '/data_permission_model/list', '根据查询条件返回数据权限模型全局元数据表列表', '2026-06-03 02:28:25', '2026-06-03 02:28:25'),
    (177, 'G2RAIN_DEPARTMENT', '数据权限模型字段明细表', '新增或更新数据权限模型字段明细表信息', 'POST', '/data_permission_field/save', '新增或更新数据权限模型字段明细表基础信息', '2026-06-03 02:28:25', '2026-06-03 02:28:25'),
    (178, 'G2RAIN_DEPARTMENT', '数据权限模型字段明细表', '删除数据权限模型字段明细表记录', 'DELETE', '/data_permission_field/{id}', '根据主键删除数据权限模型字段明细表记录', '2026-06-03 02:28:25', '2026-06-03 02:28:25'),
    (179, 'G2RAIN_DEPARTMENT', '数据权限模型字段明细表', '分页查询数据权限模型字段明细表列表', 'GET', '/data_permission_field/page', '分页查询数据权限模型字段明细表列表', '2026-06-03 02:28:25', '2026-06-03 02:28:25'),
    (180, 'G2RAIN_DEPARTMENT', '数据权限模型字段明细表', '查询数据权限模型字段明细表列表', 'GET', '/data_permission_field/list', '根据查询条件返回数据权限模型字段明细表列表', '2026-06-03 02:28:25', '2026-06-03 02:28:25'),
    (181, 'G2RAIN_DEPARTMENT', '部门表', '新增或更新部门表信息', 'POST', '/department/save', '新增或更新部门表基础信息', '2026-06-03 02:28:25', '2026-06-03 02:28:25'),
    (182, 'G2RAIN_DEPARTMENT', '部门表', '删除部门表记录', 'DELETE', '/department/{id}', '根据主键删除部门表记录', '2026-06-03 02:28:25', '2026-06-03 02:28:25'),
    (183, 'G2RAIN_DEPARTMENT', '部门表', '修改部门状态', 'POST', '/department/{id}/status', '修改部门状态', '2026-06-03 02:28:25', '2026-06-03 02:28:25'),
    (184, 'G2RAIN_DEPARTMENT', '部门表', '查询部门树形结构', 'GET', '/department/tree', '根据查询条件返回有层级关系的部门树', '2026-06-05 02:28:46', '2026-06-05 02:28:46'),
    (185, 'G2RAIN_DEPARTMENT', '部门表', '分页查询部门表列表', 'GET', '/department/page', '分页查询部门表列表', '2026-06-03 02:28:25', '2026-06-03 02:28:25'),
    (186, 'G2RAIN_DEPARTMENT', '部门表', '查询部门表列表', 'GET', '/department/list', '根据查询条件返回部门表列表', '2026-06-03 02:28:25', '2026-06-03 02:28:25'),
    (187, 'G2RAIN_DEPARTMENT', '部门人员关系表', '新增或更新部门人员关系表信息', 'POST', '/department_user_relation/save', '新增或更新部门人员关系表基础信息', '2026-06-03 02:28:25', '2026-06-03 02:28:25'),
    (188, 'G2RAIN_DEPARTMENT', '部门人员关系表', '批量添加部门用户', 'POST', '/department_user_relation/add_users', '批量添加部门用户关联，已存在的用户自动忽略', '2026-06-03 02:28:25', '2026-06-03 02:28:25'),
    (189, 'G2RAIN_DEPARTMENT', '部门人员关系表', '删除部门人员关系表记录', 'DELETE', '/department_user_relation/{id}', '根据主键删除部门人员关系表记录', '2026-06-03 02:28:25', '2026-06-03 02:28:25'),
    (190, 'G2RAIN_DEPARTMENT', '部门人员关系表', '分页查询部门人员关系表列表', 'GET', '/department_user_relation/page', '分页查询部门人员关系表列表', '2026-06-03 02:28:25', '2026-06-03 02:28:25'),
    (191, 'G2RAIN_DEPARTMENT', '部门人员关系表', '查询部门人员关系表列表', 'GET', '/department_user_relation/list', '根据查询条件返回部门人员关系表列表', '2026-06-03 02:28:25', '2026-06-03 02:28:25'),
    (192, 'G2RAIN_DEPARTMENT', '数据权限元数据表', '新增或更新数据权限元数据表信息', 'POST', '/data_permission_meta/save', '新增或更新数据权限元数据表基础信息', '2026-06-03 02:28:25', '2026-06-03 02:28:25'),
    (193, 'G2RAIN_DEPARTMENT', '数据权限元数据表', '删除数据权限元数据表记录', 'DELETE', '/data_permission_meta/{id}', '根据主键删除数据权限元数据表记录', '2026-06-03 02:28:25', '2026-06-03 02:28:25'),
    (194, 'G2RAIN_DEPARTMENT', '数据权限元数据表', '修改权限策略状态', 'POST', '/data_permission_meta/{id}/status', '修改权限策略状态', '2026-06-03 02:28:25', '2026-06-03 02:28:25'),
    (195, 'G2RAIN_DEPARTMENT', '数据权限元数据表', '分页查询数据权限元数据表列表', 'GET', '/data_permission_meta/page', '分页查询数据权限元数据表列表', '2026-06-03 02:28:25', '2026-06-03 02:28:25'),
    (196, 'G2RAIN_DEPARTMENT', '数据权限元数据表', '查询数据权限元数据表列表', 'GET', '/data_permission_meta/list', '根据查询条件返回数据权限元数据表列表', '2026-06-03 02:28:25', '2026-06-03 02:28:25'),
    (197, 'G2RAIN_DEPARTMENT', '数据权限小组表', '新增或更新数据权限小组表信息', 'POST', '/data_permission_group/save', '新增或更新数据权限小组表基础信息', '2026-06-03 02:28:25', '2026-06-03 02:28:25'),
    (198, 'G2RAIN_DEPARTMENT', '数据权限小组表', '删除数据权限小组表记录', 'DELETE', '/data_permission_group/{id}', '根据主键删除数据权限小组表记录', '2026-06-03 02:28:25', '2026-06-03 02:28:25'),
    (199, 'G2RAIN_DEPARTMENT', '数据权限小组表', '修改权限小组状态', 'POST', '/data_permission_group/{id}/status', '修改权限小组状态', '2026-06-03 02:28:25', '2026-06-03 02:28:25'),
    (200, 'G2RAIN_DEPARTMENT', '数据权限小组表', '分页查询数据权限小组表列表', 'GET', '/data_permission_group/page', '分页查询数据权限小组表列表', '2026-06-03 02:28:25', '2026-06-03 02:28:25'),
    (201, 'G2RAIN_DEPARTMENT', '数据权限小组表', '查询数据权限小组表列表', 'GET', '/data_permission_group/list', '根据查询条件返回数据权限小组表列表', '2026-06-03 02:28:25', '2026-06-03 02:28:25'),
    (202, 'G2RAIN_DEPARTMENT', '数据权限小组人员关系表', '新增或更新数据权限小组人员关系表信息', 'POST', '/data_permission_group_user_relation/save', '新增或更新数据权限小组人员关系表基础信息', '2026-06-03 02:28:25', '2026-06-03 02:28:25'),
    (203, 'G2RAIN_DEPARTMENT', '数据权限小组人员关系表', '批量添加小组用户', 'POST', '/data_permission_group_user_relation/add_users', '批量添加小组用户，已存在的关联自动忽略', '2026-06-03 02:28:25', '2026-06-03 02:28:25'),
    (204, 'G2RAIN_DEPARTMENT', '数据权限小组人员关系表', '删除数据权限小组人员关系表记录', 'DELETE', '/data_permission_group_user_relation/{id}', '根据主键删除数据权限小组人员关系表记录', '2026-06-03 02:28:25', '2026-06-03 02:28:25'),
    (205, 'G2RAIN_DEPARTMENT', '数据权限小组人员关系表', '修改小组用户关联状态', 'POST', '/data_permission_group_user_relation/{id}/status', '修改小组用户关联状态', '2026-06-03 02:28:25', '2026-06-03 02:28:25'),
    (206, 'G2RAIN_DEPARTMENT', '数据权限小组人员关系表', '分页查询数据权限小组人员关系表列表', 'GET', '/data_permission_group_user_relation/page', '分页查询数据权限小组人员关系表列表', '2026-06-03 02:28:25', '2026-06-03 02:28:25'),
    (207, 'G2RAIN_DEPARTMENT', '数据权限小组人员关系表', '查询数据权限小组人员关系表列表', 'GET', '/data_permission_group_user_relation/list', '根据查询条件返回数据权限小组人员关系表列表', '2026-06-03 02:28:25', '2026-06-03 02:28:25'),
    (208, 'G2RAIN_DEPARTMENT', '数据权限 Other 规则表', '新增或更新数据权限 Other 规则表信息', 'POST', '/data_permission_other/save', '新增或更新数据权限 Other 规则表基础信息', '2026-06-03 02:28:25', '2026-06-03 02:28:25'),
    (209, 'G2RAIN_DEPARTMENT', '数据权限 Other 规则表', '删除数据权限 Other 规则表记录', 'DELETE', '/data_permission_other/{id}', '根据主键删除数据权限 Other 规则表记录', '2026-06-03 02:28:25', '2026-06-03 02:28:25'),
    (210, 'G2RAIN_DEPARTMENT', '数据权限 Other 规则表', '修改规则配置状态', 'POST', '/data_permission_other/{id}/status', '修改规则配置状态', '2026-06-03 02:28:25', '2026-06-03 02:28:25'),
    (211, 'G2RAIN_DEPARTMENT', '数据权限 Other 规则表', '分页查询数据权限 Other 规则表列表', 'GET', '/data_permission_other/page', '分页查询数据权限 Other 规则表列表', '2026-06-03 02:28:25', '2026-06-03 02:28:25'),
    (212, 'G2RAIN_DEPARTMENT', '数据权限 Other 规则表', '查询数据权限 Other 规则表列表', 'GET', '/data_permission_other/list', '根据查询条件返回数据权限 Other 规则表列表', '2026-06-03 02:28:25', '2026-06-03 02:28:25');

-- 应用资源菜单
INSERT INTO `resource_menu`
(`id`, `parent_id`, `application_id`, `menu_name`, `menu_code`, `link_path`, `icon`, `menu_sort_order`, `create_time`, `update_time`)
VALUES
    (213,NULL,9,'系统管理','system_management_menu','','',10000,'2026-01-31 17:12:28','2026-04-19 00:02:38'),
    (214,213,9,'机构管理','organ_management_menu','/organ','',1,'2026-01-31 17:12:28','2026-01-31 17:12:28'),
    (215,213,9,'机构三方信息','idp_enterprise_organ','/idp_enterprise_organ','',2,'2026-05-25 14:36:41','2026-06-04 15:58:52'),
    (216,213,9,'用户管理','user_management_menu','/user','',3,'2026-01-31 17:12:28','2026-05-25 14:36:20'),
    (217,213,9,'角色管理','role_management_menu','/role','',5,'2026-01-31 17:12:28','2026-05-25 14:36:16'),
    (218,NULL,10,'部门管理','dept_management_menu','','',10001,'2026-06-03 02:29:55','2026-06-04 15:55:49'),
    (219,218,10,'权限模型','data_permission_model','/data_permission_model','',1,'2026-06-03 02:30:49','2026-06-03 02:30:49'),
    (220,218,10,'部门配置','department','/department','',2,'2026-06-03 02:31:54','2026-06-03 02:31:54'),
    (221,218,10,'权限策略','data_permission_meta','/data_permission_meta','',3,'2026-06-03 02:32:09','2026-06-03 02:32:09'),
    (222,218,10,'权限小组','data_permission_group','/data_permission_group','',5,'2026-06-03 02:32:26','2026-06-03 02:32:26'),
    (223,NULL,9,'应用管理','application_management_menu','','',10002,'2026-01-31 17:12:28','2026-06-03 02:30:07'),
    (224,223,9,'应用配置','application_config_menu','/application','',1,'2026-01-31 17:12:28','2026-01-31 17:12:28'),
    (225,223,9,'应用三方配置','application_idp_provision','/application_idp_provision','',2,'2026-05-25 14:35:51','2026-05-25 14:35:51'),
    (226,223,9,'资源配置','resource_settings_menu','/resource_settings','',3,'2026-01-31 17:12:28','2026-05-25 14:35:26'),
    (227,223,9,'资源菜单','resource_menu_menu','/resource_menu','',5,'2026-01-31 17:12:28','2026-05-25 14:35:23'),
    (228,223,9,'资源页面','resource_page_menu','/resource_page','',6,'2026-01-31 17:12:28','2026-05-25 14:35:19'),
    (229,223,9,'功能权限','control_unit_menu','/control_unit','',7,'2026-01-31 17:12:28','2026-05-25 14:35:15'),
    (230,223,9,'业务能力','control_domain_menu','/control_domain','',8,'2026-01-31 17:12:28','2026-05-25 14:35:11'),
    (231,223,9,'授权记录','application_authorization_menu','/application_authorization','',9,'2026-01-31 17:12:28','2026-05-25 14:35:06'),
    (232,NULL,9,'平台配置','platform_settings_menu','','',10003,'2026-01-31 17:12:28','2026-04-19 00:02:50'),
    (233,232,9,'服务注册','service_registry_menu','/service_registry','',1,'2026-01-31 17:12:28','2026-01-31 17:12:28'),
    (234,232,9,'服务接口','resource_api_menu','/resource_api','',2,'2026-01-31 17:12:28','2026-01-31 17:12:28'),
    (235,NULL,9,'平台运营','platform_operations_menu','','',10005,'2026-01-31 17:12:28','2026-04-19 00:02:56'),
    (236,235,9,'账号管理','passport_management_menu','/passport','',1,'2026-01-31 17:12:28','2026-01-31 17:12:28'),
    (237,235,9,'账号绑定信息','passport_idp_binding','/passport_idp_binding','',2,'2026-05-25 14:34:00','2026-05-25 14:34:15'),
    (238,235,9,'登陆日志','login_token_menu','/login_token','',3,'2026-01-31 17:12:28','2026-05-25 14:34:20'),
    (239,235,9,'审计事件','audit_event_menu','/audit_event','',5,'2026-01-31 17:12:28','2026-05-25 14:34:26'),
    (240,NULL,8,'平台技术','infra_menu','','',10006,'2026-04-10 20:06:57','2026-04-19 00:03:01'),
    (241,240,8,'序列号段调控','g2rain_raindrop_menu','/g2rain_raindrop','',1,'2026-04-10 20:15:29','2026-04-10 20:15:29'),
    (242,240,8,'字典用途设置','dictionary_usage_menu','/dictionary_usage','',2,'2026-04-10 20:10:42','2026-04-10 20:12:57'),
    (243,240,8,'地区语言设置','locale_setting_menu','/locale_setting','',3,'2026-04-10 20:15:06','2026-04-10 20:15:06'),
    (244,240,8,'多语言文案库','i18n_message_menu','/i18n_message','',5,'2026-04-10 20:13:38','2026-04-10 20:14:39');

-- 应用资源页面
INSERT INTO `resource_page`
(`id`, `application_id`, `page_name`, `page_code`, `link_path`, `create_time`, `update_time`)
VALUES
    (245,9,'机构管理界面','organ','/organ','2026-01-31 09:12:28','2026-01-31 09:12:28'),
    (246,9,'外部企业界面','idp_enterprise_organ','/idp_enterprise_organ','2026-05-25 14:30:49','2026-05-25 14:30:49'),
    (247,9,'用户管理界面','user','/user','2026-01-31 09:12:28','2026-01-31 09:12:28'),
    (248,9,'角色管理界面','role','/role','2026-01-31 09:12:28','2026-01-31 09:12:28'),
    (249,9,'应用配置界面','application','/application','2026-01-31 09:12:28','2026-01-31 09:12:28'),
    (250,9,'应用三方界面','application_idp_provision','/application_idp_provision','2026-05-25 14:30:49','2026-05-25 14:30:49'),
    (251,9,'资源配置界面','resource_settings','/resource_settings','2026-01-31 09:12:28','2026-05-04 21:08:53'),
    (252,9,'资源菜单界面','resource_menu','/resource_menu','2026-01-31 09:12:28','2026-05-04 21:08:53'),
    (253,9,'资源页面界面','resource_page','/resource_page','2026-01-31 09:12:28','2026-05-04 21:08:53'),
    (254,9,'功能权限界面','control_unit','/control_unit','2026-01-31 09:12:28','2026-05-04 21:08:53'),
    (255,9,'业务能力界面','control_domain','/control_domain','2026-01-31 09:12:28','2026-05-04 21:08:53'),
    (256,9,'授权记录界面','application_authorization','/application_authorization','2026-01-31 09:12:28','2026-05-04 21:08:53'),
    (257,9,'静态访问令牌','personal_static_access_token','/personal_static_access_token','2026-05-20 01:34:21','2026-05-20 01:34:21'),
    (258,9,'服务注册界面','service_registry','/service_registry','2026-01-31 09:12:28','2026-05-04 21:08:53'),
    (259,9,'服务接口界面','resource_api','/resource_api','2026-01-31 09:12:28','2026-05-04 21:08:53'),
    (260,9,'账号管理界面','passport','/passport','2026-01-31 09:12:28','2026-01-31 09:12:28'),
    (261,9,'账号绑定界面','passport_idp_binding','/passport_idp_binding','2026-05-25 14:30:49','2026-05-25 14:30:49'),
    (262,9,'登陆日志界面','login_token','/login_token','2026-01-31 09:12:28','2026-01-31 09:12:28'),
    (263,9,'审计事件界面','audit_event','/audit_event','2026-01-31 09:12:28','2026-01-31 09:12:28'),
    (264,8,'序列号段调控','g2rain_raindrop','/g2rain_raindrop','2026-04-10 15:23:17','2026-04-10 15:23:17'),
    (265,8,'字典用途设置','dictionary_usage','/dictionary_usage','2026-04-10 15:22:01','2026-04-10 15:22:01'),
    (266,8,'地区语言设置','locale_setting','/locale_setting','2026-04-10 15:23:02','2026-04-10 15:23:02'),
    (267,8,'多语言文案库','i18n_message','/i18n_message','2026-04-10 15:22:16','2026-04-10 15:22:31'),
    (268,10,'权限模型界面','data_permission_model','/data_permission_model','2026-06-03 02:28:48','2026-06-03 02:28:48'),
    (269,10,'权限字段界面','data_permission_field','/data_permission_field','2026-06-03 02:28:48','2026-06-03 02:28:48'),
    (270,10,'部门管理界面','department','/department','2026-05-31 04:29:32','2026-05-31 04:38:26'),
    (271,10,'部门人员关系','department_user_relation','/department_user_relation','2026-06-03 02:28:48','2026-06-03 02:28:48'),
    (272,10,'数据权限元数据','data_permission_meta','/data_permission_meta','2026-06-03 02:28:48','2026-06-03 02:28:48'),
    (273,10,'数据权限小组','data_permission_group','/data_permission_group','2026-06-03 02:28:48','2026-06-03 02:28:48'),
    (274,10,'小组人员关系','data_permission_group_user_relation','/data_permission_group_user_relation','2026-06-03 02:28:48','2026-06-03 02:28:48'),
    (275,10,'数据权限界面','data_permission_other','/data_permission_other','2026-06-03 02:28:48','2026-06-03 02:28:48');

-- 应用页面元素
INSERT INTO `resource_page_element`
(`id`, `application_id`, `page_code`, `page_element_name`, `page_element_code`, `create_time`, `update_time`)
VALUES
    (276,9,'organ','新增按钮','organ:add','2026-01-31 09:12:28','2026-01-31 09:12:28'),
    (277,9,'organ','删除按钮','organ:delete','2026-01-31 09:12:28','2026-01-31 09:12:28'),
    (278,9,'organ','修改按钮','organ:edit','2026-01-31 09:12:28','2026-01-31 09:12:28'),
    (279,9,'organ','三方应用信息','organ:idp_enterprise_view','2026-05-25 14:30:49','2026-05-29 00:34:39'),
    (280,9,'organ','生成邀请码','organ:invite_generate','2026-05-29 00:34:09','2026-05-29 00:34:56'),
    (281,9,'organ','调整归属','organ:reassign','2026-01-31 09:12:28','2026-01-31 09:12:28'),
    (282,9,'organ','修改状态','organ:status_update','2026-01-31 09:12:28','2026-01-31 09:12:28'),
    (283,9,'idp_enterprise_organ','新增','idp_enterprise_organ:add','2026-05-25 14:30:49','2026-05-25 14:30:49'),
    (284,9,'idp_enterprise_organ','删除','idp_enterprise_organ:delete','2026-05-25 14:30:49','2026-05-25 14:30:49'),
    (285,9,'idp_enterprise_organ','编辑','idp_enterprise_organ:edit','2026-05-25 14:30:49','2026-05-25 14:30:49'),
    (286,9,'user','新增','user:add','2026-05-25 14:30:49','2026-05-25 14:30:49'),
    (287,9,'user','删除按钮','user:delete','2026-01-31 09:12:28','2026-01-31 09:12:28'),
    (288,9,'user','修改按钮','user:edit','2026-01-31 09:12:28','2026-01-31 09:12:28'),
    (289,9,'role','新增按钮','role:add','2026-01-31 09:12:28','2026-01-31 09:12:28'),
    (290,9,'role','删除按钮','role:delete','2026-01-31 09:12:28','2026-01-31 09:12:28'),
    (291,9,'role','修改按钮','role:edit','2026-01-31 09:12:28','2026-01-31 09:12:28'),
    (292,9,'role','分配权限','role:control_utils_assign','2026-01-31 09:12:28','2026-01-31 09:12:28'),
    (293,9,'role','分配用户','role:users_assign','2026-01-31 09:12:28','2026-01-31 09:12:28'),
    (294,9,'application','新增按钮','application:add','2026-01-31 09:12:28','2026-01-31 09:12:28'),
    (295,9,'application','删除按钮','application:delete','2026-01-31 09:12:28','2026-01-31 09:12:28'),
    (296,9,'application','修改按钮','application:edit','2026-01-31 09:12:28','2026-01-31 09:12:28'),
    (297,9,'application','idp_provision_config','application:idp_provision_config','2026-05-25 14:30:49','2026-05-25 14:30:49'),
    (298,9,'application','关联应用','application:integrate','2026-01-31 09:12:28','2026-01-31 09:12:28'),
    (299,9,'application','公钥配置','application:public_key_config','2026-01-31 09:12:28','2026-01-31 09:12:28'),
    (300,9,'application','修改状态','application:status_update','2026-01-31 09:12:28','2026-01-31 09:12:28'),
    (301,9,'application','新增','application_idp_provision:add','2026-05-25 14:30:49','2026-05-25 14:30:49'),
    (302,9,'application','删除','application_idp_provision:delete','2026-05-25 14:30:49','2026-05-25 14:30:49'),
    (303,9,'application','编辑','application_idp_provision:edit','2026-05-25 14:30:49','2026-05-25 14:30:49'),
    (304,9,'resource_settings','导入按钮','resource_settings:upload','2026-01-31 09:12:28','2026-01-31 09:12:28'),
    (305,9,'resource_menu','新增按钮','resource_menu:add','2026-01-31 09:12:28','2026-01-31 09:12:28'),
    (306,9,'resource_menu','删除按钮','resource_menu:delete','2026-01-31 09:12:28','2026-01-31 09:12:28'),
    (307,9,'resource_menu','修改按钮','resource_menu:edit','2026-01-31 09:12:28','2026-01-31 09:12:28'),
    (308,9,'resource_page','新增按钮','resource_page:add','2026-01-31 09:12:28','2026-01-31 09:12:28'),
    (309,9,'resource_page','删除按钮','resource_page:delete','2026-01-31 09:12:28','2026-01-31 09:12:28'),
    (310,9,'resource_page','修改按钮','resource_page:edit','2026-01-31 09:12:28','2026-01-31 09:12:28'),
    (311,9,'resource_page','页面元素','resource_page:page_element_mgmt','2026-01-31 09:12:28','2026-01-31 09:12:28'),
    (312,9,'control_unit','新增按钮','control_unit:add','2026-01-31 09:12:28','2026-01-31 09:12:28'),
    (313,9,'control_unit','删除按钮','control_unit:delete','2026-01-31 09:12:28','2026-01-31 09:12:28'),
    (314,9,'control_unit','修改按钮','control_unit:edit','2026-01-31 09:12:28','2026-01-31 09:12:28'),
    (315,9,'control_unit','配置资源','control_unit:resources_config','2026-01-31 09:12:28','2026-01-31 09:12:28'),
    (316,9,'control_unit','修改状态','control_unit:status_update','2026-01-31 09:12:28','2026-01-31 09:12:28'),
    (317,9,'control_domain','新增按钮','control_domain:add','2026-01-31 09:12:28','2026-01-31 09:12:28'),
    (318,9,'control_domain','删除按钮','control_domain:delete','2026-01-31 09:12:28','2026-01-31 09:12:28'),
    (319,9,'control_domain','修改按钮','control_domain:edit','2026-01-31 09:12:28','2026-01-31 09:12:28'),
    (320,9,'control_domain','关联权限','control_domain:control_utils_associate','2026-01-31 09:12:28','2026-01-31 09:12:28'),
    (321,9,'control_domain','开通功能','control_domain:features_activate','2026-01-31 09:12:28','2026-01-31 09:12:28'),
    (322,9,'application_authorization','同步能力','application_authorization:control_utils_sync','2026-01-31 09:12:28','2026-01-31 09:12:28'),
    (323,9,'application_authorization','管理密钥','application_authorization:manager_api_keys','2026-05-20 01:34:22','2026-05-20 01:34:22'),
    (324,9,'application_authorization','修改状态','application_authorization:status_update','2026-01-31 09:12:28','2026-01-31 09:12:28'),
    (325,9,'personal_static_access_token','新增按钮','personal_static_access_token:add','2026-05-20 01:34:22','2026-05-20 01:34:22'),
    (326,9,'personal_static_access_token','删除按钮','personal_static_access_token:delete','2026-05-20 01:34:22','2026-05-20 01:34:22'),
    (327,9,'personal_static_access_token','编辑按钮','personal_static_access_token:edit','2026-05-20 01:34:22','2026-05-20 01:34:22'),
    (328,9,'personal_static_access_token','修改状态','personal_static_access_token:status_update','2026-01-31 09:12:28','2026-01-31 09:12:28'),
    (329,9,'service_registry','新增按钮','service_registry:add','2026-01-31 09:12:28','2026-01-31 09:12:28'),
    (330,9,'service_registry','删除按钮','service_registry:delete','2026-01-31 09:12:28','2026-01-31 09:12:28'),
    (331,9,'service_registry','修改按钮','service_registry:edit','2026-01-31 09:12:28','2026-01-31 09:12:28'),
    (332,9,'resource_api','新增按钮','resource_api:add','2026-01-31 09:12:28','2026-01-31 09:12:28'),
    (333,9,'resource_api','删除按钮','resource_api:delete','2026-01-31 09:12:28','2026-01-31 09:12:28'),
    (334,9,'resource_api','修改按钮','resource_api:edit','2026-01-31 09:12:28','2026-01-31 09:12:28'),
    (335,9,'resource_api','导入按钮','resource_api:import','2026-01-31 09:12:28','2026-01-31 09:12:28'),
    (336,9,'passport','新增按钮','passport:add','2026-01-31 09:12:28','2026-01-31 09:12:28'),
    (337,9,'passport','删除按钮','passport:delete','2026-01-31 09:12:28','2026-01-31 09:12:28'),
    (338,9,'passport','修改按钮','passport:edit','2026-01-31 09:12:28','2026-01-31 09:12:28'),
    (339,9,'passport','修改状态','passport:status_update','2026-01-31 09:12:28','2026-01-31 09:12:28'),
    (340,9,'passport_idp_binding','新增','passport_idp_binding:add','2026-05-25 14:30:49','2026-05-25 14:30:49'),
    (341,9,'passport_idp_binding','删除','passport_idp_binding:delete','2026-05-25 14:30:49','2026-05-25 14:30:49'),
    (342,9,'passport_idp_binding','编辑','passport_idp_binding:edit','2026-05-25 14:30:49','2026-05-25 14:30:49'),
    (343,8,'g2rain_raindrop','新增按钮','g2rain_raindrop:add','2026-04-10 22:20:20','2026-04-10 22:20:20'),
    (344,8,'g2rain_raindrop','删除按钮','g2rain_raindrop:delete','2026-04-10 22:20:20','2026-04-10 22:20:20'),
    (345,8,'g2rain_raindrop','编辑按钮','g2rain_raindrop:edit','2026-04-10 22:20:20','2026-04-10 22:20:20'),
    (346,8,'dictionary_usage','新增按钮','dictionary_usage:add','2026-04-10 22:20:20','2026-04-10 22:20:20'),
    (347,8,'dictionary_usage','删除按钮','dictionary_usage:delete','2026-04-10 22:20:20','2026-04-10 22:20:20'),
    (348,8,'dictionary_usage','修改按钮','dictionary_usage:edit','2026-04-10 22:20:20','2026-04-10 22:20:20'),
    (349,8,'dictionary_usage','打开明细','dictionary_usage:items','2026-04-11 21:58:31','2026-04-11 22:12:10'),
    (350,8,'dictionary_usage','新增字典','dictionary_item:add','2026-04-11 22:07:40','2026-04-11 22:11:45'),
    (351,8,'dictionary_usage','删除字典','dictionary_item:delete','2026-04-11 22:07:40','2026-04-11 22:11:55'),
    (352,8,'dictionary_usage','修改字典','dictionary_item:edit','2026-04-11 22:07:40','2026-04-11 22:12:01'),
    (353,8,'locale_setting','新增按钮','locale_setting:add','2026-04-10 22:20:20','2026-04-10 22:20:20'),
    (354,8,'locale_setting','删除按钮','locale_setting:delete','2026-04-10 22:20:20','2026-04-10 22:20:20'),
    (355,8,'locale_setting','修改按钮','locale_setting:edit','2026-04-10 22:20:20','2026-04-10 22:20:20'),
    (356,8,'i18n_message','新增按钮','i18n_message:add','2026-04-10 22:20:20','2026-04-10 22:20:20'),
    (357,8,'i18n_message','删除按钮','i18n_message:delete','2026-04-10 22:20:20','2026-04-10 22:20:20'),
    (358,8,'i18n_message','修改按钮','i18n_message:edit','2026-04-10 22:20:20','2026-04-10 22:20:20'),
    (359,10,'data_permission_model','新增','data_permission_model:add','2026-06-03 02:28:48','2026-06-03 02:28:48'),
    (360,10,'data_permission_model','删除','data_permission_model:delete','2026-06-03 02:28:48','2026-06-03 02:28:48'),
    (361,10,'data_permission_model','编辑','data_permission_model:edit','2026-06-03 02:28:48','2026-06-03 02:28:48'),
    (362,10,'data_permission_model','条件字段','data_permission_model:condition_field','2026-06-03 02:28:48','2026-06-03 02:28:48'),
    (363,10,'data_permission_field','新增','data_permission_field:add','2026-06-03 02:28:48','2026-06-03 02:28:48'),
    (364,10,'data_permission_field','删除','data_permission_field:delete','2026-06-03 02:28:48','2026-06-03 02:28:48'),
    (365,10,'data_permission_field','编辑','data_permission_field:edit','2026-06-03 02:28:48','2026-06-03 02:28:48'),
    (366,10,'department','新增','department:add','2026-06-03 02:28:48','2026-06-03 02:28:48'),
    (367,10,'department','删除','department:delete','2026-06-03 02:28:48','2026-06-03 02:28:48'),
    (368,10,'department','编辑','department:edit','2026-06-03 02:28:48','2026-06-03 02:28:48'),
    (369,10,'department','关联用户','department:relation_users','2026-06-03 02:28:48','2026-06-03 02:28:48'),
    (370,10,'department','状态变更','department:status_update','2026-06-03 06:49:05','2026-06-03 06:49:05'),
    (371,10,'department_user_relation','新增','department_user_relation:add','2026-06-03 02:28:48','2026-06-03 02:28:48'),
    (372,10,'department_user_relation','删除','department_user_relation:delete','2026-06-03 02:28:48','2026-06-03 02:28:48'),
    (373,10,'data_permission_meta','新增','data_permission_meta:add','2026-06-03 02:28:48','2026-06-03 02:28:48'),
    (374,10,'data_permission_meta','删除','data_permission_meta:delete','2026-06-03 02:28:48','2026-06-03 02:28:48'),
    (375,10,'data_permission_meta','编辑','data_permission_meta:edit','2026-06-03 02:28:48','2026-06-03 02:28:48'),
    (376,10,'data_permission_meta','状态变更','data_permission_meta:status_update','2026-06-03 06:49:05','2026-06-03 06:49:05'),
    (377,10,'data_permission_group','新增','data_permission_group:add','2026-06-03 02:28:48','2026-06-03 02:28:48'),
    (378,10,'data_permission_group','删除','data_permission_group:delete','2026-06-03 02:28:48','2026-06-03 02:28:48'),
    (379,10,'data_permission_group','编辑','data_permission_group:edit','2026-06-03 02:28:48','2026-06-03 02:28:48'),
    (380,10,'data_permission_group','关联用户','data_permission_group:relation_users','2026-06-03 02:28:48','2026-06-03 02:28:48'),
    (381,10,'data_permission_group','规则配置','data_permission_group:rule_config','2026-06-03 02:28:48','2026-06-03 02:28:48'),
    (382,10,'data_permission_group','状态变更','data_permission_group:status_update','2026-06-03 06:49:05','2026-06-03 06:49:05'),
    (383,10,'data_permission_group_user_relation','新增','data_permission_group_user_relation:add','2026-06-03 02:28:48','2026-06-03 02:28:48'),
    (384,10,'data_permission_group_user_relation','删除','data_permission_group_user_relation:delete','2026-06-03 02:28:48','2026-06-03 02:28:48'),
    (385,10,'data_permission_group_user_relation','状态变更','data_permission_group_user_relation:status_update','2026-06-03 06:49:05','2026-06-03 06:49:05'),
    (386,10,'data_permission_other','新增','data_permission_other:add','2026-06-03 02:28:48','2026-06-03 02:28:48'),
    (387,10,'data_permission_other','删除','data_permission_other:delete','2026-06-03 02:28:48','2026-06-03 02:28:48'),
    (388,10,'data_permission_other','编辑','data_permission_other:edit','2026-06-03 02:28:48','2026-06-03 02:28:48'),
    (389,10,'data_permission_other','状态变更','data_permission_other:status_update','2026-06-03 06:49:05','2026-06-03 06:49:05');

-- 控制单元资源关联
INSERT INTO `control_unit_resource_relation`
(`id`, `control_unit_id`, `resource_id`, `resource_type`, `status`, `create_time`, `update_time`)
VALUES
    -- 燧人氏 menu
    (390, 15, 240, 'MENU', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (391, 15, 241, 'MENU', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (392, 15, 242, 'MENU', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (393, 15, 243, 'MENU', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (394, 15, 244, 'MENU', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),

    -- 女娲 menu
    (395, 16, 213, 'MENU', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (396, 16, 214, 'MENU', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (397, 16, 215, 'MENU', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (398, 16, 216, 'MENU', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (399, 16, 217, 'MENU', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (400, 16, 223, 'MENU', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (401, 16, 224, 'MENU', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (402, 16, 225, 'MENU', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (403, 16, 226, 'MENU', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (404, 16, 227, 'MENU', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (405, 16, 228, 'MENU', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (406, 16, 229, 'MENU', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (407, 16, 230, 'MENU', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (408, 16, 231, 'MENU', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (409, 16, 232, 'MENU', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (410, 16, 233, 'MENU', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (411, 16, 234, 'MENU', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (412, 16, 235, 'MENU', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (413, 16, 236, 'MENU', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (414, 16, 237, 'MENU', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (415, 16, 238, 'MENU', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (416, 16, 239, 'MENU', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),

    -- 颛顼 menu
    (417, 17, 218, 'MENU', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (418, 17, 219, 'MENU', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),

    -- 有巢氏 menu
    (419, 18, 213, 'MENU', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (420, 18, 214, 'MENU', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (421, 18, 216, 'MENU', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (422, 18, 217, 'MENU', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (423, 18, 223, 'MENU', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (424, 18, 231, 'MENU', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),

    -- 大禹 menu
    (425, 19, 218, 'MENU', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (426, 19, 220, 'MENU', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (427, 19, 221, 'MENU', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (428, 19, 222, 'MENU', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),

    -- 燧人氏 page
    (429, 15, 264, 'PAGE', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (430, 15, 265, 'PAGE', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (431, 15, 266, 'PAGE', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (432, 15, 267, 'PAGE', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),

    -- 女娲 page
    (433, 16, 245, 'PAGE', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (434, 16, 246, 'PAGE', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (435, 16, 247, 'PAGE', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (436, 16, 248, 'PAGE', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (437, 16, 249, 'PAGE', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (438, 16, 250, 'PAGE', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (439, 16, 251, 'PAGE', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (440, 16, 252, 'PAGE', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (441, 16, 253, 'PAGE', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (442, 16, 254, 'PAGE', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (443, 16, 255, 'PAGE', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (444, 16, 256, 'PAGE', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (445, 16, 257, 'PAGE', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (446, 16, 258, 'PAGE', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (447, 16, 259, 'PAGE', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (448, 16, 260, 'PAGE', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (449, 16, 261, 'PAGE', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (450, 16, 262, 'PAGE', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (451, 16, 263, 'PAGE', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),

    -- 颛顼 page
    (452, 17, 268, 'PAGE', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (453, 17, 269, 'PAGE', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),

    -- 有巢氏 page
    (454, 18, 245, 'PAGE', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (455, 18, 247, 'PAGE', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (456, 18, 248, 'PAGE', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (457, 18, 256, 'PAGE', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (458, 18, 257, 'PAGE', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),

    -- 大禹 page
    (459, 19, 270, 'PAGE', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (460, 19, 271, 'PAGE', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (461, 19, 272, 'PAGE', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (462, 19, 273, 'PAGE', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (463, 19, 274, 'PAGE', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (464, 19, 275, 'PAGE', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),

    -- 燧人氏 page element
    (465, 15, 343, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (466, 15, 344, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (467, 15, 345, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (468, 15, 346, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (469, 15, 347, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (470, 15, 348, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (471, 15, 349, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (472, 15, 350, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (473, 15, 351, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (474, 15, 352, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (475, 15, 353, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (476, 15, 354, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (477, 15, 355, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (478, 15, 356, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (479, 15, 357, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (480, 15, 358, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),

    -- 女娲 page element
    (481, 16, 276, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (482, 16, 277, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (483, 16, 278, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (484, 18, 279, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (485, 18, 280, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (486, 18, 281, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (487, 18, 282, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (488, 18, 283, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (489, 18, 284, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (490, 18, 285, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (491, 18, 286, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (492, 18, 287, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (493, 18, 288, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (494, 18, 289, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (495, 16, 290, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (496, 16, 291, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (497, 16, 292, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (498, 16, 293, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (499, 16, 294, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (500, 16, 295, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (501, 16, 296, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (502, 16, 297, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (503, 16, 298, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (504, 16, 299, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (505, 16, 300, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (506, 16, 301, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (507, 16, 302, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (508, 16, 303, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (509, 16, 304, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (510, 16, 305, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (511, 16, 306, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (512, 16, 307, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (513, 16, 308, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (514, 16, 309, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (515, 16, 310, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (516, 16, 311, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (517, 16, 312, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (518, 16, 313, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (519, 16, 314, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (520, 16, 315, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (521, 16, 316, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (522, 16, 317, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (523, 16, 318, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (524, 16, 319, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (525, 16, 320, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (526, 16, 321, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (527, 16, 322, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (528, 16, 323, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (529, 16, 324, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (530, 16, 325, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (531, 16, 326, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (532, 16, 327, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (533, 16, 328, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (534, 16, 329, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (535, 16, 330, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (536, 16, 331, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (537, 16, 332, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (538, 16, 333, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (539, 16, 334, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (540, 16, 335, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (541, 16, 336, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (542, 16, 337, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (543, 16, 338, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (544, 16, 339, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (545, 16, 340, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (546, 16, 341, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (547, 16, 342, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),

    -- 颛顼 page element
    (548, 17, 359, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (549, 17, 360, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (550, 17, 361, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (551, 17, 362, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (552, 17, 363, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (553, 17, 364, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (554, 17, 365, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),

    -- 有巢氏 page element
    (555, 18, 276, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (556, 18, 277, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (557, 18, 278, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (558, 18, 279, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (559, 18, 280, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),

    (560, 18, 281, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (561, 18, 288, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (562, 18, 289, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (563, 18, 290, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (564, 18, 291, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (565, 18, 292, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (566, 18, 293, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (567, 18, 322, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (568, 18, 323, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (569, 18, 325, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (570, 18, 326, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (571, 18, 327, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),

    -- 大禹 page element
    (572, 19, 366, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (573, 19, 367, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (574, 19, 368, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (575, 19, 369, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (576, 19, 370, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (577, 19, 371, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (578, 19, 372, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (579, 19, 373, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (580, 19, 374, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (581, 19, 375, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (582, 19, 376, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (583, 19, 377, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (584, 19, 378, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (585, 19, 379, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (586, 19, 380, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (587, 19, 381, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (588, 19, 382, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (589, 19, 383, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (590, 19, 384, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (591, 19, 385, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (592, 19, 386, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (593, 19, 387, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (594, 19, 388, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (595, 19, 389, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28'),

    -- 盘古 api
    (596, 14, 41, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (597, 14, 51, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (598, 14, 58, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (599, 14, 59, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (600, 14, 60, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (601, 14, 61, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (602, 14, 66, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (603, 14, 67, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (604, 14, 72, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (605, 14, 81, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (606, 14, 84, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (607, 14, 91, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (608, 14, 171, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (609, 14, 172, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),

    -- 燧人氏 api
    (610, 15, 30, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (611, 15, 31, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (612, 15, 32, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (613, 15, 33, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (614, 15, 34, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (615, 15, 35, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (616, 15, 36, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (617, 15, 37, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (618, 15, 38, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (619, 15, 39, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (620, 15, 40, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (621, 15, 41, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (622, 15, 42, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (623, 15, 43, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (624, 15, 44, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (625, 15, 45, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (626, 15, 46, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (627, 15, 47, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (628, 15, 48, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (629, 15, 49, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (630, 15, 50, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (631, 15, 51, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (632, 15, 52, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (633, 15, 53, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (634, 15, 54, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (635, 15, 55, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (636, 15, 56, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (637, 15, 57, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (638, 15, 58, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (639, 15, 60, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),

    -- 女娲 api
    (640, 16, 51, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (641, 16, 58, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (642, 16, 59, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (643, 16, 60, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (644, 16, 61, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (645, 16, 62, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (646, 16, 63, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (647, 16, 64, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (648, 16, 65, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (649, 16, 66, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (650, 16, 67, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (651, 16, 68, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (652, 16, 69, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (653, 16, 70, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (654, 16, 71, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (655, 16, 72, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (656, 16, 73, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (657, 16, 74, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (658, 16, 75, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (659, 16, 76, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (660, 16, 77, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (661, 16, 78, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (662, 16, 79, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (663, 16, 80, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (664, 16, 81, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (665, 16, 82, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (666, 16, 83, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (667, 16, 84, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (668, 16, 85, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (669, 16, 86, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (670, 16, 87, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (671, 16, 88, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (672, 16, 89, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (673, 16, 90, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (674, 16, 91, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (675, 16, 92, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (676, 16, 93, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (677, 16, 94, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (678, 16, 95, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (679, 16, 96, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (680, 16, 97, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (681, 16, 98, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (682, 16, 99, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (683, 16, 100, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (684, 16, 101, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (685, 16, 102, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (686, 16, 103, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (687, 16, 104, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (688, 16, 105, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (689, 16, 106, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (690, 16, 107, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (691, 16, 108, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (692, 16, 109, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (693, 16, 110, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (694, 16, 111, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (695, 16, 112, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (696, 16, 113, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (697, 16, 114, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (698, 16, 115, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (699, 16, 116, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (700, 16, 117, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (701, 16, 118, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (702, 16, 119, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (703, 16, 120, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (704, 16, 121, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (705, 16, 122, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (706, 16, 123, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (707, 16, 124, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (708, 16, 125, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (709, 16, 126, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (710, 16, 127, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (711, 16, 128, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (712, 16, 129, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (713, 16, 130, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (714, 16, 131, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (715, 16, 132, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (716, 16, 133, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (717, 16, 134, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (718, 16, 135, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (719, 16, 136, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (720, 16, 137, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (721, 16, 138, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (722, 16, 139, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (723, 16, 140, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (724, 16, 141, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (725, 16, 142, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (726, 16, 143, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (727, 16, 144, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (728, 16, 145, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (729, 16, 146, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (730, 16, 147, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (731, 16, 148, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (732, 16, 149, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (733, 16, 150, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (734, 16, 151, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (735, 16, 152, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (736, 16, 153, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (737, 16, 154, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (738, 16, 155, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (739, 16, 156, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (740, 16, 157, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (741, 16, 158, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (742, 16, 159, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (743, 16, 160, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (744, 16, 161, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (745, 16, 162, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (746, 16, 163, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (747, 16, 164, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (748, 16, 165, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (749, 16, 166, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (750, 16, 167, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (751, 16, 168, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (752, 16, 169, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (753, 16, 170, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (754, 16, 171, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (755, 16, 172, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),

    -- 颛顼 api
    (756, 17, 58, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (757, 17, 60, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (758, 17, 173, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (759, 17, 174, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (760, 17, 175, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (761, 17, 176, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (762, 17, 177, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (763, 17, 178, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (764, 17, 179, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (765, 17, 180, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),

    -- 有巢氏 api
    (766, 18, 51, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (767, 18, 58, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (768, 18, 60, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (769, 18, 62, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (770, 18, 65, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (771, 18, 66, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (772, 18, 67, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (773, 18, 68, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (774, 18, 69, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (775, 18, 71, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (776, 18, 72, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (777, 18, 73, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (778, 18, 74, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (779, 18, 75, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (780, 18, 76, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (781, 18, 79, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (782, 18, 87, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (783, 18, 89, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (784, 18, 90, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (785, 18, 91, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (786, 18, 92, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (787, 18, 123, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (788, 18, 124, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (789, 18, 125, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (790, 18, 126, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (791, 18, 128, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (792, 18, 130, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (793, 18, 146, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (794, 18, 150, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (795, 18, 151, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (796, 18, 153, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (797, 18, 154, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (798, 18, 155, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (799, 18, 156, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (800, 18, 157, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (801, 18, 158, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (802, 18, 159, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (803, 18, 160, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (804, 18, 161, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (805, 18, 162, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (806, 18, 167, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (807, 18, 168, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (808, 18, 170, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),

    -- 大禹 api
    (809, 19, 51, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (810, 19, 58, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (811, 19, 60, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (812, 19, 72, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (813, 19, 66, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (814, 19, 67, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (815, 19, 181, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (816, 19, 182, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (817, 19, 183, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (818, 19, 184, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (819, 19, 185, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (820, 19, 186, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (821, 19, 187, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (822, 19, 188, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (823, 19, 189, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (824, 19, 190, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (825, 19, 191, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (826, 19, 192, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (827, 19, 193, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (828, 19, 194, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (829, 19, 195, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (830, 19, 196, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (831, 19, 197, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (832, 19, 198, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (833, 19, 199, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (834, 19, 200, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (835, 19, 201, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (836, 19, 202, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (837, 19, 203, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (838, 19, 204, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (839, 19, 205, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (840, 19, 206, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (841, 19, 207, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (842, 19, 208, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (843, 19, 209, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (844, 19, 210, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (845, 19, 211, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (846, 19, 212, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (847, 19, 176, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28'),
    (848, 19, 180, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28');
