# G2Rain Docker Compose 部署项目

这是一个基于 Docker Compose 的 G2Rain 开源 SaaS 平台部署配置项目：推荐先通过 **`init-once.sh`** 完成环境、SQL 占位符、源码克隆与默认镜像构建，再通过 **`start.sh`** 启动栈，日常迭代使用 **`update.sh`**。

## 🚀 快速开始

### 环境要求

**运行 `start.sh` / Compose 栈：**

- Docker 20.10+
- 可执行的 `docker-compose` 命令（与仓库内脚本一致；同时兼容 `docker compose` 插件用于部分检查）
- 至少 4GB 可用内存；建议预留 **10GB+** 磁盘（含镜像、`data/`、`codes/`）

**首次执行 `./init-once.sh`（克隆源码并默认构建本地镜像）还需：**

- Git、JDK、Maven（`java`、`mvn` 在 `PATH` 中）
- 能访问克隆源（默认 `https://github.com/g2rain`，可通过环境变量 `G2RAIN_GIT_BASE` 改为镜像站或私有前缀）

### 职责划分（推荐心智模型）

| 脚本 | 作用 |
|------|------|
| **`init-once.sh`** | 一次性安装：若无则生成 `.env`、按 `.env` 替换 `config/mysql/g2rain-basis.sql` 中的 `__PLATFORM_HOST__` / `__PLATFORM_PORT__`、可选生成 SSL、按 **`services.conf`** 克隆到 **`codes/`**、**默认**在各仓库执行 **`build.sh`**（可配置重试）、成功后写入 **`.g2rain-deploy-install.done`**。不执行 `docker compose up`。 |
| **`start.sh`** | 可重复启动：检查依赖与证书、缺镜像时尝试从 `codes/` 构建再 `pull`、`docker-compose up -d`。 |
| **`update.sh`** | 日常更新：按 `services.conf` 拉代码、构建、滚动容器等。 |

**MySQL：** 业务初始化 SQL 仅在 **`data/mysql` 为空**、MySQL 首次执行 `docker-entrypoint-initdb.d` 时导入。若数据卷已有数据，事后修改 `g2rain-basis.sql` 或 `.env` **不会**自动更新库内旧行，需自行迁移或清空数据卷后重装。

---

### `init-once.sh`：快捷方案与全参数

**快捷方案（最少命令）** — 适合先跑通流程，再在 `.env` 里改平台地址、端口等：

```bash
./init-once.sh
./config/generate-ssl.sh <服务器IP或域名>
./start.sh
```

说明：`init-once.sh` 若发现没有 `.env`，会从 `env.example` 复制一份；克隆后**默认**会依次执行各仓 **`build.sh`**，整段构建常见 **约 20～60 分钟**（视机器与网络而定）。完成后务必具备 **`ssl/server.crt`** 与 **`ssl/server.key`**，否则 `start.sh` 会拒绝启动。

**全参数方案** — 适合自动化或一次写清平台地址与证书：

```bash
# 创建 .env 时写入 PLATFORM_HOST / PLATFORM_PORT；安装阶段生成 ssl/；忽略已完成标记重装
./init-once.sh --host 43.138.13.145 --port 10443 --ssl-ip 192.168.1.100 --force

# 仅克隆与 SQL/.env，暂不构建镜像（网络差或先配环境）
./init-once.sh --skip-build

# 调整每仓 build 失败重试（默认 3 次、间隔 15 秒）
G2RAIN_BUILD_RETRIES=5 G2RAIN_BUILD_RETRY_SLEEP=30 ./init-once.sh

# 使用其他 Git 组织或镜像前缀
G2RAIN_GIT_BASE=https://github.com/your-org ./init-once.sh
```

常用选项：`--host` / `--port`（**仅当尚不存在 `.env` 时**与从模板创建联动）、`--skip-build`、`--ssl-ip`、`--force`；环境变量 `G2RAIN_DEPLOY_INIT_FORCE=1` 等同 `--force`。完整说明：`./init-once.sh --help`。

---

### `start.sh`：快捷方案与全参数

**快捷方案：**

```bash
./start.sh
```

**全参数方案：**

```bash
# 若尚无 .env，从 env.example 创建并写入平台 host/port（与手动改 .env 等价）
./start.sh --host 43.138.13.145 --port 10080

# 仅生成 SSL（完成后需再执行 ./start.sh 正常启动）
./start.sh --generate-ssl 192.168.1.100

./start.sh --help
```

未检测到 **`.g2rain-deploy-install.done`** 时，`start.sh` 会提示先执行 **`./init-once.sh`**（不强制退出）。若缺少业务镜像且存在 **`codes/<目录>`**，会按 **`services.conf`** 尝试对应 **`build.sh`**，仍缺再执行 **`docker-compose pull`**。

**注意：**

- SSL 证书仅用于集群总入口 **nginx**；其他后端服务不依赖该证书文件。
- 证书不存在时 **`start.sh` 会阻止启动**；请使用服务器公网 IP、内网 IP 或域名生成（与 `generate-ssl.sh` 说明一致）。
- 重新生成证书：删除 `ssl/server.crt`、`ssl/server.key` 后重新执行 `./config/generate-ssl.sh` 或 `./start.sh --generate-ssl <地址>`。

### 服务访问

端口以 **`.env`** 为准（参见 `env.example` 中的 `NGINX_HTTP_PORT`、`NGINX_HTTPS_PORT`、`MYSQL_PORT`、`REDIS_PORT`）。默认示例常为：

- **HTTP：** `http://localhost:10080`（若你未改 `NGINX_HTTP_PORT`）
- **HTTPS：** `https://localhost:10443`（自签名证书时浏览器会提示风险）
- **MySQL / Redis：** 默认映射端口见 `.env`（如 `MYSQL_PORT=3306`）

## 📁 项目结构

```
g2rain-deploy/
├── docker-compose.yml          # Docker Compose 配置
├── env.example                 # 环境变量模板（复制为 .env）
├── services.conf               # 克隆目录与 compose 服务、build 命令映射（Bash 源文件）
├── init-once.sh                # 一次性安装：.env / SQL 占位符 / 克隆 codes / 默认 build
├── start.sh                    # 启动栈（缺镜像时可从 codes/ 构建）
├── stop.sh                     # 停止脚本
├── update.sh                   # 更新：拉代码、构建、更新容器
├── codes/                      # 克隆的业务仓库根目录（.gitignore，由 init-once 创建）
├── .g2rain-deploy-install.done # 安装完成标记（.gitignore，存在则 init-once 默认跳过）
├── config/
│   ├── generate-ssl.sh         # SSL 证书生成
│   ├── generate_key.sh         # 前端 ES256 密钥生成
│   ├── mysql/                  # MySQL 配置与初始化 SQL（含 g2rain-basis.sql 平台占位符）
│   ├── redis/
│   ├── nginx/
│   └── nacos/
├── data/                       # 持久化数据（.gitignore）
│   ├── mysql/
│   └── redis/
├── logs/                       # 日志（.gitignore）
└── ssl/                        # 入口证书（私钥勿提交）
    ├── server.crt
    └── server.key
```

### `services.conf` 与 `codes/`

`services.conf` 为 Bash 片段，定义数组 **`SERVICES`**：每一项为 **`repo|dir|compose_service|build_cmd`**（GitHub 仓库名、检出到 `codes/` 下的目录名、`docker-compose.yml` 中的服务名、构建命令，默认 `./build.sh`）。**`init-once.sh`**、**`update.sh`**、**`start.sh`**（缺镜像时）均依赖该映射。克隆根目录由其中的 **`CODES_DIR`** 控制（默认同级 **`codes/`**）。

## 🛠️ 服务组件

### MySQL 8.0
- **端口**: 3306
- **数据持久化**: `data/mysql`
- **配置文件**: `config/mysql/my.cnf`
- **日志目录**: `logs/mysql`

### Redis 7
- **端口**: 6379
- **数据持久化**: `data/redis`
- **配置文件**: `config/redis/redis.conf`

### Nginx
- **HTTP / HTTPS 端口**：由 `.env` 中 `NGINX_HTTP_PORT`、`NGINX_HTTPS_PORT` 配置（默认见 `env.example`，如 `10080` / `10443`）
- **配置文件**: `config/nginx/`
- **日志目录**: `logs/nginx`
- **SSL证书**: `ssl/server.crt` 和 `ssl/server.key`

### 应用与中间件容器

各业务容器对外端口由 **`docker-compose.yml`** 与 **`.env`** 共同决定（例如网关、IAM 等映射到宿主机的端口）；容器内 Spring 服务常见监听 **8080**。镜像名多为 `g2rain/...:latest`，本地开发可通过 **`init-once.sh`** / **`update.sh`** 在 **`codes/`** 中构建。各服务日志目录见 **`logs/<服务名>/`**。


## 📋 管理命令

### 首次安装（init-once）

与上文 **「`init-once.sh`：快捷方案与全参数」** 一致。完成后执行 `./start.sh` 拉起栈。日常代码与镜像更新请用 **`./update.sh`**。

### 启动服务（start）

与上文 **「`start.sh`：快捷方案与全参数」** 一致。简要对照：

```bash
./start.sh
./start.sh --host <HOST> --port <PORT>
./start.sh --generate-ssl <IP或域名>
./start.sh --help
```

### 停止服务
```bash
# 停止服务但保留容器
./stop.sh

# 停止服务并清理容器
./stop.sh --cleanup
```

### 生成SSL证书
```bash
# 方式1：使用独立脚本（推荐）
./config/generate-ssl.sh <服务器IP地址>

# 方式2：使用 start.sh 参数
./start.sh --generate-ssl <服务器IP地址>

# 示例
./config/generate-ssl.sh 192.168.1.100

# 重新生成证书（会提示是否覆盖）
./config/generate-ssl.sh 192.168.1.100
```

**SSL证书说明**：
- **仅用于集群总入口 nginx**：SSL证书仅用于 docker-compose.yml 中配置的 nginx 服务（集群总入口），其他服务（gateway、iam、basis、infra、test-app、main-shell 等）均不需要证书
- 证书包含指定的IP地址和 localhost
- 自签名证书，浏览器会显示安全警告，需要手动信任
- 证书有效期：365天
- 证书文件位置：`ssl/server.crt` 和 `ssl/server.key`

### 生成前端项目密钥

`generate_key.sh` 用于生成前端项目所需的 ES256 (P-256) 公私钥对，支持 PEM 和 DER 两种格式。

```bash
# 基本用法
./config/generate_key.sh <目标目录> [密钥名称]

# 示例1：生成默认名称的密钥（生成 private-key.pem, public-key.pem 等）
./config/generate_key.sh config/g2rain-main-shell/keys

# 示例2：生成指定名称的密钥（生成 iam-private-key.pem, iam-public-key.pem 等）
./config/generate_key.sh config/g2rain-main-shell/keys iam

# 示例3：为其他应用生成密钥
./config/generate_key.sh config/g2rain-test-app/keys test
```

**输出文件**：
- `private-key.pem` / `<name>-private-key.pem` - 私钥（PEM格式，PKCS#8）
- `public-key.pem` / `<name>-public-key.pem` - 公钥（PEM格式）
- `private-key.der` / `<name>-private-key.der` - 私钥（DER格式）
- `public-key.der` / `<name>-public-key.der` - 公钥（DER格式）

**密钥说明**：
- 使用 ES256 算法（P-256 椭圆曲线）
- 私钥格式为 PKCS#8，兼容 lua-resty-openssl
- 同时生成 PEM 和 DER 两种格式，满足不同场景需求
- 文件权限自动设置为 644（只读）

**IAM 模块配置**：

前端项目还需要在 `config/<项目名>/keys` 目录下添加以下两个文件，用于获取 IAM 模块的公钥和公钥 ID：

- `iam-public-key` - IAM 模块的公钥文件
- `iam-key-id` - IAM 模块的公钥 ID 文件

这两个文件需要从 IAM 服务获取，并手动放置到对应前端项目的 keys 目录下。例如：

```bash
# 为 g2rain-main-shell 配置 IAM 公钥
# 将 iam-public-key 和 iam-key-id 文件放置到：
config/g2rain-main-shell/keys/iam-public-key
config/g2rain-main-shell/keys/iam-key-id

# 为 g2rain-test-app 配置 IAM 公钥
# 将 iam-public-key 和 iam-key-id 文件放置到：
config/g2rain-test-app/keys/iam-public-key
config/g2rain-test-app/keys/iam-key-id
```

**Nginx 路径映射配置**：

前端项目部署时，还需要在 `config/nginx/conf.d/locations.inc` 文件中添加路径映射配置。路径必须与前端项目中 `.env.production` 文件中的 `VITE_CONTEXT_PATH` 配置保持一致。

例如，如果前端项目的 `VITE_CONTEXT_PATH=/test`，则需要在 `locations.inc` 中添加：

```nginx
location /test/ {
    proxy_pass http://g2rain-test-app:8080;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline' 'unsafe-eval';" always;
}
```

**配置说明**：
- `location /test/` 中的路径必须与前端项目的 `VITE_CONTEXT_PATH` 完全一致（包括前导斜杠）
- `proxy_pass` 中的服务名称必须与 `docker-compose.yml` 中对应的服务名称一致
- 配置完成后需要重启 nginx 服务使配置生效：`docker-compose restart nginx`

**注意事项**：
- 确保已安装 OpenSSL
- 如果目标目录不存在，脚本会自动创建
- 生成的密钥文件会覆盖同名的现有文件（不会提示确认）
- IAM 公钥和公钥 ID 文件需要从 IAM 服务获取，并手动配置到对应前端项目的 keys 目录
- **重要**：路径映射配置必须与前端项目的 `VITE_CONTEXT_PATH` 保持一致，否则前端应用无法正常访问

### 更新服务

`update.sh` 会读取 **`services.conf`**：默认先对有关仓库 **`git pull`** 并执行 **`build.sh`**，再 **`docker-compose pull` / `up`**（细节以 **`./update.sh --help`** 为准）。

**快捷方案：** 全量更新所有服务。

**全参数方案：** 只更新指定服务、强制拉镜像等。

```bash
# 更新所有服务
./update.sh

# 更新指定服务
./update.sh g2rain-gateway
./update.sh g2rain-iam
./update.sh g2rain-main-shell
./update.sh mysql
./update.sh redis
./update.sh nacos
./update.sh nginx

# 强制拉取最新镜像并更新
./update.sh --force-pull

# 更新并清理未使用镜像
./update.sh --cleanup-all
```

### 查看服务状态
```bash
docker-compose ps
```

### 查看服务日志
```bash
# 查看所有服务日志
docker-compose logs -f

# 查看指定服务日志
docker-compose logs -f app
docker-compose logs -f mysql
docker-compose logs -f redis
docker-compose logs -f nginx
```

## ⚙️ 配置说明

### 环境变量配置

复制 `env.example` 为 `.env` 并根据需要修改（**`init-once.sh` / `start.sh` 在首次时也可代为创建 `.env`**）：

```bash
cp env.example .env
```

与部署脚本强相关的主要项（完整列表以 `env.example` 为准）：

```env
# 平台对外的 Host / Port（写入 compose 中 SSO 等；init-once 会据此替换 g2rain-basis.sql 占位符）
PLATFORM_HOST=your server host
PLATFORM_PORT=your server host

# Nginx 入口端口（HTTP / HTTPS）
NGINX_HTTP_PORT=10080
NGINX_HTTPS_PORT=10443

# MySQL / Redis
MYSQL_ROOT_PASSWORD=g2rain123456
MYSQL_DATABASE=g2rain
MYSQL_PORT=3306
REDIS_PORT=6379
```

### 数据持久化

所有重要数据都进行了持久化配置：

- **MySQL数据**: `data/mysql` 目录
- **Redis数据**: `data/redis` 目录
- **应用日志**: `logs/app` 目录
- **服务日志**: `logs/` 目录

### 网络配置

- **网络名称**: g2rain-network
- **子网**: 172.20.0.0/16
- **驱动**: bridge

## 🔧 高级配置

### MySQL配置优化

编辑 `config/mysql/my.cnf` 进行MySQL性能优化：

```ini
# 内存设置
innodb_buffer_pool_size=1G
max_connections=1000

# 日志设置
slow_query_log=1
long_query_time=2
```

### Redis配置优化

编辑 `config/redis/redis.conf` 进行Redis配置：

```conf
# 内存设置
maxmemory 512mb
maxmemory-policy allkeys-lru

# 持久化设置
save 900 1
save 300 10
save 60 10000
```

### Nginx配置

编辑 `config/nginx/conf.d/default.conf` 进行反向代理配置。

**配置文件说明**：
- `default.conf`: HTTP 和 HTTPS server 块配置
- `locations.inc`: 共享的 location 配置（被 HTTP 和 HTTPS 共同使用）

**前端项目路径映射**：

在 `config/nginx/conf.d/locations.inc` 文件中配置前端项目的路径映射。路径必须与前端项目的 `VITE_CONTEXT_PATH` 配置保持一致。

例如，如果前端项目的 `VITE_CONTEXT_PATH=/test`，则添加：

```nginx
location /test/ {
    proxy_pass http://g2rain-test-app:8080;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline' 'unsafe-eval';" always;
}
```

配置完成后重启 nginx：`docker-compose restart nginx`

### SSL证书配置

SSL证书仅用于集群总入口的 nginx 服务，用于提供 HTTPS 访问。其他服务（gateway、iam、basis、infra、test-app、main-shell 等）均为内部服务，不需要证书。

#### 生成证书

首次部署时，需要为 nginx 生成SSL证书：

```bash
./config/generate-ssl.sh <服务器IP地址>
```

**注意事项**：
- **仅用于 nginx**：证书仅用于 docker-compose.yml 中配置的 nginx 服务（集群总入口）
- 请使用服务器的实际IP地址（公网IP或内网IP）
- 如果IP地址变更，需要重新生成证书
- 证书生成后，启动脚本会自动检查证书是否存在

#### 证书管理

```bash
# 查看证书信息
openssl x509 -in ssl/server.crt -text -noout

# 检查证书有效期
openssl x509 -in ssl/server.crt -noout -dates

# 重新生成证书（删除旧证书后重新生成）
rm ssl/server.crt ssl/server.key
./config/generate-ssl.sh <新IP地址>
```

## 🚨 故障排除

### 常见问题

1. **SSL 证书不存在**
   ```bash
   # 错误提示：SSL证书不存在，无法启动HTTPS服务
   ./config/generate-ssl.sh <服务器IP或域名>
   # 或在安装阶段一并生成：
   ./init-once.sh --ssl-ip <服务器IP或域名>
   ```

2. **端口冲突**
   ```bash
   # 检查端口占用（按 .env 中实际端口调整，以下为 env.example 常见示例）
   netstat -tulpn | grep :3306
   netstat -tulpn | grep :6379
   netstat -tulpn | grep :10080
   netstat -tulpn | grep :10443
   ```

3. **权限问题**
   ```bash
   # 设置目录权限
   chmod -R 755 data/
   chmod -R 755 logs/
   ```

4. **服务启动失败**
   ```bash
   # 查看详细日志
   docker-compose logs -f [服务名]
   ```

### 数据备份

```bash
# 手动备份数据
cp -r data/ backup/data_$(date +%Y%m%d_%H%M%S)/
```

### 数据恢复

```bash
# 停止服务
./stop.sh --cleanup

# 恢复数据
cp -r backup/data_YYYYMMDD_HHMMSS/* data/

# 重新启动
./start.sh
```

## 📊 监控和维护

### 健康检查

所有服务都配置了健康检查：

```bash
# 检查服务健康状态
docker-compose ps
```

### 日志管理

```bash
# 清理旧日志
find logs/ -name "*.log" -mtime +7 -delete
```

### 镜像更新

```bash
# 更新所有镜像
./update.sh

# 清理未使用镜像
docker system prune -f
```

## 🤝 贡献指南

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 打开 Pull Request

## 📄 许可证

本项目基于 [Apache 2.0许可证](LICENSE) 开源。

## 🆘 支持

如果您遇到问题或有任何疑问，请：

1. 查看本文档的故障排除部分
2. 检查 [Issues](https://github.com/g2rain/g2rain-deploy/issues)
3. 创建新的 Issue 描述您的问题

---

**G2Rain团队** - 让SaaS部署更简单！
