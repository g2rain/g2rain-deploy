#!/bin/bash

# G2Rain部署启动脚本
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

# 检查Docker和Docker Compose是否安装
check_dependencies() {
    log_info "检查依赖环境..."
    
    if ! command -v docker &> /dev/null; then
        log_error "Docker未安装，请先安装Docker"
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        log_error "Docker Compose未安装，请先安装Docker Compose"
        exit 1
    fi
    
    log_success "依赖环境检查通过"
}

# 检查环境变量文件
check_env_file() {
    local platform_host="${1:-}"
    local platform_port="${2:-}"

    if [ ! -f ".env" ]; then
        log_warning "未找到.env文件，正在从env.example创建..."
        if [ -f "env.example" ]; then
            cp env.example .env

            # 如果传入了 host/port，则在生成 .env 时替换对应项
            if [ -n "$platform_host" ]; then
                sed -i "s/^PLATFORM_HOST=.*/PLATFORM_HOST=${platform_host}/" .env
            fi
            if [ -n "$platform_port" ]; then
                sed -i "s/^PLATFORM_PORT=.*/PLATFORM_PORT=${platform_port}/" .env
            fi

            log_success "已创建.env文件，请根据需要修改配置"
        else
            log_error "未找到env.example文件"
            exit 1
        fi
    fi
}

# 创建必要的目录
create_directories() {
    log_info "创建必要的目录结构..."
    
    directories=(
        "data/mysql"
        "data/redis"
        "logs/mysql"
        "logs/nginx"
        "logs/app"
        "config/mysql"
        "config/redis"
        "config/nginx/conf.d"
        "config/app"
        "ssl"
    )
    
    for dir in "${directories[@]}"; do
        if [ ! -d "$dir" ]; then
            mkdir -p "$dir"
            log_info "创建目录: $dir"
        fi
    done
    
    log_success "目录结构创建完成"
}

# 设置目录权限
set_permissions() {
    log_info "设置目录权限..."
    
    # 设置MySQL数据目录权限
    chmod 755 data/mysql 2>/dev/null || true
    chmod 755 logs/mysql 2>/dev/null || true
    
    # 设置Redis数据目录权限
    chmod 755 data/redis 2>/dev/null || true
    
    # 设置Nginx日志目录权限
    chmod 755 logs/nginx 2>/dev/null || true
    
    log_success "权限设置完成"
}

# 检查SSL证书是否存在
check_ssl_certificate() {
    local ssl_dir="ssl"
    local cert_file="$ssl_dir/server.crt"
    local key_file="$ssl_dir/server.key"
    
    if [ -f "$cert_file" ] && [ -f "$key_file" ]; then
        return 0
    else
        return 1
    fi
}

# 生成自签名SSL证书（接受IP地址作为参数）
generate_ssl_certificate() {
    local server_ip=$1
    
    # 检查IP地址参数
    if [ -z "$server_ip" ]; then
        log_error "请提供服务器IP地址"
        echo ""
        echo "用法: $0 --generate-ssl <IP地址>"
        echo "示例: $0 --generate-ssl 192.168.1.100"
        echo ""
        return 1
    fi
    
    # 获取脚本所在目录
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local generate_ssl_script="$script_dir/config/generate-ssl.sh"
    
    # 检查 generate-ssl.sh 是否存在
    if [ ! -f "$generate_ssl_script" ]; then
        log_error "未找到 generate-ssl.sh 脚本: $generate_ssl_script"
        return 1
    fi
    
    # 检查 generate-ssl.sh 是否可执行
    if [ ! -x "$generate_ssl_script" ]; then
        log_warning "generate-ssl.sh 不可执行，尝试添加执行权限..."
        chmod +x "$generate_ssl_script" 2>/dev/null || {
            log_error "无法为 generate-ssl.sh 添加执行权限"
            return 1
        }
    fi
    
    # 调用 generate-ssl.sh 脚本
    log_info "调用 generate-ssl.sh 生成SSL证书..."
    "$generate_ssl_script" "$server_ip"
    
    return $?
}

# 从 docker-compose.yml 读取某服务的 image 行（不含变量展开）
compose_image_for_service() {
    local svc="$1"
    local yml="${SCRIPT_DIR}/docker-compose.yml"
    if [[ ! -f "$yml" ]]; then
        echo ""
        return 0
    fi
    awk -v s="$svc" '
        $0 ~ "^  " s ":" { found=1; next }
        found && /^  [a-zA-Z0-9_-]+:/ { exit }
        found && /^    image:/ {
            sub(/^    image:[[:space:]]*/, "");
            gsub(/\r/, "");
            print;
            exit
        }
    ' "$yml"
}

# 将 image: ${VAR:-default} 中的 default 展开（满足本仓库 compose 写法）
expand_compose_image() {
    local s="$1"
    local prev=""
    while [[ "$s" != "$prev" ]]; do
        prev="$s"
        s="$(echo "$s" | sed -E 's/\$\{[A-Z0-9_]+:-([^}]+)\}/\1/g')"
    done
    echo "$s" | tr -d '\r' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}

# 若本地缺少镜像且存在 services.conf 与源码目录，则尝试执行对应 build.sh
build_missing_from_services_conf() {
    local conf="${SCRIPT_DIR}/services.conf"
    if [[ ! -f "$conf" ]]; then
        return 0
    fi
    # shellcheck disable=SC1090
    source "$conf"
    local codes_dir="${CODES_DIR:-./codes}"
    local codes_abs
    if [[ "$codes_dir" == ./* ]]; then
        codes_abs="${SCRIPT_DIR}/${codes_dir#./}"
    elif [[ "$codes_dir" == /* ]]; then
        codes_abs="$codes_dir"
    else
        codes_abs="${SCRIPT_DIR}/${codes_dir}"
    fi

    local entry repo dir compose_service build_cmd img_raw img
    for entry in "${SERVICES[@]:-}"; do
        IFS='|' read -r repo dir compose_service build_cmd <<<"$entry"
        repo="${repo:-}"
        dir="${dir:-$repo}"
        compose_service="${compose_service:-}"
        build_cmd="${build_cmd:-./build.sh}"
        if [[ -z "$repo" || -z "$dir" || -z "$compose_service" ]]; then
            continue
        fi
        img_raw="$(compose_image_for_service "$compose_service")"
        img="$(expand_compose_image "$img_raw")"
        if [[ -z "$img" ]]; then
            continue
        fi
        if docker image inspect "$img" &>/dev/null; then
            continue
        fi
        if [[ ! -d "${codes_abs}/${dir}" ]]; then
            log_warning "镜像不存在且缺少源码目录: $img → ${codes_abs}/${dir}（请先执行 ./init-once.sh）"
            continue
        fi
        local first_token="${build_cmd%% *}"
        if [[ "$first_token" == ./*.sh && -f "${codes_abs}/${dir}/${first_token}" && ! -x "${codes_abs}/${dir}/${first_token}" ]]; then
            log_warning "检测到脚本不可执行，自动修复权限: ${codes_abs}/${dir}/${first_token}"
            chmod +x "${codes_abs}/${dir}/${first_token}"
        fi
        log_info "尝试从源码构建缺失镜像: $compose_service ($img)"
        if (cd "${codes_abs}/${dir}" && bash -lc "$build_cmd"); then
            log_success "源码构建完成: $compose_service"
        else
            log_warning "源码构建失败: $compose_service（将仍可能尝试 pull）"
        fi
    done
}

# 检查镜像是否存在
check_images_exist() {
    log_info "检查Docker镜像是否存在..."
    
    # 方法1: 尝试使用 docker-compose config --images (适用于较新版本)
    local images=$(docker-compose config --images 2>/dev/null)
    local exit_code=$?
    
    # 方法2: 如果方法1失败，从docker-compose config输出中提取镜像
    if [ -z "$images" ] || [ $exit_code -ne 0 ]; then
        log_info "尝试从docker-compose配置中提取镜像列表..."
        local config_output=$(docker-compose config 2>&1)
        local config_exit_code=$?
        
        if [ $config_exit_code -eq 0 ] && [ -n "$config_output" ]; then
            images=$(echo "$config_output" | grep -E "^\s+image:" | sed 's/.*image:\s*//' | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//' | sort -u)
        elif [ $config_exit_code -ne 0 ]; then
            log_warning "docker-compose config 执行失败，错误信息: $(echo "$config_output" | head -n 3)"
        fi
    fi
    
    # 方法3: 如果方法2也失败，直接从docker-compose.yml文件解析
    if [ -z "$images" ]; then
        log_info "尝试从docker-compose.yml文件中解析镜像列表..."
        if [ -f "docker-compose.yml" ]; then
            images=$(grep -E "^\s+image:" docker-compose.yml | sed 's/.*image:\s*//' | sed 's/\${[^}]*}//g' | sed 's/:-[^}]*}//g' | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//' | sort -u)
        fi
    fi
    
    if [ -z "$images" ]; then
        log_warning "无法获取镜像列表，将尝试拉取镜像"
        return 1
    fi
    
    # 检查每个镜像是否存在
    local missing_images=0
    local total_images=0
    while IFS= read -r image; do
        # 处理环境变量替换后的镜像名称（移除可能的空值）
        image=$(echo "$image" | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
        if [ -n "$image" ] && [ "$image" != "null" ]; then
            total_images=$((total_images + 1))
            # 检查镜像是否存在（支持带标签和不带标签的情况）
            local image_exists=0
            if docker image inspect "$image" &> /dev/null; then
                image_exists=1
            else
                # 尝试检查不带标签的镜像
                local image_name=$(echo "$image" | cut -d':' -f1)
                if docker images --format "{{.Repository}}:{{.Tag}}" | grep -q "^${image_name}:"; then
                    image_exists=1
                fi
            fi
            
            if [ $image_exists -eq 0 ]; then
                log_info "镜像不存在: $image"
                missing_images=$((missing_images + 1))
            fi
        fi
    done <<< "$images"
    
    if [ $total_images -eq 0 ]; then
        log_warning "未找到任何镜像配置，将尝试拉取镜像"
        return 1
    fi
    
    if [ $missing_images -eq 0 ]; then
        log_success "所有镜像已存在（共 $total_images 个），跳过拉取"
        return 0
    else
        log_info "发现 $missing_images/$total_images 个镜像不存在，需要拉取"
        return 1
    fi
}

# 启动服务
start_services() {
    log_info "启动G2Rain服务..."
    
    if ! check_images_exist; then
        build_missing_from_services_conf
    fi
    if ! check_images_exist; then
        log_info "拉取Docker镜像..."
        docker-compose pull
    fi
    
    log_info "启动容器服务（由 docker-compose 依赖与健康检查控制顺序）..."
    docker-compose up -d
    
    log_success "服务启动完成"
}

# 检查服务状态
check_services() {
    log_info "检查服务状态..."

    # 检查MySQL
    if docker-compose exec -T mysql mysqladmin ping -h localhost &> /dev/null; then
        log_success "MySQL服务运行正常"
    else
        log_warning "MySQL服务可能未完全启动，请稍后检查"
    fi
    
    # 检查Redis
    if docker-compose exec -T redis redis-cli ping &> /dev/null; then
        log_success "Redis服务运行正常"
    else
        log_warning "Redis服务可能未完全启动，请稍后检查"
    fi
    
    # 显示服务状态
    log_info "当前服务状态:"
    docker-compose ps
}

# 显示访问信息
show_access_info() {
    log_success "G2Rain部署完成！"
    echo ""
    echo "访问信息:"
    echo "  应用地址: http://localhost:${NGINX_HTTP_PORT:-8080}"
    if [ -f "ssl/server.crt" ]; then
        echo "  HTTPS地址: https://localhost:${NGINX_HTTPS_PORT:-443}"
        echo "  (使用自签名证书，浏览器会显示安全警告)"
    fi
    echo "  MySQL端口: 3306"
    echo "  Redis端口: 6379"
    echo ""
    echo "管理命令:"
    echo "  查看日志: docker-compose logs -f"
    echo "  停止服务: ./stop.sh"
    echo "  重启服务: docker-compose restart"
    echo "  更新服务: ./update.sh"
    echo ""
}

# 主函数
main() {
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    echo "=========================================="
    echo "    G2Rain Docker Compose 启动脚本"
    echo "=========================================="
    echo ""
    
    # 处理命令行参数
    case "${1:-}" in
        --generate-ssl)
            cd "$SCRIPT_DIR" || exit 1
            if [ -z "$2" ]; then
                log_error "请提供服务器IP地址"
                echo ""
                echo "用法: $0 --generate-ssl <IP地址>"
                echo "示例: $0 --generate-ssl 192.168.1.100"
                echo ""
                exit 1
            fi
            generate_ssl_certificate "$2"
            exit $?
            ;;
        --help)
            echo "G2Rain部署启动脚本使用说明:"
            echo ""
            echo "用法:"
            echo "  $0                   启动所有服务"
            echo "  $0 --host <HOST> --port <PORT>  启动服务并在首次生成 .env 时写入平台地址"
            echo "  $0 --generate-ssl <IP地址>  生成SSL证书"
            echo "  $0 --help            显示帮助信息"
            echo ""
            echo "示例:"
            echo "  $0 --host 43.138.13.145 --port 10080"
            echo "  $0 --generate-ssl 192.168.1.100  生成包含指定IP的SSL证书"
            echo ""
            exit 0
            ;;
        *)
            cd "$SCRIPT_DIR" || exit 1

            # 解析可选参数（用于首次生成 .env 时写入平台地址）
            local platform_host=""
            local platform_port=""

            while [ $# -gt 0 ]; do
                case "$1" in
                    --host)
                        platform_host="${2:-}"
                        shift 2
                        ;;
                    --port)
                        platform_port="${2:-}"
                        shift 2
                        ;;
                    *)
                        shift
                        ;;
                esac
            done

            # 正常启动流程
            check_dependencies
            check_env_file "$platform_host" "$platform_port"

            if [ ! -f "${SCRIPT_DIR}/.g2rain-deploy-install.done" ]; then
                log_warning "未检测到 .g2rain-deploy-install.done；若为全新部署请先执行: ./init-once.sh"
            fi

            create_directories
            set_permissions
            
            # 检查SSL证书是否存在
            if ! check_ssl_certificate; then
                log_error "SSL证书不存在，无法启动HTTPS服务"
                echo ""
                echo "请先生成SSL证书:"
                echo "  $0 --generate-ssl <服务器IP地址>"
                echo ""
                echo "示例:"
                echo "  $0 --generate-ssl 192.168.1.100"
                echo ""
                echo "注意: 请使用服务器的公网IP地址或内网IP地址"
                echo ""
                exit 1
            fi
            
            start_services
            check_services
            show_access_info
            ;;
    esac
}

# 执行主函数
main "$@"
