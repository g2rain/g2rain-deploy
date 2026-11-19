业务侧 Docker Compose 片段目录
================================

约定
----
- 本目录下扩展名为 `.yml` 的文件会在 start / stop / update 时按「主 docker-compose.yml（或 compose-v2 主文件）之后追加 -f」合并加载；不排序。
- 仓库默认提供 **`g2rain-cms.yml`**（**`g2rain-cms`**、**`g2rain-cms-app`**）、**`g2rain-admin-shell.yml`**（**`g2rain-admin-shell`**，Context Path `/admin`）、**`g2rain-chat-shell.yml`**（**`g2rain-chat-shell`**，Context Path `/chat`）、**`g2rain-knowledge.yml`**（**`docling-serve`** 默认 **`docling-serve-cpu`**、**`milvus`**、**`g2rain-knowledge`**、**`g2rain-knowledge-app`** Context Path `/knowledge`）与 **`g2rain-agent.yml`**（**`g2rain-agent-app`** Context Path `/agent`、**`g2rain-agent-runtime`**、**`g2rain-agent-studio`**、**`g2rain-mcp-registry`**、**`g2rain-model-nexus`**），与主 compose 中的网络、MySQL 初始化等配合使用；勿在主 compose 中重复定义同名 service。
- **`docling-serve`**：先构建派生镜像，再 `./update.sh docling-serve`。在部署根目录执行 `docker-compose -f docker-compose.yml -f business.d/g2rain-knowledge.yml build docling-serve`（Compose V2 则把主文件换成 `compose-v2/compose.yaml` 并使用 `docker compose`）。服务器 `.env` 的 `DOCLING_IMAGE` 须为 `g2rain/docling-serve-cpu:v1.29.0`；写死官方 `ghcr.io/docling-project/docling-serve-cpu:v1.29.0` 会继续使用未修复镜像。HybridChunker 需预置 `all-MiniLM-L6-v2` 到 `DOCLING_HF_CACHE`（默认 `/root/.cache/huggingface`）；改挂载后须 `./update.sh docling-serve` recreate，勿只 `docker restart`。
- 请勿在多个片段中重复定义同一 service 名，合并结果由 Compose 覆盖规则决定，易产生非预期行为。

可选：只加载部分片段
--------------------
在 ./start.sh、./stop.sh、./update.sh 上可重复传入：

  --business <片段名>

片段名为 `business.d` 下的文件名，可写 `foo` 或 `foo.yml`。指定后**仅**加载列出的片段，不再自动加载本目录下其余 `.yml`。若仍需要 CMS，请把 **`g2rain-cms`**（或 **`g2rain-cms.yml`**）一并列入，例如：`./start.sh --business g2rain-cms --business gateway-webmvc`。

示例
----
  ./start.sh --business tenant-a
  ./stop.sh --business tenant-a --cleanup
  ./update.sh g2rain-manager-app --business tenant-a

将根目录 **`docker-compose.fragment.gateway-webmvc.yml`** 复制到本目录（如 **`gateway-webmvc.yml`**）可切换为 WebMVC 网关镜像；详见仓库根 **`README.md`**「网关 WebMVC 与 business.d 合并片段」。

扩展目录
--------
`.env` 中可设置 `G2RAIN_EXTENSION_DIR` 指向扩展目录（相对路径以部署根为准）。未设置或为空表示不使用扩展；已设置但目录不存在时报错退出。

目录约定：

- `business.d/*.yml`：与本目录同名规则的业务片段
- `service_config.d/*.conf`：额外 `SERVICES` 映射
- `config/mysql/*.sql`：初始化 SQL（由片段给 `mysql` 追加挂载；文件名以 `z` 开头，保证在开源脚本之后执行）
- 其他文件由片段自行引用

未指定 `--business` 时，扫描本目录与 `${G2RAIN_EXTENSION_DIR}/business.d/` 下全部 `.yml`；指定时按名在两处查找。两处同名片段时报「业务片段重名」。

片段中引用扩展目录内的文件必须写成 `${G2RAIN_EXTENSION_DIR}/...`。

示例：

```bash
# .env
# G2RAIN_EXTENSION_DIR=../example-extension/deploy

./start.sh --business example
```
