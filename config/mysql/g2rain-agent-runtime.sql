-- =============================================
-- g2rain_agent_runtime 数据库表结构
-- MySQL 8.0
-- =============================================

-- 创建数据库
CREATE DATABASE IF NOT EXISTS `g2rain_agent_runtime` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE `g2rain_agent_runtime`;

-- ---------------------------------------------
-- 1. 聊天会话 (chat_conversation)
-- ---------------------------------------------
DROP TABLE IF EXISTS `chat_conversation`;

CREATE TABLE `chat_conversation` (
    `id` BIGINT NOT NULL COMMENT                                                                        '主键标识',
    `organ_id` BIGINT NOT NULL COMMENT                                                                  '机构标识',
    `conversation_id` VARCHAR(64) NOT NULL COMMENT                                                      '会话唯一标识',
    `user_id` BIGINT NOT NULL COMMENT                                                                   '用户标识',
    `title` VARCHAR(256) DEFAULT NULL COMMENT                                                           '会话标题',
    `active_task_id` VARCHAR(64) DEFAULT NULL COMMENT                                                   '当前运行或挂起中的任务',
    `session_shared` JSON DEFAULT NULL COMMENT                                                          '会话级共享值（带来源与过期时间）',
    `state_version` BIGINT NOT NULL DEFAULT 0 COMMENT                                                   '本轮栅栏版本；新会话为 0，落库按此单调推进',
    `last_message_time` TIMESTAMP NULL DEFAULT NULL COMMENT                                             '最近消息时间',
    `create_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP COMMENT                                      '创建时间',
    `update_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT          '更新时间',
    `version` INT NOT NULL DEFAULT 0 COMMENT                                                            '记录版本',
    `delete_flag` TINYINT NOT NULL DEFAULT 0 COMMENT                                                    '删除标识[0:未删除, 1:已删除]',
    PRIMARY KEY (`id`),
    INDEX `idx_organ_conversation` (`organ_id`, `conversation_id`),
    INDEX `idx_organ_user` (`organ_id`, `user_id`),
    INDEX `idx_organ_user_last_msg` (`organ_id`, `user_id`, `last_message_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT=                             '聊天会话表';

-- ---------------------------------------------
-- 2. 聊天消息 (chat_message)
-- ---------------------------------------------
DROP TABLE IF EXISTS `chat_message`;

CREATE TABLE `chat_message` (
    `id` BIGINT NOT NULL COMMENT                                                                        '主键标识',
    `organ_id` BIGINT NOT NULL COMMENT                                                                  '机构标识',
    `conversation_id` VARCHAR(64) NOT NULL COMMENT                                                      '所属会话',
    `task_id` VARCHAR(64) DEFAULT NULL COMMENT                                                          '关联任务；可空',
    `node_id` VARCHAR(64) DEFAULT NULL COMMENT                                                          '中间文字所属节点',
    `round` INT DEFAULT NULL COMMENT                                                                    '中间文字所属 ReAct 轮次',
    `message_id` VARCHAR(64) NOT NULL COMMENT                                                           '消息业务标识',
    `channel` VARCHAR(32) DEFAULT NULL COMMENT                                                          '来源渠道/客户端应用',
    `model` VARCHAR(128) DEFAULT NULL COMMENT                                                           '模型名：用户消息为所选模型，最终回复为实际调用模型',
    `role` VARCHAR(32) NOT NULL COMMENT                                                                 '角色[USER, AGENT]',
    `message_type` VARCHAR(32) NOT NULL DEFAULT 'USER_TEXT' COMMENT                                     '消息类型[USER_TEXT, AGENT_REPLY]',
    `content` MEDIUMTEXT NOT NULL COMMENT                                                               '消息内容',
    `trace_id` VARCHAR(64) DEFAULT NULL COMMENT                                                         '本条消息追踪号',
    `created_at_ms` BIGINT NOT NULL COMMENT                                                             '业务发言时间 epoch ms',
    `elapsed_ms` INT DEFAULT NULL COMMENT                                                               '本轮耗时毫秒；仅最终回复',
    `create_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP COMMENT                                      '入库时间',
    `update_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT          '更新时间',
    `version` INT NOT NULL DEFAULT 0 COMMENT                                                            '记录版本',
    `delete_flag` TINYINT NOT NULL DEFAULT 0 COMMENT                                                    '删除标识[0:未删除, 1:已删除]',
    PRIMARY KEY (`id`),
    INDEX `idx_organ_message` (`organ_id`, `message_id`),
    INDEX `idx_organ_conversation` (`organ_id`, `conversation_id`, `created_at_ms`),
    INDEX `idx_organ_task` (`organ_id`, `task_id`),
    INDEX `idx_organ_trace` (`organ_id`, `trace_id`),
    INDEX `idx_organ_task_node` (`organ_id`, `task_id`, `node_id`, `created_at_ms`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT=                             '聊天消息表';

-- ---------------------------------------------
-- 3. 任务实例 (task_instance)
-- ---------------------------------------------
DROP TABLE IF EXISTS `task_instance`;

CREATE TABLE `task_instance` (
    `id` BIGINT NOT NULL COMMENT                                                                        '主键标识',
    `organ_id` BIGINT NOT NULL COMMENT                                                                  '机构标识',
    `conversation_id` VARCHAR(64) NOT NULL COMMENT                                                      '所属会话',
    `task_id` VARCHAR(64) NOT NULL COMMENT                                                              '任务业务标识',
    `agent_id` BIGINT DEFAULT NULL COMMENT                                                              '绑定的 Agent 主键',
    `goal_summary` VARCHAR(2000) DEFAULT NULL COMMENT                                                   '任务目标摘要',
    `request` MEDIUMTEXT DEFAULT NULL COMMENT                                                           '开任务时的用户原文',
    `skill_versions` JSON DEFAULT NULL COMMENT                                                          '开跑时固定的 skill 版本',
    `shared` JSON DEFAULT NULL COMMENT                                                                  '任务级共享值',
    `prior` JSON DEFAULT NULL COMMENT                                                                   '前情',
    `task_record` JSON DEFAULT NULL COMMENT                                                             '结束时的任务记录',
    `source_message_id` VARCHAR(64) DEFAULT NULL COMMENT                                                '触发开任务的消息标识',
    `status` VARCHAR(32) NOT NULL DEFAULT 'RUNNING' COMMENT                                             '任务状态[RUNNING, SUSPENDED, SUCCEEDED, FAILED, CANCELED]',
    `current_node_id` VARCHAR(64) DEFAULT NULL COMMENT                                                  '当前节点',
    `final_message` VARCHAR(2000) DEFAULT NULL COMMENT                                                  '终态对外文案',
    `started_time` TIMESTAMP NULL DEFAULT NULL COMMENT                                                  '开始时间',
    `suspended_time` TIMESTAMP NULL DEFAULT NULL COMMENT                                                '最近一次挂起时间',
    `finished_time` TIMESTAMP NULL DEFAULT NULL COMMENT                                                 '结束时间',
    `trace_id` VARCHAR(64) DEFAULT NULL COMMENT                                                         '开任务入站追踪号',
    `state_version` BIGINT NOT NULL DEFAULT 0 COMMENT                                                   '本轮栅栏版本，落库按此单调推进',
    `create_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP COMMENT                                      '创建时间',
    `update_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT          '更新时间',
    `version` INT NOT NULL DEFAULT 0 COMMENT                                                            '记录版本',
    `delete_flag` TINYINT NOT NULL DEFAULT 0 COMMENT                                                    '删除标识[0:未删除, 1:已删除]',
    PRIMARY KEY (`id`),
    INDEX `idx_organ_task` (`organ_id`, `task_id`),
    INDEX `idx_organ_conversation` (`organ_id`, `conversation_id`),
    INDEX `idx_organ_status` (`organ_id`, `status`),
    INDEX `idx_organ_conversation_finished` (`organ_id`, `conversation_id`, `finished_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT=                             '任务实例表';

-- ---------------------------------------------
-- 4. 任务图节点 / 步骤 (task_graph_node)
-- ---------------------------------------------
DROP TABLE IF EXISTS `task_graph_node`;

CREATE TABLE `task_graph_node` (
    `id` BIGINT NOT NULL COMMENT                                                                        '主键标识',
    `organ_id` BIGINT NOT NULL COMMENT                                                                  '机构标识',
    `task_id` VARCHAR(64) NOT NULL COMMENT                                                              '所属任务',
    `node_id` VARCHAR(64) NOT NULL COMMENT                                                              '步骤业务标识',
    `title` VARCHAR(256) DEFAULT NULL COMMENT                                                           '步骤标题',
    `objective` VARCHAR(2000) DEFAULT NULL COMMENT                                                      '步骤硬目标（给 ReAct）',
    `skill_key` VARCHAR(128) DEFAULT NULL COMMENT                                                       '技能键',
    `target` VARCHAR(128) DEFAULT NULL COMMENT                                                          '完成目标：节点要完成的写工具注册名',
    `target_claimed` TINYINT NOT NULL DEFAULT 0 COMMENT                                                 '完成目标是否由首个写调用自动记录[0:否, 1:是]',
    `delegate_depth` INT NOT NULL DEFAULT 0 COMMENT                                                     '委派深度',
    `status` VARCHAR(32) NOT NULL DEFAULT 'PENDING' COMMENT                                             '步骤状态[PENDING, READY, RUNNING, WAITING_DELEGATE, SUSPENDED, DONE, FAILED, SKIPPED, CANCELLED, TIMEOUT]',
    `result` VARCHAR(2000) DEFAULT NULL COMMENT                                                         '节点结论：完成时给用户的结论',
    `state` JSON DEFAULT NULL COMMENT                                                                   '节点空间（便签、轮次、动作）',
    `error_code` VARCHAR(64) DEFAULT NULL COMMENT                                                       '错误码',
    `error_message` VARCHAR(1000) DEFAULT NULL COMMENT                                                  '错误信息',
    `started_time` TIMESTAMP NULL DEFAULT NULL COMMENT                                                  '开始时间',
    `finished_time` TIMESTAMP NULL DEFAULT NULL COMMENT                                                 '结束时间',
    `create_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP COMMENT                                      '创建时间',
    `update_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT          '更新时间',
    `version` INT NOT NULL DEFAULT 0 COMMENT                                                            '记录版本',
    `delete_flag` TINYINT NOT NULL DEFAULT 0 COMMENT                                                    '删除标识[0:未删除, 1:已删除]',
    PRIMARY KEY (`id`),
    INDEX `idx_organ_task_node` (`organ_id`, `task_id`, `node_id`),
    INDEX `idx_organ_task` (`organ_id`, `task_id`),
    INDEX `idx_organ_status` (`organ_id`, `status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT=                             '任务图步骤表';

-- ---------------------------------------------
-- 5. 任务图依赖边 (task_graph_edge)
-- ---------------------------------------------
DROP TABLE IF EXISTS `task_graph_edge`;

CREATE TABLE `task_graph_edge` (
    `id` BIGINT NOT NULL COMMENT                                                                        '主键标识',
    `organ_id` BIGINT NOT NULL COMMENT                                                                  '机构标识',
    `task_id` VARCHAR(64) NOT NULL COMMENT                                                              '所属任务',
    `from_node_id` VARCHAR(64) NOT NULL COMMENT                                                         '前置步骤',
    `to_node_id` VARCHAR(64) NOT NULL COMMENT                                                           '后继步骤',
    `edge_type` VARCHAR(32) NOT NULL DEFAULT 'NORMAL' COMMENT                                           '边类型[NORMAL, DELEGATE]',
    `create_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP COMMENT                                      '创建时间',
    `update_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT          '更新时间',
    `version` INT NOT NULL DEFAULT 0 COMMENT                                                            '记录版本',
    `delete_flag` TINYINT NOT NULL DEFAULT 0 COMMENT                                                    '删除标识[0:未删除, 1:已删除]',
    PRIMARY KEY (`id`),
    INDEX `idx_organ_task_edge` (`organ_id`, `task_id`, `from_node_id`, `to_node_id`),
    INDEX `idx_organ_task` (`organ_id`, `task_id`),
    INDEX `idx_organ_task_to` (`organ_id`, `task_id`, `to_node_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT=                             '任务图依赖边表';

-- ---------------------------------------------
-- 6. 大报文溢出 (task_node_payload)
-- ---------------------------------------------
DROP TABLE IF EXISTS `task_node_payload`;

CREATE TABLE `task_node_payload` (
    `id` BIGINT NOT NULL COMMENT                                                                        '主键标识',
    `organ_id` BIGINT NOT NULL COMMENT                                                                  '机构标识',
    `payload_id` VARCHAR(64) NOT NULL COMMENT                                                           '报文业务标识',
    `task_id` VARCHAR(64) NOT NULL COMMENT                                                              '所属任务',
    `node_id` VARCHAR(64) NOT NULL COMMENT                                                              '所属节点',
    `payload_type` VARCHAR(32) NOT NULL COMMENT                                                         '报文类型[ARTIFACT, OUTPUT]',
    `payload_data` JSON NOT NULL COMMENT                                                                '报文内容',
    `tool_name` VARCHAR(256) DEFAULT NULL COMMENT                                                       '工具名',
    `trace_id` VARCHAR(64) DEFAULT NULL COMMENT                                                         '追踪号',
    `create_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP COMMENT                                      '创建时间',
    `update_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT          '更新时间',
    `version` INT NOT NULL DEFAULT 0 COMMENT                                                            '记录版本',
    `delete_flag` TINYINT NOT NULL DEFAULT 0 COMMENT                                                    '删除标识[0:未删除, 1:已删除]',
    PRIMARY KEY (`id`),
    INDEX `idx_organ_payload` (`organ_id`, `payload_id`),
    INDEX `idx_organ_task` (`organ_id`, `task_id`),
    INDEX `idx_organ_node` (`organ_id`, `node_id`),
    INDEX `idx_organ_type` (`organ_id`, `payload_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT=                             '大报文溢出表';

-- ---------------------------------------------
-- 7. 任务检查点 (task_checkpoint)
-- ---------------------------------------------
DROP TABLE IF EXISTS `task_checkpoint`;

CREATE TABLE `task_checkpoint` (
    `id` BIGINT NOT NULL COMMENT                                                                        '主键标识',
    `organ_id` BIGINT NOT NULL COMMENT                                                                  '机构标识',
    `task_id` VARCHAR(64) NOT NULL COMMENT                                                              '所属任务；每任务至多一条，恢复/终态逻辑删除',
    `node_id` VARCHAR(64) DEFAULT NULL COMMENT                                                          '挂起的节点',
    `checkpoint_id` VARCHAR(64) NOT NULL COMMENT                                                        '检查点业务标识',
    `type` VARCHAR(32) NOT NULL COMMENT                                                                 '检查点类型[FOLLOW_UP, APPROVAL, VERIFY]',
    `question` VARCHAR(2000) DEFAULT NULL COMMENT                                                       '追问/确认文案',
    `expected_fields` JSON DEFAULT NULL COMMENT                                                         '追问期望补充的字段',
    `allowed_actions` JSON NOT NULL COMMENT                                                             '恢复动作',
    `suggestions` JSON DEFAULT NULL COMMENT                                                             '快捷建议文案',
    `pending_action` JSON DEFAULT NULL COMMENT                                                          '待审批动作',
    `create_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP COMMENT                                      '创建时间',
    `update_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT          '更新时间',
    `version` INT NOT NULL DEFAULT 0 COMMENT                                                            '记录版本',
    `delete_flag` TINYINT NOT NULL DEFAULT 0 COMMENT                                                    '删除标识[0:未删除, 1:已删除]',
    PRIMARY KEY (`id`),
    INDEX `idx_organ_checkpoint` (`organ_id`, `checkpoint_id`),
    INDEX `idx_organ_task` (`organ_id`, `task_id`),
    INDEX `idx_organ_type` (`organ_id`, `type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT=                             '任务检查点表';

-- ---------------------------------------------
-- 8. 工具调用记录 (tool_call_record)
-- ---------------------------------------------
DROP TABLE IF EXISTS `tool_call_record`;

CREATE TABLE `tool_call_record` (
    `id` BIGINT NOT NULL COMMENT                                                                        '主键标识',
    `organ_id` BIGINT NOT NULL COMMENT                                                                  '机构标识',
    `task_id` VARCHAR(64) NOT NULL COMMENT                                                              '所属任务',
    `node_id` VARCHAR(64) NOT NULL COMMENT                                                              '所属节点',
    `call_id` VARCHAR(64) NOT NULL COMMENT                                                              '调用业务标识',
    `tool_name` VARCHAR(256) NOT NULL COMMENT                                                           '工具名',
    `side_effect` VARCHAR(16) NOT NULL DEFAULT 'NONE' COMMENT                                           '副作用[NONE, WRITE]',
    `request` JSON DEFAULT NULL COMMENT                                                                 '请求内容（敏感值只存 handle）',
    `args_hash` VARCHAR(32) NOT NULL COMMENT                                                            '全量规范化业务入参摘要',
    `idempotency_key` VARCHAR(64) CHARACTER SET ascii NOT NULL COMMENT                                  'effective 业务幂等键的 SHA-256 十六进制（契约路径值或 argsHash 兜底）',
    `round` INT DEFAULT NULL COMMENT                                                                    'ReAct 轮次',
    `response` JSON DEFAULT NULL COMMENT                                                                '响应内容',
    `result_summary` VARCHAR(1000) DEFAULT NULL COMMENT                                                 '结果简报：证据回放给模型的响应摘录',
    `entities` JSON DEFAULT NULL COMMENT                                                                '结果中的实体',
    `payload_id` VARCHAR(64) DEFAULT NULL COMMENT                                                       '超长报文在 task_node_payload 中的标识',
    `call_status` VARCHAR(32) NOT NULL COMMENT                                                          '调用状态[STARTED, SUCCESS, FAILED, TIMEOUT, CANCELLED, UNKNOWN, UNKNOWN_PRE_CALL]',
    `business_ok` TINYINT DEFAULT NULL COMMENT                                                          '业务是否成功[0, 1]；无法判断为空',
    `empty_result` TINYINT NOT NULL DEFAULT 0 COMMENT                                                   '是否空结果[0, 1]',
    `failure_kind` VARCHAR(32) NOT NULL DEFAULT 'NONE' COMMENT                                          '失败分类[NONE, PARAMETER_FAILURE, AUTH_FAILURE, TIMEOUT, RATE_LIMIT, BUSINESS_FAILURE, TRANSPORT_FAILURE, UNKNOWN]',
    `error_code` VARCHAR(64) DEFAULT NULL COMMENT                                                       '错误码',
    `error_message` VARCHAR(1000) DEFAULT NULL COMMENT                                                  '错误信息',
    `duration_ms` BIGINT DEFAULT NULL COMMENT                                                           '耗时毫秒',
    `trace_id` VARCHAR(64) DEFAULT NULL COMMENT                                                         '追踪号',
    `create_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP COMMENT                                      '创建时间',
    `update_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT          '更新时间',
    `version` INT NOT NULL DEFAULT 0 COMMENT                                                            '记录版本',
    `delete_flag` TINYINT NOT NULL DEFAULT 0 COMMENT                                                    '删除标识[0:未删除, 1:已删除]',
    PRIMARY KEY (`id`),
    INDEX `idx_organ_call` (`organ_id`, `call_id`),
    INDEX `idx_organ_task_node` (`organ_id`, `task_id`, `node_id`),
    INDEX `idx_organ_tool` (`organ_id`, `tool_name`),
    INDEX `idx_organ_status` (`organ_id`, `call_status`),
    INDEX `idx_organ_idempotency` (`organ_id`, `task_id`, `tool_name`, `idempotency_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT=                             '工具调用记录表';

-- ---------------------------------------------
-- 9. 任务恢复动作记录 (task_resume_record)
-- ---------------------------------------------
DROP TABLE IF EXISTS `task_resume_record`;

CREATE TABLE `task_resume_record` (
    `id` BIGINT NOT NULL COMMENT                                                                        '主键标识',
    `organ_id` BIGINT NOT NULL COMMENT                                                                  '机构标识',
    `task_id` VARCHAR(64) NOT NULL COMMENT                                                              '所属任务',
    `node_id` VARCHAR(64) DEFAULT NULL COMMENT                                                          '关联节点',
    `resume_id` VARCHAR(64) NOT NULL COMMENT                                                            '恢复动作业务标识',
    `checkpoint_id` VARCHAR(64) DEFAULT NULL COMMENT                                                    '关联检查点',
    `message_id` VARCHAR(64) DEFAULT NULL COMMENT                                                       '关联消息',
    `resume_action` VARCHAR(32) NOT NULL COMMENT                                                        '恢复动作[REPLY, CONFIRM, REJECT, CANCEL]',
    `acted_at` TIMESTAMP NULL DEFAULT NULL COMMENT                                                      '动作时间',
    `create_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP COMMENT                                      '创建时间',
    `update_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT          '更新时间',
    `version` INT NOT NULL DEFAULT 0 COMMENT                                                            '记录版本',
    `delete_flag` TINYINT NOT NULL DEFAULT 0 COMMENT                                                    '删除标识[0:未删除, 1:已删除]',
    PRIMARY KEY (`id`),
    INDEX `idx_organ_resume` (`organ_id`, `resume_id`),
    INDEX `idx_organ_task` (`organ_id`, `task_id`),
    INDEX `idx_organ_checkpoint` (`organ_id`, `checkpoint_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT=                             '任务恢复动作审计表';

-- ---------------------------------------------
-- 10. 执行过程步骤 (chat_progress)
-- ---------------------------------------------
DROP TABLE IF EXISTS `chat_progress`;

CREATE TABLE `chat_progress` (
    `id` BIGINT NOT NULL COMMENT                                                                        '主键标识',
    `organ_id` BIGINT NOT NULL COMMENT                                                                  '机构标识',
    `conversation_id` VARCHAR(64) NOT NULL COMMENT                                                      '所属会话',
    `trace_id` VARCHAR(64) NOT NULL COMMENT                                                             '所属轮次追踪号；与最终回复的 trace_id 关联',
    `task_id` VARCHAR(64) DEFAULT NULL COMMENT                                                          '关联任务；可空',
    `step_id` VARCHAR(64) NOT NULL COMMENT                                                              '步骤标识；本轮内唯一',
    `parent_step_id` VARCHAR(64) DEFAULT NULL COMMENT                                                   '上级步骤；顶层为空',
    `seq` INT NOT NULL COMMENT                                                                          '本轮内开始顺序',
    `stage` VARCHAR(16) NOT NULL COMMENT                                                                '环节[ROUTE, PLAN, NODE, ROUND, MODEL, TOOL, VERIFY]',
    `status` VARCHAR(16) NOT NULL COMMENT                                                               '状态[RUNNING, DONE, FAILED]',
    `title` VARCHAR(256) NOT NULL COMMENT                                                               '标题',
    `detail` VARCHAR(1000) DEFAULT NULL COMMENT                                                         '补充说明',
    `node_id` VARCHAR(64) DEFAULT NULL COMMENT                                                          '所属节点',
    `round` INT DEFAULT NULL COMMENT                                                                    'ReAct 轮次',
    `error_code` VARCHAR(64) DEFAULT NULL COMMENT                                                       '失败错误码',
    `extra` JSON DEFAULT NULL COMMENT                                                                   '排查信息（token、参数摘要、上游原文）；不下发 chat，供会话追踪查看',
    `started_at_ms` BIGINT NOT NULL COMMENT                                                             '开始时间 epoch ms',
    `elapsed_ms` INT DEFAULT NULL COMMENT                                                               '耗时毫秒',
    `create_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP COMMENT                                      '创建时间',
    `update_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT          '更新时间',
    `version` INT NOT NULL DEFAULT 0 COMMENT                                                            '记录版本',
    `delete_flag` TINYINT NOT NULL DEFAULT 0 COMMENT                                                    '删除标识[0:未删除, 1:已删除]',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_organ_trace_step` (`organ_id`, `trace_id`, `step_id`, (IF(delete_flag = 0, 0, NULL))),
    INDEX `idx_organ_conversation` (`organ_id`, `conversation_id`, `trace_id`, `seq`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT=                             '执行过程步骤表';
