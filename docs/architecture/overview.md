# 架构与职责

仓库把部署职责划分为四部分：生命周期脚本负责操作顺序；Compose 文件定义运行拓扑；服务映射定义源码与镜像构建；配置目录提供中间件、代理、数据库初始化及应用密钥材料。

```text
运维人员
  -> init-once.sh：准备 .env、证书、源码与镜像
  -> start.sh：选择 Compose 栈、合并片段、启动并等待健康
  -> update.sh：拉取/构建或拉取镜像、重建服务
  -> stop.sh：停止；显式 cleanup 时清理容器/网络/镜像

配置输入
  -> env.example / .env
  -> services.conf + service_config.d
  -> 主 Compose + business.d
  -> config/ 中间件、SQL、Nginx 与应用密钥
```

本仓库不实现平台业务逻辑，也不替代生产级密钥管理、备份、灾难恢复、集群调度和高可用设计。
