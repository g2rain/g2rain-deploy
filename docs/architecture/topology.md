# 部署拓扑

## 基础主编排

V1 与 V2 主配置静态解析后均包含 15 个服务：MySQL、Redis、Nacos、Kafka、Nginx、Gateway，以及 Infra、Basis、IAM、Department、Member 五个后端和 Main Shell、Infra App、Manager App、Department App 四个前端应用。

## 默认业务扩展

`business.d/g2rain-cms.yml` 增加 `g2rain-cms` 与 `g2rain-cms-app`。主配置与该片段合并后共 17 个服务。其他 `business.d/*.yml` 可继续扩展，但不得重复定义服务名，除非明确接受 Compose 覆盖语义。

## 依赖顺序

启动脚本先启动 MySQL 与 Redis，再等待 MySQL、Redis、Nacos、Kafka 健康，最后启动完整栈。具体 `depends_on` 和健康检查仍以当前 Compose 文件为准。

## 网关变体

默认服务映射从 `g2rain-gateway-webflux` 构建 `g2rain-gateway`。仓库提供 WebMVC 网关片段，可复制到 `business.d` 参与合并；切换前必须确认镜像、服务名和下游兼容性。
