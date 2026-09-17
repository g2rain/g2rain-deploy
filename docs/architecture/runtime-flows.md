# 运行流程

## 首次初始化

1. 校验 Docker、Compose、Git、Maven 和 JDK。
2. 从模板创建或更新 `.env` 中的平台地址。
3. 可选生成 SSL 证书并处理数据库初始化 SQL 占位符。
4. 合并服务映射，在 `codes/` 下克隆或快进更新仓库。
5. 除非 `--skip-build`，执行每个映射的构建命令。
6. 写入安装完成标记；失败后可修复问题并重跑。

## 启动

1. 解析 Compose CLI、业务片段和服务映射。
2. 准备目录、权限、环境与证书。
3. 拉取缺失的第三方基础镜像，并尝试从源码构建缺失的 G2rain 镜像。
4. 启动基础设施、等待健康，再启动完整服务栈。

## 更新

更新指定服务时，脚本根据 Compose 服务名查找源码映射，执行 Git `fetch`、`pull --ff-only` 和构建命令，再重建目标服务。`--force-pull` 改为强制拉取镜像；无服务参数时处理全部服务。

## 停止与清理

普通停止保留数据。`stop.sh --cleanup` 会执行更广的容器、网络和未使用镜像清理；`update.sh --cleanup-all` 会调用 Docker system prune。执行前必须确认 Docker Context 和恢复方案。
