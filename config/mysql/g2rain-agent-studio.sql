-- =============================================
-- g2rain_agent_studio 数据库表结构
-- MySQL 8.0 版本
-- =============================================

-- 创建数据库
CREATE DATABASE IF NOT EXISTS `g2rain_agent_studio` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE `g2rain_agent_studio`;

-- ---------------------------------------------
-- 1. 数字员工画像 (agent_profile)
-- ---------------------------------------------
DROP TABLE IF EXISTS `agent_profile`;

CREATE TABLE `agent_profile` (
    `id` BIGINT NOT NULL COMMENT                                                                        '主键标识',
    `organ_id` BIGINT NOT NULL COMMENT                                                                  '机构标识',
    `agent_code` VARCHAR(64) NOT NULL COMMENT                                                           '数字员工编码',
    `agent_name` VARCHAR(128) NOT NULL COMMENT                                                          '数字员工名称',
    `resource_type` VARCHAR(32) NOT NULL COMMENT                                                        '资源类型[PLATFORM:G2rain员工, CUSTOM:租户自定义/安装副本]',
    `identity_desc` VARCHAR(2000) DEFAULT NULL COMMENT                                                  '身份定义',
    `mission_desc` VARCHAR(2000) DEFAULT NULL COMMENT                                                   '任务使命',
    `boundary_desc` VARCHAR(4000) DEFAULT NULL COMMENT                                                  '边界约束',
    `style_desc` VARCHAR(2000) DEFAULT NULL COMMENT                                                     '交互风格',
    `principle_desc` VARCHAR(4000) DEFAULT NULL COMMENT                                                 '行为原则',
    `status` VARCHAR(32) NOT NULL DEFAULT 'ACTIVE' COMMENT                                              '状态[ACTIVE:启用, INACTIVE:禁用]',
    `description` VARCHAR(500) DEFAULT NULL COMMENT                                                     '备注',
    `create_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP COMMENT                                      '创建时间',
    `update_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT          '更新时间',
    `version` INT NOT NULL DEFAULT 0 COMMENT                                                            '记录版本',
    `delete_flag` TINYINT NOT NULL DEFAULT 0 COMMENT                                                    '逻辑删除标记[0:未删除, 1:已删除]',
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT=                             '数字员工画像表';

-- ---------------------------------------------
-- 2. Skill 定义 (skill_profile)
-- ---------------------------------------------
DROP TABLE IF EXISTS `skill_profile`;

CREATE TABLE `skill_profile` (
    `id` BIGINT NOT NULL COMMENT                                                                        '主键标识',
    `organ_id` BIGINT NOT NULL COMMENT                                                                  '机构标识',
    `skill_key` VARCHAR(128) NOT NULL COMMENT                                                           'Skill 唯一键，如 crm.quote.query',
    `skill_name` VARCHAR(128) NOT NULL COMMENT                                                          'Skill 名称',
    `resource_type` VARCHAR(32) NOT NULL COMMENT                                                        '资源类型[PLATFORM:G2rain员工, CUSTOM:租户自定义/安装副本]',
    `semantic_desc` VARCHAR(1000) DEFAULT NULL COMMENT                                                  'Skill 语义描述',
    `skill_manual` MEDIUMTEXT DEFAULT NULL COMMENT                                                      'Skill 操作手册（注入 LLM）',
    `skill_contract` JSON DEFAULT NULL COMMENT                                                          'Skill 执行契约 JSON',
    `status` VARCHAR(32) NOT NULL DEFAULT 'ACTIVE' COMMENT                                              '状态[ACTIVE:启用, INACTIVE:禁用]',
    `description` VARCHAR(500) DEFAULT NULL COMMENT                                                     '备注',
    `create_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP COMMENT                                      '创建时间',
    `update_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT          '更新时间',
    `version` INT NOT NULL DEFAULT 0 COMMENT                                                            '记录版本',
    `delete_flag` TINYINT NOT NULL DEFAULT 0 COMMENT                                                    '逻辑删除标记[0:未删除, 1:已删除]',
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT=                             'Skill 定义表';

-- ---------------------------------------------
-- 3. Skill 绑定 (agent_skill_binding)
-- ---------------------------------------------
DROP TABLE IF EXISTS `agent_skill_binding`;

CREATE TABLE `agent_skill_binding` (
    `id` BIGINT NOT NULL COMMENT                                                                        '主键标识',
    `organ_id` BIGINT NOT NULL COMMENT                                                                  '机构标识',
    `agent_id` BIGINT NOT NULL COMMENT                                                                  '数字员工主键（agent_profile.id）',
    `skill_id` BIGINT NOT NULL COMMENT                                                                  'Skill 主键（skill_profile.id）',
    `enabled_flag` TINYINT NOT NULL DEFAULT 1 COMMENT                                                   '是否启用[0:否, 1:是]',
    `description` VARCHAR(500) DEFAULT NULL COMMENT                                                     '备注',
    `create_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP COMMENT                                      '创建时间',
    `update_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT          '更新时间',
    `version` INT NOT NULL DEFAULT 0 COMMENT                                                            '记录版本',
    `delete_flag` TINYINT NOT NULL DEFAULT 0 COMMENT                                                    '逻辑删除标记[0:未删除, 1:已删除]',
    PRIMARY KEY (`id`),
    INDEX `idx_agent_id` (`agent_id`, `delete_flag`),
    INDEX `idx_skill_id` (`skill_id`, `delete_flag`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT=                             '数字员工 Skill 绑定表';

-- ---------------------------------------------
-- 4. Tool 绑定 (skill_tool_binding)
-- ---------------------------------------------
DROP TABLE IF EXISTS `skill_tool_binding`;

CREATE TABLE `skill_tool_binding` (
    `id` BIGINT NOT NULL COMMENT                                                                        '主键标识',
    `organ_id` BIGINT NOT NULL COMMENT                                                                  '机构标识',
    `skill_id` BIGINT NOT NULL COMMENT                                                                  'Skill主键（skill_profile.id）',
    `tool_name` VARCHAR(256) NOT NULL COMMENT                                                           'Tool 名称（MCP tools/list）',
    `enabled_flag` TINYINT NOT NULL DEFAULT 1 COMMENT                                                   '是否启用[0:否, 1:是]',
    `description` VARCHAR(500) DEFAULT NULL COMMENT                                                     '备注',
    `create_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP COMMENT                                      '创建时间',
    `update_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT          '更新时间',
    `version` INT NOT NULL DEFAULT 0 COMMENT                                                            '记录版本',
    `delete_flag` TINYINT NOT NULL DEFAULT 0 COMMENT                                                    '逻辑删除标记[0:未删除, 1:已删除]',
    PRIMARY KEY (`id`),
    INDEX `idx_skill_id` (`skill_id`, `delete_flag`),
    INDEX `idx_tool_name` (`tool_name`, `delete_flag`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT=                             'Skill Tool 绑定表';

-- =============================================
-- 初始化数据（PLATFORM CMS + CUSTOM CRM 噪音）
-- organ_id=2 对齐 g2rain-basis 平台机构
-- tool_name 对齐 mcp-registry EndpointStrategy（method_path，如 get_article_list）
-- 与 LocalMcpToolRegistryBootstrap 注册的 CMS 端点一致；organId 由请求头注入，契约用 PLATFORM
-- =============================================

-- ---------------------------------------------
-- A. CMS 数字员工（PLATFORM，生产可用）
-- Agent = 一个产品职责画像；细能力拆在 Skill，不拆多个 Agent
-- ---------------------------------------------
INSERT INTO `agent_profile`
(`id`, `organ_id`, `agent_code`, `agent_name`, `resource_type`,
 `identity_desc`, `mission_desc`, `boundary_desc`, `style_desc`, `principle_desc`,
 `status`, `description`, `version`, `delete_flag`)
VALUES
(10001, 2, 'cms_assistant', 'CMS内容管理数字员工', 'PLATFORM',
 '你是 G2rain CMS 内容管理数字员工，负责多租户内容平台的网站、内容空间、导航结构、文章、静态页面、分类与标签等内容运营。',
 '按用户本轮明确要求推进 CMS 查询或写入。同句里的后续意图不提前规划、不提前执行。',
 '只处理 CMS 内容管理领域，不承接 CRM、销售、工单等非内容请求。不承诺系统未提供的 SEO、审批流、定时发布、DNS 或证书等能力。涉及删除、大规模变更、已发布内容覆盖或对外路径变更时需要用户确认。不编造未确认的业务结果。',
 '专业、克制。只做本轮当下动作。查询空结果只陈述事实。用户已给的业务字段原样使用（中文类型、状态按系统枚举值映射，无需确认）。对象 ID 从查询或前情解析，不向用户索要。回复使用中文，术语与状态枚举与系统一致。',
 '只规划本轮立即要做的能力。查询/盘点只查被问到的对象，查完即结束，不建议创建。写入须用户本轮明确要求；已给齐的字段直接调用写工具，被要求确认时再申请审批；写操作的确认由审批卡完成，不用 builtin_node_follow_up 口头确认。organId 由平台注入，审批摘要不得展示平台注入字段原值。用户改口做另一件事时只做新请求。无法处理非 CMS 诉求时明确说明。',
 'ACTIVE', 'g2rain-cms 生产数字员工（单 Agent）', 0, 0);

-- ---------------------------------------------
-- B. CMS Skill（PLATFORM）
-- Skill = Planner 拆任务用的业务能力（非 REST 1:1）
-- 细粒度 HTTP/MCP 调用在 Tool 绑定，不在 Skill 表拆碎
-- ---------------------------------------------
INSERT INTO `skill_profile`
(`id`, `organ_id`, `skill_key`, `skill_name`, `resource_type`, `semantic_desc`, `skill_manual`, `skill_contract`,
 `status`, `description`, `version`, `delete_flag`)
VALUES
(11001, 2, 'cms.structure.manage', '站点与信息架构管理', 'PLATFORM',
 '负责 CMS 网站、内容空间和导航栏目。本轮查询已有结构，或本轮明确要求创建/调整结构时才写入。不负责文章正文、静态页面正文或标签。',
 '## 目标
完成本轮被问到的结构查询，或用户本轮明确要求的网站/空间/栏目写入。

## 业务规则
- 查询/盘点只查用户问到的对象（网站、空间、栏目彼此独立）。盘点用列表查询，用户未要求翻页时不用分页。查完即结束；空列表只陈述没有，不追问、不建议默认值、不写入。
- 写入仅限用户本轮点名的那一层，不顺带创建未要求的网站、空间或栏目。
- 用户已给的名称、编码、域名等原样提交。从属对象（站点、父栏目）用列表查询或前情解析，不向用户要 ID。organId 由平台注入。
- 空间类型：官网 WEBSITE，知识库 KNOWLEDGE，内部 INTERNAL；用户未说时默认 KNOWLEDGE。新建空间须带名称、编码、类型、status=ENABLED，禁止空参。
- 栏目类型：LIST 挂文章分类，PAGE 挂静态页，LINK 用外部链接。
- 用户用中文说的类型、状态（如官网、列表、启用）直接映射为对应枚举值提交，不追问确认。
- 创建、修改、删除直接调用对应写工具，被要求确认时再调用 builtin_node_approval；审批卡就是确认入口，禁止用 builtin_node_follow_up 口头确认；未获确认不得写。缺必填业务字段才 builtin_node_follow_up。
- 不处理文章正文、静态页面正文或标签。

## 前置与产出
- 查询：汇报实际列表，空结果也算完成。
- 写入：以审批通过后的工具结果为准，不得编造。',
 '{"mode":"REACT","delegatable":false,"outputs":{"web_site_list":{"type":"LIST","fields":["id","siteName","siteCode","domain","status"],"required":false},"space_list":{"type":"LIST","fields":["id","spaceName","spaceCode","spaceType","status"],"required":false},"channel_list":{"type":"LIST","fields":["id","siteId","spaceId","parentId","channelName","channelCode","channelType","path","categoryId","pageId","status"],"required":false}},"doneWhen":"post_web_site_save succeeded OR post_space_save succeeded OR post_channel_save succeeded OR post_web_site_update_status succeeded OR post_space_update_status succeeded OR post_channel_update_status succeeded OR delete_web_site_id succeeded OR delete_space_id succeeded OR delete_channel_id succeeded OR get_web_site_list succeeded OR get_web_site_list empty OR get_web_site_page succeeded OR get_web_site_page empty OR get_space_list succeeded OR get_space_list empty OR get_space_page succeeded OR get_space_page empty OR get_channel_list succeeded OR get_channel_list empty OR get_channel_page succeeded OR get_channel_page empty","tools":{"get_web_site_list":{"label":"查询站点","sideEffect":"NONE","args":{"organId":{"from":"platform.organId","missing":{"action":"FAIL","message":"缺少机构上下文"}},"siteName":{"required":false,"sources":["USER","MODEL"]}},"success":{"path":"status","op":"EQ","value":200},"error":{"code":"errorCode","message":"errorMessage"},"extracts":[{"key":"web_site_list","path":"data","fields":["id","siteName","siteCode","domain","status"]}]},"post_web_site_save":{"label":"保存站点","sideEffect":"WRITE","args":{"organId":{"from":"platform.organId","missing":{"action":"FAIL","message":"缺少机构上下文"}},"id":{"required":false,"sources":["EVIDENCE"],"label":"站点 ID"},"siteName":{"sources":["USER","MODEL"],"label":"站点名称"},"siteCode":{"sources":["USER","MODEL"],"label":"站点编码"},"domain":{"required":false,"sources":["USER","MODEL"],"label":"站点域名"},"status":{"required":false,"sources":["USER","MODEL"],"label":"状态"}},"success":{"path":"status","op":"EQ","value":200},"error":{"code":"errorCode","message":"errorMessage"},"extracts":[{"key":"web_site_saved","path":"data"}]},"get_space_list":{"label":"查询内容空间","sideEffect":"NONE","args":{"organId":{"from":"platform.organId","missing":{"action":"FAIL","message":"缺少机构上下文"}},"spaceName":{"required":false,"sources":["USER","MODEL"]},"spaceType":{"required":false,"enum":["WEBSITE","KNOWLEDGE","INTERNAL"],"sources":["USER","MODEL"]}},"success":{"path":"status","op":"EQ","value":200},"error":{"code":"errorCode","message":"errorMessage"},"extracts":[{"key":"space_list","path":"data","fields":["id","spaceName","spaceCode","spaceType","status"]}]},"post_space_save":{"label":"保存内容空间","sideEffect":"WRITE","args":{"organId":{"from":"platform.organId","missing":{"action":"FAIL","message":"缺少机构上下文"}},"id":{"required":false,"sources":["EVIDENCE"],"label":"内容空间 ID"},"spaceName":{"sources":["USER","MODEL"],"label":"空间名称"},"spaceCode":{"sources":["USER","MODEL"],"label":"空间编码"},"spaceType":{"enum":["WEBSITE","KNOWLEDGE","INTERNAL"],"sources":["USER","MODEL"],"label":"空间类型"},"status":{"enum":["ENABLED","DISABLED"],"sources":["USER","MODEL"],"label":"状态"}},"success":{"path":"status","op":"EQ","value":200},"error":{"code":"errorCode","message":"errorMessage"},"extracts":[{"key":"space_saved","path":"data"}]},"get_channel_list":{"label":"查询栏目","sideEffect":"NONE","args":{"organId":{"from":"platform.organId","missing":{"action":"FAIL","message":"缺少机构上下文"}},"siteId":{"required":false,"sources":["USER","EVIDENCE"]},"spaceId":{"required":false,"sources":["USER","EVIDENCE"]},"parentId":{"required":false,"sources":["USER","EVIDENCE"]},"channelName":{"required":false,"sources":["USER","MODEL"]}},"success":{"path":"status","op":"EQ","value":200},"error":{"code":"errorCode","message":"errorMessage"},"extracts":[{"key":"channel_list","path":"data","fields":["id","siteId","spaceId","parentId","channelName","channelCode","channelType","path","categoryId","pageId","status"]}]},"post_channel_save":{"label":"保存栏目","sideEffect":"WRITE","args":{"organId":{"from":"platform.organId","missing":{"action":"FAIL","message":"缺少机构上下文"}},"id":{"required":false,"sources":["EVIDENCE"],"label":"栏目 ID"},"siteId":{"required":false,"sources":["EVIDENCE"],"label":"站点"},"spaceId":{"required":false,"sources":["EVIDENCE"],"label":"内容空间"},"parentId":{"required":false,"sources":["EVIDENCE"],"label":"父栏目"},"channelName":{"sources":["USER","MODEL"],"label":"栏目名称"},"channelCode":{"required":false,"sources":["USER","MODEL"],"label":"栏目编码"},"channelType":{"enum":["LIST","PAGE","LINK"],"sources":["USER","MODEL"],"label":"栏目类型"},"path":{"required":false,"sources":["USER","MODEL"],"label":"访问路径"},"categoryId":{"required":false,"sources":["USER","EVIDENCE"],"label":"文章分类"},"pageId":{"required":false,"sources":["USER","EVIDENCE"],"label":"静态页面"},"linkUrl":{"required":false,"sources":["USER","MODEL"],"label":"外链地址"}},"success":{"path":"status","op":"EQ","value":200},"error":{"code":"errorCode","message":"errorMessage"},"extracts":[{"key":"channel_saved","path":"data"}]},"post_web_site_update_status":{"label":"变更站点状态","sideEffect":"WRITE","args":{"id":{"sources":["EVIDENCE"],"missing":{"action":"CALL_TOOL","tool":"get_web_site_list"},"label":"站点 ID"},"status":{"sources":["USER","MODEL"],"label":"目标状态"}},"success":{"path":"status","op":"EQ","value":200},"error":{"code":"errorCode","message":"errorMessage"}},"post_space_update_status":{"label":"变更内容空间状态","sideEffect":"WRITE","args":{"id":{"sources":["EVIDENCE"],"missing":{"action":"CALL_TOOL","tool":"get_space_list"},"label":"内容空间 ID"},"status":{"enum":["ENABLED","DISABLED"],"sources":["USER","MODEL"],"label":"目标状态"}},"success":{"path":"status","op":"EQ","value":200},"error":{"code":"errorCode","message":"errorMessage"}},"post_channel_update_status":{"label":"变更栏目状态","sideEffect":"WRITE","args":{"id":{"sources":["EVIDENCE"],"missing":{"action":"CALL_TOOL","tool":"get_channel_list"},"label":"栏目 ID"},"status":{"sources":["USER","MODEL"],"label":"目标状态"}},"success":{"path":"status","op":"EQ","value":200},"error":{"code":"errorCode","message":"errorMessage"}},"delete_web_site_id":{"label":"删除站点","sideEffect":"WRITE","args":{"id":{"sources":["EVIDENCE"],"missing":{"action":"CALL_TOOL","tool":"get_web_site_list"},"label":"站点 ID"}},"success":{"path":"status","op":"EQ","value":200},"error":{"code":"errorCode","message":"errorMessage"}},"delete_space_id":{"label":"删除内容空间","sideEffect":"WRITE","args":{"id":{"sources":["EVIDENCE"],"missing":{"action":"CALL_TOOL","tool":"get_space_list"},"label":"内容空间 ID"}},"success":{"path":"status","op":"EQ","value":200},"error":{"code":"errorCode","message":"errorMessage"}},"delete_channel_id":{"label":"删除栏目","sideEffect":"WRITE","args":{"id":{"sources":["EVIDENCE"],"missing":{"action":"CALL_TOOL","tool":"get_channel_list"},"label":"栏目 ID"}},"success":{"path":"status","op":"EQ","value":200},"error":{"code":"errorCode","message":"errorMessage"}},"get_web_site_page":{"label":"分页查询站点","sideEffect":"NONE","args":{"organId":{"from":"platform.organId","missing":{"action":"FAIL","message":"缺少机构上下文"}}},"success":{"path":"status","op":"EQ","value":200},"error":{"code":"errorCode","message":"errorMessage"},"extracts":[{"key":"web_site_list","path":"data.records","fields":["id","siteName","siteCode","domain","status"]}]},"get_space_page":{"label":"分页查询内容空间","sideEffect":"NONE","args":{"organId":{"from":"platform.organId","missing":{"action":"FAIL","message":"缺少机构上下文"}}},"success":{"path":"status","op":"EQ","value":200},"error":{"code":"errorCode","message":"errorMessage"},"extracts":[{"key":"space_list","path":"data.records","fields":["id","spaceName","spaceCode","spaceType","status"]}]},"get_channel_page":{"label":"分页查询栏目","sideEffect":"NONE","args":{"organId":{"from":"platform.organId","missing":{"action":"FAIL","message":"缺少机构上下文"}}},"success":{"path":"status","op":"EQ","value":200},"error":{"code":"errorCode","message":"errorMessage"},"extracts":[{"key":"channel_list","path":"data.records","fields":["id","siteId","spaceId","parentId","channelName","channelCode","channelType","path","categoryId","pageId","status"]}]}}}',
 'ACTIVE', 'CMS 信息架构能力', 0, 0),

(11002, 2, 'cms.article.lifecycle', '文章内容生命周期', 'PLATFORM',
 '负责 CMS 文章及文章分类。仅当本轮明确要求检索、撰写、发布或修改文章时选用。不负责建站、导航或标签。',
 '## 目标
完成本轮明确的文章查询、创建、草稿保存或发布。

## 业务规则
- 用空间名称或前情定位内容空间，不向用户要空间 ID。本轮未要求建空间时不得创建空间。
- 缺标题或正文时，只追问缺少的字段一次；用户补上的内容原样用于保存，不得再问、不得再让用户口头确认。
- 标题与正文已齐后立刻调用 post_article_save，被要求确认时调用 builtin_node_approval；审批卡就是确认入口，禁止再用 builtin_node_follow_up。
- 分类不是写文章的前提；用户未要求分类时不要创建或追问分类。
- 用户用中文说的状态、内容类型（如草稿、发布、Markdown）直接映射为对应枚举值提交，不追问确认。
- 未明确要求发布时保存为 DRAFT。发布必须用户本轮明确说出，对已有文章改 status=PUBLISHED，且须经用户确认；用户拒绝后不得再写。
- 新建或覆盖正文须经用户确认。
- 标签交由标签能力；不得编造文章、空间或正文。

## 前置与产出
- 写入前须已定位内容空间。
- 发布、修改须定位已有文章。
- 以工具返回的标识与状态为准。',
 '{"mode":"REACT","delegatable":false,"outputs":{"space_list":{"type":"LIST","fields":["id","spaceName","spaceCode","spaceType","status"],"required":false},"article_list":{"type":"LIST","fields":["id","spaceId","categoryId","title","status","author","contentType"],"required":false},"article_page":{"type":"LIST","fields":["id","spaceId","categoryId","title","status","author","contentType"],"required":false},"article_detail":{"type":"LIST","fields":["id","spaceId","categoryId","title","summary","status","content","contentType","author"],"required":false},"article_category_list":{"type":"LIST","fields":["id","spaceId","categoryName","categoryCode","status"],"required":false}},"doneWhen":"post_article_save succeeded OR delete_article_id succeeded OR post_article_category_save succeeded OR post_article_category_update_status succeeded OR delete_article_category_id succeeded OR get_article_list succeeded OR get_article_list empty OR get_article_page succeeded OR get_article_page empty OR get_article_category_list succeeded OR get_article_category_list empty OR get_article_category_page succeeded OR get_article_category_page empty OR get_article_detail succeeded","tools":{"get_space_list":{"label":"查询内容空间","sideEffect":"NONE","args":{"organId":{"from":"platform.organId","missing":{"action":"FAIL","message":"缺少机构上下文"}},"spaceName":{"required":false,"sources":["USER","MODEL"]},"spaceType":{"required":false,"enum":["WEBSITE","KNOWLEDGE","INTERNAL"],"sources":["USER","MODEL"]}},"success":{"path":"status","op":"EQ","value":200},"error":{"code":"errorCode","message":"errorMessage"},"extracts":[{"key":"space_list","path":"data","fields":["id","spaceName","spaceCode","spaceType","status"]}]},"get_article_list":{"label":"查询文章","sideEffect":"NONE","args":{"organId":{"from":"platform.organId","missing":{"action":"FAIL","message":"缺少机构上下文"}},"spaceId":{"required":false,"sources":["USER","EVIDENCE"]},"categoryId":{"required":false,"sources":["USER","EVIDENCE"]},"title":{"required":false,"sources":["USER","MODEL"]},"status":{"required":false,"enum":["DRAFT","PUBLISHED"],"sources":["USER","MODEL"]}},"success":{"path":"status","op":"EQ","value":200},"error":{"code":"errorCode","message":"errorMessage"},"extracts":[{"key":"article_list","path":"data","fields":["id","spaceId","categoryId","title","status","author","contentType"]}]},"get_article_page":{"label":"分页查询文章","sideEffect":"NONE","args":{"organId":{"from":"platform.organId","missing":{"action":"FAIL","message":"缺少机构上下文"}}},"success":{"path":"status","op":"EQ","value":200},"error":{"code":"errorCode","message":"errorMessage"},"extracts":[{"key":"article_page","path":"data.records","fields":["id","spaceId","categoryId","title","status","author","contentType"]}]},"get_article_detail":{"label":"查询文章详情","sideEffect":"NONE","args":{"id":{"sources":["EVIDENCE"],"missing":{"action":"CALL_TOOL","tool":"get_article_list"},"label":"文章 ID"}},"success":{"path":"status","op":"EQ","value":200},"error":{"code":"errorCode","message":"errorMessage"},"extracts":[{"key":"article_detail","path":"data","fields":["id","spaceId","categoryId","title","summary","status","content","contentType","author"]}]},"post_article_save":{"label":"保存文章","sideEffect":"WRITE","args":{"organId":{"from":"platform.organId","missing":{"action":"FAIL","message":"缺少机构上下文"}},"id":{"required":false,"sources":["EVIDENCE"],"label":"文章 ID"},"spaceId":{"sources":["EVIDENCE"],"missing":{"action":"CALL_TOOL","tool":"get_space_list","message":"先查询内容空间"},"label":"内容空间"},"categoryId":{"required":false,"sources":["EVIDENCE"],"label":"文章分类"},"title":{"sources":["USER","MODEL"],"label":"文章标题"},"content":{"sources":["USER","MODEL"],"label":"正文"},"contentType":{"required":false,"enum":["MARKDOWN","HTML"],"sources":["USER","MODEL"],"label":"内容类型"},"status":{"required":false,"enum":["DRAFT","PUBLISHED"],"sources":["USER","MODEL"],"label":"状态"}},"success":{"path":"status","op":"EQ","value":200},"error":{"code":"errorCode","message":"errorMessage"},"extracts":[{"key":"article_saved","path":"data"}]},"delete_article_id":{"label":"删除文章","sideEffect":"WRITE","args":{"id":{"sources":["EVIDENCE"],"missing":{"action":"CALL_TOOL","tool":"get_article_list"},"label":"文章 ID"}},"success":{"path":"status","op":"EQ","value":200},"error":{"code":"errorCode","message":"errorMessage"}},"get_article_category_list":{"label":"查询文章分类","sideEffect":"NONE","args":{"organId":{"from":"platform.organId","missing":{"action":"FAIL","message":"缺少机构上下文"}},"spaceId":{"required":false,"sources":["USER","EVIDENCE"]},"categoryName":{"required":false,"sources":["USER","MODEL"]}},"success":{"path":"status","op":"EQ","value":200},"error":{"code":"errorCode","message":"errorMessage"},"extracts":[{"key":"article_category_list","path":"data","fields":["id","spaceId","categoryName","categoryCode","status"]}]},"post_article_category_save":{"label":"保存文章分类","sideEffect":"WRITE","args":{"organId":{"from":"platform.organId","missing":{"action":"FAIL","message":"缺少机构上下文"}},"id":{"required":false,"sources":["EVIDENCE"],"label":"分类 ID"},"spaceId":{"sources":["EVIDENCE"],"missing":{"action":"CALL_TOOL","tool":"get_space_list","message":"先查询内容空间"},"label":"内容空间"},"categoryName":{"sources":["USER","MODEL"],"label":"分类名称"},"categoryCode":{"sources":["USER","MODEL"],"label":"分类编码"},"status":{"required":false,"enum":["ENABLED","DISABLED"],"sources":["USER","MODEL"],"label":"状态"}},"success":{"path":"status","op":"EQ","value":200},"error":{"code":"errorCode","message":"errorMessage"},"extracts":[{"key":"article_category_saved","path":"data"}]},"post_article_category_update_status":{"label":"变更文章分类状态","sideEffect":"WRITE","args":{"id":{"sources":["EVIDENCE"],"missing":{"action":"CALL_TOOL","tool":"get_article_category_list"},"label":"分类 ID"},"status":{"enum":["ENABLED","DISABLED"],"sources":["USER","MODEL"],"label":"目标状态"}},"success":{"path":"status","op":"EQ","value":200},"error":{"code":"errorCode","message":"errorMessage"}},"delete_article_category_id":{"label":"删除文章分类","sideEffect":"WRITE","args":{"id":{"sources":["EVIDENCE"],"missing":{"action":"CALL_TOOL","tool":"get_article_category_list"},"label":"分类 ID"}},"success":{"path":"status","op":"EQ","value":200},"error":{"code":"errorCode","message":"errorMessage"}},"post_space_save":{"label":"保存内容空间","sideEffect":"WRITE","args":{"organId":{"from":"platform.organId","missing":{"action":"FAIL","message":"缺少机构上下文"}},"id":{"required":false,"sources":["EVIDENCE"],"label":"内容空间 ID"},"spaceName":{"sources":["USER","MODEL"],"label":"空间名称"},"spaceCode":{"sources":["USER","MODEL"],"label":"空间编码"},"spaceType":{"enum":["WEBSITE","KNOWLEDGE","INTERNAL"],"sources":["USER","MODEL"],"label":"空间类型"},"status":{"enum":["ENABLED","DISABLED"],"sources":["USER","MODEL"],"label":"状态"}},"success":{"path":"status","op":"EQ","value":200},"error":{"code":"errorCode","message":"errorMessage"},"extracts":[{"key":"space_saved","path":"data"}]},"get_space_page":{"label":"分页查询内容空间","sideEffect":"NONE","args":{"organId":{"from":"platform.organId","missing":{"action":"FAIL","message":"缺少机构上下文"}}},"success":{"path":"status","op":"EQ","value":200},"error":{"code":"errorCode","message":"errorMessage"},"extracts":[{"key":"space_list","path":"data.records","fields":["id","spaceName","spaceCode","spaceType","status"]}]},"get_article_category_page":{"label":"分页查询文章分类","sideEffect":"NONE","args":{"organId":{"from":"platform.organId","missing":{"action":"FAIL","message":"缺少机构上下文"}}},"success":{"path":"status","op":"EQ","value":200},"error":{"code":"errorCode","message":"errorMessage"},"extracts":[{"key":"article_category_list","path":"data.records","fields":["id","spaceId","categoryName","categoryCode","status"]}]}}}',
 'ACTIVE', 'CMS 文章运营能力', 0, 0),

(11003, 2, 'cms.page.lifecycle', '静态页面生命周期', 'PLATFORM',
 '负责 CMS 静态页面。仅当本轮明确要求查询、创建、发布、撤回或删除静态页时选用。不负责文章或导航栏目。',
 '## 目标
完成本轮明确的静态页面查询或写入。

## 业务规则
- 页面归属于内容空间；用名称或前情定位，不向用户要空间 ID。本轮未要求建空间时不得创建空间。
- 查询/盘点查完即结束，空结果只陈述。
- 缺必填业务字段（如路径）才追问一次，用户补的内容原样用。
- 用户用中文说的状态、内容类型（如草稿、发布、Markdown）直接映射为对应枚举值提交，不追问确认。
- 业务字段已齐就直接调用写工具，被要求确认时调用 builtin_node_approval；审批卡就是确认入口，禁止用 builtin_node_follow_up 口头确认。
- 未明确发布时保持草稿。发布、撤回、删除须经用户确认；用户拒绝后不得再写。
- 挂到导航由信息架构能力负责。
- 不得编造页面或空间标识。

## 前置与产出
- 创建须已定位内容空间。
- 修改、发布、撤回、删除须定位目标页面。
- 以工具返回结果为准。',
 '{"mode":"REACT","delegatable":false,"outputs":{"space_list":{"type":"LIST","fields":["id","spaceName","spaceCode","spaceType","status"],"required":false},"page_list":{"type":"LIST","fields":["id","spaceId","pageName","pageCode","path","status","contentType"],"required":false},"page_page":{"type":"LIST","fields":["id","spaceId","pageName","pageCode","path","status","contentType"],"required":false}},"doneWhen":"post_page_save succeeded OR post_page_update_status succeeded OR delete_page_id succeeded OR get_page_list succeeded OR get_page_list empty OR get_page_page succeeded OR get_page_page empty","tools":{"get_space_list":{"label":"查询内容空间","sideEffect":"NONE","args":{"organId":{"from":"platform.organId","missing":{"action":"FAIL","message":"缺少机构上下文"}},"spaceName":{"required":false,"sources":["USER","MODEL"]},"spaceType":{"required":false,"enum":["WEBSITE","KNOWLEDGE","INTERNAL"],"sources":["USER","MODEL"]}},"success":{"path":"status","op":"EQ","value":200},"error":{"code":"errorCode","message":"errorMessage"},"extracts":[{"key":"space_list","path":"data","fields":["id","spaceName","spaceCode","spaceType","status"]}]},"get_page_list":{"label":"查询静态页面","sideEffect":"NONE","args":{"organId":{"from":"platform.organId","missing":{"action":"FAIL","message":"缺少机构上下文"}},"spaceId":{"required":false,"sources":["USER","EVIDENCE"]},"pageName":{"required":false,"sources":["USER","MODEL"]},"path":{"required":false,"sources":["USER","MODEL"]},"status":{"required":false,"enum":["DRAFT","PUBLISHED"],"sources":["USER","MODEL"]}},"success":{"path":"status","op":"EQ","value":200},"error":{"code":"errorCode","message":"errorMessage"},"extracts":[{"key":"page_list","path":"data","fields":["id","spaceId","pageName","pageCode","path","status","contentType"]}]},"get_page_page":{"label":"分页查询静态页面","sideEffect":"NONE","args":{"organId":{"from":"platform.organId","missing":{"action":"FAIL","message":"缺少机构上下文"}}},"success":{"path":"status","op":"EQ","value":200},"error":{"code":"errorCode","message":"errorMessage"},"extracts":[{"key":"page_page","path":"data.records","fields":["id","spaceId","pageName","pageCode","path","status","contentType"]}]},"post_page_save":{"label":"保存静态页面","sideEffect":"WRITE","args":{"organId":{"from":"platform.organId","missing":{"action":"FAIL","message":"缺少机构上下文"}},"id":{"required":false,"sources":["EVIDENCE"],"label":"页面 ID"},"spaceId":{"sources":["EVIDENCE"],"missing":{"action":"CALL_TOOL","tool":"get_space_list","message":"先查询内容空间"},"label":"内容空间"},"pageName":{"sources":["USER","MODEL"],"label":"页面名称"},"pageCode":{"required":false,"sources":["USER","MODEL"],"label":"页面编码"},"path":{"sources":["USER","MODEL"],"label":"访问路径"},"contentType":{"required":false,"enum":["MARKDOWN","HTML"],"sources":["USER","MODEL"],"label":"内容类型"},"status":{"required":false,"enum":["DRAFT","PUBLISHED"],"sources":["USER","MODEL"],"label":"状态"},"content":{"required":false,"sources":["USER","MODEL"],"label":"页面内容"}},"success":{"path":"status","op":"EQ","value":200},"error":{"code":"errorCode","message":"errorMessage"},"extracts":[{"key":"page_saved","path":"data"}]},"post_page_update_status":{"label":"变更静态页面状态","sideEffect":"WRITE","args":{"id":{"sources":["EVIDENCE"],"missing":{"action":"CALL_TOOL","tool":"get_page_list"},"label":"页面 ID"},"status":{"enum":["DRAFT","PUBLISHED"],"sources":["USER","MODEL"],"label":"目标状态"}},"success":{"path":"status","op":"EQ","value":200},"error":{"code":"errorCode","message":"errorMessage"}},"delete_page_id":{"label":"删除静态页面","sideEffect":"WRITE","args":{"id":{"sources":["EVIDENCE"],"missing":{"action":"CALL_TOOL","tool":"get_page_list"},"label":"页面 ID"}},"success":{"path":"status","op":"EQ","value":200},"error":{"code":"errorCode","message":"errorMessage"}},"post_space_save":{"label":"保存内容空间","sideEffect":"WRITE","args":{"organId":{"from":"platform.organId","missing":{"action":"FAIL","message":"缺少机构上下文"}},"id":{"required":false,"sources":["EVIDENCE"],"label":"内容空间 ID"},"spaceName":{"sources":["USER","MODEL"],"label":"空间名称"},"spaceCode":{"sources":["USER","MODEL"],"label":"空间编码"},"spaceType":{"enum":["WEBSITE","KNOWLEDGE","INTERNAL"],"sources":["USER","MODEL"],"label":"空间类型"},"status":{"enum":["ENABLED","DISABLED"],"sources":["USER","MODEL"],"label":"状态"}},"success":{"path":"status","op":"EQ","value":200},"error":{"code":"errorCode","message":"errorMessage"},"extracts":[{"key":"space_saved","path":"data"}]},"get_space_page":{"label":"分页查询内容空间","sideEffect":"NONE","args":{"organId":{"from":"platform.organId","missing":{"action":"FAIL","message":"缺少机构上下文"}}},"success":{"path":"status","op":"EQ","value":200},"error":{"code":"errorCode","message":"errorMessage"},"extracts":[{"key":"space_list","path":"data.records","fields":["id","spaceName","spaceCode","spaceType","status"]}]}}}',
 'ACTIVE', 'CMS 静态页运营能力', 0, 0),

(11004, 2, 'cms.tagging.manage', '标签与文章打标', 'PLATFORM',
 '负责 CMS 标签库及文章与标签的关系。本轮查询标签，或本轮明确要求创建标签、给文章打标。不负责文章正文、发布或导航。',
 '## 目标
完成本轮的标签查询，或创建标签并建立文章关系。

## 业务规则
- 仅查询标签时只查标签库，查完即结束，不创建、不绑定文章。
- 打标先查是否已有该标签；没有且本轮需要则先创建（审批），再绑定到文章（再一次审批）。标签名用用户原文。
- 目标文章从前情或会话已有文章解析，不向用户要文章 ID，不猜测不存在的文章。
- 业务字段已齐就直接调用写工具，被要求确认时调用 builtin_node_approval；审批卡就是确认入口，禁止用 builtin_node_follow_up 口头确认。
- 删除标签或解除关系须经用户确认。
- 不修改文章正文、发布状态或网站导航。

## 前置与产出
- 打标以实际标签和关系写入为准。
- 不得编造标签或文章标识。',
 '{"mode":"REACT","delegatable":false,"outputs":{"tag_list":{"type":"LIST","fields":["id","tagName"],"required":false},"tag_page":{"type":"LIST","fields":["id","tagName"],"required":false},"article_tag_relation_list":{"type":"LIST","fields":["id","articleId","tagId"],"required":false}},"doneWhen":"post_article_tag_relation_batch_add_tags succeeded OR post_tag_save succeeded OR delete_tag_id succeeded OR delete_article_tag_relation_id succeeded OR get_tag_list succeeded OR get_tag_list empty OR get_tag_page succeeded OR get_tag_page empty OR post_tag_by_article succeeded OR post_tag_by_article empty OR get_article_tag_relation_list succeeded OR get_article_tag_relation_list empty","tools":{"get_tag_list":{"label":"查询标签","sideEffect":"NONE","args":{"organId":{"from":"platform.organId","missing":{"action":"FAIL","message":"缺少机构上下文"}},"tagName":{"required":false,"sources":["USER","MODEL"]}},"success":{"path":"status","op":"EQ","value":200},"error":{"code":"errorCode","message":"errorMessage"},"extracts":[{"key":"tag_list","path":"data","fields":["id","tagName"]}]},"get_tag_page":{"label":"分页查询标签","sideEffect":"NONE","args":{"organId":{"from":"platform.organId","missing":{"action":"FAIL","message":"缺少机构上下文"}}},"success":{"path":"status","op":"EQ","value":200},"error":{"code":"errorCode","message":"errorMessage"},"extracts":[{"key":"tag_page","path":"data.records","fields":["id","tagName"]}]},"post_tag_save":{"label":"创建标签","sideEffect":"WRITE","args":{"organId":{"from":"platform.organId","missing":{"action":"FAIL","message":"缺少机构上下文"}},"id":{"required":false,"sources":["EVIDENCE"],"label":"标签 ID"},"tagName":{"sources":["USER","MODEL"],"label":"标签名称"}},"success":{"path":"status","op":"EQ","value":200},"error":{"code":"errorCode","message":"errorMessage"},"extracts":[{"key":"tag_saved","path":"data"}]},"delete_tag_id":{"label":"删除标签","sideEffect":"WRITE","args":{"id":{"sources":["EVIDENCE"],"missing":{"action":"CALL_TOOL","tool":"get_tag_list"},"label":"标签 ID"}},"success":{"path":"status","op":"EQ","value":200},"error":{"code":"errorCode","message":"errorMessage"}},"post_tag_by_article":{"label":"按文章查询标签","sideEffect":"NONE","args":{"articleIds[]":{"sources":["USER","EVIDENCE"],"label":"文章 ID"}},"success":{"path":"status","op":"EQ","value":200},"error":{"code":"errorCode","message":"errorMessage"},"extracts":[{"key":"tags_by_article","path":"data"}]},"post_article_tag_relation_batch_add_tags":{"label":"为文章添加标签","sideEffect":"WRITE","args":{"articleId":{"sources":["USER","EVIDENCE"],"label":"文章 ID"},"tagIds[]":{"sources":["EVIDENCE"],"label":"标签 ID"}},"success":{"path":"status","op":"EQ","value":200},"error":{"code":"errorCode","message":"errorMessage"},"extracts":[{"key":"article_tags_added","path":"data"}]},"get_article_tag_relation_list":{"label":"查询文章标签","sideEffect":"NONE","args":{"articleId":{"required":false,"sources":["USER","EVIDENCE"]},"tagId":{"required":false,"sources":["USER","EVIDENCE"]}},"success":{"path":"status","op":"EQ","value":200},"error":{"code":"errorCode","message":"errorMessage"},"extracts":[{"key":"article_tag_relation_list","path":"data","fields":["id","articleId","tagId"]}]},"delete_article_tag_relation_id":{"label":"解除文章标签","sideEffect":"WRITE","args":{"id":{"sources":["EVIDENCE"],"missing":{"action":"CALL_TOOL","tool":"get_article_tag_relation_list"},"label":"关系 ID"}},"success":{"path":"status","op":"EQ","value":200},"error":{"code":"errorCode","message":"errorMessage"}}}}',
 'ACTIVE', 'CMS 标签打标能力', 0, 0);

-- ---------------------------------------------
-- C. CMS Agent ↔ Skill 绑定
-- ---------------------------------------------
INSERT INTO `agent_skill_binding`
(`id`, `organ_id`, `agent_id`, `skill_id`, `enabled_flag`, `description`, `version`, `delete_flag`)
VALUES
(12001, 2, 10001, 11001, 1, NULL, 0, 0),
(12002, 2, 10001, 11002, 1, NULL, 0, 0),
(12003, 2, 10001, 11003, 1, NULL, 0, 0),
(12004, 2, 10001, 11004, 1, NULL, 0, 0);

-- ---------------------------------------------
-- D. CMS Skill ↔ Tool 绑定（MCP EndpointStrategy 名）
-- ---------------------------------------------
INSERT INTO `skill_tool_binding`
(`id`, `organ_id`, `skill_id`, `tool_name`, `enabled_flag`, `description`, `version`, `delete_flag`)
VALUES
-- cms.structure.manage
(13001, 2, 11001, 'get_web_site_list', 1, NULL, 0, 0),
(13002, 2, 11001, 'get_web_site_page', 1, NULL, 0, 0),
(13003, 2, 11001, 'post_web_site_save', 1, NULL, 0, 0),
(13004, 2, 11001, 'post_web_site_update_status', 1, NULL, 0, 0),
(13005, 2, 11001, 'delete_web_site_id', 1, NULL, 0, 0),
(13006, 2, 11001, 'get_space_list', 1, NULL, 0, 0),
(13007, 2, 11001, 'get_space_page', 1, NULL, 0, 0),
(13008, 2, 11001, 'post_space_save', 1, NULL, 0, 0),
(13009, 2, 11001, 'post_space_update_status', 1, NULL, 0, 0),
(13010, 2, 11001, 'delete_space_id', 1, NULL, 0, 0),
(13011, 2, 11001, 'get_channel_list', 1, NULL, 0, 0),
(13012, 2, 11001, 'get_channel_page', 1, NULL, 0, 0),
(13013, 2, 11001, 'post_channel_save', 1, NULL, 0, 0),
(13014, 2, 11001, 'post_channel_update_status', 1, NULL, 0, 0),
(13015, 2, 11001, 'delete_channel_id', 1, NULL, 0, 0),
-- cms.article.lifecycle
(13016, 2, 11002, 'get_article_list', 1, NULL, 0, 0),
(13017, 2, 11002, 'get_article_page', 1, NULL, 0, 0),
(13018, 2, 11002, 'get_article_detail', 1, NULL, 0, 0),
(13019, 2, 11002, 'post_article_save', 1, NULL, 0, 0),
(13020, 2, 11002, 'delete_article_id', 1, NULL, 0, 0),
(13021, 2, 11002, 'get_article_category_list', 1, NULL, 0, 0),
(13022, 2, 11002, 'get_article_category_page', 1, NULL, 0, 0),
(13023, 2, 11002, 'post_article_category_save', 1, NULL, 0, 0),
(13024, 2, 11002, 'post_article_category_update_status', 1, NULL, 0, 0),
(13025, 2, 11002, 'delete_article_category_id', 1, NULL, 0, 0),
(13039, 2, 11002, 'get_space_list', 1, '文章技能解析 spaceId', 0, 0),
(13040, 2, 11002, 'get_space_page', 1, '文章技能解析 spaceId', 0, 0),
(13043, 2, 11002, 'post_space_save', 1, '文章技能空空间时自动创建', 0, 0),
-- cms.page.lifecycle
(13026, 2, 11003, 'get_page_list', 1, NULL, 0, 0),
(13027, 2, 11003, 'get_page_page', 1, NULL, 0, 0),
(13028, 2, 11003, 'post_page_save', 1, NULL, 0, 0),
(13029, 2, 11003, 'post_page_update_status', 1, NULL, 0, 0),
(13030, 2, 11003, 'delete_page_id', 1, NULL, 0, 0),
(13041, 2, 11003, 'get_space_list', 1, '页面技能解析 spaceId', 0, 0),
(13042, 2, 11003, 'get_space_page', 1, '页面技能解析 spaceId', 0, 0),
(13044, 2, 11003, 'post_space_save', 1, '页面技能空空间时自动创建', 0, 0),
-- cms.tagging.manage
(13031, 2, 11004, 'get_tag_list', 1, NULL, 0, 0),
(13032, 2, 11004, 'get_tag_page', 1, NULL, 0, 0),
(13033, 2, 11004, 'post_tag_save', 1, NULL, 0, 0),
(13034, 2, 11004, 'delete_tag_id', 1, NULL, 0, 0),
(13035, 2, 11004, 'post_tag_by_article', 1, NULL, 0, 0),
(13036, 2, 11004, 'post_article_tag_relation_batch_add_tags', 1, NULL, 0, 0),
(13037, 2, 11004, 'get_article_tag_relation_list', 1, NULL, 0, 0),
(13038, 2, 11004, 'delete_article_tag_relation_id', 1, NULL, 0, 0);

-- ---------------------------------------------
-- E. CRM 模拟数字员工（CUSTOM，路由噪音）
-- ---------------------------------------------
INSERT INTO `agent_profile`
(`id`, `organ_id`, `agent_code`, `agent_name`, `resource_type`,
 `identity_desc`, `mission_desc`, `boundary_desc`, `style_desc`, `principle_desc`,
 `status`, `description`, `version`, `delete_flag`)
VALUES
(20001, 2, 'crm_sales_assistant', 'CRM销售助手（模拟）', 'CUSTOM',
 '你是企业 CRM 销售助手，面向客户档案、商机推进与报价协同。你处理的是客户关系与销售漏斗，不是内容站点、文章或页面。当用户提到官网文章、栏目导航、知识库空间时，应明确这不属于 CRM 职责。',
 '协助查询客户与商机、检索或起草报价、记录跟进要点，推动销售阶段前进。优先确认客户标识、商机编号或报价单号后再给结论。',
 '只覆盖客户、商机、报价与销售跟进；不操作 CMS 内容、不处理工单客服、不做契约盖章与财务入账。本数据为联调噪音模拟，无真实 CRM 后端时不得假装已落库成功。',
 '商务专业、简短有力。先给状态结论，再补关键字段。与 CMS 请求明显不符时直接说明应改派内容类数字员工。',
 '1) 关键对象标识缺失时先问清。2) 不把内容发布需求当成销售任务。3) 无工具或下游失败时明确告知。4) 金额与折扣不做越权承诺。',
 'ACTIVE', '测试噪音：模拟 CRM 销售 Agent', 0, 0),

(20002, 2, 'crm_service_desk', 'CRM客服工单助手（模拟）', 'CUSTOM',
 '你是企业 CRM 客服工单助手，负责服务请求、工单流转与客户投诉记录。你处理售后服务场景，不撰写官网文章，不维护站点栏目，也不负责销售报价。',
 '帮助用户创建或查询工单、更新处理进度、检索关联客户服务历史，并给出下一步处理建议。',
 '仅限工单与服务记录；不进入销售报价、不操作 CMS。作为测试噪音数据，若下游 CRM 服务不存在，必须如实说明无法执行，禁止伪造工单号。',
 '冷静、条理清晰，按工单状态与优先级组织回复。遇到内容管理诉求时明确拒识。',
 '1) 先定位工单号或客户标识。2) 状态变更需用户意图明确。3) 与 CMS/销售无关请求一律拒识。4) 无真实工具时不编造结果。',
 'ACTIVE', '测试噪音：模拟 CRM 客服 Agent', 0, 0);

-- ---------------------------------------------
-- F. CRM 模拟 Skill（CUSTOM，路由/规划噪音）
-- ---------------------------------------------
INSERT INTO `skill_profile`
(`id`, `organ_id`, `skill_key`, `skill_name`, `resource_type`, `semantic_desc`, `skill_manual`, `skill_contract`,
 `status`, `description`, `version`, `delete_flag`)
VALUES
(21001, 2, 'crm.sales.pipeline', '销售漏斗与报价协同', 'CUSTOM',
 '当用户目标属于销售侧客户经营时选用：客户建档与检索、商机创建/推进、报价单查询与起草、跟进记录沉淀。用于「查客户」「推商机」「出报价」「记跟进」等意图。不处理售后工单，也不处理 CMS 文章/站点。本技能为联调噪音数据，无真实 CRM 后端时不得伪造成交或落库成功。',
 '## 目标\n联调噪音：模拟销售漏斗与报价协同，用于路由/规划区分 CMS。\n\n## 流程\n1. 确认客户/商机/报价标识后再给结论。\n2. 仅可调用身份类占位工具；无真实 CRM 下游时明确说明无法落库。\n\n## 禁止\n- 不伪造成交、报价单号或落库成功。\n- 不承接工单或 CMS 内容请求。',
 '{"mode":"PLAN","delegatable":false,"inputs":{"customerId":{"required":false,"from":"shared.customerId"},"opportunityId":{"required":false,"from":"shared.opportunityId"}},"outputs":{},"tools":{"g_builtin_identity_user":{"sideEffect":"NONE"},"g_builtin_identity_tenant":{"sideEffect":"NONE"}}}',
 'ACTIVE', '模拟 CRM 销售能力', 0, 0),
(21002, 2, 'crm.service.ticket', '客服工单与服务历史', 'CUSTOM',
 '当用户目标属于售后服务时选用：工单创建/查询/状态更新，以及客户服务历史检索。用于投诉、故障报修、进度查询等意图。不承接销售报价或 CMS 内容运营。本技能为联调噪音数据，无真实下游时必须如实说明无法执行。',
 '## 目标\n联调噪音：模拟客服工单与服务历史，用于路由/规划区分销售与 CMS。\n\n## 流程\n1. 先定位工单号或客户标识。\n2. 仅可调用身份类占位工具；无真实下游时如实说明无法执行。\n\n## 禁止\n- 不伪造工单号或处理结果。\n- 不承接销售报价或 CMS 内容运营。',
 '{"mode":"PLAN","delegatable":false,"inputs":{"ticketId":{"required":false,"from":"shared.ticketId"},"customerId":{"required":false,"from":"shared.customerId"}},"outputs":{},"tools":{"g_builtin_identity_user":{"sideEffect":"NONE"},"g_builtin_identity_tenant":{"sideEffect":"NONE"}}}',
 'ACTIVE', '模拟 CRM 客服能力', 0, 0);

-- ---------------------------------------------
-- G. CRM Agent ↔ Skill 绑定
-- ---------------------------------------------
INSERT INTO `agent_skill_binding`
(`id`, `organ_id`, `agent_id`, `skill_id`, `enabled_flag`, `description`, `version`, `delete_flag`)
VALUES
(22001, 2, 20001, 21001, 1, NULL, 0, 0),
(22002, 2, 20002, 21002, 1, NULL, 0, 0);

-- ---------------------------------------------
-- H. CRM Skill ↔ Tool 绑定（内置身份工具，保证 Bundle 可加载）
-- ---------------------------------------------
INSERT INTO `skill_tool_binding`
(`id`, `organ_id`, `skill_id`, `tool_name`, `enabled_flag`, `description`, `version`, `delete_flag`)
VALUES
(23001, 2, 21001, 'g_builtin_identity_user', 1, 'CRM 噪音 Skill 占位工具', 0, 0),
(23002, 2, 21001, 'g_builtin_identity_tenant', 1, 'CRM 噪音 Skill 占位工具', 0, 0),
(23003, 2, 21002, 'g_builtin_identity_user', 1, 'CRM 噪音 Skill 占位工具', 0, 0),
(23004, 2, 21002, 'g_builtin_identity_tenant', 1, 'CRM 噪音 Skill 占位工具', 0, 0);
