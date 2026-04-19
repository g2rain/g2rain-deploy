#!/bin/bash

# G2Rain SSL证书生成脚本
# 作者: G2Rain团队
# 版本: 1.0

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 生成自签名SSL证书
generate_ssl_certificate() {
    local server_ip=$1
    
    # 检查IP地址参数
    if [ -z "$server_ip" ]; then
        log_error "请提供服务器IP地址"
        echo ""
        echo "用法: $0 <IP地址>"
        echo "示例: $0 192.168.1.100"
        echo ""
        exit 1
    fi
    
    # 验证IP地址格式（简单验证）
    if ! echo "$server_ip" | grep -qE '^([0-9]{1,3}\.){3}[0-9]{1,3}$'; then
        log_error "无效的IP地址格式: $server_ip"
        exit 1
    fi
    
    # 获取脚本所在目录，并获取项目根目录（上一级目录）
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local project_root="$(cd "$script_dir/.." && pwd)"
    local ssl_dir="$project_root/ssl"
    local cert_file="$ssl_dir/server.crt"
    local key_file="$ssl_dir/server.key"
    
    # 检查 openssl 是否安装
    if ! command -v openssl &> /dev/null; then
        log_error "OpenSSL未安装，无法生成SSL证书"
        log_info "请先安装OpenSSL:"
        log_info "  CentOS/RHEL: yum install openssl"
        log_info "  Ubuntu/Debian: apt-get install openssl"
        exit 1
    fi
    
    log_info "生成自签名SSL证书..."
    log_info "服务器IP地址: $server_ip"
    
    # 确保ssl目录存在
    mkdir -p "$ssl_dir"
    
    # 如果证书已存在，询问是否覆盖
    if [ -f "$cert_file" ] || [ -f "$key_file" ]; then
        log_warning "SSL证书已存在: $cert_file"
        read -p "是否覆盖现有证书? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "已取消操作"
            exit 0
        fi
        rm -f "$cert_file" "$key_file"
    fi
    
    # 生成证书配置
    local cert_config="
[req]
default_bits = 2048
prompt = no
default_md = sha256
distinguished_name = dn
req_extensions = v3_req

[dn]
C=CN
ST=State
L=City
O=G2Rain
OU=IT Department
CN=$server_ip

[v3_req]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names

[alt_names]
IP.1 = $server_ip
IP.2 = 127.0.0.1
DNS.1 = localhost
DNS.2 = $server_ip
"
    
    # 创建临时配置文件
    local temp_config=$(mktemp)
    echo "$cert_config" > "$temp_config"
    
    # 生成私钥和证书
    log_info "正在生成证书..."
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout "$key_file" \
        -out "$cert_file" \
        -config "$temp_config" \
        -extensions v3_req 2>/dev/null
    
    # 清理临时文件
    rm -f "$temp_config"
    
    if [ $? -eq 0 ] && [ -f "$cert_file" ] && [ -f "$key_file" ]; then
        chmod 600 "$key_file"
        chmod 644 "$cert_file"
        log_success "SSL证书生成成功！"
        echo ""
        echo "证书文件:"
        echo "  证书: $cert_file"
        echo "  私钥: $key_file"
        echo ""
        echo "证书信息:"
        echo "  包含IP地址: $server_ip, 127.0.0.1"
        echo "  有效期: 365天"
        echo ""
        echo "现在可以运行 ./start.sh 启动服务"
        echo ""
        return 0
    else
        log_error "SSL证书生成失败"
        exit 1
    fi
}

# 主函数
main() {
    echo "=========================================="
    echo "    G2Rain SSL证书生成脚本"
    echo "=========================================="
    echo ""
    
    if [ $# -eq 0 ]; then
        log_error "请提供服务器IP地址"
        echo ""
        echo "用法: $0 <IP地址>"
        echo "示例: $0 192.168.1.100"
        echo ""
        echo "注意: 请使用服务器的公网IP地址或内网IP地址"
        echo ""
        exit 1
    fi
    
    generate_ssl_certificate "$1"
}

# 执行主函数
main "$@"
