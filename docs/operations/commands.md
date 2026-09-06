# 命令参考

## 初始化

```shell
./init-once.sh [--host HOST] [--port PORT] [--skip-build] [--ssl-ip IP] [--force]
./init-once.sh --service <name> [--service <name> ...]
```

- `--skip-build`：仍同步源码，但跳过所有镜像构建。
- `--force`：忽略完成标记重新执行。
- `--ssl-ip`：调用 OpenSSL 生成证书。

## 启动

```shell
./start.sh
./start.sh --compose-v2
./start.sh --business <name> --service <name>
./start.sh --host <host> --port <port>
./start.sh --generate-ssl <ip>
./start.sh kafka
```

## 停止

```shell
./stop.sh
./stop.sh --business <name>
./stop.sh --cleanup
```

`--cleanup` 会扩大清理范围，不应作为普通停止的默认选项。

## 更新

```shell
./update.sh
./update.sh <compose-service>
./update.sh <compose-service> --force-pull
./update.sh --cleanup-all
```

所有生命周期命令还支持 `--compose-v1`/`--compose-v2`；业务和服务片段参数可重复。执行前使用各脚本的 `--help` 核对当前实现。
