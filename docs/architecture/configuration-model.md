# 配置与合并模型

## 环境变量

`env.example` 是 `.env` 模板，包含平台地址、端口、数据库、Redis、Nacos、时区和镜像等配置。模板中的固定值仅用于本地示例，生产环境必须全部审查并替换敏感项。Nacos 外置库时在服务器 `.env` 设置 `MYSQL_SERVICE_HOST`（默认 `mysql` 为本 compose 服务名），勿把真实内网地址提交进仓库。

## 测试环境资源上限

`docker-compose.yml` 与 `compose-v2/compose.yaml` 通过文件级 YAML 锚点（`x-deploy-*`、`x-java-tool-options`）为各服务声明 `deploy.resources` 上限，面向低并发测试主机。

| 角色 | 锚点 | 典型 memory limit |
|------|------|-------------------|
| 前端 App / Shell | `deploy-frontend` | 256M |
| JDK 25 后端 | `deploy-java` + `JAVA_TOOL_OPTIONS`（`-Xms64m`/`-Xmx512m`、`MaxMetaspaceSize=256m`、`UseG1GC`） | 1G |
| MySQL | `deploy-mysql` + `config/mysql/my.cnf`（`innodb_buffer_pool_size=256M`） | 768M |
| Redis | `deploy-redis` + `config/redis/redis.conf`（`maxmemory 128mb`） | 256M |
| Nacos | `deploy-nacos` + `JVM_XMS`/`JVM_XMX` | 768M |
| Kafka | `deploy-kafka`（沿用 `KAFKA_HEAP_OPTS`） | 512M |
| Nginx | `deploy-nginx` | 128M |

编排不设置 `cpus`（Compose V1 对 `deploy.resources.reservations.cpus` 会告警且常被忽略）。知识库片段 `business.d/g2rain-knowledge.yml` 内联声明 Docling（默认 `g2rain/docling-serve-cpu:v1.29.0`，limit 2G / reservation 256M）、Milvus（limit 2G / reservation 256M）、`g2rain-knowledge`（1G + `JAVA_TOOL_OPTIONS`）与 `g2rain-knowledge-app`（256M，入口 `/knowledge/`），面向低并发测试；若 OOM（exit 137）或解析失败再按需调高 limit。reservation 是软预留，不代表进程空闲常驻。Milvus 嵌入式 etcd 的 `advertise-client-urls` 为 `http://127.0.0.1:2379`，库大小上限 1GiB，心跳 500ms、选举超时 5000ms（`config/milvus/embedEtcd.yaml`）。Docling 派生镜像以官方 `ghcr.io/docling-project/docling-serve-cpu:v1.29.0` 为基础，在构建阶段把 `opencv-python` 换成同版本 `opencv-python-headless`，避免旧内核无法加载 Qt。部署前需 build 该镜像，且 `.env` 的 `DOCLING_IMAGE` 不能写死未修复的官方标签。Milvus 入口在启动时 `chown` `data/milvus/` 后降权运行，并用 `MILVUS_BOOTSTRAP_TOKEN` 按 `config/milvus/knowledge-collection.json` 幂等创建 `KNOWLEDGE_MILVUS_COLLECTION`（默认 `g2rain_knowledge_chunks_qwen_4096_v1`）。已有同名 collection 不会删除或重建。片段文件不能引用主文件 YAML 锚点。

JDK 25 在容器已设 memory limit 时默认 `MaxRAMPercentage≈75%`，因此业务 Java 服务必须显式设置 `JAVA_TOOL_OPTIONS`，不能只靠容器 limit。策略为低起步、按需涨：`-Xms64m`、`-Xmx512m`、`MaxMetaspaceSize=256m`（Metaspace 本身按加载增长）、容器 limit `1G` / reservation `256M`，热点可吃满上限，空闲常驻远低于 1G。保留 `-XX:+ExitOnOutOfMemoryError`；若仍 Metaspace OOM 或 exit 137，再按实测调高。

MySQL / Redis 的进程内上限（`innodb_buffer_pool_size`、`maxmemory`）须与对应 `deploy.resources` 一致，且为容器与 OS 留出余量；生产或高并发前应按实测调高。

## Compose CLI 选择

`--compose-v2` 或 `--compose-v1` 的优先级最高；未指定时读取 `config/compose-cli.env`，再回退到脚本默认。辅助脚本可探测本机 CLI 并写入偏好文件，也支持 `--dry-run` 和 `--print-export`。

## 业务 Compose 片段

默认加载 `business.d/*.yml`（含 CMS、Admin Shell、Knowledge）；使用可重复的 `--business <name>` 时只加载指定片段。主 Compose 始终位于参数链第一位，业务片段随后追加。默认目录扫描不显式排序，多个片段不得依赖隐含顺序。

## 服务构建映射

`services.conf` 中每项格式为：

```text
repo|dir|compose_service|build_cmd
```

默认继续加载 `service_config.d/*.conf`。相同 `compose_service` 的后加载记录会整行覆盖已有记录；可重复使用 `--service <name>` 限定片段并固定命令行顺序。片段会被 Shell `source`，因此只能接受受信任内容。
