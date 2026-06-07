CREATE DATABASE IF NOT EXISTS g2rain_cms DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE g2rain_cms;

CREATE TABLE space
(
    id          BIGINT       NOT NULL COMMENT '空间标识',
    organ_id    BIGINT       NOT NULL COMMENT '机构标识',
    space_name  VARCHAR(128) NOT NULL COMMENT '空间名称',
    space_code  VARCHAR(64)  NOT NULL COMMENT '空间编码',
    space_type  VARCHAR(32)  NOT NULL COMMENT '空间类型[WEBSITE:官网, KNOWLEDGE:知识库, INTERNAL:内部]',
    status      VARCHAR(32)  NOT NULL DEFAULT 'ENABLED' COMMENT '状态[ENABLED:启用, DISABLED:禁用]',
    create_time TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    version     INT          NOT NULL DEFAULT 0 COMMENT '记录版本',
    delete_flag TINYINT      NOT NULL DEFAULT 0 COMMENT '删除标识[0:未删除, 1:已删除]',
    PRIMARY KEY (id),
    UNIQUE KEY uk_organ_code (organ_id, space_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='内容空间表';

CREATE TABLE channel
(
    id           BIGINT       NOT NULL COMMENT '栏目标识',
    organ_id     BIGINT       NOT NULL COMMENT '机构标识',
    space_id     BIGINT       NOT NULL COMMENT '空间标识',
    site_id       BIGINT         NOT NULL COMMENT '站点标识',
    parent_id    BIGINT                DEFAULT 0 COMMENT '父栏目标识',
    channel_name VARCHAR(128) NOT NULL COMMENT '栏目名称',
    channel_code VARCHAR(64)           DEFAULT NULL COMMENT '栏目编码',
    channel_type VARCHAR(32)  NOT NULL COMMENT '栏目类型[LIST:列表, PAGE:页面, LINK:外链]',
    path         VARCHAR(255)          DEFAULT NULL COMMENT '访问路径',
    category_id  BIGINT                DEFAULT NULL COMMENT '分类标识',
    page_id      BIGINT                DEFAULT NULL COMMENT '页面标识',
    link_url     VARCHAR(255)          DEFAULT NULL COMMENT '外链URL',
    sort_order   INT          NOT NULL DEFAULT 0 COMMENT '排序',
    visible      TINYINT      NOT NULL DEFAULT 1 COMMENT '是否显示[0:否, 1:是]',
    status       VARCHAR(32)  NOT NULL DEFAULT 'ENABLED' COMMENT '状态',
    create_time  TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time  TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    version      INT          NOT NULL DEFAULT 0 COMMENT '记录版本',
    delete_flag  TINYINT      NOT NULL DEFAULT 0 COMMENT '删除标识',
    PRIMARY KEY (id),
    INDEX        idx_space_id (space_id),
    INDEX        idx_parent_id (parent_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='栏目表';

CREATE TABLE article
(
    id                    BIGINT       NOT NULL COMMENT '文章标识',
    organ_id              BIGINT       NOT NULL COMMENT '机构标识',
    space_id              BIGINT       NOT NULL COMMENT '空间标识',
    category_id           BIGINT       NOT NULL COMMENT '分类标识',
    source_application_id BIGINT                DEFAULT NULL COMMENT '来源应用标识',
    source_trace_id       VARCHAR(128)          DEFAULT NULL COMMENT '来源追踪ID',
    title                 VARCHAR(255) NOT NULL COMMENT '标题',
    summary               VARCHAR(512)          DEFAULT NULL COMMENT '摘要',
    cover                 VARCHAR(255)          DEFAULT NULL COMMENT '封面',
    content_type          VARCHAR(32)  NOT NULL COMMENT '内容类型[MARKDOWN:Markdown, HTML:HTML]',
    content               LONGTEXT COMMENT '内容',
    author                VARCHAR(128)          DEFAULT NULL COMMENT '作者',
    status                VARCHAR(32)  NOT NULL DEFAULT 'DRAFT' COMMENT '状态[DRAFT:草稿, PUBLISHED:发布]',
    publish_time          TIMESTAMP NULL DEFAULT NULL COMMENT '发布时间',
    create_time           TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time           TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    version               INT          NOT NULL DEFAULT 0 COMMENT '记录版本',
    delete_flag           TINYINT      NOT NULL DEFAULT 0 COMMENT '删除标识',
    PRIMARY KEY (id),
    INDEX                 idx_space_id (space_id),
    INDEX                 idx_category_id (category_id),
    INDEX                 idx_app_id (source_application_id),
    INDEX                 idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='文章表';

CREATE TABLE page
(
    id          BIGINT       NOT NULL COMMENT '页面标识',
    organ_id    BIGINT       NOT NULL COMMENT '机构标识',
    space_id    BIGINT       NOT NULL COMMENT '空间标识',
    page_name   VARCHAR(128) NOT NULL COMMENT '页面名称',
    page_code   VARCHAR(64)           DEFAULT NULL COMMENT '页面编码',
    path        VARCHAR(255)          DEFAULT NULL COMMENT '访问路径',
    content_type VARCHAR(32) DEFAULT 'MARKDOWN' COMMENT '内容类型[MARKDOWN:Markdown, HTML:HTML]',
    content     LONGTEXT COMMENT '页面内容',
    status      VARCHAR(32)  NOT NULL DEFAULT 'DRAFT' COMMENT '状态[DRAFT:草稿, PUBLISHED:发布]',
    create_time TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    version     INT          NOT NULL DEFAULT 0 COMMENT '记录版本',
    delete_flag TINYINT      NOT NULL DEFAULT 0 COMMENT '删除标识',
    PRIMARY KEY (id),
    INDEX       idx_space_id (space_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='页面表';


CREATE TABLE tag
(
    id          BIGINT       NOT NULL COMMENT '标签标识',
    organ_id    BIGINT       NOT NULL COMMENT '机构标识',
    tag_name    VARCHAR(128) NOT NULL COMMENT '标签名称',
    create_time TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    version     INT          NOT NULL DEFAULT 0 COMMENT '记录版本',
    delete_flag TINYINT      NOT NULL DEFAULT 0 COMMENT '删除标识',
    PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='标签表';

CREATE TABLE article_tag_relation
(
    id          BIGINT  NOT NULL COMMENT '主键标识',
    article_id  BIGINT  NOT NULL COMMENT '文章标识',
    tag_id      BIGINT  NOT NULL COMMENT '标签标识',
    create_time TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    version     INT     NOT NULL DEFAULT 0 COMMENT '记录版本',
    delete_flag TINYINT NOT NULL DEFAULT 0 COMMENT '删除标识',
    PRIMARY KEY (id),
    INDEX       idx_article_tag (article_id, tag_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='文章标签关系表';

USE g2rain_cms;

-- ====================== 站点表 web_site ======================
CREATE TABLE web_site
(
    id            BIGINT         NOT NULL COMMENT '站点标识',
    organ_id      BIGINT         NOT NULL COMMENT '机构标识',
    site_name     VARCHAR(128)   NOT NULL COMMENT '站点名称',
    site_code     VARCHAR(64)    NOT NULL COMMENT '站点编码',
    domain        VARCHAR(255)            DEFAULT NULL COMMENT '站点域名（多个用逗号分隔）',
    description   VARCHAR(512)            DEFAULT NULL COMMENT '站点描述',
    status        VARCHAR(32)    NOT NULL DEFAULT 'ENABLED' COMMENT '状态[ENABLED:启用, DISABLED:禁用]',
    create_time   TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time   TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    version       INT            NOT NULL DEFAULT 0 COMMENT '记录版本',
    delete_flag   TINYINT        NOT NULL DEFAULT 0 COMMENT '删除标识[0:未删除, 1:已删除]',
    PRIMARY KEY (id),
    UNIQUE KEY uk_organ_code (organ_id, site_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='站点表';

-- ====================== 文章分类表 article_category ======================
CREATE TABLE article_category
(
    id            BIGINT         NOT NULL COMMENT '分类标识',
    organ_id      BIGINT         NOT NULL COMMENT '机构标识',
    space_id      BIGINT         NOT NULL COMMENT '空间标识',
    category_name VARCHAR(128)    NOT NULL COMMENT '分类名称',
    category_code VARCHAR(64)             DEFAULT NULL COMMENT '分类编码',
    status        VARCHAR(32)     NOT NULL DEFAULT 'ENABLED' COMMENT '状态[ENABLED:启用, DISABLED:禁用]',
    create_time   TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time   TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    version       INT             NOT NULL DEFAULT 0 COMMENT '记录版本',
    delete_flag   TINYINT         NOT NULL DEFAULT 0 COMMENT '删除标识[0:未删除, 1:已删除]',
    PRIMARY KEY (id),
    INDEX         idx_space_id (space_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='文章分类表';