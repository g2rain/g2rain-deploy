# 安全、密钥与数据

## 环境凭据

`env.example` 中的固定密码和认证材料仅能作为本地示例。生产环境必须使用独立强凭据和受控 Secret 注入，限制文件权限，避免通过命令行、日志、备份或工单泄露。

## 应用密钥

仓库当前跟踪多个 `config/g2rain-*-app/keys/` 目录，其中包含命名为私钥的 PEM/DER 文件。它们必须视为不可信的演示材料：禁止生产复用，并应决定是否从当前版本及 Git 历史移除。若曾在任何环境使用，必须立即轮换对应密钥。

生成脚本输出的新私钥只应写入部署主机的受限 Secret 路径，不应再次提交。公钥与 IAM key id 的分发也需要版本和信任链管理。

## 数据与网络

- MySQL、Redis、Nacos 和 Kafka 不应直接暴露到不可信网络。
- Docling Serve 与 Milvus 由 `business.d/g2rain-knowledge.yml` 编排，仅在 `g2rain-network` 内提供服务；不得为二者添加面向公网的端口映射。
- Milvus 必须保持鉴权开启。首次部署由运维使用初始 root 账号完成一次性引导：修改默认 root 密码、创建供 Knowledge Service 使用的最小权限账号，并以 `MILVUS_TOKEN` 通过受控 Secret 注入 `username:password` 连接凭据；Compose 配置本身不创建业务账号，不得将初始密码或真实凭据提交到仓库。
- Milvus 的持久化目录为 `data/milvus/`，其中包含向量数据、嵌入式 etcd 和本地 WAL，必须整体纳入备份与恢复演练。知识原文件和解析产物默认持久化在 `data/g2rain-knowledge/`（由 `business.d/g2rain-knowledge.yml` 挂载），须独立备份。
- 生产端口、网络策略、TLS、备份和最小权限由部署环境负责。
- Nginx/Gateway 转发的身份头必须只在可信网络内建立与传播。
- 日志和备份可能含 Token、用户数据及连接信息，应限制访问和保留周期。

## 执行边界

`service_config.d/*.conf` 会被 `source`，`build_cmd` 会直接执行，源码仓库的 `build.sh` 也进入信任边界。只允许受评审的映射、仓库和提交参与部署。
