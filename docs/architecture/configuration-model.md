# 配置与合并模型

## 环境变量

`env.example` 是 `.env` 模板，包含平台地址、端口、数据库、Redis、Nacos、时区和镜像等配置。模板中的固定值仅用于本地示例，生产环境必须全部审查并替换敏感项。

## 测试环境资源上限

`docker-compose.yml` 与 `compose-v2/compose.yaml` 通过文件级 YAML 锚点（`x-deploy-*`、`x-java-tool-options`）为各服务声明 `deploy.resources` 上限，面向低并发测试主机。

| 角色 | 锚点 | 典型 memory limit |
|------|------|-------------------|
| 前端 App / Shell | `deploy-frontend` | 256M |
| JDK 25 后端 | `deploy-java` + `JAVA_TOOL_OPTIONS`（`-Xms128m`/`-Xmx128m`、`UseSerialGC`） | 384M |
| MySQL | `deploy-mysql` + `config/mysql/my.cnf`（`innodb_buffer_pool_size=256M`） | 768M |
| Redis | `deploy-redis` + `config/redis/redis.conf`（`maxmemory 128mb`） | 256M |
| Nacos | `deploy-nacos` + `JVM_XMS`/`JVM_XMX` | 768M |
| Kafka | `deploy-kafka`（沿用 `KAFKA_HEAP_OPTS`） | 512M |
| Nginx | `deploy-nginx` | 128M |

编排不设置 `cpus`（Compose V1 对 `deploy.resources.reservations.cpus` 会告警且常被忽略）。知识库片段 `business.d/g2rain-knowledge.yml` 内联声明 Docling（512M）、Milvus（1G）与 `g2rain-knowledge`（384M + `JAVA_TOOL_OPTIONS`），面向低并发测试；若 OOM（exit 137）或解析失败再按需调高。Milvus 入口在启动时 `chown` `data/milvus/` 后降权运行。片段文件不能引用主文件 YAML 锚点。

JDK 25 在容器已设 memory limit 时默认 `MaxRAMPercentage≈75%`，因此业务 Java 服务必须显式设置 `JAVA_TOOL_OPTIONS`，不能只靠容器 limit。生产或压测前应按实测调高，避免 OOM（exit 137）或启动失败。

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
