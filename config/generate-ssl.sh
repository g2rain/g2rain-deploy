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

# 验证 IPv4
is_valid_ipv4() {
    local ip=$1
    local IFS='.'
    local -a octets

    # 基础格式校验
    if [[ ! $ip =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
        return 1
    fi

    read -r -a octets <<< "$ip"
    if [ ${#octets[@]} -ne 4 ]; then
        return 1
    fi

    # 每段范围 0-255
    for octet in "${octets[@]}"; do
        if [ "$octet" -lt 0 ] || [ "$octet" -gt 255 ]; then
            return 1
        fi
    done

    return 0
}

# 验证域名（简单校验）
is_valid_domain() {
    local domain=$1

    # 允许 localhost 作为本地域名
    if [ "$domain" = "localhost" ]; then
        return 0
    fi

    # 基本域名格式：至少包含一个点，每段 1-63，整体不超过 253
    if [[ ! $domain =~ ^([a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,63}$ ]]; then
        return 1
    fi

    if [ "${#domain}" -gt 253 ]; then
        return 1
    fi

    return 0
}

# 生成自签名SSL证书
generate_ssl_certificate() {
    local server_host=$1
    local host_type=""
    
    # 检查参数
    if [ -z "$server_host" ]; then
        log_error "请提供服务器IP或域名"
        echo ""
        echo "用法: $0 <IP地址|域名>"
        echo "示例:"
        echo "  $0 192.168.1.100"
        echo "  $0 demo.g2rain.com"
        echo ""
        exit 1
    fi
    
    # 判断参数类型（IP 或 域名）
    if is_valid_ipv4 "$server_host"; then
        host_type="ip"
    elif is_valid_domain "$server_host"; then
        host_type="domain"
    else
        log_error "无效的IP地址或域名格式: $server_host"
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
    if [ "$host_type" = "ip" ]; then
        log_info "服务器IP地址: $server_host"
    else
        log_info "服务器域名: $server_host"
    fi
    
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
    
    # 根据参数类型构造 SAN
    local san_entries=""
    if [ "$host_type" = "ip" ]; then
        san_entries="IP.1 = $server_host
IP.2 = 127.0.0.1
DNS.1 = localhost"
    else
        san_entries="DNS.1 = $server_host
DNS.2 = localhost
IP.1 = 127.0.0.1"
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
CN=$server_host

[v3_req]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names

[alt_names]
$san_entries
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
        if [ "$host_type" = "ip" ]; then
            echo "  包含IP地址: $server_host, 127.0.0.1"
            echo "  包含域名: localhost"
        else
            echo "  包含域名: $server_host, localhost"
            echo "  包含IP地址: 127.0.0.1"
        fi
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
        log_error "请提供服务器IP或域名"
        echo ""
        echo "用法: $0 <IP地址|域名>"
        echo "示例:"
        echo "  $0 192.168.1.100"
        echo "  $0 demo.g2rain.com"
        echo ""
        echo "注意: 请使用服务器公网IP、内网IP或可访问域名"
        echo ""
        exit 1
    fi
    
    generate_ssl_certificate "$1"
}

# 执行主函数
main "$@"
