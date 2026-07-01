# g2rain-deploy

## 1. 徽标与状态标识
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)
[![Docker Compose](https://img.shields.io/badge/Docker%20Compose-Deployment-2496ED?logo=docker&logoColor=white)](https://www.docker.com/)
[![Docker](https://img.shields.io/badge/Docker-20.10%2B-2496ED?logo=docker&logoColor=white)](https://www.docker.com/)
[![Shell](https://img.shields.io/badge/Shell-Bash-4EAA25?logo=gnu-bash&logoColor=white)](https://www.gnu.org/software/bash/)

## 2. 项目简介
`g2rain-deploy` 是 G2rain 平台的标准化部署仓库，负责把基础中间件、后端服务、前端子应用、业务扩展编排为一套可初始化、可启动、可更新、可扩展的交付环境。

## 3. 平台定位
在 G2rain“企业级 AI 原生开源 SaaS 平台”体系中，`g2rain-deploy` 位于交付与运维支撑侧，服务于测试环境、演示环境、私有化环境和持续交付场景。

它解决的不是单一服务如何启动，而是整个平台如何以统一方式完成：
- 环境初始化与首次安装
- 多仓库源码拉取与镜像构建
- 中间件、网关、后端、前端的整体编排
- 按业务片段扩展 compose 组合
- 按服务清单扩展平台交付范围

它与 `g2rain-basis`、`g2rain-iam`、`g2rain-infra`、`g2rain-gateway-webflux`、`g2rain-main-shell`、`g2rain-manager-app` 等仓库协同，承担平台“一键落地”的最后一公里。

## 4. 核心能力
- 初始化能力：通过 `init-once.sh` 完成 `.env` 生成、SQL 参数替换、证书准备、仓库拉取与镜像构建。
- 启动编排能力：通过 `start.sh`、`docker-compose.yml` 与 `compose-v2/` 拉起整个平台运行环境。
- 更新能力：通过 `services.conf`、`service_config.d/*.conf` 与 `update.sh` 完成服务级别的统一更新。
- 扩展能力：通过 `business.d/*.yml` 按需叠加业务 compose 片段。
- 配置与挂载能力：通过 `config/` 统一管理中间件、Nginx/OpenResty 与应用密钥挂载。

## 5. 技术栈
- 脚本语言：`Shell`
- 编排方式：`Docker Compose`、`docker compose`
- 运行环境：`Docker 20.10+`
- 中间件：`MySQL`、`Redis`、`Nacos`、`Kafka`、`Nginx/OpenResty`
- 配置机制：`.env`、`services.conf`、`business.d/*.yml`、`service_config.d/*.conf`

## 6. 快速开始
### 环境要求
- `Git`
- `Docker 20.10+`
- `docker-compose` 或 `docker compose`
- `JDK`、`Maven`

### 首次初始化
```bash
./init-once.sh --host <部署域名或IP> --port <HTTPS端口> --ssl-ip <证书绑定IP>
```

### 启动平台
```bash
./start.sh
```

### 停止平台
```bash
./stop.sh
```

### 更新服务
```bash
./update.sh
./update.sh g2rain-basis
```

## 7. 项目结构
```text
g2rain-deploy/
├── business.d/               # 业务 compose 片段扩展
├── compose-v2/               # docker compose v2 兼容文件
├── config/                   # 中间件与应用运行配置
├── scripts/                  # 脚本公共能力
├── service_config.d/         # 服务清单增量扩展
├── services.conf             # 默认服务与构建映射
├── docker-compose.yml        # 主编排文件
├── init-once.sh              # 首次安装入口
├── start.sh                  # 启动入口
├── stop.sh                   # 停止入口
└── update.sh                 # 更新入口
```

- `business.d/`：存放业务 compose 扩展片段。
- `service_config.d/`：增量扩展 `services.conf`。
- `services.conf`：定义仓库、目录、compose 服务名与构建命令。
- `config/`：集中管理 SQL、MySQL、Redis、Nginx、Nacos 与密钥挂载。

## 8. 核心业务流程
### 1）首次安装主线
- `init-once.sh` 先检查 `Git`、`Docker`、`JDK`、`Maven` 等依赖。
- 若 `.env` 不存在，则从 `env.example` 生成配置。
- 然后按 `services.conf` 拉取 `codes/` 下对应仓库，调用 `build.sh` 构建镜像。

### 2）标准启动主线
- `start.sh` 先校验 `.env`、证书、目录权限与 compose 命令可用性。
- 之后加载主 `docker-compose.yml`，并按需合并 `business.d/*.yml`。
- 依赖健康后再继续拉起开关、后端和前端应用。

### 3）按服务更新主线
- `update.sh` 读取 `services.conf` 与 `service_config.d/*.conf` 生成最终服务列表。
- 可全量更新，也可只更新指定 compose 服务对应仓库。

### 4）业务扩展主线
- 新增业务模块优先通过 `business.d/*.yml` 接入。
- 新增服务构建定义优先通过 `service_config.d/*.conf` 扩展。

## 9. 常用命令
```bash
./init-once.sh --host 43.138.13.145 --port 443 --ssl-ip 43.138.13.145
./init-once.sh --skip-build
./start.sh
./stop.sh
./update.sh
./update.sh g2rain-basis
```

## 10. 质量与测试
- 当前仓库以部署脚本、compose 编排和配置交付为主，尚未看到自动化测试结构。
- 建议后续补充脚本自检、配置校验与部署前检查说明。

## 11. 相关仓库
- `g2rain-basis`：平台基础治理与交付能力
- `g2rain-iam`：统一身份认证与令牌管理
- `g2rain-infra`：基础设施与平台公共服务
- `g2rain-gateway-webflux`：默认网关实现
- `g2rain-main-shell`：主壳前端应用

## 12. 使用建议
- 适合作为 G2rain 平台测试、演示、私有化部署的标准交付入口。
- 若新增业务模块，优先通过 `business.d/*.yml` 扩展。
- 若新增服务构建定义，优先通过 `service_config.d/*.conf` 扩展。

## 13. 贡献指南
欢迎以 Issue、文档改进、部署脚本增强、配置校验补充等形式参与贡献。

## 14. 许可证
本项目基于 [Apache 2.0许可证](LICENSE) 开源。

## 15. 联系我们
- **站点**: https://www.g2rain.com/
- **Issues**: [GitHub Issues](https://github.com/g2rain/g2rain/issues)
- **讨论**: [GitHub Discussions](https://github.com/g2rain/g2rain/discussions)
- **邮箱**: g2rain_developer@163.com

## 16. 致谢
感谢所有为这个项目做出贡献的开发者们。
如果这个项目对您有帮助，欢迎 Star 支持。
