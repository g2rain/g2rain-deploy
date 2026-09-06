# 启动、停止与更新

## 启动

启动前先解析 Compose：

```shell
docker compose --env-file .env -f docker-compose.yml config
```

再执行 `./start.sh`。脚本会检查镜像、启动基础设施、等待健康并启动其余服务。完成后应检查 Compose 状态、关键容器日志、HTTPS 入口、登录和核心服务调用。

## 停止

普通维护使用 `./stop.sh`。只有明确要清理容器、网络和未使用镜像时才使用 `--cleanup`；持久化卷是否保留必须依据脚本输出与 Compose 定义再次确认。

## 更新

指定更新参数是 Compose 服务名，而不一定等于仓库名，例如默认 Gateway 映射。源码更新使用 `git pull --ff-only`，本地分叉或冲突会阻止更新。更新前备份数据和当前镜像/提交信息，更新后验证健康状态和业务冒烟流程。

`--force-pull` 与源码构建路径不同；选择前先确认目标版本来自镜像仓库还是本地源码。
