业务侧 Docker Compose 片段目录
================================

约定
----
- 本目录下扩展名为 `.yml` 的文件会在 start / stop / update 时按「主 docker-compose.yml（或 compose-v2 主文件）之后追加 -f」合并加载；不排序。
- 仓库默认提供 **`g2rain-cms.yml`**（**`g2rain-cms`**、**`g2rain-cms-app`**），与主 compose 中的网络、MySQL 初始化等配合使用；勿在主 compose 中重复定义同名 service。
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
