# service_config.d — 额外服务映射片段

在默认 `services.conf` 之外，可按环境或业务模块追加 `SERVICES` 条目。**脚本运行时仅在内存中合并**，不会改写 `services.conf`。

## 文件格式

每个 `*.conf` 只需定义 `SERVICES` 数组，格式与 `services.conf` 中一致：

```bash
SERVICES=(
  "repo|dir|compose_service|build_cmd"
  # 可选第 5 段：完整克隆地址
  # "example|example|example|./build.sh|https://github.com/example/example.git"
)
```

字段含义：`repo|dir|compose_service|build_cmd[|git_url]`（仓库名、`codes/` 下目录名、compose 服务名、构建命令；`git_url` 可省略，省略时为 `${GIT_BASE}/${repo}.git`）。

若设置了 `G2RAIN_EXTENSION_DIR`，还会加载 `${G2RAIN_EXTENSION_DIR}/service_config.d/*.conf`；与本目录同名片段时报错。

## 加载规则

1. 始终先加载根目录 `services.conf`。
2. 再加载本目录与扩展目录下片段：`*.conf`**不做排序**，按 Bash 对该目录的稳定展开顺序逐个处理。
3. **去重**：以每条记录的第三段 **`compose_service`** 为键。若片段中某项与已有项键相同，则**整行被新记录替换**（同文件或后续文件中再次出现同键会继续覆盖）。
4. **默认**：加载本目录与扩展目录下全部 `*.conf`。
5. **指定片段**：使用 `--service <名>`（可重复），按名在本目录与扩展目录查找，顺序与命令行一致，不扫描其余文件。

示例：

```bash
./init-once.sh --service example
./update.sh --service example
./start.sh --service example
```

`stop.sh` 不依赖服务映射，无需 `--service`。
