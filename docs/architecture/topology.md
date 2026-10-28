# 部署拓扑

## 基础主编排

V1 与 V2 主配置静态解析后均包含 16 个服务：MySQL、Redis、Nacos、Kafka、Nginx、Gateway，以及 Infra、Basis、IAM、Department、Member 五个后端和 Main Shell、Infra App、Manager App、Department App、Member App 五个前端应用。

## 默认业务扩展

`business.d/g2rain-cms.yml` 增加 `g2rain-cms` 与 `g2rain-cms-app`；`business.d/g2rain-admin-shell.yml` 增加 `g2rain-admin-shell`（Context Path `/admin`）；`business.d/g2rain-chat-shell.yml` 增加 `g2rain-chat-shell`（Context Path `/chat`）；`business.d/g2rain-knowledge.yml` 增加 `docling-serve`、`milvus`、`g2rain-knowledge` 与 `g2rain-knowledge-app`（Context Path `/knowledge`）；`business.d/g2rain-agent.yml` 增加 `g2rain-agent-app`（Context Path `/agent`）、`g2rain-agent-runtime`、`g2rain-agent-studio`、`g2rain-mcp-registry` 与 `g2rain-model-nexus`。其他 `business.d/*.yml` 可继续扩展，但不得重复定义服务名，除非明确接受 Compose 覆盖语义。

## 知识库业务片段

`docling-serve` 与 `milvus` 均接入 `g2rain-network`，并默认映射宿主机端口：Docling `5001`（`DOCLING_PORT`）、Milvus SDK `19530`（`MILVUS_PORT`）；Milvus 健康检查 `9091` 仅容器内使用。`docling-serve` 默认镜像为 `g2rain/docling-serve-cpu:v1.29.0`（可由 `DOCLING_IMAGE` 覆盖），由 `docling-serve/Dockerfile` 基于官方 `ghcr.io/docling-project/docling-serve-cpu:v1.29.0` 构建，内存 limit 2G；无 GPU 测试栈使用 CPU 变体。HybridChunker 依赖 `sentence-transformers/all-MiniLM-L6-v2`：将宿主机 HF cache（`DOCLING_HF_CACHE`，默认 `./data/docling-hf`）挂到容器 `HF_HOME`，并默认 `HF_HUB_OFFLINE=1`，避免运行时访问 `huggingface.co`。`g2rain-knowledge` 通过 `http://docling-serve:5001` 调用文档解析，通过 `http://milvus:19530` 访问向量检索。`g2rain-knowledge-app` 经 Nginx `/knowledge/` 对外；业务 API 仍经 `/api/` → Gateway（`route_prefix=knowledge`）。Milvus 以 Standalone 单容器运行，使用嵌入式 etcd、Woodpecker 本地 WAL 和本地存储，数据持久化在 `data/milvus/`；首期不引入 MinIO 或外部消息队列。知识原文件及解析产物持久化在 `data/g2rain-knowledge/`（容器内默认 `/data/knowledge`）。

Milvus v3 镜像默认非 root：`milvus` 服务入口以 root `chown` `data/milvus/` 后，再通过 `runuser`/`setpriv` 降权启动。进程健康后按 `config/milvus/knowledge-collection.json` 幂等创建 collection，并写入 `data/milvus/.knowledge-collection-ready`；健康检查同时要求该标记，因此 `g2rain-knowledge` 不会在表出现前开始检索。可用 `./update.sh milvus` 单独更新。模板已含 RQ-008 `visibility` 字段与标量索引；已存在的同名 collection 需按 knowledge 仓运维文档原地加字段，不会因更新模板自动补列。

## 依赖顺序

启动脚本先启动 MySQL 与 Redis，再等待 MySQL、Redis、Nacos、Kafka 健康，最后启动完整栈。具体 `depends_on` 和健康检查仍以当前 Compose 文件为准。

## 网关变体

默认服务映射从 `g2rain-gateway-webflux` 构建 `g2rain-gateway`。仓库提供 WebMVC 网关片段，可复制到 `business.d` 参与合并；切换前必须确认镜像、服务名和下游兼容性。
