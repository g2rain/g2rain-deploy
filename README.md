# G2Rain Docker Compose 部署项目

这是一个基于Docker Compose的G2Rain开源SaaS平台部署配置项目，提供了完整的容器化部署解决方案。

## 🚀 快速开始

### 环境要求

- Docker 20.10+
- Docker Compose 2.0+
- 至少4GB可用内存
- 至少10GB可用磁盘空间

### 一键启动

```bash
# 1. 复制环境变量文件
cp env.example .env

# 2. 修改配置（可选）
vim .env

# 3. 生成SSL证书（必需，用于nginx的HTTPS访问）
./config/generate-ssl.sh <服务器IP地址>
# 或使用 start.sh 的参数
./start.sh --generate-ssl <服务器IP地址>

# 示例：如果服务器IP是 192.168.1.100
./config/generate-ssl.sh 192.168.1.100

# 4. 启动服务
./start.sh
```

**注意**: 
- SSL证书仅用于集群总入口的 nginx 服务，其他服务不需要证书
- SSL证书是启动服务的必需项，如果证书不存在，启动脚本会提示并阻止启动
- 请使用服务器的公网IP地址或内网IP地址生成证书
- 证书有效期：365天
- 如需重新生成证书，删除 `ssl/server.crt` 和 `ssl/server.key` 后重新运行生成命令

### 服务访问

- **HTTP地址**: http://localhost:8080
- **HTTPS地址**: https://localhost:443（使用自签名证书，浏览器会显示安全警告）
- **MySQL端口**: 3306
- **Redis端口**: 6379

## 📁 项目结构

```
g2rain-deploy/
├── docker-compose.yml          # Docker Compose配置文件
├── env.example                 # 环境变量示例文件
├── start.sh                    # 启动脚本
├── stop.sh                     # 停止脚本
├── update.sh                   # 更新脚本
├── config/                     # 配置文件目录
│   ├── generate-ssl.sh         # SSL证书生成脚本
│   ├── generate_key.sh         # 前端项目密钥生成脚本
├── data/                       # 数据持久化目录
│   ├── mysql/                  # MySQL数据目录
│   └── redis/                  # Redis数据目录
├── logs/                       # 日志目录
│   ├── mysql/                  # MySQL日志
│   ├── nginx/                  # Nginx日志
│   └── app/                    # 应用日志
├── config/                     # 配置文件目录
│   ├── mysql/                  # MySQL配置
│   ├── redis/                  # Redis配置
│   ├── nginx/                  # Nginx配置
│   └── app/                    # 应用配置
└── ssl/                        # SSL证书目录
    ├── server.crt              # SSL证书文件
    └── server.key              # SSL私钥文件
```

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
- **HTTP端口**: 8080（可通过环境变量 `NGINX_HTTP_PORT` 配置）
- **HTTPS端口**: 443（可通过环境变量 `NGINX_HTTPS_PORT` 配置）
- **配置文件**: `config/nginx/`
- **日志目录**: `logs/nginx`
- **SSL证书**: `ssl/server.crt` 和 `ssl/server.key`

### 应用服务
- **端口**: 8080
- **镜像**: 可配置
- **日志目录**: `logs/app`

## 📋 管理命令

### 启动服务
```bash
# 首次启动前，需要先生成SSL证书
./config/generate-ssl.sh <服务器IP地址>

# 启动所有服务
./start.sh

# 查看帮助信息
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

复制 `env.example` 为 `.env` 并根据需要修改：

```bash
cp env.example .env
```

主要配置项：

```env
# 应用配置
APP_IMAGE=g2rain/app:latest
APP_PORT=8080

# MySQL配置
MYSQL_ROOT_PASSWORD=g2rain123456
MYSQL_DATABASE=g2rain
MYSQL_USER=g2rain
MYSQL_PASSWORD=g2rain123456

# Redis配置
REDIS_PORT=6379
REDIS_PASSWORD=

# Nginx配置
NGINX_HTTP_PORT=8080
NGINX_HTTPS_PORT=443
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

1. **SSL证书不存在**
   ```bash
   # 错误提示：SSL证书不存在，无法启动HTTPS服务
   # 解决方法：生成SSL证书
   ./config/generate-ssl.sh <服务器IP地址>
   ```

2. **端口冲突**
   ```bash
   # 检查端口占用
   netstat -tulpn | grep :3306
   netstat -tulpn | grep :6379
   netstat -tulpn | grep :8080
   netstat -tulpn | grep :443
   ```

2. **权限问题**
   ```bash
   # 设置目录权限
   chmod -R 755 data/
   chmod -R 755 logs/
   ```

3. **服务启动失败**
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
