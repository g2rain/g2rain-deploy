-- =============================================
-- g2rain_basis 数据库表结构
-- MySQL 8.0 版本
-- =============================================

-- 创建数据库
CREATE DATABASE IF NOT EXISTS `g2rain_basis` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
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
    `create_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP COMMENT                                      '创建时间',
    `update_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT          '更新时间',
    `version` INT NOT NULL DEFAULT 0 COMMENT                                                            '记录版本',
    `delete_flag` TINYINT NOT NULL DEFAULT 0 COMMENT                                                    '删除标识[0:未删除, 1:已删除]',
    PRIMARY KEY (`id`),
    INDEX `idx_username` (`username`),
    INDEX `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT=                             '账号表';

-- =============================================
-- 2. 用户表 (user)
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT=                             '用户表';

-- =============================================
-- 3. 机构表 (organ)
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT=                             '机构表';

-- =============================================
-- 4. 机构路径关系表 (organ_closure)
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT=                             '机构路径关系表';

-- =============================================
-- 5. 应用资源菜单表 (resource_menu)
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT=                             '应用资源菜单表';

-- =============================================
-- 6. 应用资源页面表 (resource_page)
-- =============================================
DROP TABLE IF EXISTS `resource_page`;

CREATE TABLE `resource_page` (
     `id` BIGINT NOT NULL COMMENT 													                    '页面标识',
     `application_id` BIGINT NOT NULL COMMENT 													        '应用标识',
     `page_name` VARCHAR(128) NOT NULL COMMENT												            '页面名称',
     `page_code` VARCHAR(128) NOT NULL COMMENT												            '页面编码',
     `link_path` VARCHAR(128) NOT NULL COMMENT 													        '链接路径',
     `create_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP COMMENT                                     '创建时间',
     `update_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT         '更新时间',
     `version` INT NOT NULL DEFAULT 0 COMMENT                                                           '记录版本',
     `delete_flag` TINYINT NOT NULL DEFAULT 0 COMMENT                                                   '删除标识[0:未删除, 1:已删除]',
     PRIMARY KEY (`id`),
     INDEX `idx_app_del_id` (`application_id`, `delete_flag`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT=                             '应用资源页面表';

-- =============================================
-- 7. 应用资源页面元素表 (resource_page_element)
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT=                             '应用资源页面元素表';

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT=                             '服务注册表';

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT=                             '资源接口表';

-- =============================================
-- 10. 控制单元表 (control_unit)
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT=                             '控制单元表';

-- =============================================
-- 11. 控制单元资源关联表 (control_unit_resource_relation)
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT=                             '控制单元资源关联表';

-- =============================================
-- 12. 角色表 (role)
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT=                             '角色表';

-- =============================================
-- 13. 用户角色关联表 (user_role_relation)
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT=                             '用户角色关联表';

-- =============================================
-- 14. 角色控制单元关联表 (role_control_unit_relation)
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT=                             '角色控制单元关联表';

-- =============================================
-- 15. 控制域表 (control_domain)
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT=                             '控制域表';

-- =============================================
-- 16. 控制域控制单元关联表 (control_domain_control_unit_relation)
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT=                             '控制域控制单元关联表';

-- =============================================
-- 17. 应用表 (application)
-- =============================================
DROP TABLE IF EXISTS `application`;

CREATE TABLE `application` (
    `id` BIGINT NOT NULL COMMENT 													                    '应用标识',
    `organ_id` BIGINT NOT NULL COMMENT 												                    '机构标识',
    `application_name` VARCHAR(128) NOT NULL COMMENT                                                    '应用名称',
    `application_code` VARCHAR(64) DEFAULT NULL COMMENT                                                 '应用编码',
    `can_integrate` TINYINT NOT NULL DEFAULT 0 COMMENT                                                  '是否具备集成功能[0:否, 1:是]',
    `landing` TINYINT NOT NULL DEFAULT 0 COMMENT                                                        '默认数据[0:否, 1:是]',
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT=                             '应用表';

-- =============================================
-- 18. 应用归类关系表 (application_suite)
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT=                             '应用归类关系表';

-- =============================================
-- 19. 应用授权记录表 (application_authorization)
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT=                             '应用授权记录表';

-- =============================================
-- 20. 登录信息表 (login_token)
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
) ENGINE=InnoDB DEFAULT CHARSET=UTF8MB4 COLLATE=utf8mb4_unicode_ci COMMENT=								'登录信息表, 记录了当前登录状态的相关信息';

-- =============================================
-- 21. 审计事件表 (audit_event)
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
    `target_organ_id` BIGINT DEFAULT NULL COMMENT                                                       '数据操作的目标组织标识',
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
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT=                         '审计事件表';

-- 账号
INSERT INTO `passport`
(`id`, `username`, `password`, `real_name`, `sex`, `birthday`, `id_no`, `mobile`, `email`, `status`, `create_time`, `update_time`, `version`, `delete_flag`)
VALUES
    (200, 'admin', 'PBKDF2WithHmacSHA256$65536$YSskABrEQZiuRcM3GMl6gQ==$Hl9gA9UnYmS1BoY3Ov3XY2qYQpUKF1Sl0QneYZ5zc7k=', '平台超管', 'MALE', NULL, NULL, NULL, NULL, 'NORMAL', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0);

-- 机构
INSERT INTO `organ`
(`id`, `organ_name`, `organ_type`, `status`, `admin`, `create_time`, `update_time`, `version`, `delete_flag`)
VALUES
    (201, '平台机构', 'COMPANY', 'ACTIVE', 1, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0);

-- 机构路径关系
INSERT INTO `organ_closure`
(`id`, `ancestor_id`, `descendant_id`, `descendant_type`, `relation_type`, `path_count`, `create_time`, `update_time`, `version`, `delete_flag`)
VALUES
    (202, 201, 201, 'COMPANY', 'SELF_ASSOCIATION', 1, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0);

-- 角色
INSERT INTO `role`
(`id`, `organ_id`, `role_name`, `role_type`, `create_time`, `update_time`, `version`, `delete_flag`)
VALUES
    (203, 201, '超管角色', 'ADMIN', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0);

-- 用户
INSERT INTO `user`
(`id`, `passport_id`, `organ_id`, `email`, `mobile`, `real_name`, `admin`, `create_time`, `update_time`, `version`, `delete_flag`)
VALUES
    (205, 200, 201, NULL, NULL, '平台管理员', 1, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0);

-- 用户角色关联
INSERT INTO `user_role_relation`
(`id`, `user_id`, `role_id`, `create_time`, `update_time`, `version`, `delete_flag`)
VALUES
    (206, 205, 203, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0);

-- 应用
INSERT INTO `application`
(`id`, `organ_id`, `application_name`, `application_code`, `can_integrate`, `landing`, `application_type`, `public_key_algorithm`, `public_key_format`, `public_key`, `access_token_expires_in`, `refresh_token_expires_in`, `endpoint_url`, `context_path`, `status`, `description`, `create_time`, `update_time`, `version`, `delete_flag`)
VALUES
    (207, 201, '综合管理平台', 'g2rain-main-shell',  1, 1, 'SUPPORT', 'EC', 'PEM', '-----BEGIN PUBLIC KEY-----\nMFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEXmlg1y2fUD9KJj4WB6DrRZU+iVwA yzz60AxRoFb2yDnBvYiiK9JR1p5QUw2jkR9RPvkZez1Kx2BqxwyOoWRV/A==\n-----END PUBLIC KEY-----\n', 3600, 86400, 'http://demo.g2rain.com', '/main',    'PUBLISHED', '管理平台入口', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (208, 201, '业务支撑平台', 'g2rain-manager-app',  0, 1, 'SUPPORT', 'EC', 'PEM', '-----BEGIN PUBLIC KEY-----\nMFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEXGDOn5B+GFE42lcMd5u47r6na9iE H1AzxAU49KiWBz17su0M1vPZ+s57bvMlYvbcPG2nfWcJvJzRuKUakrUhsA==\n-----END PUBLIC KEY-----\n', 3600, 86400, 'http://demo.g2rain.com', '/manager',    'PUBLISHED', '业务支撑平台', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (209, 201, '基础支撑平台', 'g2rain-infra-app', 0, 1, 'SUPPORT', 'EC', 'PEM', '-----BEGIN PUBLIC KEY-----\nMFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEAcmLmXDroj3aJiTFxP6oy5Q+3Tawz1LFg0BY1a5CRNynqpVvG+/wVGUhXf7KOJ7/nA2OO/H+IQaHryS+SXtnOA==\n-----END PUBLIC KEY-----\n', 3600, 86400, 'http://demo.g2rain.com', '/infra', 'PUBLISHED', '用于管理字典, 国际化, 发号器功能', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0);

-- 应用归类关系
INSERT INTO `application_suite`
(`id`, `application_id`, `master_application_id`, `create_time`, `update_time`, `version`, `delete_flag`)
VALUES
    (210, 208, 207, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (211, 209, 207, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0);

-- 控制单元
INSERT INTO `control_unit`
(`id`, `application_id`, `control_unit_name`, `control_unit_scope`, `landing`, `status`, `description`, `create_time`, `update_time`, `version`, `delete_flag`)
VALUES
    (212, 207, '盘古',   'PERPETUAL', 1, 'PUBLISHED', '平台准入基础能力', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (213, 208, '燧人氏', 'OPERATION', 1, 'PUBLISHED', '核心运营支撑组件', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (215, 208, '女娲',   'CUSTOMER',  1, 'PUBLISHED', '租户空间构建逻辑', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (216, 209, '后羿',   'OPERATION',  1, 'PUBLISHED', '保障平台技术能力', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0);

-- 角色控制单元关联
INSERT INTO `role_control_unit_relation`
(`id`, `role_id`, `control_unit_id`, `application_authorization_id`, `status`, `create_time`, `update_time`, `version`, `delete_flag`)
VALUES
    (217, 203, 213, NULL, 'ACTIVATED', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (218, 203, 216, NULL, 'ACTIVATED', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0);

-- 服务注册表
INSERT INTO `service_registry`
(`id`, `service_code`, `name`, `endpoint`, `route_prefix`, `description`, `create_time`, `update_time`, `version`, `delete_flag`)
VALUES
    (219, 'G2RAIN_BASIS', '业务支撑服务', 'lb://g2rain-basis', 'basis', '业务支撑服务', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (220, 'G2RAIN_INFRA', '基础支撑服务', 'lb://g2rain-infra', 'infra', '基础支撑服务', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0);

-- 资源后端接口
INSERT INTO `resource_api`
(`id`, `service_code`, `api_tags`, `name`, `method`, `path`, `description`, `create_time`, `update_time`, `version`, `delete_flag`)
VALUES
    (223,'G2RAIN_INFRA','地域语言','新增或更新地域语言设置','POST','/locale_setting/save','新增或更新地域与语言偏好配置','2026-05-08 10:02:08','2026-05-08 10:02:08',0,0),
    (225,'G2RAIN_INFRA','国际化信息','新增或更新国际化信息','POST','/i18n_message/save','新增或更新国际化文案信息','2026-05-08 10:02:08','2026-05-08 10:02:08',0,0),
    (226,'G2RAIN_INFRA','全局唯一序列','新增或更新全局唯一 ID 记录','POST','/g2rain_raindrop/save','新增或更新全局唯一 ID 管理表数据','2026-05-08 10:02:08','2026-05-08 10:02:08',0,0),
    (227,'G2RAIN_INFRA','字典用途','新增或更新字典用途','POST','/dictionary_usage/save','新增或更新字典用途信息','2026-05-08 10:02:08','2026-05-08 10:02:08',0,0),
    (228,'G2RAIN_INFRA','字典明细','新增或更新字典明细','POST','/dictionary_item/save','新增或更新字典明细信息','2026-05-08 10:02:08','2026-05-08 10:02:08',0,0),
    (231,'G2RAIN_INFRA','地域语言','分页查询地域语言设置列表','GET','/locale_setting/page','分页查询地域-语言设置列表','2026-05-08 10:02:08','2026-05-08 10:02:08',0,0),
    (232,'G2RAIN_INFRA','地域语言','获取地域语言字典','GET','/locale_setting/locale_dict','获取地域语言字典','2026-05-08 10:02:08','2026-05-08 10:02:08',0,0),
    (233,'G2RAIN_INFRA','地域语言','查询地域语言设置列表','GET','/locale_setting/list','根据查询条件返回地域-语言设置列表','2026-05-08 10:02:08','2026-05-08 10:02:08',0,0),
    (235,'G2RAIN_INFRA','地域语言','获取语言地域映射','GET','/locale_setting/get_language_countries','获取语言地域映射','2026-05-08 10:02:08','2026-05-08 10:02:08',0,0),
    (236,'G2RAIN_INFRA','地域语言','获取地域语言编码和名称映射集合','GET','/locale_setting/code_name_map','获取地域语言编码和名称映射集合','2026-05-08 10:02:08','2026-05-08 10:02:08',0,0),
    (237,'G2RAIN_INFRA','国际化信息','分页查询国际化信息列表','GET','/i18n_message/page','分页查询国际化信息列表','2026-05-08 10:02:08','2026-05-08 10:02:08',0,0),
    (238,'G2RAIN_INFRA','国际化信息','查询国际化信息列表','GET','/i18n_message/list','根据查询条件返回国际化信息列表','2026-05-08 10:02:08','2026-05-08 10:02:08',0,0),
    (239,'G2RAIN_INFRA','国际化信息','获取国际化用途集合','GET','/i18n_message/i18n_message_usages','获取国际化用途集合','2026-05-08 10:02:08','2026-05-08 10:02:08',0,0),
    (260,'G2RAIN_INFRA','全局唯一序列','分页查询全局唯一 ID 记录列表','GET','/g2rain_raindrop/page','分页查询全局唯一 ID 管理记录列表','2026-05-08 10:02:08','2026-05-08 10:02:08',0,0),
    (261,'G2RAIN_INFRA','全局唯一序列','查询全局唯一 ID 记录列表','GET','/g2rain_raindrop/list','根据查询条件返回全局唯一 ID 管理记录列表','2026-05-08 10:02:08','2026-05-08 10:02:08',0,0),
    (262,'G2RAIN_INFRA','全局唯一序列','查询业务标签字典集合','GET','/g2rain_raindrop/biz_tag_dict','查询业务标签字典集合','2026-05-08 10:02:08','2026-05-08 10:02:08',0,0),
    (263,'G2RAIN_INFRA','字典用途','分页查询字典用途列表','GET','/dictionary_usage/page','分页查询字典用途列表','2026-05-08 10:02:08','2026-05-08 10:02:08',0,0),
    (265,'G2RAIN_INFRA','字典用途','查询字典用途列表','GET','/dictionary_usage/list','根据查询条件返回字典用途列表','2026-05-08 10:02:08','2026-05-08 10:02:08',0,0),
    (266,'G2RAIN_INFRA','字典明细','分页查询字典明细列表','GET','/dictionary_item/tree','分页查询字典明细列表','2026-05-08 10:02:08','2026-05-08 10:02:08',0,0),
    (267,'G2RAIN_INFRA','字典明细','分页查询字典明细列表','GET','/dictionary_item/page','分页查询字典明细列表','2026-05-08 10:02:08','2026-05-08 10:02:08',0,0),
    (268,'G2RAIN_INFRA','字典明细','查询字典明细列表','GET','/dictionary_item/list','根据查询条件返回字典明细列表','2026-05-08 10:02:08','2026-05-08 10:02:08',0,0),
    (270,'G2RAIN_INFRA','地域语言','删除地域语言设置记录','DELETE','/locale_setting/{id}','根据主键删除地域-语言设置记录','2026-05-08 10:02:08','2026-05-08 10:02:08',0,0),
    (271,'G2RAIN_INFRA','国际化信息','删除国际化信息记录','DELETE','/i18n_message/{id}','根据主键删除国际化信息记录','2026-05-08 10:02:08','2026-05-08 10:02:08',0,0),
    (272,'G2RAIN_INFRA','全局唯一序列','删除全局唯一 ID 记录','DELETE','/g2rain_raindrop/{id}','根据主键删除全局唯一 ID 管理记录','2026-05-08 10:02:08','2026-05-08 10:02:08',0,0),
    (273,'G2RAIN_INFRA','字典用途','删除字典用途记录','DELETE','/dictionary_usage/{id}','根据主键删除字典用途记录','2026-05-08 10:02:08','2026-05-08 10:02:08',0,0),
    (275,'G2RAIN_INFRA','字典明细','删除字典明细记录','DELETE','/dictionary_item/{id}','根据主键删除字典明细记录','2026-05-08 10:02:08','2026-05-08 10:02:08',0,0),
    (276,'G2RAIN_BASIS','用户-角色关联','新增或更新用户角色关联','POST','/user_role_relation/save','新增或更新用户角色关联记录','2026-05-08 10:03:52','2026-05-08 10:03:52',0,0),
    (277,'G2RAIN_BASIS','用户-角色关联','为角色分配用户','POST','/user_role_relation/assign_users','批量为指定角色分配用户关联关系','2026-05-08 10:03:52','2026-05-08 10:03:52',0,0),
    (278,'G2RAIN_BASIS','用户','新增或更新用户信息','POST','/user/save','新增或更新用户基础信息','2026-05-08 10:03:52','2026-05-08 10:03:52',0,0),
    (279,'G2RAIN_BASIS','租户初始化','开通租户账号','POST','/tenant_provision/provision_account','为指定租户开通账号并初始化最小可用功能','2026-05-08 10:03:52','2026-05-08 10:03:52',0,0),
    (280,'G2RAIN_BASIS','服务注册','新增或更新服务注册','POST','/service_registry/save','新增或更新服务注册信息','2026-05-08 10:03:52','2026-05-08 10:03:52',0,0),
    (281,'G2RAIN_BASIS','角色-控制单元关联','新增角色控制单元关联','POST','/role_control_unit_relation/save','新增角色与控制单元的关联记录','2026-05-08 10:03:52','2026-05-08 10:03:52',0,0),
    (282,'G2RAIN_BASIS','角色','新增或更新角色信息','POST','/role/save','新增或更新角色基础信息','2026-05-08 10:03:52','2026-05-08 10:03:52',0,0),
    (283,'G2RAIN_BASIS','资源页面元素','新增或更新页面元素','POST','/resource_page_element/save','新增或更新应用资源页面元素信息','2026-05-08 10:03:52','2026-05-08 10:03:52',0,0),
    (285,'G2RAIN_BASIS','资源页面','新增或更新资源页面','POST','/resource_page/save','新增或更新应用资源页面信息','2026-05-08 10:03:52','2026-05-08 10:03:52',0,0),
    (286,'G2RAIN_BASIS','资源菜单','新增或更新资源菜单','POST','/resource_menu/save','新增或更新应用资源菜单信息','2026-05-08 10:03:52','2026-05-08 10:03:52',0,0),
    (287,'G2RAIN_BASIS','资源上传','上传应用资源文件','POST','/resource/{applicationId}/upload','上传并解析指定应用的资源文件内容','2026-05-08 10:03:52','2026-05-08 10:03:52',0,0),
    (288,'G2RAIN_BASIS','账号','更新账号状态','POST','/passport/{id}/status','根据主键更新账号启用状态','2026-05-08 10:03:52','2026-05-08 10:03:52',0,0),
    (289,'G2RAIN_BASIS','账号','更新账号密码','POST','/passport/{id}/password','根据主键更新账号登录密码','2026-05-08 10:03:52','2026-05-08 10:03:52',0,0),
    (290,'G2RAIN_BASIS','账号','新增或更新账号','POST','/passport/save','新增或更新账号信息','2026-05-08 10:03:52','2026-05-08 10:03:52',0,0),
    (291,'G2RAIN_BASIS','机构','更新机构状态','POST','/organ/{id}/status','根据主键更新机构启用状态','2026-05-08 10:03:52','2026-05-08 10:03:52',0,0),
    (292,'G2RAIN_BASIS','机构','调整机构层级关系','POST','/organ/{descendantId}/hierarchy','对指定机构执行挂载、迁移或卸载等层级调整操作','2026-05-08 10:03:52','2026-05-08 10:03:52',0,0),
    (293,'G2RAIN_BASIS','机构','新增或更新机构信息','POST','/organ/save','新增或更新机构基础信息','2026-05-08 10:03:52','2026-05-08 10:03:52',0,0),
    (295,'G2RAIN_BASIS','权限点资源关联','新增控制单元资源关联','POST','/control_unit_resource_relation/save','批量新增控制单元与资源关联记录','2026-05-08 10:03:52','2026-05-08 10:03:52',0,0),
    (296,'G2RAIN_BASIS','控制单元','更新控制单元状态','POST','/control_unit/{id}/status','根据主键更新控制单元启用状态','2026-05-08 10:03:52','2026-05-08 10:03:52',0,0),
    (297,'G2RAIN_BASIS','控制单元','新增或更新控制单元','POST','/control_unit/save','新增或更新控制单元基础信息','2026-05-08 10:03:52','2026-05-08 10:03:52',0,0),
    (298,'G2RAIN_BASIS','控制域-控制单元关联','新增控制域控制单元关联','POST','/control_domain_control_unit_relation/save','批量新增控制域与控制单元关联记录','2026-05-08 10:03:52','2026-05-08 10:03:52',0,0),
    (299,'G2RAIN_BASIS','控制域','新增或更新控制域信息','POST','/control_domain/save','新增或更新控制域基础信息','2026-05-08 10:03:52','2026-05-08 10:03:52',0,0),
    (300,'G2RAIN_BASIS','应用归类关系','新增或更新应用归类关系','POST','/application_suite/save','新增或更新应用与归类的关联关系','2026-05-08 10:03:52','2026-05-08 10:03:52',0,0),
    (301,'G2RAIN_BASIS','应用授权','修改应用授权记录状态','POST','/application_authorization/{id}/status','修改应用授权记录状态','2026-05-08 10:03:52','2026-05-08 10:03:52',0,0),
    (302,'G2RAIN_BASIS','应用授权','新增或更新应用授权记录','POST','/application_authorization/save','新增或更新应用授权记录','2026-05-08 10:03:52','2026-05-08 10:03:52',0,0),
    (303,'G2RAIN_BASIS','应用','更新应用状态','POST','/application/{id}/status','根据主键更新应用启用状态','2026-05-08 10:03:52','2026-05-08 10:03:52',0,0),
    (305,'G2RAIN_BASIS','应用','下载应用公钥','GET','/application/{id}/public_key','下载指定应用的 PEM 或 DER 格式公钥文件','2026-05-08 10:03:52','2026-05-08 10:03:52',0,0),
    (306,'G2RAIN_BASIS','应用','上传或更新应用公钥','POST','/application/{id}/public_key','上传 PEM/DER 公钥文件并更新应用公钥配置','2026-05-08 10:03:52','2026-05-08 10:03:52',0,0),
    (307,'G2RAIN_BASIS','应用','新增或更新应用信息','POST','/application/save','新增或更新应用基础信息','2026-05-08 10:03:52','2026-05-08 10:03:52',0,0),
    (308,'G2RAIN_BASIS','用户-角色关联','分页查询用户-角色关联列表','GET','/user_role_relation/page','分页查询用户角色关联列表','2026-05-08 10:03:52','2026-05-08 10:03:52',0,0),
    (309,'G2RAIN_BASIS','用户-角色关联','查询用户-角色关联列表','GET','/user_role_relation/list','根据查询条件返回用户角色关联列表','2026-05-08 10:03:52','2026-05-08 10:03:52',0,0),
    (310,'G2RAIN_BASIS','用户','获取用户下拉选项','GET','/user/user_options','返回用于下拉选择的用户简要信息集合','2026-05-08 10:03:52','2026-05-08 10:03:52',0,0),
    (311,'G2RAIN_BASIS','用户','按角色查询用户列表','GET','/user/role/{roleId}','根据角色主键查询已关联用户列表','2026-05-08 10:03:52','2026-05-08 10:03:52',0,0),
    (312,'G2RAIN_BASIS','用户','分页查询用户列表','GET','/user/page','分页查询用户列表','2026-05-08 10:03:52','2026-05-08 10:03:52',0,0),
    (313,'G2RAIN_BASIS','用户','查询用户列表','GET','/user/list','根据查询条件返回用户列表','2026-05-08 10:03:52','2026-05-08 10:03:52',0,0),
    (315,'G2RAIN_BASIS','服务注册','分页查询服务注册列表','GET','/service_registry/page','分页查询服务注册列表','2026-05-08 10:03:52','2026-05-08 10:03:52',0,0),
    (316,'G2RAIN_BASIS','服务注册','查询服务注册列表','GET','/service_registry/list','根据查询条件返回服务注册列表','2026-05-08 10:03:52','2026-05-08 10:03:52',0,0),
    (317,'G2RAIN_BASIS','角色-控制单元关联','按角色查询控制单元关联','GET','/role_control_unit_relation/role/{roleId}','根据角色主键查询角色控制单元关联列表','2026-05-08 10:03:52','2026-05-08 10:03:52',0,0),
    (318,'G2RAIN_BASIS','角色-控制单元关联','分页查询角色-控制单元关联列表','GET','/role_control_unit_relation/page','分页查询角色控制单元关联列表','2026-05-08 10:03:52','2026-05-08 10:03:52',0,0),
    (319,'G2RAIN_BASIS','角色-控制单元关联','查询角色-控制单元关联列表','GET','/role_control_unit_relation/list','根据查询条件返回角色控制单元关联列表','2026-05-08 10:03:52','2026-05-08 10:03:52',0,0),
    (320,'G2RAIN_BASIS','角色','分页查询角色列表','GET','/role/page','分页查询角色列表','2026-05-08 10:03:52','2026-05-08 10:03:52',0,0),
    (321,'G2RAIN_BASIS','角色','查询角色列表','GET','/role/list','根据查询条件返回角色列表','2026-05-08 10:03:52','2026-05-08 10:03:52',0,0),
    (322,'G2RAIN_BASIS','资源页面元素','分页查询资源页面元素列表','GET','/resource_page_element/page','分页查询资源页面元素列表','2026-05-08 10:03:52','2026-05-08 10:03:52',0,0),
    (323,'G2RAIN_BASIS','资源页面元素','查询资源页面元素列表','GET','/resource_page_element/list','根据查询条件返回资源页面元素列表','2026-05-08 10:03:52','2026-05-08 10:03:52',0,0),
    (325,'G2RAIN_BASIS','资源页面','分页查询资源页面列表','GET','/resource_page/page','分页查询资源页面列表','2026-05-08 10:03:52','2026-05-08 10:03:52',0,0),
    (326,'G2RAIN_BASIS','资源页面','查询资源页面列表','GET','/resource_page/list','根据查询条件返回资源页面列表','2026-05-08 10:03:52','2026-05-08 10:03:52',0,0),
    (327,'G2RAIN_BASIS','资源菜单','分页查询资源菜单列表','GET','/resource_menu/page','分页查询资源菜单列表','2026-05-08 10:03:52','2026-05-08 10:03:52',0,0),
    (328,'G2RAIN_BASIS','资源菜单','查询资源菜单列表','GET','/resource_menu/list','根据查询条件返回资源菜单列表','2026-05-08 10:03:52','2026-05-08 10:03:52',0,0),
    (329,'G2RAIN_BASIS','资源接口','分页查询资源接口列表','GET','/resource_api/page','分页查询资源接口列表','2026-05-08 10:03:52','2026-05-08 10:03:52',0,0),
    (330,'G2RAIN_BASIS','资源接口','查询资源接口列表','GET','/resource_api/list','根据查询条件返回资源接口列表','2026-05-08 10:03:52','2026-05-08 10:03:52',0,0),
    (331,'G2RAIN_BASIS','账号','分页查询账号列表','GET','/passport/page','分页查询账号列表','2026-05-08 10:03:52','2026-05-08 10:03:52',0,0),
    (332,'G2RAIN_BASIS','账号','查询账号列表','GET','/passport/list','根据查询条件返回账号列表','2026-05-08 10:03:52','2026-05-08 10:03:52',0,0),
    (333,'G2RAIN_BASIS','机构','搜索机构','GET','/organ/search','根据机构名称关键字模糊查询机构列表','2026-05-08 10:03:52','2026-05-08 10:03:52',0,0),
    (335,'G2RAIN_BASIS','机构','分页查询机构列表','GET','/organ/page','分页查询机构列表','2026-05-08 10:03:52','2026-05-08 10:03:52',0,0),
    (336,'G2RAIN_BASIS','机构','查询机构列表','GET','/organ/list','根据查询条件返回机构列表','2026-05-08 10:03:52','2026-05-08 10:03:52',0,0),
    (337,'G2RAIN_BASIS','机构','获取机构层级关系','GET','/organ/hierarchy','查询机构及其子机构的树形层级结构','2026-05-08 10:03:52','2026-05-08 10:03:52',0,0),
    (338,'G2RAIN_BASIS','登录令牌','分页查询登录令牌列表','GET','/login_token/page','分页查询登录令牌列表','2026-05-08 10:03:52','2026-05-08 10:03:52',0,0),
    (339,'G2RAIN_BASIS','登录令牌','查询登录令牌列表','GET','/login_token/list','根据查询条件返回登录令牌列表','2026-05-08 10:03:52','2026-05-08 10:03:52',0,0),
    (350,'G2RAIN_BASIS','权限点资源关联','分页查询权限点资源关联列表','GET','/control_unit_resource_relation/page','分页查询权限点资源关联列表','2026-05-08 10:03:52','2026-05-08 10:03:52',0,0),
    (351,'G2RAIN_BASIS','权限点资源关联','查询权限点资源关联列表','GET','/control_unit_resource_relation/list','根据查询条件返回权限点资源关联列表','2026-05-08 10:03:52','2026-05-08 10:03:52',0,0),
    (352,'G2RAIN_BASIS','控制单元','分页查询控制单元列表','GET','/control_unit/page','分页查询控制单元列表','2026-05-08 10:03:52','2026-05-08 10:03:52',0,0),
    (353,'G2RAIN_BASIS','控制单元','查询控制单元列表','GET','/control_unit/list','根据查询条件返回控制单元列表','2026-05-08 10:03:52','2026-05-08 10:03:52',0,0),
    (355,'G2RAIN_BASIS','控制域-控制单元关联','分页查询控制域-控制单元关联列表','GET','/control_domain_control_unit_relation/page','分页查询控制域控制单元关联列表','2026-05-08 10:03:52','2026-05-08 10:03:52',0,0),
    (356,'G2RAIN_BASIS','控制域-控制单元关联','查询控制域-控制单元关联列表','GET','/control_domain_control_unit_relation/list','根据查询条件返回控制域控制单元关联列表','2026-05-08 10:03:52','2026-05-08 10:03:52',0,0),
    (357,'G2RAIN_BASIS','控制域','分页查询控制域列表','GET','/control_domain/page','分页查询控制域列表','2026-05-08 10:03:52','2026-05-08 10:03:52',0,0),
    (358,'G2RAIN_BASIS','控制域','查询控制域列表','GET','/control_domain/list','根据查询条件返回控制域列表','2026-05-08 10:03:52','2026-05-08 10:03:52',0,0),
    (359,'G2RAIN_BASIS','资源授权','查询当前用户信息','GET','/authority/user','查询当前登录用户的权限相关用户信息','2026-05-08 10:03:52','2026-05-08 10:03:52',0,0),
    (360,'G2RAIN_BASIS','资源授权','查询资源权限信息','GET','/authority/resources','查询当前用户的资源访问权限信息','2026-05-08 10:03:52','2026-05-08 10:03:52',0,0),
    (361,'G2RAIN_BASIS','资源授权','查询菜单权限列表','GET','/authority/menus','查询当前用户可访问的菜单权限列表','2026-05-08 10:03:52','2026-05-08 10:03:52',0,0),
    (362,'G2RAIN_BASIS','审计事件','分页查询审计事件','GET','/audit_event/page','按条件筛选审计事件并分页，含总数与当前页数据','2026-05-08 10:03:52','2026-05-08 10:03:52',0,0),
    (363,'G2RAIN_BASIS','审计事件','查询审计事件列表','GET','/audit_event/list','按条件筛选审计事件，不分页返回列表','2026-05-08 10:03:52','2026-05-08 10:03:52',0,0),
    (365,'G2RAIN_BASIS','应用归类关系','分页查询应用归类关系列表','GET','/application_suite/page','分页查询应用归类关系列表','2026-05-08 10:03:52','2026-05-08 10:03:52',0,0),
    (366,'G2RAIN_BASIS','应用归类关系','查询应用归类关系列表','GET','/application_suite/list','根据查询条件返回应用归类关系列表','2026-05-08 10:03:52','2026-05-08 10:03:52',0,0),
    (367,'G2RAIN_BASIS','应用授权','分页查询应用授权记录列表','GET','/application_authorization/page','分页查询应用授权记录列表','2026-05-08 10:03:52','2026-05-08 10:03:52',0,0),
    (368,'G2RAIN_BASIS','应用授权','查询应用授权记录列表','GET','/application_authorization/list','根据查询条件返回应用授权记录列表','2026-05-08 10:03:52','2026-05-08 10:03:52',0,0),
    (369,'G2RAIN_BASIS','应用','检查应用公钥是否存在','GET','/application/{id}/has_public_key','检查指定应用是否已配置公钥','2026-05-08 10:03:52','2026-05-08 10:03:52',0,0),
    (370,'G2RAIN_BASIS','应用','分页查询应用列表','GET','/application/page','分页查询应用列表','2026-05-08 10:03:52','2026-05-08 10:03:52',0,0),
    (371,'G2RAIN_BASIS','应用','查询应用列表','GET','/application/list','根据查询条件返回应用列表','2026-05-08 10:03:52','2026-05-08 10:03:52',0,0),
    (372,'G2RAIN_BASIS','应用','查询应用名称映射','GET','/application/id_name_map','根据查询条件获取应用 ID 与名称映射列表','2026-05-08 10:03:52','2026-05-08 10:03:52',0,0),
    (373,'G2RAIN_BASIS','用户','删除用户记录','DELETE','/user/{id}','根据主键删除用户记录','2026-05-08 10:03:52','2026-05-08 10:03:52',0,0),
    (375,'G2RAIN_BASIS','服务注册','删除服务注册','DELETE','/service_registry/{id}','根据主键删除服务注册记录','2026-05-08 10:03:52','2026-05-08 10:03:52',0,0),
    (376,'G2RAIN_BASIS','角色','删除角色记录','DELETE','/role/{id}','根据主键删除角色记录','2026-05-08 10:03:52','2026-05-08 10:03:52',0,0),
    (377,'G2RAIN_BASIS','资源页面元素','删除页面元素记录','DELETE','/resource_page_element/{id}','根据主键删除应用资源页面元素记录','2026-05-08 10:03:52','2026-05-08 10:03:52',0,0),
    (378,'G2RAIN_BASIS','资源页面','删除资源页面记录','DELETE','/resource_page/{id}','根据主键删除应用资源页面记录','2026-05-08 10:03:52','2026-05-08 10:03:52',0,0),
    (379,'G2RAIN_BASIS','资源菜单','删除资源菜单记录','DELETE','/resource_menu/{id}','根据主键删除应用资源菜单记录','2026-05-08 10:03:52','2026-05-08 10:03:52',0,0),
    (380,'G2RAIN_BASIS','资源接口','根据主键删除资源接口记录','DELETE','/resource_api/{id}','根据主键删除资源接口记录','2026-05-08 10:03:52','2026-05-08 10:03:52',0,0),
    (381,'G2RAIN_BASIS','账号','删除账号记录','DELETE','/passport/{id}','根据主键删除账号记录','2026-05-08 10:03:52','2026-05-08 10:03:52',0,0),
    (382,'G2RAIN_BASIS','机构','删除机构记录','DELETE','/organ/{id}','根据主键删除机构记录','2026-05-08 10:03:52','2026-05-08 10:03:52',0,0),
    (383,'G2RAIN_BASIS','控制单元','删除控制单元记录','DELETE','/control_unit/{id}','根据主键删除控制单元记录','2026-05-08 10:03:52','2026-05-08 10:03:52',0,0),
    (385,'G2RAIN_BASIS','控制域','删除控制域记录','DELETE','/control_domain/{id}','根据主键删除控制域记录','2026-05-08 10:03:52','2026-05-08 10:03:52',0,0),
    (386,'G2RAIN_BASIS','应用授权','根据主键删除应用授权记录','DELETE','/application_authorization/{id}','根据主键删除应用授权记录','2026-05-08 10:03:52','2026-05-08 10:03:52',0,0),
    (387,'G2RAIN_BASIS','应用','删除应用记录','DELETE','/application/{id}','根据主键删除应用记录','2026-05-08 10:03:52','2026-05-08 10:03:52',0,0),
    (388,'G2RAIN_BASIS','资源接口','批量导入资源接口','POST','/resource_api/{serviceCode}/import','批量导入资源接口信息','2026-04-28 02:14:24','2026-04-28 02:14:24',0,0),
    (389,'G2RAIN_BASIS','资源接口','新增或更新资源接口','POST','/resource_api/save','新增或更新资源接口信息','2026-04-28 02:14:24','2026-04-28 02:14:24',0,0);

-- 应用资源菜单
INSERT INTO `resource_menu`
(`id`, `parent_id`, `application_id`, `menu_name`, `menu_code`, `link_path`, `icon`, `menu_sort_order`, `create_time`, `update_time`, `version`, `delete_flag`)
VALUES
    (390,NULL,208,'系统管理','system_management_menu','','',10000,'2026-02-01 01:12:28','2026-04-19 08:02:38',1,0),
    (391,390,208,'机构管理','organ_management_menu','/organ','',1,'2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),
    (392,390,208,'用户管理','user_management_menu','/user','',2,'2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),
    (393,390,208,'角色管理','role_management_menu','/role','',3,'2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),
    (395,NULL,208,'应用管理','application_management_menu','','',10001,'2026-02-01 01:12:28','2026-04-19 08:02:44',1,0),
    (396,395,208,'应用配置','application_config_menu','/application','',1,'2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),
    (397,395,208,'资源配置','resource_settings_menu','/resource_settings','',2,'2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),
    (398,395,208,'资源菜单','resource_menu_menu','/resource_menu','',3,'2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),
    (399,395,208,'资源页面','resource_page_menu','/resource_page','',5,'2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),
    (500,395,208,'功能权限','control_unit_menu','/control_unit','',6,'2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),
    (501,395,208,'业务能力','control_domain_menu','/control_domain','',7,'2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),
    (502,395,208,'授权记录','application_authorization_menu','/application_authorization','',8,'2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),
    (503,NULL,208,'平台配置','platform_settings_menu','','',10002,'2026-02-01 01:12:28','2026-04-19 08:02:50',1,0),
    (505,503,208,'服务注册','service_registry_menu','/service_registry','',1,'2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),
    (506,503,208,'服务接口','resource_api_menu','/resource_api','',2,'2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),
    (507,NULL,208,'平台运营','platform_operations_menu','','',10003,'2026-02-01 01:12:28','2026-04-19 08:02:56',1,0),
    (508,507,208,'账号管理','passport_management_menu','/passport','',1,'2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),
    (509,507,208,'登陆日志','login_token_menu','/login_token','',1,'2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),
    (510,507,208,'审计事件','audit_event_menu','/audit_event','',1,'2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),
    (511,NULL,209,'平台技术','infra_menu','','',10004,'2026-04-11 04:06:57','2026-04-19 08:03:01',2,0),
    (512,511,209,'序列号段调控','g2rain_raindrop_menu','/g2rain_raindrop','',1,'2026-04-11 04:15:29','2026-04-11 04:15:29',0,0),
    (513,511,209,'字典用途设置','dictionary_usage_menu','/dictionary_usage','',2,'2026-04-11 04:10:42','2026-04-11 04:12:57',3,0),
    (515,511,209,'地区语言设置','locale_setting_menu','/locale_setting','',3,'2026-04-11 04:15:06','2026-04-11 04:15:06',0,0),
    (516,511,209,'多语言文案库','i18n_message_menu','/i18n_message','',5,'2026-04-11 04:13:38','2026-04-11 04:14:39',1,0);

-- 应用资源页面
INSERT INTO `resource_page`
(`id`, `application_id`, `page_name`, `page_code`, `link_path`, `create_time`, `update_time`, `version`, `delete_flag`)
VALUES
    (517,208,'机构管理界面','organ','/organ','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),
    (518,208,'用户管理界面','user','/user','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),
    (519,208,'角色管理界面','role','/role','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),
    (520,208,'应用配置界面','application','/application','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),
    (521,208,'资源配置界面','resource_settings','/resource_settings','2026-02-01 01:12:28','2026-05-05 13:08:53',0,0),
    (522,208,'资源菜单界面','resource_menu','/resource_menu','2026-02-01 01:12:28','2026-05-05 13:08:53',0,0),
    (523,208,'资源页面界面','resource_page','/resource_page','2026-02-01 01:12:28','2026-05-05 13:08:53',0,0),
    (525,208,'功能权限界面','control_unit','/control_unit','2026-02-01 01:12:28','2026-05-05 13:08:53',0,0),
    (526,208,'业务能力界面','control_domain','/control_domain','2026-02-01 01:12:28','2026-05-05 13:08:53',0,0),
    (527,208,'授权记录界面','application_authorization','/application_authorization','2026-02-01 01:12:28','2026-05-05 13:08:53',0,0),
    (528,208,'服务注册界面','service_registry','/service_registry','2026-02-01 01:12:28','2026-05-05 13:08:53',0,0),
    (529,208,'服务接口界面','resource_api','/resource_api','2026-02-01 01:12:28','2026-05-05 13:08:53',0,0),
    (530,208,'账号管理界面','passport','/passport','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),
    (531,208,'登陆日志界面','login_token','/login_token','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),
    (532,208,'审计事件界面','audit_event','/audit_event','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),
    (533,209,'序列号段调控','g2rain_raindrop','/g2rain_raindrop','2026-04-11 07:23:17','2026-04-11 07:23:17',0,0),
    (535,209,'字典用途设置','dictionary_usage','/dictionary_usage','2026-04-11 07:22:01','2026-04-11 07:22:01',0,0),
    (536,209,'地区语言设置','locale_setting','/locale_setting','2026-04-11 07:23:02','2026-04-11 07:23:02',0,0),
    (537,209,'多语言文案库','i18n_message','/i18n_message','2026-04-11 07:22:16','2026-04-11 07:22:31',1,0);

-- 应用页面元素
INSERT INTO `resource_page_element`
(`id`, `application_id`, `page_code`, `page_element_name`, `page_element_code`, `create_time`, `update_time`, `version`, `delete_flag`)
VALUES
    (538,208,'organ','新增按钮','organ:add','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),
    (539,208,'organ','修改按钮','organ:edit','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),
    (550,208,'organ','调整归属','organ:reassign','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),
    (551,208,'organ','修改状态','organ:status_update','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),
    (552,208,'organ','删除按钮','organ:delete','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),
    (553,208,'user','新增按钮','user:add','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),
    (555,208,'user','修改按钮','user:edit','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),
    (556,208,'user','删除按钮','user:delete','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),
    (557,208,'role','新增按钮','role:add','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),
    (558,208,'role','修改按钮','role:edit','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),
    (559,208,'role','分配用户','role:users_assign','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),
    (560,208,'role','分配权限','role:control_utils_assign','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),
    (561,208,'role','删除按钮','role:delete','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),
    (562,208,'application','新增按钮','application:add','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),
    (563,208,'application','修改按钮','application:edit','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),
    (565,208,'application','关联应用','application:integrate','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),
    (566,208,'application','公钥配置','application:public_key_config','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),
    (567,208,'application','修改状态','application:status_update','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),
    (568,208,'application','删除按钮','application:delete','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),
    (569,208,'resource_settings','导入按钮','resource_settings:upload','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),
    (570,208,'resource_menu','新增按钮','resource_menu:add','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),
    (571,208,'resource_menu','修改按钮','resource_menu:edit','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),
    (572,208,'resource_menu','删除按钮','resource_menu:delete','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),
    (573,208,'resource_page','新增按钮','resource_page:add','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),
    (575,208,'resource_page','修改按钮','resource_page:edit','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),
    (576,208,'resource_page','页面元素','resource_page:page_element_mgmt','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),
    (577,208,'resource_page','删除按钮','resource_page:delete','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),
    (578,208,'control_unit','新增按钮','control_unit:add','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),
    (579,208,'control_unit','修改按钮','control_unit:edit','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),
    (580,208,'control_unit','配置资源','control_unit:resources_config','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),
    (581,208,'control_unit','修改状态','control_unit:status_update','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),
    (582,208,'control_unit','删除按钮','control_unit:delete','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),
    (583,208,'control_domain','新增按钮','control_domain:add','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),
    (585,208,'control_domain','修改按钮','control_domain:edit','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),
    (586,208,'control_domain','关联权限','control_domain:control_utils_associate','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),
    (587,208,'control_domain','开通功能','control_domain:features_activate','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),
    (588,208,'control_domain','删除按钮','control_domain:delete','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),
    (589,208,'application_authorization','修改状态','application_authorization:status_update','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),
    (590,208,'application_authorization','同步能力','application_authorization:control_utils_sync','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),
    (591,208,'service_registry','新增按钮','service_registry:add','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),
    (592,208,'service_registry','修改按钮','service_registry:edit','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),
    (593,208,'service_registry','删除按钮','service_registry:delete','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),
    (595,208,'resource_api','新增按钮','resource_api:add','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),
    (596,208,'resource_api','修改按钮','resource_api:edit','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),
    (597,208,'resource_api','导入按钮','resource_api:import','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),
    (598,208,'resource_api','删除按钮','resource_api:delete','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),
    (599,208,'passport','新增按钮','passport:add','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),
    (600,208,'passport','修改按钮','passport:edit','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),
    (601,208,'passport','修改状态','passport:status_update','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),
    (602,208,'passport','删除按钮','passport:delete','2026-02-01 01:12:28','2026-02-01 01:12:28',0,0),
    (603,209,'g2rain_raindrop','新增按钮','g2rain_raindrop:add','2026-04-11 14:20:20','2026-04-11 14:20:20',0,0),
    (605,209,'g2rain_raindrop','编辑按钮','g2rain_raindrop:edit','2026-04-11 14:20:20','2026-04-11 14:20:20',0,0),
    (606,209,'g2rain_raindrop','删除按钮','g2rain_raindrop:delete','2026-04-11 14:20:20','2026-04-11 14:20:20',0,0),
    (607,209,'dictionary_usage','新增按钮','dictionary_usage:add','2026-04-11 14:20:20','2026-04-11 14:20:20',0,0),
    (608,209,'dictionary_usage','修改按钮','dictionary_usage:edit','2026-04-11 14:20:20','2026-04-11 14:20:20',0,0),
    (609,209,'dictionary_usage','删除按钮','dictionary_usage:delete','2026-04-11 14:20:20','2026-04-11 14:20:20',0,0),
    (610,209,'dictionary_usage','打开明细','dictionary_usage:items','2026-04-12 13:58:31','2026-04-12 14:12:10',1,0),
    (611,209,'dictionary_usage','新增字典','dictionary_item:add','2026-04-12 14:07:40','2026-04-12 14:11:45',1,0),
    (612,209,'dictionary_usage','删除字典','dictionary_item:delete','2026-04-12 14:07:40','2026-04-12 14:11:55',1,0),
    (613,209,'dictionary_usage','修改字典','dictionary_item:edit','2026-04-12 14:07:40','2026-04-12 14:12:01',1,0),
    (615,209,'locale_setting','新增按钮','locale_setting:add','2026-04-11 14:20:20','2026-04-11 14:20:20',0,0),
    (616,209,'locale_setting','修改按钮','locale_setting:edit','2026-04-11 14:20:20','2026-04-11 14:20:20',0,0),
    (617,209,'locale_setting','删除按钮','locale_setting:delete','2026-04-11 14:20:20','2026-04-11 14:20:20',0,0),
    (618,209,'i18n_message','新增按钮','i18n_message:add','2026-04-11 14:20:20','2026-04-11 14:20:20',0,0),
    (619,209,'i18n_message','修改按钮','i18n_message:edit','2026-04-11 14:20:20','2026-04-11 14:20:20',0,0),
    (620,209,'i18n_message','删除按钮','i18n_message:delete','2026-04-11 14:20:20','2026-04-11 14:20:20',0,0);

-- 控制单元资源关联
INSERT INTO `control_unit_resource_relation`
(`id`, `control_unit_id`, `resource_id`, `resource_type`, `status`, `create_time`, `update_time`, `version`, `delete_flag`)
VALUES
    (621, 213, 390, 'MENU', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (622, 213, 391, 'MENU', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (623, 213, 392, 'MENU', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (625, 213, 393, 'MENU', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (626, 213, 395, 'MENU', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (627, 213, 396, 'MENU', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (628, 213, 397, 'MENU', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (629, 213, 398, 'MENU', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (630, 213, 399, 'MENU', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (631, 213, 500, 'MENU', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (632, 213, 501, 'MENU', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (633, 213, 502, 'MENU', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (635, 213, 503, 'MENU', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (636, 213, 505, 'MENU', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (637, 213, 506, 'MENU', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (638, 213, 507, 'MENU', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (639, 213, 508, 'MENU', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (650, 213, 509, 'MENU', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (651, 213, 510, 'MENU', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (652, 215, 390, 'MENU', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (653, 215, 391, 'MENU', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (655, 215, 392, 'MENU', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (656, 215, 393, 'MENU', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (657, 215, 395, 'MENU', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (658, 215, 396, 'MENU', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (659, 215, 502, 'MENU', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (660, 216, 511, 'MENU', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (661, 216, 512, 'MENU', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (662, 216, 513, 'MENU', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (663, 216, 515, 'MENU', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (665, 216, 516, 'MENU', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (666, 213, 517, 'PAGE', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (667, 213, 518, 'PAGE', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (668, 213, 519, 'PAGE', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (669, 213, 520, 'PAGE', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (670, 213, 521, 'PAGE', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (671, 213, 522, 'PAGE', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (672, 213, 523, 'PAGE', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (673, 213, 525, 'PAGE', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (675, 213, 526, 'PAGE', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (676, 213, 527, 'PAGE', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (677, 213, 528, 'PAGE', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (678, 213, 529, 'PAGE', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (679, 213, 530, 'PAGE', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (680, 213, 531, 'PAGE', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (681, 213, 532, 'PAGE', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (682, 215, 517, 'PAGE', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (683, 215, 518, 'PAGE', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (685, 215, 519, 'PAGE', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (686, 215, 520, 'PAGE', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (687, 215, 527, 'PAGE', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (688, 216, 533, 'PAGE', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (689, 216, 535, 'PAGE', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (690, 216, 536, 'PAGE', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (691, 216, 537, 'PAGE', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (692, 213, 538, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (693, 213, 539, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (695, 213, 550, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (696, 213, 551, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (697, 213, 552, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (698, 213, 553, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (699, 213, 555, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (700, 213, 556, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (701, 213, 557, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (702, 213, 558, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (703, 213, 559, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (705, 213, 560, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (706, 213, 561, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (707, 213, 562, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (708, 213, 563, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (709, 213, 565, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (710, 213, 566, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (711, 213, 567, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (712, 213, 568, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (713, 213, 569, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (715, 213, 570, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (716, 213, 571, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (717, 213, 572, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (718, 213, 573, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (719, 213, 575, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (720, 213, 576, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (721, 213, 577, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (722, 213, 578, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (723, 213, 579, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (725, 213, 580, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (726, 213, 581, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (727, 213, 582, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (728, 213, 583, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (729, 213, 585, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (730, 213, 586, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (731, 213, 587, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (732, 213, 588, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (733, 213, 589, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (735, 213, 590, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (736, 213, 591, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (737, 213, 592, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (738, 213, 593, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (739, 213, 595, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (750, 213, 596, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (751, 213, 597, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (752, 213, 598, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (753, 213, 599, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (755, 213, 600, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (756, 213, 601, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (757, 213, 602, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (758, 215, 538, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (759, 215, 539, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (760, 215, 550, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (761, 215, 551, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (762, 215, 552, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (763, 215, 553, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (765, 215, 555, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (766, 215, 556, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (767, 215, 557, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (768, 215, 558, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (769, 215, 559, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (770, 215, 560, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (771, 215, 561, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (772, 215, 590, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (773, 216, 603, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (775, 216, 605, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (776, 216, 606, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (777, 216, 607, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (778, 216, 608, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (779, 216, 609, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (780, 216, 610, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (781, 216, 611, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (782, 216, 612, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (783, 216, 613, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (785, 216, 615, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (786, 216, 616, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (787, 216, 617, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (788, 216, 618, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (789, 216, 619, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (790, 216, 620, 'PAGE_ELEMENT', 'ENABLED', '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (791, 212, 236, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (792, 212, 238, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (793, 212, 268, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (795, 212, 279, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (796, 212, 289, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (797, 212, 290, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (798, 212, 359, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (799, 212, 360, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (800, 212, 361, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (801, 213, 238, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (802, 213, 268, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (803, 213, 276, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (805, 213, 277, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (806, 213, 278, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (807, 213, 279, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (808, 213, 280, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (809, 213, 281, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (810, 213, 282, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (811, 213, 283, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (812, 213, 285, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (813, 213, 286, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (815, 213, 287, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (816, 213, 288, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (817, 213, 289, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (818, 213, 290, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (819, 213, 291, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (820, 213, 292, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (821, 213, 293, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (822, 213, 295, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (823, 213, 296, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (825, 213, 297, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (826, 213, 298, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (827, 213, 299, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (828, 213, 300, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (829, 213, 301, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (830, 213, 302, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (831, 213, 303, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (832, 213, 305, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (833, 213, 306, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (835, 213, 307, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (836, 213, 308, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (837, 213, 309, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (838, 213, 310, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (839, 213, 311, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (850, 213, 312, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (851, 213, 313, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (852, 213, 315, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (853, 213, 316, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (855, 213, 317, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (856, 213, 318, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (857, 213, 319, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (858, 213, 320, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (859, 213, 321, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (860, 213, 322, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (861, 213, 323, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (862, 213, 325, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (863, 213, 326, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (865, 213, 327, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (866, 213, 328, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (867, 213, 329, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (868, 213, 330, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (869, 213, 331, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (870, 213, 332, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (871, 213, 333, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (872, 213, 335, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (873, 213, 336, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (875, 213, 337, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (876, 213, 338, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (877, 213, 339, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (878, 213, 350, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (879, 213, 351, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (880, 213, 352, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (881, 213, 353, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (882, 213, 355, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (883, 213, 356, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (885, 213, 357, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (886, 213, 358, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (887, 213, 359, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (888, 213, 360, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (889, 213, 361, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (890, 213, 362, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (891, 213, 363, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (892, 213, 365, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (893, 213, 366, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (895, 213, 367, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (896, 213, 368, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (897, 213, 369, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (898, 213, 370, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (899, 213, 371, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (900, 213, 372, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (901, 213, 373, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (902, 213, 375, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (903, 213, 376, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (905, 213, 377, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (906, 213, 378, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (907, 213, 379, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (908, 213, 380, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (909, 213, 381, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (910, 213, 382, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (911, 213, 383, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (912, 213, 385, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (913, 213, 386, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (915, 213, 387, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (916, 213, 388, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (917, 213, 389, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (918, 215, 238, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (919, 215, 268, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (920, 215, 276, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (921, 215, 277, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (922, 215, 278, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (923, 215, 281, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (925, 215, 282, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (926, 215, 291, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (927, 215, 292, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (928, 215, 293, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (929, 215, 308, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (930, 215, 309, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (931, 215, 310, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (932, 215, 311, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (933, 215, 312, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (935, 215, 313, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (936, 215, 317, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (937, 215, 318, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (938, 215, 319, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (939, 215, 320, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (950, 215, 321, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (951, 215, 333, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (952, 215, 335, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (953, 215, 336, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (955, 215, 337, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (956, 215, 360, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (957, 215, 361, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (958, 215, 367, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (959, 215, 368, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (960, 215, 370, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (961, 215, 371, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (962, 215, 372, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (963, 215, 373, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (965, 215, 376, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (966, 215, 382, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (967, 216, 360, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (968, 216, 361, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (969, 216, 223, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (970, 216, 225, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (971, 216, 226, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (972, 216, 227, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (973, 216, 228, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (975, 216, 231, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (976, 216, 232, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (977, 216, 233, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (978, 216, 235, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (979, 216, 236, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (980, 216, 237, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (981, 216, 238, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (982, 216, 239, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (983, 216, 260, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (985, 216, 261, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (986, 216, 262, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (987, 216, 263, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (988, 216, 265, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (989, 216, 266, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (990, 216, 267, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (991, 216, 268, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (992, 216, 270, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (993, 216, 271, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (995, 216, 272, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (996, 216, 273, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0),
    (997, 216, 275, 'API_ENDPOINT', NULL, '2026-02-01 09:12:28', '2026-02-01 09:12:28', 0, 0);
