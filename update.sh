#!/bin/bash

# G2Rain部署更新脚本
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

# 检查Docker Compose是否安装
check_dependencies() {
    log_info "检查依赖环境..."
    
    if ! command -v docker-compose &> /dev/null; then
        log_error "Docker Compose未安装"
        exit 1
    fi
    
    log_success "依赖环境检查通过"
}

# 备份数据
backup_data() {
    local backup_dir="backup/$(date +%Y%m%d_%H%M%S)"
    
    log_info "创建数据备份..."
    mkdir -p "$backup_dir"
    
    # 备份MySQL数据
    if [ -d "data/mysql" ]; then
        log_info "备份MySQL数据..."
        cp -r data/mysql "$backup_dir/" 2>/dev/null || true
    fi
    
    # 备份Redis数据
    if [ -d "data/redis" ]; then
        log_info "备份Redis数据..."
        cp -r data/redis "$backup_dir/" 2>/dev/null || true
    fi
    
    # 备份配置文件
    if [ -d "config" ]; then
        log_info "备份配置文件..."
        cp -r config "$backup_dir/" 2>/dev/null || true
    fi
    
    log_success "数据备份完成: $backup_dir"
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
        log_success "所有镜像已存在（共 $total_images 个）"
        return 0
    else
        log_info "发现 $missing_images/$total_images 个镜像不存在"
        return 1
    fi
}

# 拉取最新镜像
pull_images() {
    local force_pull=${1:-false}
    local service_name=${2:-""}
    
    # 如果指定了服务名，只处理该服务的镜像
    if [ -n "$service_name" ]; then
        if [ "$force_pull" = "true" ]; then
            log_info "强制拉取服务 $service_name 的最新镜像..."
            docker-compose pull "$service_name"
            log_success "服务 $service_name 的镜像拉取完成"
        else
            log_info "更新指定服务 $service_name，跳过镜像拉取（假设使用本地构建的镜像）"
        fi
        return 0
    fi
    
    # 更新所有服务时，检查所有镜像是否存在
    if ! check_images_exist; then
        log_info "发现缺失的镜像，开始拉取..."
        docker-compose pull
        log_success "缺失镜像拉取完成"
        return 0
    fi
    
    # 如果所有镜像都存在
    if [ "$force_pull" = "true" ]; then
        log_info "强制拉取最新Docker镜像..."
        docker-compose pull
        log_success "镜像拉取完成"
    else
        log_info "所有镜像已存在，跳过拉取（使用 --force-pull 强制拉取最新版本）"
    fi
}

# 更新服务
update_services() {
    local service=$1
    
    if [ -n "$service" ]; then
        log_info "更新服务: $service"
        docker-compose up -d --no-deps "$service"
    else
        log_info "更新所有服务..."
        docker-compose up -d
    fi
    
    log_success "服务更新完成"
}

# 清理旧镜像
cleanup_images() {
    log_info "清理未使用的Docker镜像..."
    
    # 删除悬空镜像
    docker image prune -f
    
    # 删除未使用的镜像（可选）
    if [ "$1" = "--cleanup-all" ]; then
        log_warning "清理所有未使用的镜像..."
        docker system prune -f
    fi
    
    log_success "镜像清理完成"
}

# 检查服务状态
check_services() {
    log_info "检查服务状态..."
    
    # 等待服务启动
    sleep 10
    
    # 检查服务健康状态
    local services=("mysql" "redis" "nginx" "app")
    local all_healthy=true
    
    for service in "${services[@]}"; do
        if docker-compose ps | grep -q "$service.*Up"; then
            log_success "$service 服务运行正常"
        else
            log_warning "$service 服务可能存在问题"
            all_healthy=false
        fi
    done
    
    if [ "$all_healthy" = true ]; then
        log_success "所有服务运行正常"
    else
        log_warning "部分服务可能存在问题，请检查日志"
    fi
    
    # 显示服务状态
    log_info "当前服务状态:"
    docker-compose ps
}

# 显示更新信息
show_update_info() {
    log_success "G2Rain更新完成！"
    echo ""
    echo "更新信息:"
    echo "  备份目录: backup/"
    echo "  服务状态: docker-compose ps"
    echo "  查看日志: docker-compose logs -f"
    echo ""
    echo "如果遇到问题，可以回滚到备份:"
    echo "  ./stop.sh --cleanup"
    echo "  cp -r backup/[备份目录]/* ."
    echo "  ./start.sh"
    echo ""
}

# 显示帮助信息
show_help() {
    echo "G2Rain更新脚本使用说明:"
    echo ""
    echo "用法:"
    echo "  ./update.sh                   更新所有服务（镜像存在时跳过拉取）"
    echo "  ./update.sh [服务名]           更新指定服务（使用本地镜像，不拉取）"
    echo "  ./update.sh [服务名] --force-pull  更新指定服务并强制拉取该服务镜像"
    echo "  ./update.sh --force-pull      强制拉取最新镜像并更新所有服务"
    echo "  ./update.sh --cleanup-all     更新并清理所有未使用镜像"
    echo "  ./update.sh --help            显示帮助信息"
    echo ""
    echo "示例:"
    echo "  ./update.sh g2rain-manager-app   只更新指定服务（使用本地镜像）"
    echo "  ./update.sh g2rain-health-app    只更新健康管理H5服务（使用本地镜像）"
    echo "  ./update.sh mysql                 只更新MySQL服务"
    echo "  ./update.sh nginx                只更新Nginx服务"
    echo "  ./update.sh g2rain-iam --force-pull  更新指定服务并拉取最新镜像"
    echo "  ./update.sh --force-pull        强制拉取所有服务的最新镜像"
    echo ""
    echo "选项:"
    echo "  --force-pull    强制拉取最新镜像（更新所有服务时拉取所有镜像，更新指定服务时只拉取该服务镜像）"
    echo "  --cleanup-all    清理所有未使用的Docker镜像"
    echo "  --help           显示此帮助信息"
    echo ""
    echo "注意:"
    echo "  更新指定服务时，默认使用本地已构建的镜像，不会检查或拉取其他服务的镜像"
    echo "  如需拉取指定服务的最新镜像，请使用 --force-pull 选项"
    echo ""
}

# 主函数
main() {
    echo "=========================================="
    echo "    G2Rain Docker Compose 更新脚本"
    echo "=========================================="
    echo ""
    
    local force_pull=false
    local service_name=""
    local cleanup_all=false
    
    # 处理命令行参数
    for arg in "$@"; do
        case "$arg" in
            --help)
                show_help
                exit 0
                ;;
            --force-pull)
                force_pull=true
                log_info "将强制拉取最新镜像"
                ;;
            --cleanup-all)
                cleanup_all=true
                log_warning "将执行完整清理操作"
                ;;
            *)
                if [ -z "$service_name" ] && [ "$arg" != "--force-pull" ] && [ "$arg" != "--cleanup-all" ]; then
                    service_name="$arg"
                    log_info "将更新服务: $service_name"
                fi
                ;;
        esac
    done
    
    if [ -z "$service_name" ] && [ "$force_pull" = false ] && [ "$cleanup_all" = false ]; then
        log_info "将更新所有服务"
    fi
    
    check_dependencies
    backup_data
    pull_images "$force_pull" "$service_name"
    update_services "$service_name"
    if [ "$cleanup_all" = true ]; then
        cleanup_images "--cleanup-all"
    else
        cleanup_images
    fi
    check_services
    show_update_info
}

# 执行主函数
main "$@"
