# service_config.d — 额外服务映射片段

在默认 `services.conf` 之外，可按环境或业务模块追加 `SERVICES` 条目。**脚本运行时仅在内存中合并**，不会改写 `services.conf`。

## 文件格式

每个 `*.conf` 只需定义 `SERVICES` 数组，格式与 `services.conf` 中一致：

```bash
SERVICES=(
  "repo|dir|compose_service|build_cmd"
)
```

字段含义：`repo|dir|compose_service|build_cmd`（GitHub 仓库名、`codes/` 下目录名、compose 服务名、构建命令）。

## 加载规则

1. 始终先加载根目录 `services.conf`。
2. 再按顺序追加本目录下片段中的 `SERVICES`：
   - **默认**：扫描 `service_config.d/*.conf` 全部加载。
   - **指定片段**：使用 `--service <名>`（可重复），只加载 `service_config.d/<名>.conf`，不扫描目录其余文件。

示例：

```bash
./init-once.sh --service custom-apps
./update.sh --service custom-apps g2rain-cms
./start.sh --service module-a --service module-b
```

`stop.sh` 不依赖服务映射，无需 `--service`。
