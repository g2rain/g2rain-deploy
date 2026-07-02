# g2rain-deploy

## 1. 徽标与状态标识
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)
[![Docker Compose](https://img.shields.io/badge/Docker%20Compose-Deployment-2496ED?logo=docker&logoColor=white)](https://www.docker.com/)
[![Docker](https://img.shields.io/badge/Docker-20.10%2B-2496ED?logo=docker&logoColor=white)](https://www.docker.com/)
[![Shell](https://img.shields.io/badge/Shell-Bash-4EAA25?logo=gnu-bash&logoColor=white)](https://www.gnu.org/software/bash/)

## 2. 项目简介
`g2rain-deploy` 是 G2rain 平台的标准化部署仓库，负责把基础中间件、后端服务、前端子应用、业务扩展与交付配置编排为一套可初始化、可启动、可更新、可扩展的部署环境。

## 3. 平台定位
在 G2rain“企业级 AI 原生开源 SaaS 平台”体系中，`g2rain-deploy` 位于平台交付与运维支撑侧，服务于测试环境、演示环境、私有化部署与持续交付场景。
它解决的不是单个服务怎么启动，而是整个平台怎么以统一方式完成环境初始化、脚本执行、服务编排、配置治理、密钥挂载和后续更新。

## 4. 核心能力
- 首次安装能力：通过 `init-once.sh` 统一完成 `.env` 初始化、SQL 占位符替换、SSL 生成、源码拉取与镜像构建。
- 标准启动能力：通过 `start.sh`、`docker-compose.yml`、`compose-v2/compose.yaml` 和 `business.d/*.yml` 合并形成最终运行配置。
- 标准停止能力：通过 `stop.sh` 支持“停止保留现场”和“停止并清理容器”两种模式。
- 标准更新能力：通过 `update.sh` 联动 `services.conf` 和 `service_config.d/*.conf` 执行全量或按服务更新。
- 业务片段扩展能力：通过 `business.d/*.yml` 将主编排与业务模块解耦。
- 服务清单治理能力：通过 `services.conf`、`services-merge.inc` 和 `service_config.d/*.conf` 统一管理源码仓库、Compose 服务名和构建命令之间的映射关系。
- 交付配置治理能力：通过 `config/` 目录沉淀 MySQL、Redis、Nacos、Nginx/OpenResty 和前端应用密钥的标准交付材料。

## 5. 技术栈
- 脚本语言：`Shell`
- 编排方式：`docker-compose`、`docker compose`
- 运行环境：`Docker 20.10+`
- 中间件：`MySQL`、`Redis`、`Nacos`、`Kafka`、`Nginx/OpenResty`
- 配置机制：`.env`、`services.conf`、`business.d/*.yml`、`service_config.d/*.conf`

## 6. 快速开始
### 环境要求
- `Git`
- `Docker 20.10+`
- `docker-compose` 或 `docker compose`
- `JDK`、`Maven`（首次构建源码镜像时使用）

### 首次安装
```bash
./init-once.sh --host <部署域名或IP> --port <HTTPS端口> --ssl-ip <证书绑定IP>
```

### 启动平台
```bash
./start.sh
```

### 停止与更新
```bash
./stop.sh
./stop.sh --cleanup
./update.sh
./update.sh g2rain-basis
```

## 7. 项目结构
```text
g2rain-deploy/
├── business.d/                             # 业务扩展 Compose 片段目录
├── compose-v2/                             # Docker Compose V2 主编排文件
├── config/                                 # 数据库、中间件、Nginx、应用密钥等交付配置
├── scripts/                                # 辅助脚本，如 Compose CLI 偏好写入脚本
├── service_config.d/                       # 服务映射扩展片段目录
├── compose-cli-preference.inc              # Compose V1/V2 选择逻辑
├── compose-merge.inc                       # 主 Compose 与业务片段合并逻辑
├── services-merge.inc                      # 基础服务清单与扩展片段合并逻辑
├── docker-compose.yml                      # Docker Compose V1 主编排文件
├── docker-compose.fragment.gateway-webmvc.yml # WebMVC 网关切换片段
├── env.example                             # 环境变量示例
├── init-once.sh                            # 首次安装与初始化脚本
├── start.sh                                # 平台启动脚本
├── stop.sh                                 # 平台停止脚本
├── update.sh                               # 平台更新脚本
└── services.conf                           # 默认源码仓库与构建映射清单
```

## 8. 核心业务流程
### 8.1 首次安装流程
- `init-once.sh` 优先检查依赖、生成 `.env`，并在必要时写入 `PLATFORM_HOST`、`PLATFORM_PORT`。
- 脚本会把 `config/mysql/g2rain-basis.sql` 中的平台地址占位符替换为真实访问地址，确保平台初始化后的访问入口正确。
- 如传入 `--ssl-ip`，则调用 `config/generate-ssl.sh` 生成 HTTPS 证书。
- 脚本基于 `services.conf` 与 `service_config.d/*.conf` 解析源码仓库清单，拉取到 `codes/` 目录，并逐个执行各仓库中的 `build.sh`。
- 全流程成功后写入 `.g2rain-deploy-install.done`，作为已完成初始化的标记。

### 8.2 平台启动流程
- `start.sh` 会先校验 `.env`、目录结构、Compose CLI 与基础依赖。
- 脚本通过 `compose-cli-preference.inc` 判断当前使用 `docker-compose` 还是 `docker compose`。
- 再通过 `compose-merge.inc` 将主 Compose 文件与 `business.d/*.yml` 合并，形成最终运行编排。
- 启动后会等待 `mysql`、`redis`、`nacos`、`kafka` 等核心依赖就绪，再继续后续服务运行。

### 8.3 平台更新流程
- `update.sh` 支持全量更新，也支持按服务更新。
- 更新时会先基于 `services-merge.inc` 得到最终服务映射，再执行源码拉取、镜像构建和容器重建。
- 若使用 `--service`，则只加载指定的 `service_config.d/*.conf` 扩展映射。
- 若使用 `--business`，则只合并指定的 `business.d/*.yml` 业务片段。

## 9. 关键脚本与配置
这是 `g2rain-deploy` 的关键章节，重点说明“平台究竟依赖哪些脚本与配置完成交付、启动和更新”。

### 9.1 核心脚本
- `init-once.sh`：负责首次安装，覆盖 `.env` 初始化、SQL 占位符替换、SSL 证书生成、源码拉取、镜像构建与完成标记写入。
- `start.sh`：负责启动平台，自动准备目录结构、选择 Compose CLI、合并业务片段并启动全部容器。
- `stop.sh`：负责停止平台，支持仅停止容器，或通过 `--cleanup` 进一步清理容器、网络与无用镜像。
- `update.sh`：负责后续更新，支持全量更新和单服务更新，是持续交付阶段的主入口。
- `scripts/write-compose-cli-preference.sh`：用于写入 Compose CLI 偏好，统一 `docker-compose` 与 `docker compose` 的使用方式。

### 9.2 Compose 编排体系
- `docker-compose.yml`：默认的 Compose V1 主编排文件。
- `compose-v2/compose.yaml`：默认的 Compose V2 主编排文件。
- `compose-cli-preference.inc`：为 `start.sh`、`stop.sh`、`update.sh` 提供统一的 Compose CLI 决策逻辑，并支持 `--compose-v1`、`--compose-v2` 或配置文件切换。
- `compose-merge.inc`：负责把主 Compose 文件与 `business.d/*.yml` 合并，形成当前实际运行栈。
- `docker-compose.fragment.gateway-webmvc.yml`：用于把默认网关切换为 WebMVC 实现，可复制或纳入 `business.d/` 参与合并。

### 9.3 服务映射与源码构建
- `services.conf`：定义默认服务清单，格式为 `repo|dir|compose_service|build_cmd`。
- `CODES_DIR`：默认值为 `./codes`，表示源码拉取与构建目录。
- `GIT_BASE_DEFAULT`：定义默认源码基址，当前仓库中用于拼接 `g2rain` 组织下的各源码仓库。
- `service_config.d/*.conf`：用于按环境或按业务追加服务映射，而不直接修改主 `services.conf`。
- 当前默认纳入的服务包括 `g2rain-infra`、`g2rain-basis`、`g2rain-iam`、`g2rain-gateway-webflux`、`g2rain-cms`、`g2rain-infra-app`、`g2rain-manager-app`、`g2rain-cms-app`、`g2rain-main-shell`、`g2rain-department-app`、`g2rain-department`。

### 9.4 配置与交付材料
- `env.example`：沉淀平台级环境变量示例，覆盖 `PLATFORM_HOST`、`PLATFORM_PORT`、`PLATFORM_BASE_URL`、`MYSQL_*`、`REDIS_*`、`NGINX_HTTPS_PORT`、`NACOS_*` 和 `TZ` 等关键配置。
- `config/mysql/`：包含 `g2rain-basis.sql`、`g2rain-infra.sql`、`g2rain-cms.sql`、`g2rain-department.sql`、`init-nacos.sql` 与 `my.cnf`，用于数据库初始化与运行配置。
- `config/redis/redis.conf`：Redis 运行配置。
- `config/nacos/logback-spring.xml`：Nacos 日志配置。
- `config/nginx/nginx.conf`、`config/nginx/conf.d/default.conf`、`config/nginx/conf.d/locations.inc`：Nginx/OpenResty 入口配置，用于统一静态站点、前端子应用与 API 入口的路由管理。
- `config/generate-ssl.sh`：生成 HTTPS 证书。
- `config/generate_key.sh`：生成应用身份所需的 ES256 密钥材料。

### 9.5 应用身份密钥目录
- `config/g2rain-main-shell/keys`
- `config/g2rain-manager-app/keys`
- `config/g2rain-infra-app/keys`
- `config/g2rain-cms-app/keys`
- `config/g2rain-department-app/keys`

这些目录用于保存各前端应用的公私钥、IAM 公钥与 Key ID，是平台“应用独立身份”方案在部署侧的落地点，并与 OpenResty + Lua 脚本协同完成应用签名链路。

## 10. 常用命令
```bash
./init-once.sh --host 43.138.13.145 --port 443 --ssl-ip 43.138.13.145
./init-once.sh --skip-build
./start.sh
./start.sh --compose-v2
./start.sh --business g2rain-cms
./stop.sh
./stop.sh --cleanup
./update.sh
./update.sh g2rain-basis
./update.sh --service custom-apps g2rain-cms
```

## 11. 使用建议
- 首次交付时优先完成 `.env`、SQL 初始化参数、SSL 证书与应用密钥校验，再执行完整启动。
- 需要切换编排实现时，统一通过 Compose CLI 偏好或命令参数控制，不建议直接改动脚本主体。
- 新增业务模块时，优先通过 `business.d/*.yml` 和 `service_config.d/*.conf` 扩展，避免污染主编排与主服务清单。

## 12. 相关模块
- `g2rain-basis`：平台基础能力与应用、角色、权限、交付能力承载模块。
- `g2rain-iam`：平台身份认证与统一安全能力模块。
- `g2rain-infra`：平台基础设施与运行支撑模块。
- `g2rain-gateway-webflux`：默认网关实现。
- `g2rain-gateway-webmvc`：可替换的 WebMVC 网关实现。
- `g2rain-main-shell`：平台主壳前端应用。
- `g2rain-manager-app`：管理端前端子应用。
- `g2rain-cms-app`：CMS 前端子应用。
- `g2rain-department-app`：部门相关前端子应用。

## 13. 核心价值
- 为整个平台提供统一、可复制、可演进的 Docker Compose 交付方案。
- 把部署复杂度收敛到 `init-once.sh`、`start.sh`、`update.sh`、`services.conf`、`.env` 和 Nginx 配置中，降低环境初始化成本。
- 通过 `business.d/*.yml` 与 `service_config.d/*.conf` 保持平台交付主干稳定，同时支持业务增量扩展。
- 为应用独立身份、安全签名链路、数据库初始化和多模块协同部署提供标准交付基础。

## 14. 贡献指南
欢迎通过 Issue 与讨论区反馈部署问题、配置建议与交付经验。

## 15. 许可证
本项目基于 [Apache 2.0许可证](LICENSE) 开源。

## 16. 联系我们
- **站点**: https://www.g2rain.com/
- **Issues**: [GitHub Issues](https://github.com/g2rain/g2rain/issues)
- **讨论**: [GitHub Discussions](https://github.com/g2rain/g2rain/discussions)
- **邮箱**: g2rain_developer@163.com

## 17. 致谢
感谢所有关注和参与 G2rain 平台建设的开发者与使用者。
如果该项目对你有帮助，欢迎持续关注并支持。
