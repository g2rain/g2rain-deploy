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
    `agent_id` BIGINT NOT NULL COMMENT                                                                  '所属数字员工主键（agent_profile.id）',
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
    PRIMARY KEY (`id`),
    INDEX `idx_agent_id` (`agent_id`, `delete_flag`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT=                             'Skill 定义表';

-- ---------------------------------------------
-- 3. Tool 绑定 (skill_tool_binding)
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

-- ---------------------------------------------
-- 4. Chat 问题模板 (chat_prompt_template)
-- ---------------------------------------------
DROP TABLE IF EXISTS `chat_prompt_template`;

CREATE TABLE `chat_prompt_template` (
    `id` BIGINT NOT NULL COMMENT                                                                        '主键标识',
    `organ_id` BIGINT NOT NULL COMMENT                                                                  '机构标识',
    `prompt_text` VARCHAR(1000) NOT NULL COMMENT                                                        '问题内容',
    `sort_order` INT NOT NULL DEFAULT 0 COMMENT                                                         '展示顺序，数值越小越靠前',
    `status` VARCHAR(32) NOT NULL DEFAULT 'ACTIVE' COMMENT                                              '状态[ACTIVE:启用, INACTIVE:禁用]',
    `description` VARCHAR(500) DEFAULT NULL COMMENT                                                     '备注',
    `create_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP COMMENT                                      '创建时间',
    `update_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT          '更新时间',
    `version` INT NOT NULL DEFAULT 0 COMMENT                                                            '记录版本',
    `delete_flag` TINYINT NOT NULL DEFAULT 0 COMMENT                                                    '逻辑删除标记[0:未删除, 1:已删除]',
    PRIMARY KEY (`id`),
    INDEX `idx_organ_status_order` (`organ_id`, `status`, `delete_flag`, `sort_order`, `id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT=                             'Chat 问题模板';

-- ---------------------------------------------
-- 5. 智能体会话绑定 (agent_session_binding)
-- ---------------------------------------------
DROP TABLE IF EXISTS `agent_session_binding`;

CREATE TABLE `agent_session_binding` (
    `id` BIGINT NOT NULL COMMENT                                                                        '主键标识',
    `organ_id` BIGINT NOT NULL COMMENT                                                                  '机构标识',
    `agent_id` BIGINT NOT NULL COMMENT                                                                  '数字员工主键（agent_profile.id）',
    `session_type` VARCHAR(32) NOT NULL COMMENT                                                         '会话主体类型[SessionType: USER|MEMBER|PASSPORT|ANONYMOUS]',
    `create_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP COMMENT                                      '创建时间',
    `update_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT          '更新时间',
    `version` INT NOT NULL DEFAULT 0 COMMENT                                                            '记录版本',
    `delete_flag` TINYINT NOT NULL DEFAULT 0 COMMENT                                                    '逻辑删除标记[0:未删除, 1:已删除]',
    PRIMARY KEY (`id`),
    UNIQUE INDEX `uk_agent_session` (`agent_id`, `session_type`, (IF(delete_flag = 0, 0, NULL)))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT=                             '智能体会话绑定表';

-- =============================================
-- 初始化数据
-- organ_id=3 对齐 g2rain-basis 平台机构
-- tool_name 对齐 mcp-registry EndpointStrategy（类型_服务_方法_路径，如 native_g2rain_cms_get_article_list）
-- =============================================

-- 数字员工
INSERT INTO `agent_profile`
(`id`, `organ_id`, `agent_code`, `agent_name`, `resource_type`, `identity_desc`, `mission_desc`, `boundary_desc`, `style_desc`, `principle_desc`, `status`, `description`, `version`, `delete_flag`)
VALUES
(1, 3, 'cms_assistant', 'CMS内容管理数字员工', 'PLATFORM', '你是 G2rain CMS 内容管理数字员工，负责多租户内容平台的网站、内容空间、导航结构、文章、静态页面、分类与标签等内容运营。', '按用户本轮明确要求推进 CMS 查询或写入。同句里的后续意图不提前规划、不提前执行。', '只处理 CMS 内容管理领域，不承接 CRM、销售、工单等非内容请求。不承诺系统未提供的 SEO、审批流、定时发布、DNS 或证书等能力。涉及删除、大规模变更、已发布内容覆盖或对外路径变更时需要用户确认。不编造未确认的业务结果。', '专业、克制。只做本轮当下动作。查询空结果只陈述事实。用户已给的业务字段原样使用。对象 ID 从查询或前情解析，不向用户索要。回复使用中文，术语与状态枚举与系统一致。', '只规划本轮立即要做的能力。查询/盘点只查被问到的对象，查完即结束，不建议创建。写入须用户本轮明确要求；organId 由平台注入，审批摘要不得展示平台注入字段原值。用户改口做另一件事时只做新请求。无法处理非 CMS 诉求时明确说明。', 'ACTIVE', 'g2rain-cms 生产数字员工（单 Agent）', 0, 0),
(2, 3, 'customer_service', '智能客服', 'PLATFORM', '你是本组织的智能客服，负责依据组织知识库中已发布的内容，解答客户关于产品、服务、政策和操作流程的咨询。', '帮助客户快速、准确地获得答案：理解客户的问题，从知识库检索相关依据，用简洁易懂的语言给出答复并注明出处；知识库没有覆盖的问题，如实说明并引导客户联系人工客服。', '- 只回答知识库中有依据的问题，不凭常识或推测补充业务结论（如价格、时效、政策条款、承诺事项）。
- 不办理任何业务操作，如退款、下单、修改订单、修改账户信息；客户提出办理需求时，说明办理途径或建议联系人工客服。
- 不索取、不复述客户的敏感信息（身份证号、银行卡号、密码、验证码等）。
- 不评价竞争对手，不讨论与本组织业务无关的话题。
- 知识库暂时不可用时，如实告知稍后再试，不得说成"没有相关规定"。', '- 语气亲切、专业、耐心，使用"您"称呼客户。
- 先给结论，再给必要的说明；一般不超过 5 句话，步骤类内容用编号列出。
- 使用客户能理解的表述，不出现系统术语、内部编码或技术细节。
- 在答复末尾注明参考来源，格式为"参考：<来源>"。', '- 先检索、后作答：每个业务问题都必须先检索知识库，不得跳过检索直接回答。
- 忠于依据：答复内容必须能在检索到的证据中找到出处，证据没有说到的部分明确说"暂未查到"。
- 证据冲突时，以版本较新、相关度较高的内容为准，并提示客户以最新规定为准。
- 问题含糊、无法检索到有效依据时，先请客户补充关键信息，最多追问一次。
- 不确定时宁可说明不知道，也不给出可能错误的答案。', 'ACTIVE', '基于组织知识库回答客户咨询，只依据已发布的知识作答', 0, 0);

-- 技能
INSERT INTO `skill_profile`
(`id`, `organ_id`, `agent_id`, `skill_key`, `skill_name`, `resource_type`, `semantic_desc`, `skill_manual`, `skill_contract`, `status`, `description`, `version`, `delete_flag`)
VALUES
(3, 3, 1, 'cms.structure.manage', '站点与信息架构管理', 'PLATFORM', '负责 CMS 网站、内容空间和导航栏目。本轮查询已有结构，或本轮明确要求创建、调整、停用或删除结构时才写入。不负责文章分类、文章正文、页面（静态页）或标签。', '## 目标
完成本轮被问到的结构查询，或用户本轮明确要求的网站/空间/栏目写入。

## 业务规则
- 查询/盘点只查用户问到的对象（网站、空间、栏目彼此独立）。盘点用列表查询，用户未要求翻页时不用分页。查完即结束；空列表只陈述没有，不追问、不建议默认值、不写入。
- 写入仅限用户本轮点名的那一层，不顺带创建未要求的网站、空间或栏目。
- 用户已给的名称、编码、域名等原样提交。从属对象（站点、父栏目）用列表查询或前情解析，不向用户要 ID。organId 由平台注入。
- 空间类型：官网 WEBSITE，知识库 KNOWLEDGE，内部 INTERNAL；用户未说时默认 KNOWLEDGE。新建空间须带名称、编码、类型、status=ENABLED，禁止空参。
- 栏目类型：LIST 挂文章分类，PAGE 挂静态页，LINK 用外部链接。
- 挂文章分类或静态页时，按名称调用 native_g2rain_cms_get_article_category_list 或 native_g2rain_cms_get_page_list 定位，不向用户要 ID；找不到时用 builtin_node_fail 说明需先创建。
- 不处理文章正文、静态页面正文或标签。

## 前置与产出
- 查询：汇报实际列表，空结果也算完成。
- 写入：以审批通过后的工具结果为准，不得编造。
- 写入目标无法完成（前置对象不存在、业务失败无法补救）时，用 builtin_node_fail 说明原因和用户可以怎么做；不得用 builtin_node_finish 收口，也不得为满足结束条件补调查询。', '{"mode": "REACT", "tools": {"native_g2rain_cms_get_space_list": {"args": {"organId": {"from": "platform.organId", "missing": {"action": "FAIL", "message": "缺少机构上下文"}}, "spaceName": {"sources": ["USER", "MODEL"], "required": false}, "spaceType": {"enum": ["WEBSITE", "KNOWLEDGE", "INTERNAL"], "sources": ["USER", "MODEL"], "required": false}}, "error": {"code": "errorCode", "message": "errorMessage"}, "label": "查询内容空间", "success": {"op": "EQ", "path": "status", "value": 200}, "extracts": [{"key": "space_list", "path": "data", "entity": {"id": "id", "name": "spaceName", "type": "space"}, "fields": ["id", "spaceName", "spaceCode", "spaceType", "status"]}], "sideEffect": "NONE"}, "native_g2rain_cms_delete_space_id": {"args": {"id": {"label": "内容空间 ID", "missing": {"tool": "native_g2rain_cms_get_space_list", "action": "CALL_TOOL"}, "sources": ["EVIDENCE", "PRIOR_TASK"]}}, "error": {"code": "errorCode", "message": "errorMessage"}, "label": "删除内容空间", "success": {"op": "EQ", "path": "status", "value": 200}, "sideEffect": "WRITE"}, "native_g2rain_cms_post_space_save": {"args": {"id": {"label": "内容空间 ID", "sources": ["EVIDENCE", "PRIOR_TASK"], "required": false}, "status": {"enum": ["ENABLED", "DISABLED"], "label": "状态", "sources": ["USER", "MODEL"]}, "organId": {"from": "platform.organId", "missing": {"action": "FAIL", "message": "缺少机构上下文"}}, "spaceCode": {"label": "空间编码", "sources": ["USER", "MODEL"]}, "spaceName": {"label": "空间名称", "sources": ["USER", "MODEL"]}, "spaceType": {"enum": ["WEBSITE", "KNOWLEDGE", "INTERNAL"], "label": "空间类型", "sources": ["USER", "MODEL"]}}, "error": {"code": "errorCode", "message": "errorMessage"}, "label": "保存内容空间", "success": {"op": "EQ", "path": "status", "value": 200}, "extracts": [{"key": "space_saved", "path": "data", "entity": {"name": "spaceName", "type": "space", "scalar": "id"}}], "sideEffect": "WRITE"}, "native_g2rain_cms_get_channel_list": {"args": {"siteId": {"sources": ["USER", "EVIDENCE", "PRIOR_TASK"], "required": false}, "organId": {"from": "platform.organId", "missing": {"action": "FAIL", "message": "缺少机构上下文"}}, "spaceId": {"sources": ["USER", "EVIDENCE", "PRIOR_TASK"], "required": false}, "parentId": {"sources": ["USER", "EVIDENCE", "PRIOR_TASK"], "required": false}, "channelName": {"sources": ["USER", "MODEL"], "required": false}}, "error": {"code": "errorCode", "message": "errorMessage"}, "label": "查询栏目", "success": {"op": "EQ", "path": "status", "value": 200}, "extracts": [{"key": "channel_list", "path": "data", "entity": {"id": "id", "name": "channelName", "type": "channel"}, "fields": ["id", "siteId", "spaceId", "parentId", "channelName", "channelCode", "channelType", "path", "categoryId", "pageId", "status"]}], "sideEffect": "NONE"}, "native_g2rain_cms_delete_channel_id": {"args": {"id": {"label": "栏目 ID", "missing": {"tool": "native_g2rain_cms_get_channel_list", "action": "CALL_TOOL"}, "sources": ["EVIDENCE", "PRIOR_TASK"]}}, "error": {"code": "errorCode", "message": "errorMessage"}, "label": "删除栏目", "success": {"op": "EQ", "path": "status", "value": 200}, "sideEffect": "WRITE"}, "native_g2rain_cms_get_web_site_list": {"args": {"organId": {"from": "platform.organId", "missing": {"action": "FAIL", "message": "缺少机构上下文"}}, "siteName": {"sources": ["USER", "MODEL"], "required": false}}, "error": {"code": "errorCode", "message": "errorMessage"}, "label": "查询站点", "success": {"op": "EQ", "path": "status", "value": 200}, "extracts": [{"key": "web_site_list", "path": "data", "entity": {"id": "id", "name": "siteName", "type": "site"}, "fields": ["id", "siteName", "siteCode", "domain", "status"]}], "sideEffect": "NONE"}, "native_g2rain_cms_post_channel_save": {"args": {"id": {"label": "栏目 ID", "sources": ["EVIDENCE", "PRIOR_TASK"], "required": false}, "path": {"label": "访问路径", "sources": ["USER", "MODEL"], "required": false}, "pageId": {"label": "静态页面", "sources": ["EVIDENCE", "PRIOR_TASK"], "required": false}, "siteId": {"label": "站点", "missing": {"tool": "native_g2rain_cms_get_web_site_list", "action": "CALL_TOOL", "message": "先查询站点"}, "sources": ["EVIDENCE", "PRIOR_TASK"]}, "linkUrl": {"label": "外链地址", "sources": ["USER", "MODEL"], "required": false}, "organId": {"from": "platform.organId", "missing": {"action": "FAIL", "message": "缺少机构上下文"}}, "spaceId": {"label": "内容空间", "missing": {"tool": "native_g2rain_cms_get_space_list", "action": "CALL_TOOL", "message": "先查询内容空间"}, "sources": ["EVIDENCE", "PRIOR_TASK"]}, "parentId": {"label": "父栏目", "sources": ["EVIDENCE", "PRIOR_TASK"], "required": false}, "categoryId": {"label": "文章分类", "sources": ["EVIDENCE", "PRIOR_TASK"], "required": false}, "channelCode": {"label": "栏目编码", "sources": ["USER", "MODEL"], "required": false}, "channelName": {"label": "栏目名称", "sources": ["USER", "MODEL"]}, "channelType": {"enum": ["LIST", "PAGE", "LINK"], "label": "栏目类型", "sources": ["USER", "MODEL"]}}, "error": {"code": "errorCode", "message": "errorMessage"}, "label": "保存栏目", "success": {"op": "EQ", "path": "status", "value": 200}, "extracts": [{"key": "channel_saved", "path": "data", "entity": {"name": "channelName", "type": "channel", "scalar": "id"}}], "sideEffect": "WRITE"}, "native_g2rain_cms_delete_web_site_id": {"args": {"id": {"label": "站点 ID", "missing": {"tool": "native_g2rain_cms_get_web_site_list", "action": "CALL_TOOL"}, "sources": ["EVIDENCE", "PRIOR_TASK"]}}, "error": {"code": "errorCode", "message": "errorMessage"}, "label": "删除站点", "success": {"op": "EQ", "path": "status", "value": 200}, "sideEffect": "WRITE"}, "native_g2rain_cms_post_web_site_save": {"args": {"id": {"label": "站点 ID", "sources": ["EVIDENCE", "PRIOR_TASK"], "required": false}, "domain": {"label": "站点域名", "sources": ["USER", "MODEL"], "required": false}, "status": {"enum": ["ENABLED", "DISABLED"], "label": "状态", "sources": ["USER", "MODEL"], "required": false}, "organId": {"from": "platform.organId", "missing": {"action": "FAIL", "message": "缺少机构上下文"}}, "siteCode": {"label": "站点编码", "sources": ["USER", "MODEL"]}, "siteName": {"label": "站点名称", "sources": ["USER", "MODEL"]}}, "error": {"code": "errorCode", "message": "errorMessage"}, "label": "保存站点", "success": {"op": "EQ", "path": "status", "value": 200}, "extracts": [{"key": "web_site_saved", "path": "data", "entity": {"name": "siteName", "type": "site", "scalar": "id"}}], "sideEffect": "WRITE"}, "native_g2rain_cms_post_space_update_status": {"args": {"id": {"label": "内容空间 ID", "missing": {"tool": "native_g2rain_cms_get_space_list", "action": "CALL_TOOL"}, "sources": ["EVIDENCE", "PRIOR_TASK"]}, "status": {"enum": ["ENABLED", "DISABLED"], "label": "目标状态", "sources": ["USER", "MODEL"]}}, "error": {"code": "errorCode", "message": "errorMessage"}, "label": "变更内容空间状态", "success": {"op": "EQ", "path": "status", "value": 200}, "sideEffect": "WRITE"}, "native_g2rain_cms_post_channel_update_status": {"args": {"id": {"label": "栏目 ID", "missing": {"tool": "native_g2rain_cms_get_channel_list", "action": "CALL_TOOL"}, "sources": ["EVIDENCE", "PRIOR_TASK"]}, "status": {"enum": ["ENABLED", "DISABLED"], "label": "目标状态", "sources": ["USER", "MODEL"]}}, "error": {"code": "errorCode", "message": "errorMessage"}, "label": "变更栏目状态", "success": {"op": "EQ", "path": "status", "value": 200}, "sideEffect": "WRITE"}, "native_g2rain_cms_post_web_site_update_status": {"args": {"id": {"label": "站点 ID", "missing": {"tool": "native_g2rain_cms_get_web_site_list", "action": "CALL_TOOL"}, "sources": ["EVIDENCE", "PRIOR_TASK"]}, "status": {"enum": ["ENABLED", "DISABLED"], "label": "目标状态", "sources": ["USER", "MODEL"]}}, "error": {"code": "errorCode", "message": "errorMessage"}, "label": "变更站点状态", "success": {"op": "EQ", "path": "status", "value": 200}, "sideEffect": "WRITE"}, "native_g2rain_cms_get_page_list": {"args": {"path": {"sources": ["USER", "MODEL"], "required": false}, "status": {"enum": ["DRAFT", "PUBLISHED"], "sources": ["USER", "MODEL"], "required": false}, "organId": {"from": "platform.organId", "missing": {"action": "FAIL", "message": "缺少机构上下文"}}, "spaceId": {"sources": ["USER", "EVIDENCE", "PRIOR_TASK"], "required": false}, "pageName": {"sources": ["USER", "MODEL"], "required": false}}, "error": {"code": "errorCode", "message": "errorMessage"}, "label": "查询静态页面", "success": {"op": "EQ", "path": "status", "value": 200}, "extracts": [{"key": "page_list", "path": "data", "entity": {"id": "id", "name": "pageName", "type": "page"}, "fields": ["id", "spaceId", "pageName", "pageCode", "path", "status", "contentType"]}], "sideEffect": "NONE"}, "native_g2rain_cms_get_article_category_list": {"args": {"organId": {"from": "platform.organId", "missing": {"action": "FAIL", "message": "缺少机构上下文"}}, "spaceId": {"sources": ["USER", "EVIDENCE", "PRIOR_TASK"], "required": false}, "categoryName": {"sources": ["USER", "MODEL"], "required": false}}, "error": {"code": "errorCode", "message": "errorMessage"}, "label": "查询文章分类", "success": {"op": "EQ", "path": "status", "value": 200}, "extracts": [{"key": "article_category_list", "path": "data", "entity": {"id": "id", "name": "categoryName", "type": "category"}, "fields": ["id", "spaceId", "categoryName", "categoryCode", "status"]}], "sideEffect": "NONE"}}, "outputs": {"space_list": {"type": "LIST", "fields": ["id", "spaceName", "spaceCode", "spaceType", "status"], "required": false}, "channel_list": {"type": "LIST", "fields": ["id", "siteId", "spaceId", "parentId", "channelName", "channelCode", "channelType", "path", "categoryId", "pageId", "status"], "required": false}, "web_site_list": {"type": "LIST", "fields": ["id", "siteName", "siteCode", "domain", "status"], "required": false}, "page_list": {"type": "LIST", "fields": ["id", "spaceId", "pageName", "pageCode", "path", "status", "contentType"], "required": false}, "article_category_list": {"type": "LIST", "fields": ["id", "spaceId", "categoryName", "categoryCode", "status"], "required": false}}, "delegatable": false}', 'ACTIVE', 'CMS 信息架构能力', 0, 0),
(5, 3, 1, 'cms.article.lifecycle', '文章内容生命周期', 'PLATFORM', '负责 CMS 文章及文章分类。本轮要求检索、撰写、发布、修改或删除文章，或查询、创建、调整、停用、删除文章分类时选用。不负责建站、导航栏目或标签。', '## 目标
完成本轮明确的文章查询、创建、草稿保存或发布，以及文章分类的查询与创建。

## 业务规则
- 写文章先定位内容空间：用空间名称或前情定位，不向用户要空间 ID。定位到空间之前不追问标题或正文。
- 用户指定的空间不存在时：还有其他空间就用 builtin_node_follow_up 列出可选空间让用户选；一个空间都没有就用 builtin_node_fail 说明需先创建内容空间。本能力不创建空间。
- 缺标题或正文时，只追问缺少的字段一次；用户补上的内容原样用于保存，不得再问。
- 用户本轮明确要求新建文章分类时，定位空间后直接调用 native_g2rain_cms_post_article_category_save。
- 写文章时，文章必须属于一个分类。用户指定了分类就按名称查询定位；没指定时先查该空间的分类：有分类就用 builtin_node_follow_up 列出分类让用户选，没有分类就用 builtin_node_follow_up 询问是否新建分类及分类名称，用户同意后再创建（创建同样须经确认）。不得自行决定分类或擅自建分类。
- 新建文章必须带标题和正文，contentType 默认传 MARKDOWN，用户明确要求 HTML 时传 HTML；只改状态时只传文章 ID 和目标状态，不回传标题、正文与内容类型。
- 未明确要求发布时保存为 DRAFT。发布必须用户本轮明确说出，对已有文章改 status=PUBLISHED，且须经用户确认；用户拒绝后不得再写。
- 新建或覆盖正文须经用户确认。
- 标签交由标签能力；不得编造文章、空间或正文。

## 前置与产出
- 写入前须已定位内容空间和文章分类。
- 发布、修改须定位已有文章。
- 以工具返回的标识与状态为准。
- 写入目标无法完成（前置对象不存在、业务失败无法补救）时，用 builtin_node_fail 说明原因和用户可以怎么做；不得用 builtin_node_finish 收口，也不得为满足结束条件补调查询。', '{"mode": "REACT", "tools": {"native_g2rain_cms_get_space_list": {"args": {"organId": {"from": "platform.organId", "missing": {"action": "FAIL", "message": "缺少机构上下文"}}, "spaceName": {"sources": ["USER", "MODEL"], "required": false}, "spaceType": {"enum": ["WEBSITE", "KNOWLEDGE", "INTERNAL"], "sources": ["USER", "MODEL"], "required": false}}, "error": {"code": "errorCode", "message": "errorMessage"}, "label": "查询内容空间", "success": {"op": "EQ", "path": "status", "value": 200}, "extracts": [{"key": "space_list", "path": "data", "entity": {"id": "id", "name": "spaceName", "type": "space"}, "fields": ["id", "spaceName", "spaceCode", "spaceType", "status"]}], "sideEffect": "NONE"}, "native_g2rain_cms_get_article_list": {"args": {"id": {"label": "文章 ID", "sources": ["EVIDENCE", "PRIOR_TASK"], "required": false}, "title": {"sources": ["USER", "MODEL"], "required": false}, "status": {"enum": ["DRAFT", "PUBLISHED"], "sources": ["USER", "MODEL"], "required": false}, "organId": {"from": "platform.organId", "missing": {"action": "FAIL", "message": "缺少机构上下文"}}, "spaceId": {"sources": ["USER", "EVIDENCE", "PRIOR_TASK"], "required": false}, "categoryId": {"sources": ["USER", "EVIDENCE", "PRIOR_TASK"], "required": false}}, "error": {"code": "errorCode", "message": "errorMessage"}, "label": "查询文章", "success": {"op": "EQ", "path": "status", "value": 200}, "extracts": [{"key": "article_list", "path": "data", "entity": {"id": "id", "name": "title", "type": "article"}, "fields": ["id", "spaceId", "categoryId", "title", "summary", "content", "status", "author", "contentType"]}], "sideEffect": "NONE"}, "native_g2rain_cms_delete_article_id": {"args": {"id": {"label": "文章 ID", "missing": {"tool": "native_g2rain_cms_get_article_list", "action": "CALL_TOOL"}, "sources": ["EVIDENCE", "PRIOR_TASK"]}}, "error": {"code": "errorCode", "message": "errorMessage"}, "label": "删除文章", "success": {"op": "EQ", "path": "status", "value": 200}, "sideEffect": "WRITE"}, "native_g2rain_cms_post_article_save": {"args": {"id": {"label": "文章 ID", "sources": ["EVIDENCE", "PRIOR_TASK"], "required": false}, "title": {"label": "文章标题", "sources": ["USER", "MODEL"], "required": false}, "status": {"enum": ["DRAFT", "PUBLISHED"], "label": "状态", "sources": ["USER", "MODEL"], "required": false}, "content": {"label": "正文", "sources": ["USER", "MODEL"], "required": false}, "organId": {"from": "platform.organId", "missing": {"action": "FAIL", "message": "缺少机构上下文"}}, "spaceId": {"label": "内容空间", "missing": {"tool": "native_g2rain_cms_get_space_list", "action": "CALL_TOOL", "message": "先查询内容空间"}, "sources": ["EVIDENCE", "PRIOR_TASK"]}, "categoryId": {"label": "文章分类", "missing": {"tool": "native_g2rain_cms_get_article_category_list", "action": "CALL_TOOL", "message": "先查询文章分类"}, "sources": ["EVIDENCE", "PRIOR_TASK"]}, "contentType": {"enum": ["MARKDOWN", "HTML"], "label": "内容类型", "sources": ["USER", "MODEL"], "required": false}}, "error": {"code": "errorCode", "message": "errorMessage"}, "label": "保存文章", "success": {"op": "EQ", "path": "status", "value": 200}, "extracts": [{"key": "article_saved", "path": "data", "entity": {"name": "title", "type": "article", "scalar": "id"}}], "sideEffect": "WRITE"}, "native_g2rain_cms_get_article_category_list": {"args": {"organId": {"from": "platform.organId", "missing": {"action": "FAIL", "message": "缺少机构上下文"}}, "spaceId": {"sources": ["USER", "EVIDENCE", "PRIOR_TASK"], "required": false}, "categoryName": {"sources": ["USER", "MODEL"], "required": false}}, "error": {"code": "errorCode", "message": "errorMessage"}, "label": "查询文章分类", "success": {"op": "EQ", "path": "status", "value": 200}, "extracts": [{"key": "article_category_list", "path": "data", "entity": {"id": "id", "name": "categoryName", "type": "category"}, "fields": ["id", "spaceId", "categoryName", "categoryCode", "status"]}], "sideEffect": "NONE"}, "native_g2rain_cms_delete_article_category_id": {"args": {"id": {"label": "分类 ID", "missing": {"tool": "native_g2rain_cms_get_article_category_list", "action": "CALL_TOOL"}, "sources": ["EVIDENCE", "PRIOR_TASK"]}}, "error": {"code": "errorCode", "message": "errorMessage"}, "label": "删除文章分类", "success": {"op": "EQ", "path": "status", "value": 200}, "sideEffect": "WRITE"}, "native_g2rain_cms_post_article_category_save": {"args": {"id": {"label": "分类 ID", "sources": ["EVIDENCE", "PRIOR_TASK"], "required": false}, "status": {"enum": ["ENABLED", "DISABLED"], "label": "状态", "sources": ["USER", "MODEL"], "required": false}, "organId": {"from": "platform.organId", "missing": {"action": "FAIL", "message": "缺少机构上下文"}}, "spaceId": {"label": "内容空间", "missing": {"tool": "native_g2rain_cms_get_space_list", "action": "CALL_TOOL", "message": "先查询内容空间"}, "sources": ["EVIDENCE", "PRIOR_TASK"]}, "categoryCode": {"label": "分类编码", "sources": ["USER", "MODEL"]}, "categoryName": {"label": "分类名称", "sources": ["USER", "MODEL"]}}, "error": {"code": "errorCode", "message": "errorMessage"}, "label": "保存文章分类", "success": {"op": "EQ", "path": "status", "value": 200}, "extracts": [{"key": "article_category_saved", "path": "data", "entity": {"name": "categoryName", "type": "category", "scalar": "id"}}], "sideEffect": "WRITE"}, "native_g2rain_cms_post_article_category_update_status": {"args": {"id": {"label": "分类 ID", "missing": {"tool": "native_g2rain_cms_get_article_category_list", "action": "CALL_TOOL"}, "sources": ["EVIDENCE", "PRIOR_TASK"]}, "status": {"enum": ["ENABLED", "DISABLED"], "label": "目标状态", "sources": ["USER", "MODEL"]}}, "error": {"code": "errorCode", "message": "errorMessage"}, "label": "变更文章分类状态", "success": {"op": "EQ", "path": "status", "value": 200}, "sideEffect": "WRITE"}}, "outputs": {"space_list": {"type": "LIST", "fields": ["id", "spaceName", "spaceCode", "spaceType", "status"], "required": false}, "article_list": {"type": "LIST", "fields": ["id", "spaceId", "categoryId", "title", "summary", "content", "status", "author", "contentType"], "required": false}, "article_category_list": {"type": "LIST", "fields": ["id", "spaceId", "categoryName", "categoryCode", "status"], "required": false}}, "delegatable": false}', 'ACTIVE', 'CMS 文章运营能力', 0, 0),
(6, 3, 1, 'cms.page.lifecycle', '静态页面生命周期', 'PLATFORM', '负责 CMS 页面（静态页）。本轮要求查询、创建、发布、撤回或删除页面时选用。不负责文章或导航栏目。', '## 目标
完成本轮明确的静态页面查询或写入。

## 业务规则
- 页面归属于内容空间；用名称或前情定位，不向用户要空间 ID。本轮未要求建空间时不得创建空间。
- 查询/盘点查完即结束，空结果只陈述。
- 缺必填业务字段（如路径）才追问一次，用户补的内容原样用。
- 未明确发布时保持草稿。发布、撤回、删除须经用户确认；用户拒绝后不得再写。
- 挂到导航由信息架构能力负责。
- 不得编造页面或空间标识。

## 前置与产出
- 创建须已定位内容空间。
- 修改、发布、撤回、删除须定位目标页面。
- 以工具返回结果为准。
- 写入目标无法完成（前置对象不存在、业务失败无法补救）时，用 builtin_node_fail 说明原因和用户可以怎么做；不得用 builtin_node_finish 收口，也不得为满足结束条件补调查询。', '{"mode": "REACT", "tools": {"native_g2rain_cms_get_page_list": {"args": {"path": {"sources": ["USER", "MODEL"], "required": false}, "status": {"enum": ["DRAFT", "PUBLISHED"], "sources": ["USER", "MODEL"], "required": false}, "organId": {"from": "platform.organId", "missing": {"action": "FAIL", "message": "缺少机构上下文"}}, "spaceId": {"sources": ["USER", "EVIDENCE", "PRIOR_TASK"], "required": false}, "pageName": {"sources": ["USER", "MODEL"], "required": false}}, "error": {"code": "errorCode", "message": "errorMessage"}, "label": "查询静态页面", "success": {"op": "EQ", "path": "status", "value": 200}, "extracts": [{"key": "page_list", "path": "data", "entity": {"id": "id", "name": "pageName", "type": "page"}, "fields": ["id", "spaceId", "pageName", "pageCode", "path", "status", "contentType"]}], "sideEffect": "NONE"}, "native_g2rain_cms_delete_page_id": {"args": {"id": {"label": "页面 ID", "missing": {"tool": "native_g2rain_cms_get_page_list", "action": "CALL_TOOL"}, "sources": ["EVIDENCE", "PRIOR_TASK"]}}, "error": {"code": "errorCode", "message": "errorMessage"}, "label": "删除静态页面", "success": {"op": "EQ", "path": "status", "value": 200}, "sideEffect": "WRITE"}, "native_g2rain_cms_get_space_list": {"args": {"organId": {"from": "platform.organId", "missing": {"action": "FAIL", "message": "缺少机构上下文"}}, "spaceName": {"sources": ["USER", "MODEL"], "required": false}, "spaceType": {"enum": ["WEBSITE", "KNOWLEDGE", "INTERNAL"], "sources": ["USER", "MODEL"], "required": false}}, "error": {"code": "errorCode", "message": "errorMessage"}, "label": "查询内容空间", "success": {"op": "EQ", "path": "status", "value": 200}, "extracts": [{"key": "space_list", "path": "data", "entity": {"id": "id", "name": "spaceName", "type": "space"}, "fields": ["id", "spaceName", "spaceCode", "spaceType", "status"]}], "sideEffect": "NONE"}, "native_g2rain_cms_post_page_save": {"args": {"id": {"label": "页面 ID", "sources": ["EVIDENCE", "PRIOR_TASK"], "required": false}, "path": {"label": "访问路径", "sources": ["USER", "MODEL"]}, "status": {"enum": ["DRAFT", "PUBLISHED"], "label": "状态", "sources": ["USER", "MODEL"], "required": false}, "content": {"label": "页面内容", "sources": ["USER", "MODEL"], "required": false}, "organId": {"from": "platform.organId", "missing": {"action": "FAIL", "message": "缺少机构上下文"}}, "spaceId": {"label": "内容空间", "missing": {"tool": "native_g2rain_cms_get_space_list", "action": "CALL_TOOL", "message": "先查询内容空间"}, "sources": ["EVIDENCE", "PRIOR_TASK"]}, "pageCode": {"label": "页面编码", "sources": ["USER", "MODEL"], "required": false}, "pageName": {"label": "页面名称", "sources": ["USER", "MODEL"]}, "contentType": {"enum": ["MARKDOWN", "HTML"], "label": "内容类型", "sources": ["USER", "MODEL"], "required": false}}, "error": {"code": "errorCode", "message": "errorMessage"}, "label": "保存静态页面", "success": {"op": "EQ", "path": "status", "value": 200}, "extracts": [{"key": "page_saved", "path": "data", "entity": {"name": "pageName", "type": "page", "scalar": "id"}}], "sideEffect": "WRITE"}, "native_g2rain_cms_post_space_save": {"args": {"id": {"label": "内容空间 ID", "sources": ["EVIDENCE", "PRIOR_TASK"], "required": false}, "status": {"enum": ["ENABLED", "DISABLED"], "label": "状态", "sources": ["USER", "MODEL"]}, "organId": {"from": "platform.organId", "missing": {"action": "FAIL", "message": "缺少机构上下文"}}, "spaceCode": {"label": "空间编码", "sources": ["USER", "MODEL"]}, "spaceName": {"label": "空间名称", "sources": ["USER", "MODEL"]}, "spaceType": {"enum": ["WEBSITE", "KNOWLEDGE", "INTERNAL"], "label": "空间类型", "sources": ["USER", "MODEL"]}}, "error": {"code": "errorCode", "message": "errorMessage"}, "label": "保存内容空间", "success": {"op": "EQ", "path": "status", "value": 200}, "extracts": [{"key": "space_saved", "path": "data", "entity": {"name": "spaceName", "type": "space", "scalar": "id"}}], "sideEffect": "WRITE"}, "native_g2rain_cms_post_page_update_status": {"args": {"id": {"label": "页面 ID", "missing": {"tool": "native_g2rain_cms_get_page_list", "action": "CALL_TOOL"}, "sources": ["EVIDENCE", "PRIOR_TASK"]}, "status": {"enum": ["DRAFT", "PUBLISHED"], "label": "目标状态", "sources": ["USER", "MODEL"]}}, "error": {"code": "errorCode", "message": "errorMessage"}, "label": "变更静态页面状态", "success": {"op": "EQ", "path": "status", "value": 200}, "sideEffect": "WRITE"}}, "outputs": {"page_list": {"type": "LIST", "fields": ["id", "spaceId", "pageName", "pageCode", "path", "status", "contentType"], "required": false}, "space_list": {"type": "LIST", "fields": ["id", "spaceName", "spaceCode", "spaceType", "status"], "required": false}}, "delegatable": false}', 'ACTIVE', 'CMS 静态页运营能力', 0, 0),
(7, 3, 1, 'cms.tagging.manage', '标签与文章打标', 'PLATFORM', '负责 CMS 标签库及文章与标签的关系。本轮查询标签，或本轮明确要求创建、删除标签，给文章打标或解除标签。不负责文章正文、发布或导航。', '## 目标
完成本轮的标签查询，或创建标签并建立文章关系。

## 业务规则
- 仅查询标签时只查标签库，查完即结束，不创建、不绑定文章。
- 打标前须知道标签是否已存在：上游步骤或前情已有结果时直接使用，没有时再查询；不存在且本轮需要则先创建（审批），再绑定到文章（再一次审批）。标签名用用户原文。
- 目标文章优先从上游步骤或前情解析；都没有时按标题调用 native_g2rain_cms_get_article_list 查询定位，不向用户要文章 ID，不猜测不存在的文章。
- 删除标签或解除关系须经用户确认。
- 不修改文章正文、发布状态或网站导航。

## 前置与产出
- 打标以实际标签和关系写入为准。
- 不得编造标签或文章标识。
- 写入目标无法完成（前置对象不存在、业务失败无法补救）时，用 builtin_node_fail 说明原因和用户可以怎么做；不得用 builtin_node_finish 收口，也不得为满足结束条件补调查询。', '{"mode": "REACT", "tools": {"native_g2rain_cms_get_tag_list": {"args": {"organId": {"from": "platform.organId", "missing": {"action": "FAIL", "message": "缺少机构上下文"}}, "tagName": {"sources": ["USER", "MODEL"], "required": false}}, "error": {"code": "errorCode", "message": "errorMessage"}, "label": "查询标签", "success": {"op": "EQ", "path": "status", "value": 200}, "extracts": [{"key": "tag_list", "path": "data", "entity": {"id": "id", "name": "tagName", "type": "tag"}, "fields": ["id", "tagName"]}], "sideEffect": "NONE"}, "native_g2rain_cms_delete_tag_id": {"args": {"id": {"label": "标签 ID", "missing": {"tool": "native_g2rain_cms_get_tag_list", "action": "CALL_TOOL"}, "sources": ["EVIDENCE", "PRIOR_TASK"]}}, "error": {"code": "errorCode", "message": "errorMessage"}, "label": "删除标签", "success": {"op": "EQ", "path": "status", "value": 200}, "sideEffect": "WRITE"}, "native_g2rain_cms_post_tag_save": {"args": {"id": {"label": "标签 ID", "sources": ["EVIDENCE", "PRIOR_TASK"], "required": false}, "organId": {"from": "platform.organId", "missing": {"action": "FAIL", "message": "缺少机构上下文"}}, "tagName": {"label": "标签名称", "sources": ["USER", "MODEL"]}}, "error": {"code": "errorCode", "message": "errorMessage"}, "label": "创建标签", "success": {"op": "EQ", "path": "status", "value": 200}, "extracts": [{"key": "tag_saved", "path": "data", "entity": {"name": "tagName", "type": "tag", "scalar": "id"}}], "sideEffect": "WRITE"}, "native_g2rain_cms_get_article_list": {"args": {"title": {"sources": ["USER", "MODEL"], "required": false}, "status": {"enum": ["DRAFT", "PUBLISHED"], "sources": ["USER", "MODEL"], "required": false}, "organId": {"from": "platform.organId", "missing": {"action": "FAIL", "message": "缺少机构上下文"}}, "spaceId": {"sources": ["USER", "EVIDENCE", "PRIOR_TASK"], "required": false}, "categoryId": {"sources": ["USER", "EVIDENCE", "PRIOR_TASK"], "required": false}}, "error": {"code": "errorCode", "message": "errorMessage"}, "label": "查询文章", "success": {"op": "EQ", "path": "status", "value": 200}, "extracts": [{"key": "article_list", "path": "data", "entity": {"id": "id", "name": "title", "type": "article"}, "fields": ["id", "spaceId", "categoryId", "title", "status", "author", "contentType"]}], "sideEffect": "NONE"}, "native_g2rain_cms_post_tag_by_article": {"args": {"articleIds[]": {"label": "文章 ID", "missing": {"tool": "native_g2rain_cms_get_article_list", "action": "CALL_TOOL"}, "sources": ["EVIDENCE", "PRIOR_TASK"]}}, "error": {"code": "errorCode", "message": "errorMessage"}, "label": "按文章查询标签", "success": {"op": "EQ", "path": "status", "value": 200}, "extracts": [{"key": "tags_by_article", "path": "data"}], "sideEffect": "NONE"}, "native_g2rain_cms_get_article_tag_relation_list": {"args": {"tagId": {"sources": ["USER", "EVIDENCE", "PRIOR_TASK"], "required": false}, "articleId": {"sources": ["EVIDENCE", "PRIOR_TASK"], "required": false}}, "error": {"code": "errorCode", "message": "errorMessage"}, "label": "查询文章标签", "success": {"op": "EQ", "path": "status", "value": 200}, "extracts": [{"key": "article_tag_relation_list", "path": "data", "fields": ["id", "articleId", "tagId"]}], "sideEffect": "NONE"}, "native_g2rain_cms_delete_article_tag_relation_id": {"args": {"id": {"label": "关系 ID", "missing": {"tool": "native_g2rain_cms_get_article_tag_relation_list", "action": "CALL_TOOL"}, "sources": ["EVIDENCE", "PRIOR_TASK"]}}, "error": {"code": "errorCode", "message": "errorMessage"}, "label": "解除文章标签", "success": {"op": "EQ", "path": "status", "value": 200}, "sideEffect": "WRITE"}, "native_g2rain_cms_post_article_tag_relation_batch_add_tags": {"args": {"tagIds[]": {"label": "标签 ID", "sources": ["EVIDENCE", "PRIOR_TASK"]}, "articleId": {"label": "文章 ID", "missing": {"tool": "native_g2rain_cms_get_article_list", "action": "CALL_TOOL"}, "sources": ["EVIDENCE", "PRIOR_TASK"]}}, "error": {"code": "errorCode", "message": "errorMessage"}, "label": "为文章添加标签", "success": {"op": "EQ", "path": "status", "value": 200}, "extracts": [{"key": "article_tags_added", "path": "data"}], "sideEffect": "WRITE"}}, "outputs": {"tag_list": {"type": "LIST", "fields": ["id", "tagName"], "required": false}, "article_tag_relation_list": {"type": "LIST", "fields": ["id", "articleId", "tagId"], "required": false}}, "delegatable": false}', 'ACTIVE', 'CMS 标签打标能力', 0, 0),
(8, 3, 2, 'knowledge.qa', '知识问答', 'PLATFORM', '负责基于组织知识库回答客户咨询。适用于产品功能、服务政策、收费规则、售后流程、操作指引等需要查阅资料的问题。不负责办理退款、下单、修改账户等业务操作，也不处理与本组织业务无关的闲聊。', '## 目标
根据客户的问题调用知识问答，由知识库基于证据生成答复。

## 业务规则
- 先调用后作答：回答任何业务问题前，都必须调用知识问答；不得依据常识或记忆直接作答。
- 检索语句：把客户的问题改写成简洁的检索语句，保留关键名词（产品名、业务名、时间、金额等），去掉寒暄和语气词。
- 结合上下文：客户追问"那多久到账""这个呢"之类时，结合之前的对话补全主语后再调用。
- 多个问题：只调用一次，把多个问题合并在同一条检索语句中。
- 标签与条数：不要自行填写标签编码和返回条数，使用服务默认值；只有客户明确给出标签编码时才填写。
- 调用失败时：告知客户"知识库暂时无法访问，请稍后再试"，不得说成没有相关规定。
- 办理类请求（退款、下单、改地址、改账户等）：同样调用知识问答，由知识库给出办理途径；本客服只能解答咨询。
- 不得编造任何业务数据、政策条款、时效或金额。

## 前置与产出
- 需要的输入：客户的问题（必要时结合对话上下文）。
- 产出：知识问答返回的答复。', '{"mode": "REACT", "tools": {"native_g2rain_knowledge_post_knowledge_answer": {"args": {"topK": {"sources": ["MODEL"], "required": false}, "query": {"label": "问题", "sources": ["USER", "MODEL"]}, "allTagCodes": {"sources": ["USER"], "required": false}, "anyTagCodes": {"sources": ["USER"], "required": false}}, "error": {"code": "errorCode", "message": "errorMessage"}, "label": "知识问答", "success": {"op": "EQ", "path": "status", "value": 200}, "extracts": [{"key": "evidence", "path": "data.sources"}], "sideEffect": "NONE", "returnDirect": "data.answer"}}, "delegatable": true}', 'ACTIVE', NULL, 0, 0);

-- 技能工具绑定
INSERT INTO `skill_tool_binding`
(`id`, `organ_id`, `skill_id`, `tool_name`, `enabled_flag`, `description`, `version`, `delete_flag`)
VALUES
(9, 3, 3, 'native_g2rain_cms_get_web_site_list', 1, NULL, 0, 0),
(10, 3, 3, 'native_g2rain_cms_post_web_site_save', 1, NULL, 0, 0),
(11, 3, 3, 'native_g2rain_cms_post_web_site_update_status', 1, NULL, 0, 0),
(12, 3, 3, 'native_g2rain_cms_delete_web_site_id', 1, NULL, 0, 0),
(13, 3, 3, 'native_g2rain_cms_get_space_list', 1, NULL, 0, 0),
(15, 3, 3, 'native_g2rain_cms_post_space_save', 1, NULL, 0, 0),
(16, 3, 3, 'native_g2rain_cms_post_space_update_status', 1, NULL, 0, 0),
(17, 3, 3, 'native_g2rain_cms_delete_space_id', 1, NULL, 0, 0),
(18, 3, 3, 'native_g2rain_cms_get_channel_list', 1, NULL, 0, 0),
(19, 3, 3, 'native_g2rain_cms_post_channel_save', 1, NULL, 0, 0),
(20, 3, 3, 'native_g2rain_cms_post_channel_update_status', 1, NULL, 0, 0),
(21, 3, 3, 'native_g2rain_cms_delete_channel_id', 1, NULL, 0, 0),
(22, 3, 3, 'native_g2rain_cms_get_page_list', 1, NULL, 0, 0),
(23, 3, 3, 'native_g2rain_cms_get_article_category_list', 1, NULL, 0, 0),
(25, 3, 5, 'native_g2rain_cms_get_article_list', 1, NULL, 0, 0),
(26, 3, 5, 'native_g2rain_cms_post_article_save', 1, NULL, 0, 0),
(27, 3, 5, 'native_g2rain_cms_delete_article_id', 1, NULL, 0, 0),
(28, 3, 5, 'native_g2rain_cms_get_article_category_list', 1, NULL, 0, 0),
(29, 3, 5, 'native_g2rain_cms_post_article_category_save', 1, NULL, 0, 0),
(30, 3, 5, 'native_g2rain_cms_post_article_category_update_status', 1, NULL, 0, 0),
(31, 3, 5, 'native_g2rain_cms_delete_article_category_id', 1, NULL, 0, 0),
(32, 3, 6, 'native_g2rain_cms_get_page_list', 1, NULL, 0, 0),
(33, 3, 6, 'native_g2rain_cms_post_page_save', 1, NULL, 0, 0),
(35, 3, 6, 'native_g2rain_cms_post_page_update_status', 1, NULL, 0, 0),
(36, 3, 6, 'native_g2rain_cms_delete_page_id', 1, NULL, 0, 0),
(37, 3, 7, 'native_g2rain_cms_get_tag_list', 1, NULL, 0, 0),
(38, 3, 7, 'native_g2rain_cms_post_tag_save', 1, NULL, 0, 0),
(39, 3, 7, 'native_g2rain_cms_delete_tag_id', 1, NULL, 0, 0),
(50, 3, 7, 'native_g2rain_cms_post_tag_by_article', 1, NULL, 0, 0),
(51, 3, 7, 'native_g2rain_cms_post_article_tag_relation_batch_add_tags', 1, NULL, 0, 0),
(52, 3, 7, 'native_g2rain_cms_get_article_tag_relation_list', 1, NULL, 0, 0),
(53, 3, 7, 'native_g2rain_cms_delete_article_tag_relation_id', 1, NULL, 0, 0),
(55, 3, 5, 'native_g2rain_cms_get_space_list', 1, '文章技能解析 spaceId', 0, 0),
(56, 3, 6, 'native_g2rain_cms_get_space_list', 1, '页面技能解析 spaceId', 0, 0),
(57, 3, 6, 'native_g2rain_cms_post_space_save', 1, '页面技能空空间时自动创建', 0, 0),
(58, 3, 7, 'native_g2rain_cms_get_article_list', 1, '打标技能按标题定位文章', 0, 0),
(59, 3, 8, 'native_g2rain_knowledge_post_knowledge_answer', 1, NULL, 0, 0);

-- Chat 问题模板
INSERT INTO `chat_prompt_template`
(`id`, `organ_id`, `prompt_text`, `sort_order`, `status`, `description`, `version`, `delete_flag`)
VALUES
(60, 3, 'G2rain 适合哪些客服场景？', 1, 'ACTIVE', NULL, 0, 0),
(61, 3, '知识库如何保证回答有据可查？', 2, 'ACTIVE', NULL, 0, 0),
(62, 3, '智能客服能接入企业现有系统吗？', 3, 'ACTIVE', NULL, 0, 0),
(63, 3, '如何在企业环境中部署 G2rain？', 5, 'ACTIVE', NULL, 0, 0),
(65, 3, '怎样避免不同组织间的数据越权？', 6, 'ACTIVE', NULL, 0, 0);

-- 智能体会话绑定（宣传体验阶段：匿名即可访问）
INSERT INTO `agent_session_binding`
(`id`, `organ_id`, `agent_id`, `session_type`, `version`, `delete_flag`)
VALUES
(66, 3, 1, 'ANONYMOUS', 0, 0),
(67, 3, 1, 'USER', 0, 0),
(68, 3, 1, 'MEMBER', 0, 0),
(69, 3, 2, 'ANONYMOUS', 0, 0),
(70, 3, 2, 'USER', 0, 0),
(71, 3, 2, 'MEMBER', 0, 0);
