# 首次安装

## 前置检查

- 在受控 Linux 主机或兼容 Bash 环境执行。
- 安装 Git、Docker、Docker Compose、JDK 和 Maven。
- 复制 `env.example` 为 `.env`，替换所有密码、Token、主机和端口。
- 确认当前 Docker Context、磁盘空间、开放端口和持久化目录。
- 为源码仓库准备访问权限，审查 `services.conf` 及扩展片段中的构建命令。

## 执行原则

`init-once.sh` 不会启动完整平台；初始化完成后再单独执行 `start.sh`。安装标记用于避免重复执行，`--force` 会绕过保护。MySQL 初始化 SQL 仅在空数据卷首次创建时自动执行，已有数据卷不会自动重放。

初始化会克隆/更新多个仓库并执行其中的 `build.sh`，应视为供应链执行边界。不要对不受信任的仓库地址、服务映射或扩展文件运行该流程。
