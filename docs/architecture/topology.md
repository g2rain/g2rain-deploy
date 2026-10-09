# 部署拓扑

## 基础主编排

V1 与 V2 主配置静态解析后均包含 16 个服务：MySQL、Redis、Nacos、Kafka、Nginx、Gateway，以及 Infra、Basis、IAM、Department、Member 五个后端和 Main Shell、Infra App、Manager App、Department App、Member App 五个前端应用。

## 默认业务扩展

`business.d/g2rain-cms.yml` 增加 `g2rain-cms` 与 `g2rain-cms-app`；`business.d/g2rain-admin-shell.yml` 增加 `g2rain-admin-shell`（Context Path `/admin`）；`business.d/g2rain-chat-shell.yml` 增加 `g2rain-chat-shell`（Context Path `/chat`）；`business.d/g2rain-knowledge.yml` 增加 `docling-serve`、`milvus` 与 `g2rain-knowledge`。其他 `business.d/*.yml` 可继续扩展，但不得重复定义服务名，除非明确接受 Compose 覆盖语义。

## 知识库业务片段

`docling-serve` 与 `milvus` 均只接入 `g2rain-network`，不映射宿主机端口。`g2rain-knowledge` 通过 `http://docling-serve:5001` 调用文档解析与 HybridChunker，通过 `http://milvus:19530` 访问向量检索。Milvus 以 Standalone 单容器运行，使用嵌入式 etcd、Woodpecker 本地 WAL 和本地存储，数据持久化在 `data/milvus/`；首期不引入 MinIO 或外部消息队列。知识原文件及解析产物持久化在 `data/g2rain-knowledge/`（容器内默认 `/data/knowledge`）。

## 依赖顺序

启动脚本先启动 MySQL 与 Redis，再等待 MySQL、Redis、Nacos、Kafka 健康，最后启动完整栈。具体 `depends_on` 和健康检查仍以当前 Compose 文件为准。

## 网关变体

默认服务映射从 `g2rain-gateway-webflux` 构建 `g2rain-gateway`。仓库提供 WebMVC 网关片段，可复制到 `business.d` 参与合并；切换前必须确认镜像、服务名和下游兼容性。
