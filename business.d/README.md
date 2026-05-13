业务侧 Docker Compose 片段目录
================================

约定
----
- 本目录下扩展名为 `.yml` 的文件会在 start / stop / update 时按「主 docker-compose.yml（或 compose-v2 主文件）之后追加 -f」合并加载；不排序。
- 请勿在多个片段中重复定义同一 service 名，合并结果由 Compose 覆盖规则决定，易产生非预期行为。

可选：只加载部分片段
--------------------
在 ./start.sh、./stop.sh、./update.sh 上可重复传入：

  --business <片段名>

片段名为 `business.d` 下的文件名，可写 `foo` 或 `foo.yml`。指定后**仅**加载列出的片段，不再自动加载本目录下其余 `.yml`。

示例
----
  ./start.sh --business tenant-a
  ./stop.sh --business tenant-a --cleanup
  ./update.sh g2rain-manager-app --business tenant-a
