# 配置与合并模型

## 环境变量

`env.example` 是 `.env` 模板，包含平台地址、端口、数据库、Redis、Nacos、时区和镜像等配置。模板中的固定值仅用于本地示例，生产环境必须全部审查并替换敏感项。

## Compose CLI 选择

`--compose-v2` 或 `--compose-v1` 的优先级最高；未指定时读取 `config/compose-cli.env`，再回退到脚本默认。辅助脚本可探测本机 CLI 并写入偏好文件，也支持 `--dry-run` 和 `--print-export`。

## 业务 Compose 片段

默认加载 `business.d/*.yml`；使用可重复的 `--business <name>` 时只加载指定片段。主 Compose 始终位于参数链第一位，业务片段随后追加。默认目录扫描不显式排序，多个片段不得依赖隐含顺序。

## 服务构建映射

`services.conf` 中每项格式为：

```text
repo|dir|compose_service|build_cmd
```

默认继续加载 `service_config.d/*.conf`。相同 `compose_service` 的后加载记录会整行覆盖已有记录；可重复使用 `--service <name>` 限定片段并固定命令行顺序。片段会被 Shell `source`，因此只能接受受信任内容。
