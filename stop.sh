#!/bin/bash

# G2Rain部署停止脚本
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

# 停止服务
stop_services() {
    log_info "停止G2Rain服务..."
    
    # 检查是否有运行中的服务
    if ! docker-compose ps -q | grep -q .; then
        log_warning "没有运行中的G2Rain服务"
        return 0
    fi
    
    # 优雅停止服务
    log_info "正在优雅停止服务..."
    docker-compose stop
    
    log_success "服务已停止"
}

# 清理容器（可选）
cleanup_containers() {
    local cleanup=$1
    
    if [ "$cleanup" = "--cleanup" ]; then
        log_warning "清理容器和网络..."
        
        # 停止并删除容器
        docker-compose down
        
        # 清理未使用的镜像
        log_info "清理未使用的Docker镜像..."
        docker image prune -f
        
        log_success "清理完成"
    else
        log_info "容器已停止但未删除，数据已保留"
        log_info "如需完全清理，请使用: ./stop.sh --cleanup"
    fi
}

# 显示服务状态
show_status() {
    log_info "当前服务状态:"
    docker-compose ps
    
    echo ""
    log_info "数据目录状态:"
    if [ -d "data" ]; then
        echo "  MySQL数据: data/mysql"
        echo "  Redis数据: data/redis"
        echo "  Kafka数据: Docker 命名卷 kafka_data（见 docker-compose.yml）"
    fi
    
    if [ -d "logs" ]; then
        echo "  日志目录: logs/"
    fi
}

# 显示帮助信息
show_help() {
    echo "G2Rain停止脚本使用说明:"
    echo ""
    echo "用法:"
    echo "  ./stop.sh                停止服务但保留容器"
    echo "  ./stop.sh --cleanup      停止服务并清理容器"
    echo "  ./stop.sh --help         显示帮助信息"
    echo ""
    echo "选项:"
    echo "  --cleanup    停止服务并删除容器、网络和未使用的镜像"
    echo "  --help       显示此帮助信息"
    echo ""
}

# 主函数
main() {
    echo "=========================================="
    echo "    G2Rain Docker Compose 停止脚本"
    echo "=========================================="
    echo ""
    
    # 处理命令行参数
    case "${1:-}" in
        --help)
            show_help
            exit 0
            ;;
        --cleanup)
            log_warning "将执行完整清理操作"
            ;;
        "")
            log_info "将停止服务但保留容器和数据"
            ;;
        *)
            log_error "未知参数: $1"
            show_help
            exit 1
            ;;
    esac
    
    check_dependencies
    stop_services
    cleanup_containers "$1"
    show_status
    
    echo ""
    log_success "G2Rain服务已停止"
    echo ""
    echo "重新启动服务:"
    echo "  ./start.sh"
    echo ""
    echo "查看服务状态:"
    echo "  docker-compose ps"
    echo ""
}

# 执行主函数
main "$@"
