-- =============================================
-- g2rain_infra 数据库表结构
-- MySQL 8.0 版本
-- =============================================

-- 创建数据库
CREATE
DATABASE IF NOT EXISTS `g2rain_infra` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `g2rain_infra`;

-- =============================================
-- 1. 字典用途表 (dictionary_usage)
-- =============================================
DROP TABLE IF EXISTS `dictionary_usage`;

CREATE TABLE `dictionary_usage`
(
    `id`          BIGINT      NOT NULL COMMENT                                                          '主键标识',
    `usage_code`  VARCHAR(64) NOT NULL COMMENT                                                          '字典用途代码',
    `usage_name`  VARCHAR(64) NOT NULL COMMENT                                                          '字典用途名称',
    `description` VARCHAR(512)         DEFAULT NULL COMMENT                                             '业务描述',
    `create_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP COMMENT                                      '创建时间',
    `update_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT          '更新时间',
    `version`     INT         NOT NULL DEFAULT 0 COMMENT                                                '记录版本',
    `delete_flag` TINYINT     NOT NULL DEFAULT 0 COMMENT                                                '删除标识[0:未删除, 1:已删除]',
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT=                             '字典用途表';

-- =============================================
-- 2. 字典明细表 (dictionary_item)
-- =============================================
DROP TABLE IF EXISTS `dictionary_item`;

CREATE TABLE `dictionary_item`
(
    `id`          BIGINT       NOT NULL COMMENT                                                         '主键标识',
    `parent_id`   BIGINT NULL COMMENT                                                                   '父节点ID,用于 tree 结构字典',
    `usage_code`  VARCHAR(64)  NOT NULL COMMENT                                                         '字典用途代码',
    `code`        VARCHAR(64)  NOT NULL COMMENT                                                         '字典项编码,用于系统标识',
    `name`        VARCHAR(128) NOT NULL COMMENT                                                         '字典名称(默认语言)',
    `description` VARCHAR(512)          DEFAULT NULL COMMENT                                            '业务描述',
    `sort_index`  INT                   DEFAULT NULL COMMENT                                            '字典排序',
    `create_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP COMMENT                                      '创建时间',
    `update_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT          '更新时间',
    `version`     INT          NOT NULL DEFAULT 0 COMMENT                                               '记录版本',
    `delete_flag` TINYINT      NOT NULL DEFAULT 0 COMMENT                                               '删除标识[0:未删除, 1:已删除]',
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT=                             '字典明细表';

-- =============================================
-- 3. 地域-语言设置表 (locale_setting)
-- =============================================
DROP TABLE IF EXISTS `locale_setting`;

CREATE TABLE `locale_setting`
(
    `id`            BIGINT      NOT NULL COMMENT                                                        '主键标识',
    `language_code` VARCHAR(32) NOT NULL COMMENT                                                        '语言编码,如 zh',
    `region_code`   VARCHAR(32) NOT NULL COMMENT                                                        '国家/地区编码,如 CN',
    `code`          VARCHAR(64) NOT NULL COMMENT                                                        '区域标识,如 zh-CN',
    `name`          VARCHAR(64) NOT NULL COMMENT                                                        '区域名称,如 中国-简体中文',
    `description`   VARCHAR(255)         DEFAULT NULL COMMENT                                           '语言描述',
    `create_time`   TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP COMMENT                                    '创建时间',
    `update_time`   TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT        '更新时间',
    `version`       INT         NOT NULL DEFAULT 0 COMMENT                                              '记录版本',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT=                             '地域-语言设置表';

-- =============================================
-- 4. 国际化信息表 (i18n_message)
-- =============================================
DROP TABLE IF EXISTS `i18n_message`;

CREATE TABLE `i18n_message`
(
    `id`                 BIGINT       NOT NULL COMMENT                                                  '主键标识',
    `message_usage_code` VARCHAR(64)  NOT NULL COMMENT                                                  '消息用途代码',
    `language_code`      VARCHAR(32)  NOT NULL COMMENT                                                  '语言编码,如 zh',
    `region_code`        VARCHAR(32) NULL COMMENT                                                       '国家/地区编码,如 CN',
    `message_code`       VARCHAR(128) NOT NULL COMMENT                                                  '国际化消息编码(唯一)',
    `message_text`       TEXT         NOT NULL COMMENT                                                  '国际化内容文本',
    `extend_field`       JSON NULL COMMENT                                                              '扩展字段,存储额外格式化内容',
    `create_time`        TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP COMMENT                               '创建时间',
    `update_time`        TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT   '更新时间',
    `version`            INT          NOT NULL DEFAULT 0 COMMENT                                        '记录版本',
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT=                             '国际化信息表';

-- =============================================
-- 5. 全局唯一ID管理表 (g2rain_raindrop)
-- =============================================
DROP TABLE IF EXISTS `g2rain_raindrop`;

CREATE TABLE `g2rain_raindrop`
(
    `id`          BIGINT       NOT NULL AUTO_INCREMENT COMMENT                                          '主键标识',
    `biz_tag`     VARCHAR(128) NOT NULL COMMENT                                                         '业务标识,每个业务对应一行',
    `max_id`      BIGINT       NOT NULL DEFAULT 1 COMMENT                                               '当前分配到的最大ID',
    `step`        INT          NOT NULL DEFAULT 0 COMMENT                                               '分配步长,用于批量预分配ID',
    `description` VARCHAR(256)          DEFAULT '' COMMENT                                              '业务描述',
    `create_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP COMMENT                                      '创建时间',
    `update_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT          '更新时间',
    `version`     INT          NOT NULL DEFAULT 0 COMMENT                                               '记录版本',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_biz_tag` (`biz_tag`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT=                             '全局唯一ID管理表';

insert into g2rain_raindrop (`id`, `biz_tag`, `max_id`, `step`, `description`, `create_time`, `update_time`)
values (1, 'COMMON', 2000, 100, '全局共用号段', '2026-05-05 15:27:32', '2026-05-05 15:27:32');

insert into locale_setting (`id`, `language_code`, `region_code`, `code`, `name`, `description`, `create_time`, `update_time`)
values (2, 'zh', 'CN', 'zh-CN', '简体中文-中国',  '简体中文-中国大陆', '2026-05-05 15:27:32', '2026-05-05 15:27:32');

insert into dictionary_usage (`id`, `usage_code`, `usage_name`, `description`, `create_time`, `update_time`)
values (3, 'ORGAN_TYPE', '组织类型', '组织类型', '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (5, 'SESSION_TYPE', '会话类型', '会话类型', '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (6, 'SEX', '性别', '性别', '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (7, 'APPLICATION_TYPE', '应用类型', '应用类型', '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (8, 'APPLICATION_STATUS', '应用状态', '应用状态', '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (9, 'ROLE_TYPE', '角色类型', '角色类型', '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (10, 'CONTROL_UNIT_STATUS', '功能权限状态', '控制单元状态', '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (11, 'CONTROL_UNIT_SCOPE', '功能权限作用域', '控制单元作用域', '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (12, 'CONTROL_DOMAIN_TYPE', '业务能力类型', '控制域类型', '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (13, 'CONTROL_DOMAIN_SCOPE', '业务能力作用域', '控制域作用域', '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (15, 'ORGAN_STATUS', '机构状态', '机构状态', '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (16, 'RESOURCE_TYPE', '资源类型', '资源类型', '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (17, 'RESOURCE_STATUS', '资源状态', '资源状态', '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (18, 'AUTHORIZATION_STATUS', '授权状态', '授权状态', '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (19, 'PASSPORT_STATUS', '账号状态', '账号状态', '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (20, 'KEY_ALGORITHM', '密钥算法', '密钥算法', '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (21, 'PUBLIC_KEY_FORMAT', '公钥格式', '公钥格式', '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (22, 'I18N_MSG_USAGE', '消息用途', '国际化消息用途', '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (23, 'BOOLEAN_FLAG', '布尔标记', '布尔标记', '2026-05-05 15:27:32', '2026-05-05 15:27:32');

insert into dictionary_item (`id`, `parent_id`, `usage_code`, `code`, `name`, `description`, `sort_index`, `create_time`, `update_time`)
values (25, null, 'ORGAN_TYPE', 'SALES_PARTNER', '渠道商', '渠道商', 0, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (26, null, 'ORGAN_TYPE', 'SERVICE_PROVIDER', '服务商', '服务商', 1, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (27, null, 'ORGAN_TYPE', 'COMPANY', '公司', '公司', 2, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (28, null, 'ORGAN_TYPE', 'TENANT', '租户', '租户', 3, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (29, null, 'SESSION_TYPE', 'USER', '用户类型', '用户类型', 0, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (30, null, 'SESSION_TYPE', 'PASSPORT', '账号类型', '账号类型', 1, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (31, null, 'SEX', 'MALE', '男性', '男性', 0, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (32, null, 'SEX', 'FEMALE', '女性', '女性', 1, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (33, null, 'APPLICATION_TYPE', 'SUPPORT', '支撑应用', '支撑应用', 0, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (35, null, 'APPLICATION_TYPE', 'SYSTEM', '系统应用', '系统应用', 1, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (36, null, 'APPLICATION_TYPE', 'PUBLIC', '开放平台应用', '开放平台应用', 2, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (37, null, 'APPLICATION_TYPE', 'PRIVATE', '私有平台应用', '私有平台应用', 3, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (38, null, 'APPLICATION_STATUS', 'PUBLISHED', '已发布', '已发布', 0, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (39, null, 'APPLICATION_STATUS', 'UNPUBLISHED', '未发布', '未发布', 1, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (50, null, 'ROLE_TYPE', 'ADMIN', '默认角色', '超管角色, 只读', 0, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (51, null, 'ROLE_TYPE', 'USER', '用户角色', '用户角色', 1, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (52, null, 'CONTROL_UNIT_STATUS', 'PUBLISHED', '已发布', '已发布', 0, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (53, null, 'CONTROL_UNIT_STATUS', 'UNPUBLISHED', '未发布', '未发布', 1, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (55, null, 'CONTROL_UNIT_SCOPE', 'CUSTOMER', '客户功能', '客户功能', 0, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (56, null, 'CONTROL_UNIT_SCOPE', 'OPERATION', '运营功能', '运营功能', 1, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (57, null, 'CONTROL_UNIT_SCOPE', 'PERPETUAL', '永久有效', '永久有效', 2, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (58, null, 'CONTROL_DOMAIN_TYPE', 'TRADE', '交易开通类型', '交易开通类型', 0, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (59, null, 'CONTROL_DOMAIN_TYPE', 'APPLICATION', '应用授权开通类型', '应用授权开通类型', 1, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (60, null, 'CONTROL_DOMAIN_SCOPE', 'CUSTOMER', '客户交付范围', '客户交付范围', 0, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (61, null, 'CONTROL_DOMAIN_SCOPE', 'OPERATION', '平台运营范围', '平台运营范围', 1, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (62, null, 'ORGAN_STATUS', 'ACTIVE', '有效', '有效', 0, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (63, null, 'ORGAN_STATUS', 'INACTIVE', '无效', '无效', 1, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (65, null, 'RESOURCE_STATUS', 'VISIBLE', '显示', '显示', 0, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (66, null, 'RESOURCE_STATUS', 'ENABLED', '可用', '可用', 1, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (67, null, 'AUTHORIZATION_STATUS', 'ACTIVATED', '激活', '激活', 0, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (68, null, 'AUTHORIZATION_STATUS', 'DEACTIVATED', '关停', '关停', 1, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (69, null, 'RESOURCE_TYPE', 'MENU', '菜单资源', '菜单资源', 0, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (70, null, 'RESOURCE_TYPE', 'PAGE', '页面资源', '页面资源', 1, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (71, null, 'RESOURCE_TYPE', 'PAGE_ELEMENT', '页面元素资源', '页面元素资源', 2, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (72, null, 'RESOURCE_TYPE', 'API_ENDPOINT', '接口地址资源', '接口地址资源', 3, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (73, null, 'PASSPORT_STATUS', 'NORMAL', '正常', '正常', 0, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (75, null, 'PASSPORT_STATUS', 'FROZEN', '冻结', '冻结', 1, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (76, null, 'KEY_ALGORITHM', 'EC', '椭圆曲线算法(EC)', '椭圆曲线算法(EC)', 0, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (77, null, 'PUBLIC_KEY_FORMAT', 'PEM', 'PEM 格式', 'PEM 格式', 0, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (78, null, 'PUBLIC_KEY_FORMAT', 'DER', 'DER 格式', 'DER 格式', 1, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (79, null, 'I18N_MSG_USAGE', 'DICTIONARY', '数据字典', '数据字典', 0, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (80, null, 'I18N_MSG_USAGE', 'ERROR_CODE', '错误信息', '错误信息', 1, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (81, null, 'I18N_MSG_USAGE', 'UI_MESSAGE', '页面文案', '页面文案', 2, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (82, null, 'BOOLEAN_FLAG', '0', '否', '假 / 否 / 禁用', 0, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (83, null, 'BOOLEAN_FLAG', '1', '是', '真 / 是 / 启用', 1, '2026-05-05 15:27:32', '2026-05-05 15:27:32');

INSERT INTO `i18n_message` (`id`, `message_usage_code`, `language_code`, `region_code`, `message_code`, `message_text`, `extend_field`, `create_time`, `update_time`)
VALUES (85, 'ERROR_CODE', 'zh', 'CN', 'system.40000', '参数无效', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (86, 'ERROR_CODE', 'zh', 'CN', 'system.40001', '参数{0:paramName}不能为空', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (87, 'ERROR_CODE', 'zh', 'CN', 'system.40002', '参数: {0:paramValue} 不符合要求, 有效范围: {1:paramRange}', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (88, 'ERROR_CODE', 'zh', 'CN', 'system.40003', '参数: {0:paramValue} 不符合要求, 有效长度: {1:paramRange}', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (89, 'ERROR_CODE', 'zh', 'CN', 'system.40004', '参数: {0:paramValue}格式无效，需满足：{1:rule}', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (90, 'ERROR_CODE', 'zh', 'CN', 'system.40005', '参数: {0:paramValue} 类型错误, 期望类型：{1:requiredType}', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (91, 'ERROR_CODE', 'zh', 'CN', 'system.40006', '请求 [{0:uri}] 的 {1:type} 缺失或绑定异常: {2:name}', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (92, 'ERROR_CODE', 'zh', 'CN', 'system.40007', '授权码: [{0:uri}] 无效', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (93, 'ERROR_CODE', 'zh', 'CN', 'system.40008', '参数：{0:param} 无效', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (95, 'ERROR_CODE', 'zh', 'CN', 'system.40501', '请求 [{0:uri}] 的方法 ''{1:method}'' 不被支持, 可用方法: {2:supported}', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (96, 'ERROR_CODE', 'zh', 'CN', 'system.40601', '请求 [{0:uri}] 的响应类型与客户端接受响应类型请求头不匹配, 可接受类型: {1:supported}', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (97, 'ERROR_CODE', 'zh', 'CN', 'system.41501', '请求 [{0:uri}] 的请求体类型 ''{1:contentType}'' 不被支持, 可用类型: {2:supported}', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (98, 'ERROR_CODE', 'zh', 'CN', 'system.40401', '资源{0:resource}（ID:{1:id}）不存在', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (99, 'ERROR_CODE', 'zh', 'CN', 'system.40101', '未认证：{0:message}', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (100, 'ERROR_CODE', 'zh', 'CN', 'system.40301', '权限不足：{0:role}无法访问资源', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (101, 'ERROR_CODE', 'zh', 'CN', 'system.50001', '系统内部错误：{0:errorDetail}', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (102, 'ERROR_CODE', 'zh', 'CN', 'system.50002', '数据库操作异常：{0:operation}失败，原因：{1:reason}', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (103, 'ERROR_CODE', 'zh', 'CN', 'system.50003', '远程服务调用失败：{0:serviceName}（错误：{1:error}）', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (105, 'ERROR_CODE', 'zh', 'CN', 'system.50004', '缓存操作异常：{0:operation}{1:key}失败', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (106, 'ERROR_CODE', 'zh', 'CN', 'system.50005', 'JSON解析令牌不可用', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (107, 'ERROR_CODE', 'zh', 'CN', 'system.50006', '数据序列化失败', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (108, 'ERROR_CODE', 'zh', 'CN', 'system.50007', '创建JWT得密钥对不存在', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (109, 'ERROR_CODE', 'zh', 'CN', 'system.50008', '生成JWT失败', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (110, 'ERROR_CODE', 'zh', 'CN', 'system.50009', '解析JWT失败：{0:jwt}', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (111, 'ERROR_CODE', 'zh', 'CN', 'system.50010', '数据添加失败', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (112, 'ERROR_CODE', 'zh', 'CN', 'system.50011', 'ID：{0:id} 修改失败', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (113, 'ERROR_CODE', 'zh', 'CN', 'system.50012', '数据已存在', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (115, 'ERROR_CODE', 'zh', 'CN', 'basis.40001', '自关联非法', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (116, 'ERROR_CODE', 'zh', 'CN', 'basis.40002', '循环依赖非法', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (117, 'ERROR_CODE', 'zh', 'CN', 'basis.40003', '层级挂载操作非法', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (118, 'ERROR_CODE', 'zh', 'CN', 'basis.40004', '非直属关系禁止删除', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (119, 'ERROR_CODE', 'zh', 'CN', 'basis.40005', '只能删除没有下级的组织节点', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (120, 'ERROR_CODE', 'zh', 'CN', 'basis.40006', '公私钥生成失败', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (121, 'ERROR_CODE', 'zh', 'CN', 'basis.40007', '密码加密失败', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (122, 'ERROR_CODE', 'zh', 'CN', 'basis.40008', '密码哈希格式无效', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (123, 'ERROR_CODE', 'zh', 'CN', 'basis.40009', '参数 {0:paramName} 的值 {1:paramValue} 已存在', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (125, 'ERROR_CODE', 'zh', 'CN', 'basis.40010', '已发布的应用数据不允许修改', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (126, 'ERROR_CODE', 'zh', 'CN', 'basis.40011', '已发布的应用数据不允许删除', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (127, 'ERROR_CODE', 'zh', 'CN', 'basis.40012', '调整具备集成功能，请先删除应用归类数据', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (128, 'ERROR_CODE', 'zh', 'CN', 'basis.40013', '非子应用不允许进行应用归类', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (129, 'ERROR_CODE', 'zh', 'CN', 'basis.40014', '非主应用不允许作为归类目标', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (130, 'ERROR_CODE', 'zh', 'CN', 'basis.40015', '不允许删除默认应用', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (131, 'ERROR_CODE', 'zh', 'CN', 'basis.40016', '交易开通类型不允许设置平台运营交付范围', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (132, 'ERROR_CODE', 'zh', 'CN', 'basis.40017', '不允许跨应用设置功能权限', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (133, 'ERROR_CODE', 'zh', 'CN', 'basis.40018', '不允许跨应用设置菜单', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (135, 'ERROR_CODE', 'zh', 'CN', 'basis.40019', '菜单不允许自关联', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (136, 'ERROR_CODE', 'zh', 'CN', 'basis.40020', '不允许删除超管角色', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (137, 'ERROR_CODE', 'zh', 'CN', 'basis.40021', '不允许删除超管角色的功能权限', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (138, 'ERROR_CODE', 'zh', 'CN', 'basis.40022', '不允许给超管角色添加功能权限', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (139, 'ERROR_CODE', 'zh', 'CN', 'basis.40023', '功能权限不存在或已关停，角色不允许设置该功能权限', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (150, 'ERROR_CODE', 'zh', 'CN', 'basis.40024', '机构不存在默认角色, 请为机构添加默认角色', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (151, 'ERROR_CODE', 'zh', 'CN', 'basis.40025', '存在用户关联，不能删除账号', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (152, 'ERROR_CODE', 'zh', 'CN', 'basis.40026', '存在用户关联，不能删除角色', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (153, 'ERROR_CODE', 'zh', 'CN', 'basis.40027', '账号已冻结', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (155, 'ERROR_CODE', 'zh', 'CN', 'basis.40028', '用户名或密码不正确', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (156, 'ERROR_CODE', 'zh', 'CN', 'basis.40029', '机构不可用，请确认机构状态', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (157, 'ERROR_CODE', 'zh', 'CN', 'basis.40030', '应用授权记录不可修改', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (158, 'ERROR_CODE', 'zh', 'CN', 'basis.40031', '应用授权记录不可删除', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (159, 'ERROR_CODE', 'zh', 'CN', 'basis.40032', '机构记录不可删除', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (160, 'ERROR_CODE', 'zh', 'CN', 'basis.40033', '管理员不可删除', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (161, 'ERROR_CODE', 'zh', 'CN', 'basis.40034', '存在业务能力, 不允许删除应用', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (162, 'ERROR_CODE', 'zh', 'CN', 'basis.40035', '存在授权记录, 不允许删除应用', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (163, 'ERROR_CODE', 'zh', 'CN', 'basis.40036', '已关联功能权限, 不允许删除资源', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (165, 'ERROR_CODE', 'zh', 'CN', 'basis.40037', '已关联页面元素, 不允许删除资源', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (166, 'ERROR_CODE', 'zh', 'CN', 'basis.40038', '已关联资源接口, 不允许删除后端接口', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (167, 'ERROR_CODE', 'zh', 'CN', 'basis.40039', '资源文件解析失败', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (168, 'ERROR_CODE', 'zh', 'CN', 'basis.40040', '已发布功能权限禁止操作', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (169, 'ERROR_CODE', 'zh', 'CN', 'basis.40041', '已发布功能权限不可修改状态', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (170, 'ERROR_CODE', 'zh', 'CN', 'basis.40042', '存在子菜单, 不允许删除菜单', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (171, 'ERROR_CODE', 'zh', 'CN', 'basis.40043', '不允许关联未发布的功能权限', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (172, 'ERROR_CODE', 'zh', 'CN', 'basis.40044', '不允许删除默认功能权限', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (173, 'ERROR_CODE', 'zh', 'CN', 'basis.40045', '运营公司不允许创建机构', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (175, 'ERROR_CODE', 'zh', 'CN', 'basis.40046', '旧密码不正确', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (176, 'ERROR_CODE', 'zh', 'CN', 'basis.40047', '业务能力已关停，请续费后再登录', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (177, 'ERROR_CODE', 'zh', 'CN', 'basis.40048', '不支持的公钥算法', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (178, 'ERROR_CODE', 'zh', 'CN', 'basis.40049', '公钥类型与算法不匹配', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (179, 'ERROR_CODE', 'zh', 'CN', 'basis.40050', '无效公钥', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (180, 'ERROR_CODE', 'zh', 'CN', 'basis.40051', '用户不存在', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (181, 'ERROR_CODE', 'zh', 'CN', 'basis.40052', '已关联资源接口, 不允许删除服务注册信息', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (182, 'ERROR_CODE', 'zh', 'CN', 'infra.40001', '雪花 workerId 获取失败', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (183, 'ERROR_CODE', 'zh', 'CN', 'infra.40002', '当前 雪花 workerId 无效, 请等待重新抢号', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (185, 'ERROR_CODE', 'zh', 'CN', 'infra.40003', '时钟回拨超过允许范围', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (186, 'ERROR_CODE', 'zh', 'CN', 'infra.40004', '业务号段不存在或未初始化', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (187, 'ERROR_CODE', 'zh', 'CN', 'infra.40005', '号段资源未准备好', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (188, 'ERROR_CODE', 'zh', 'CN', 'infra.40006', '数据库号段更新失败', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (189, 'ERROR_CODE', 'zh', 'CN', 'infra.40007', '数据库号段记录不存在', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (190, 'ERROR_CODE', 'zh', 'CN', 'infra.40008', '不允许 COMMON 数据', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (191, 'ERROR_CODE', 'zh', 'CN', 'infra.40009', '存在字典明细, 不允许删除字典用途', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (192, 'ERROR_CODE', 'zh', 'CN', 'iam.40102', '刷新 Token 过期', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (193, 'ERROR_CODE', 'zh', 'CN', 'isolation.50001', '租户条件不存在: {0:tenantId} 参数未提供', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (195, 'ERROR_CODE', 'zh', 'CN', 'isolation.50002', '租户条件不在允许范围: {0:tenantId} 当前租户不可访问', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (196, 'ERROR_CODE', 'zh', 'CN', 'gateway.40001', 'token invalid', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (197, 'ERROR_CODE', 'zh', 'CN', 'gateway.40002', 'token expired', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (198, 'ERROR_CODE', 'zh', 'CN', 'gateway.40003', 'Subscription expired, please renew', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32'),
       (199, 'ERROR_CODE', 'zh', 'CN', 'gateway.40004', 'Request body exceeds limit: {0:maxBytes} bytes', null, '2026-05-05 15:27:32', '2026-05-05 15:27:32');
