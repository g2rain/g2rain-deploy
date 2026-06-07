#!/bin/bash

# G2Rain部署更新脚本
# 作者: G2Rain团队
# 版本: 1.0

set -e

# 目录与配置
ROOT="$(cd "$(dirname "$0")" && pwd)"
CONFIG="${ROOT}/services.conf"

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

list_config_services() {
    if [ ! -f "$CONFIG" ]; then
        return 0
    fi
    local codes_dir="${CODES_DIR:-./codes}"
    while IFS= read -r entry; do
        IFS='|' read -r repo dir compose_service build_cmd <<<"$entry"
        repo="${repo:-}"
        dir="${dir:-$repo}"
        compose_service="${compose_service:-}"
        build_cmd="${build_cmd:-./build.sh}"
        if [ -z "$repo" ] || [ -z "$dir" ] || [ -z "$compose_service" ]; then
            continue
        fi
        printf "%s\t%s\t%s\t%s\t%s\n" "$repo" "$dir" "$build_cmd" "$compose_service" "$codes_dir"
    done < <(printf "%s\n" "${SERVICES[@]:-}")
}

get_service_by_compose_name() {
    local compose_service="$1"
    if [ ! -f "$CONFIG" ]; then
        return 1
    fi
    local codes_dir="${CODES_DIR:-./codes}"
    for entry in "${SERVICES[@]:-}"; do
        IFS='|' read -r repo dir svc build_cmd <<<"$entry"
        repo="${repo:-}"
        dir="${dir:-$repo}"
        build_cmd="${build_cmd:-./build.sh}"
        svc="${svc:-}"
        if [ "$svc" = "$compose_service" ] && [ -n "$repo" ] && [ -n "$dir" ] && [ -n "$build_cmd" ]; then
            printf "%s\t%s\t%s\t%s\n" "$repo" "$dir" "$build_cmd" "$codes_dir"
            return 0
        fi
    done
    return 1
}

pull_and_build_repo() {
    local repo="$1"
    local dir="$2"
    local build_cmd="$3"
    local codes_dir="$4"

    local target="${codes_dir}/${dir}"
    local git_base="${G2RAIN_GIT_BASE:-${GIT_BASE_DEFAULT:-https://github.com/g2rain}}"
    local url="${git_base}/${repo}.git"

    mkdir -p "$codes_dir"

    if [ -d "${target}/.git" ]; then
        log_info "拉取最新代码: ${repo}（git fetch + pull --ff-only）"
        (cd "$target" && git fetch --tags --prune)
        (cd "$target" && git pull --ff-only)
    else
        if [ -e "$target" ]; then
            log_error "路径已存在但不是 git 仓库: $target"
            return 1
        fi
        log_info "克隆仓库: ${repo}"
        git clone "$url" "$target"
    fi

    ensure_build_script_executable_if_needed "$target" "$build_cmd"
    log_info "构建镜像: ${repo}（${build_cmd}）"
    (cd "$target" && bash -lc "$build_cmd")
    log_success "构建完成: ${repo}"
}

ensure_build_script_executable_if_needed() {
    local target="$1"
    local build_cmd="$2"
    local first_token="${build_cmd%% *}"

    if [[ "$first_token" == ./*.sh && -f "${target}/${first_token}" && ! -x "${target}/${first_token}" ]]; then
        log_warning "检测到脚本不可执行，自动修复权限: ${target}/${first_token}"
        chmod +x "${target}/${first_token}"
    fi
}

sync_repo_only() {
    local repo="$1"
    local dir="$2"
    local codes_dir="$3"

    local target="${codes_dir}/${dir}"
    local git_base="${G2RAIN_GIT_BASE:-${GIT_BASE_DEFAULT:-https://github.com/g2rain}}"
    local url="${git_base}/${repo}.git"

    mkdir -p "$codes_dir"

    if [ -d "${target}/.git" ]; then
        log_info "拉取最新代码: ${repo}（git fetch + pull --ff-only）"
        (cd "$target" && git fetch --tags --prune)
        (cd "$target" && git pull --ff-only)
    else
        if [ -e "$target" ]; then
            log_error "路径已存在但不是 git 仓库: $target"
            return 1
        fi
        log_info "克隆仓库: ${repo}"
        git clone "$url" "$target"
    fi
}

build_from_source() {
    local service_name="${1:-}"

    if [ ! -f "$CONFIG" ]; then
        log_warning "未找到 services.conf，跳过源码构建（仅执行镜像拉取/容器更新）"
        return 0
    fi

    if [ -n "$service_name" ]; then
        local row
        if ! row="$(get_service_by_compose_name "$service_name")"; then
            log_info "服务 $service_name 未在 services.conf 中配置，跳过源码构建"
            return 0
        fi
        local repo dir build_cmd codes_dir
        IFS=$'\t' read -r repo dir build_cmd codes_dir <<<"$row"
        pull_and_build_repo "$repo" "$dir" "$build_cmd" "$codes_dir"
        return 0
    fi

    log_info "按 services.conf 全量拉取代码..."
    mapfile -t rows < <(list_config_services)
    for row in "${rows[@]}"; do
        IFS=$'\t' read -r repo dir build_cmd compose_service codes_dir <<<"$row"
        sync_repo_only "$repo" "$dir" "$codes_dir"
    done

    log_info "按 services.conf 全量构建镜像..."
    for row in "${rows[@]}"; do
        IFS=$'\t' read -r repo dir build_cmd compose_service codes_dir <<<"$row"
        local target="${codes_dir}/${dir}"
        ensure_build_script_executable_if_needed "$target" "$build_cmd"
        log_info "构建镜像: ${repo}（${build_cmd}）"
        (cd "$target" && bash -lc "$build_cmd")
        log_success "构建完成: ${repo}"
    done
    log_success "全量源码构建完成"
}

# 检查 Docker / Compose（与 start.sh 对齐：默认 docker-compose；--compose-v2 时使用 docker compose）
check_dependencies() {
    log_info "检查依赖环境..."

    if ! command -v docker &> /dev/null; then
        log_error "Docker 未安装，请先安装 Docker"
        exit 1
    fi

    if [ "${USE_COMPOSE_V2:-0}" = 1 ]; then
        if ! docker compose version &> /dev/null; then
            log_error "未检测到 Docker Compose V2 插件（docker compose）；请安装、或修改 config/compose-cli.env、或去掉 --compose-v2 / 使用 --compose-v1"
            exit 1
        fi
        if [ ! -f "${ROOT}/compose-v2/compose.yaml" ]; then
            log_error "未找到 ${ROOT}/compose-v2/compose.yaml"
            exit 1
        fi
        log_info "使用 Compose V2: compose-v2/compose.yaml"
    else
        if ! command -v docker-compose &> /dev/null; then
            log_error "Docker Compose 未安装（未找到 docker-compose）；请安装、或运行 ./scripts/write-compose-cli-preference.sh、或 ./update.sh --compose-v2"
            exit 1
        fi
    fi

    if [ -f "$CONFIG" ]; then
        if ! command -v git &> /dev/null; then
            log_error "检测到 services.conf，但系统未安装 git"
            exit 1
        fi
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

    # Kafka 默认使用命名卷 kafka_data，无宿主 data/kafka 目录；若曾用绑定挂载可在此备份
    if [ -d "data/kafka" ]; then
        log_info "备份Kafka数据目录（仅旧版绑定挂载路径存在时）..."
        cp -r data/kafka "$backup_dir/" 2>/dev/null || true
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
    local images=$(dc config --images 2>/dev/null)
    local exit_code=$?
    
    # 方法2: 如果方法1失败，从docker-compose config输出中提取镜像
    if [ -z "$images" ] || [ $exit_code -ne 0 ]; then
        log_info "尝试从docker-compose配置中提取镜像列表..."
        local config_output=$(dc config 2>&1)
        local config_exit_code=$?
        
        if [ $config_exit_code -eq 0 ] && [ -n "$config_output" ]; then
            images=$(echo "$config_output" | grep -E "^\s+image:" | sed 's/.*image:\s*//' | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//' | sort -u)
        elif [ $config_exit_code -ne 0 ]; then
            log_warning "docker-compose config 执行失败，错误信息: $(echo "$config_output" | head -n 3)"
        fi
    fi
    
    # 方法3: 从主 compose 与 business.d 片段解析镜像行
    if [ -z "$images" ]; then
        local frag strip
        strip='s/.*image:\s*//;s/\${[^}]*}//g;s/:-[^}]*}//g;s/^[[:space:]]*//;s/[[:space:]]*$//'
        log_info "尝试从 compose 文件解析镜像列表..."
        images=""
        while IFS= read -r frag || [ -n "$frag" ]; do
            [ -z "$frag" ] && continue
            [ -f "$frag" ] || continue
            images=$(printf '%s\n%s\n' "$images" "$(grep -E "^\s+image:" "$frag" | sed "$strip")")
        done < <(g2rain_compose_all_yml_fragments)
        images=$(echo "$images" | sed '/^$/d' | sort -u)
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
            dc pull "$service_name"
            log_success "服务 $service_name 的镜像拉取完成"
        else
            log_info "更新指定服务 $service_name，跳过镜像拉取（假设使用本地构建的镜像）"
        fi
        return 0
    fi
    
    # 更新所有服务时，检查所有镜像是否存在
    if ! check_images_exist; then
        log_info "发现缺失的镜像，开始拉取..."
        dc pull
        log_success "缺失镜像拉取完成"
        return 0
    fi
    
    # 如果所有镜像都存在
    if [ "$force_pull" = "true" ]; then
        log_info "强制拉取最新Docker镜像..."
        dc pull
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
        dc up -d --no-deps "$service"
    else
        log_info "更新所有服务..."
        dc up -d
    fi
    
    log_success "服务更新完成"
}

# 清理旧镜像
cleanup_images() {
    log_info "清理未使用的Docker镜像..."
    local cleanup_opt="${1:-}"
    
    # 删除悬空镜像
    docker image prune -f
    
    # 删除未使用的镜像（可选）
    if [ "$cleanup_opt" = "--cleanup-all" ]; then
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
    local services=("mysql" "redis" "kafka" "nacos" "nginx" "app")
    local all_healthy=true
    
    for service in "${services[@]}"; do
        if dc ps | grep -q "$service.*Up"; then
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
    dc ps
}

# 显示更新信息
show_update_info() {
    log_success "G2Rain更新完成！"
    echo ""
    echo "更新信息:"
    echo "  备份目录: backup/"
    echo "  服务状态: $(g2rain_compose_cli_hint) ps"
    echo "  查看日志: $(g2rain_compose_cli_hint) logs -f"
    echo ""
    echo "如果遇到问题，可以回滚到备份:"
    if [ "${USE_COMPOSE_V2:-0}" = 1 ]; then
        echo "  ./stop.sh --compose-v2 --cleanup"
    else
        echo "  ./stop.sh --cleanup"
    fi
    echo "  cp -r backup/[备份目录]/* ."
    if [ "${USE_COMPOSE_V2:-0}" = 1 ]; then
        echo "  ./start.sh --compose-v2"
    else
        echo "  ./start.sh"
    fi
    echo ""
}

# 显示帮助信息
show_help() {
    echo "G2Rain更新脚本使用说明:"
    echo ""
    echo "用法:"
    echo "  ./update.sh                   按 services.conf 拉代码+构建镜像后更新所有服务"
    echo "  ./update.sh [服务名]           按 services.conf 拉代码+构建该服务镜像后更新该服务"
    echo "  ./update.sh [服务名] --force-pull  更新指定服务并强制拉取该服务镜像（会跳过源码构建）"
    echo "  ./update.sh --force-pull      强制拉取最新镜像并更新所有服务"
    echo "  ./update.sh --cleanup-all     更新并清理所有未使用镜像"
    echo "  ./update.sh --compose-v2     强制使用 Docker Compose V2 插件与 compose-v2/compose.yaml（与 ./start.sh --compose-v2 一致）"
    echo "  ./update.sh --compose-v1     强制使用 docker-compose 与 docker-compose.yml（覆盖 config/compose-cli.env）"
    echo "  ./update.sh --help            显示帮助信息"
    echo "  ./update.sh --business <名>   仅合并指定 business.d 片段（可重复，同 start.sh）"
    echo "  ./update.sh --service <名>    仅加载指定 service_config.d 片段（可重复，同 start.sh）"
    echo ""
    echo "示例:"
    echo "  ./update.sh --compose-v2                    使用 V2 主文件更新全部服务"
    echo "  ./update.sh --compose-v2 g2rain-manager-app  使用 V2 主文件只更新指定服务"
    echo "  ./update.sh g2rain-manager-app   只更新指定服务（使用本地镜像）"
    echo "  ./update.sh g2rain-health-app    只更新健康管理H5服务（使用本地镜像）"
    echo "  ./update.sh mysql                 只更新MySQL服务"
    echo "  ./update.sh kafka                 只更新Kafka服务"
    echo "  ./update.sh nginx                只更新Nginx服务"
    echo "  ./update.sh g2rain-iam --force-pull  更新指定服务并拉取最新镜像"
    echo "  ./update.sh --force-pull        强制拉取所有服务的最新镜像"
    echo ""
    echo "选项:"
    echo "  --force-pull     强制拉取最新镜像（更新所有服务时拉取所有镜像，更新指定服务时只拉取该服务镜像）"
    echo "  --cleanup-all    清理所有未使用的 Docker 镜像"
    echo "  --compose-v2     使用 docker compose + compose-v2/compose.yaml"
    echo "  --compose-v1     使用 docker-compose + docker-compose.yml（覆盖配置文件）"
    echo "  --business       与 business.d/README 说明一致"
    echo "  --service        与 service_config.d/README 说明一致"
    echo "  --help           显示此帮助信息"
    echo ""
    echo "注意:"
    echo "  更新指定服务时，默认使用本地已构建的镜像，不会检查或拉取其他服务的镜像"
    echo "  如需拉取指定服务的最新镜像，请使用 --force-pull 选项"
    echo "  business.d/*.yml 与主 compose 合并；默认 CLI 见 config/compose-cli.env（见 scripts/write-compose-cli-preference.sh）。"
    echo ""
}

# 主函数
main() {
    # shellcheck disable=SC1091
    source "${ROOT}/compose-cli-preference.inc"

    USE_COMPOSE_V2=0
    local _compose_cli_override=""
    G2RAIN_BUSINESS_NAMES=""
    G2RAIN_SERVICE_CONFIG_NAMES=""
    local stripped=()

    while [ $# -gt 0 ]; do
        case "$1" in
            --compose-v2)
                _compose_cli_override="v2"
                shift
                ;;
            --compose-v1)
                _compose_cli_override="v1"
                shift
                ;;
            --business)
                if [ -z "${2:-}" ]; then
                    log_error "--business 需要指定片段名（见 business.d/README）"
                    exit 1
                fi
                G2RAIN_BUSINESS_NAMES="${G2RAIN_BUSINESS_NAMES}${G2RAIN_BUSINESS_NAMES:+ }${2}"
                shift 2
                ;;
            --service)
                if [ -z "${2:-}" ]; then
                    log_error "--service 需要指定片段名（见 service_config.d/README）"
                    exit 1
                fi
                G2RAIN_SERVICE_CONFIG_NAMES="${G2RAIN_SERVICE_CONFIG_NAMES}${G2RAIN_SERVICE_CONFIG_NAMES:+ }${2}"
                shift 2
                ;;
            *)
                stripped+=("$1")
                shift
                ;;
        esac
    done
    set -- "${stripped[@]}"

    local force_pull=false
    local service_name=""
    local cleanup_all=false

    while [ $# -gt 0 ]; do
        case "$1" in
            --help)
                show_help
                exit 0
                ;;
            --force-pull)
                force_pull=true
                shift
                ;;
            --cleanup-all)
                cleanup_all=true
                shift
                ;;
            *)
                if [ -z "$service_name" ]; then
                    service_name="$1"
                    log_info "将更新服务: $service_name"
                fi
                shift
                ;;
        esac
    done

    cd "$ROOT" || exit 1
    g2rain_resolve_use_compose_v2 "$ROOT" "$_compose_cli_override"
    COMPOSE_DEPLOY_ROOT="$ROOT"
    G2RAIN_DEPLOY_ROOT="$ROOT"
    # shellcheck disable=SC1091
    source "${ROOT}/compose-merge.inc"
    # shellcheck disable=SC1091
    source "${ROOT}/services-merge.inc"
    dc() { g2rain_dc "$@"; }

    if [ -f "$CONFIG" ]; then
        g2rain_load_services_config || exit 1
        if g2rain_has_extra_service_config; then
            log_info "已合并 service_config.d 中的额外服务映射"
        fi
    fi

    echo "=========================================="
    echo "    G2Rain Docker Compose 更新脚本"
    echo "=========================================="
    echo ""

    if g2rain_has_business_compose; then
        log_info "已检测到 business.d 业务片段，将使用与 start/stop 相同的合并配置更新"
    fi

    if [ "$force_pull" = true ]; then
        log_info "将强制拉取最新镜像"
    fi
    if [ "$cleanup_all" = true ]; then
        log_warning "将执行完整清理操作"
    fi
    if [ -z "$service_name" ] && [ "$force_pull" = false ] && [ "$cleanup_all" = false ]; then
        log_info "将更新所有服务"
    fi

    check_dependencies
    backup_data
    if [ "$force_pull" = false ]; then
        build_from_source "$service_name"
    fi
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
