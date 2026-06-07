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
2. 再加载本目录下片段：`*.conf`**不做排序**，按 Bash 对该目录的稳定展开顺序逐个处理。
3. **去重**：以每条记录的第三段 **`compose_service`** 为键。若片段中某项与已有项键相同，则**整行被新记录替换**（同文件或后续文件中再次出现同键会继续覆盖）。
4. **默认**：加载 `service_config.d/*.conf` 全部片段。
5. **指定片段**：使用 `--service <名>`（可重复），只加载所列 `service_config.d/<名>.conf`，顺序与命令行一致，不扫描目录其余文件。

示例：

```bash
./init-once.sh --service custom-apps
./update.sh --service custom-apps g2rain-cms
./start.sh --service module-a --service module-b
```

`stop.sh` 不依赖服务映射，无需 `--service`。
