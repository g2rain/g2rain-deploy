#!/usr/bin/env bash
# g2rain-deploy 一次性安装：依赖检查 → .env → 替换 MySQL 初始化 SQL 占位符 →（可选）SSL →
# 克隆/拉取 services.conf 中的仓库到 codes/ → 统一循环执行各仓 build.sh（可重试）→ 写完成标记。
# 不包含 docker compose up；装完后请在本目录执行: ./start.sh
#
# 默认「先拉代码后统一构建」阶段（对应安装说明第 4 节第 7 步，现为默认行为）：
#   - 耗时：整段通常约 20～60 分钟（视 CPU、磁盘、Docker 与网络而定），单仓常见约 3～15 分钟。
#   - 失败重试：每个仓库的 build 默认最多 G2RAIN_BUILD_RETRIES 次（默认 3），两次尝试之间休眠
#     G2RAIN_BUILD_RETRY_SLEEP 秒（默认 15）。某仓耗尽重试仍失败则脚本以非零退出、不写完成标记；
#     修正问题后直接重跑即可（已存在目录会 git pull 后继续，未成功部分会再次构建）。
#   - 跳过全部构建：./init-once.sh --skip-build（例如仅补 .env / SQL / 克隆）。
#
# 用法:
#   ./init-once.sh [--host HOST] [--port PORT] [--skip-build] [--ssl-ip IP] [--force]
#   ./init-once.sh --help
#
# 环境变量:
#   G2RAIN_DEPLOY_INIT_FORCE=1           等同于 --force
#   G2RAIN_GIT_BASE=...                  克隆地址前缀（默认 https://github.com/g2rain）
#   G2RAIN_BUILD_RETRIES / G2RAIN_BUILD_RETRY_SLEEP   见上文
#
# 注意: MySQL 仅在空数据卷首次初始化时执行 docker-entrypoint-initdb.d 下的 SQL；若 data/mysql
# 已有数据，修改 g2rain-basis.sql 不会自动更新库内记录，需自行迁移或清空数据卷后重装。
#
# 日常更新镜像/代码请使用: ./update.sh

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MARKER="${ROOT}/.g2rain-deploy-install.done"
CONFIG="${ROOT}/services.conf"
ENV_EXAMPLE="${ROOT}/env.example"
ENV_FILE="${ROOT}/.env"
SQL_BASIS="${ROOT}/config/mysql/g2rain-basis.sql"
GIT_BASE="${G2RAIN_GIT_BASE:-git@github.com:g2rain}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $*"; }
log_ok() { echo -e "${GREEN}[OK]${NC} $*"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
log_err() { echo -e "${RED}[ERROR]${NC} $*" >&2; }

usage() {
  cat <<'EOF'
用法:
  ./init-once.sh [--host HOST] [--port PORT] [--skip-build] [--ssl-ip IP] [--force]
  ./init-once.sh [--service <名> ...] [--host HOST] [--port PORT] ...

说明:
  - 依据 services.conf（及 service_config.d 片段）克隆/更新 GitHub 仓库到 CODES_DIR（默认同目录下 codes/）。
  - 默认在克隆后依次执行各仓的 build 脚本（默认同配置中的 build_cmd）；耗时与重试见脚本头部注释。
  - 从 .env 读取 PLATFORM_HOST / PLATFORM_PORT，将 config/mysql/g2rain-basis.sql 中的
    __PLATFORM_HOST__、__PLATFORM_PORT__ 替换后再由 MySQL 首次初始化导入（须在空数据卷前完成）。
  - 仅当全流程成功结束时写入 .g2rain-deploy-install.done；失败不写标记，可修正后直接重跑。
  - 完成后请执行: ./start.sh

选项:
  --host / --port   若尚无 .env，从 env.example 创建后可写入平台地址（与 start.sh 行为一致）。
  --service <名>    仅加载 service_config.d/<名>.conf（可重复）；默认扫描该目录下全部 .conf。
  --skip-build      跳过各仓镜像构建（克隆仍会执行）。
  --ssl-ip IP       调用 config/generate-ssl.sh 生成 ssl/ 证书（需 openssl）。
  --force           忽略完成标记重新执行安装流程。

强制重装:
  rm -f .g2rain-deploy-install.done
  或: G2RAIN_DEPLOY_INIT_FORCE=1 ./init-once.sh --force
EOF
}

escape_sed_repl() {
  printf '%s' "$1" | sed -e 's/[\/&|]/\\&/g'
}

ensure_env_file() {
  local platform_host="${1:-}"
  local platform_port="${2:-}"

  if [[ -f "$ENV_FILE" ]]; then
    log_ok "已存在 .env"
    return 0
  fi
  if [[ ! -f "$ENV_EXAMPLE" ]]; then
    log_err "未找到 env.example，无法创建 .env"
    exit 1
  fi
  log_info "从 env.example 创建 .env"
  cp "$ENV_EXAMPLE" "$ENV_FILE"
  if [[ -n "$platform_host" ]]; then
    if grep -q '^PLATFORM_HOST=' "$ENV_FILE"; then
      sed -i.bak "s|^PLATFORM_HOST=.*|PLATFORM_HOST=${platform_host}|" "$ENV_FILE" && rm -f "${ENV_FILE}.bak"
    fi
  fi
  if [[ -n "$platform_port" ]]; then
    if grep -q '^PLATFORM_PORT=' "$ENV_FILE"; then
      sed -i.bak "s|^PLATFORM_PORT=.*|PLATFORM_PORT=${platform_port}|" "$ENV_FILE" && rm -f "${ENV_FILE}.bak"
    fi
    if grep -q '^NGINX_HTTPS_PORT=' "$ENV_FILE"; then
      sed -i.bak "s|^NGINX_HTTPS_PORT=.*|NGINX_HTTPS_PORT=${platform_port}|" "$ENV_FILE" && rm -f "${ENV_FILE}.bak"
    fi
  fi
  log_ok "已创建 .env，可按需编辑"
}

apply_sql_placeholders() {
  if [[ ! -f "$ENV_FILE" ]]; then
    log_err "缺少 .env，无法替换 SQL 占位符"
    exit 1
  fi
  if [[ ! -f "$SQL_BASIS" ]]; then
    log_warn "未找到 $SQL_BASIS，跳过 SQL 占位符替换"
    return 0
  fi
  if ! grep -q '__PLATFORM_HOST__' "$SQL_BASIS" 2>/dev/null; then
    log_info "g2rain-basis.sql 中无 __PLATFORM_HOST__ 占位符，跳过替换（可能已替换过）"
    return 0
  fi

  local ph pp
  ph=$(grep -E '^PLATFORM_HOST=' "$ENV_FILE" | head -1 | cut -d= -f2- | tr -d '\r')
  pp=$(grep -E '^PLATFORM_PORT=' "$ENV_FILE" | head -1 | cut -d= -f2- | tr -d '\r')
  if [[ -z "$ph" || -z "$pp" ]]; then
    log_err ".env 中 PLATFORM_HOST 或 PLATFORM_PORT 为空，无法替换 SQL 占位符"
    exit 1
  fi

  local eph epp
  eph=$(escape_sed_repl "$ph")
  epp=$(escape_sed_repl "$pp")

  log_info "将平台地址写入 g2rain-basis.sql（供 MySQL 首次初始化）"
  sed -i.bak \
    -e "s|__PLATFORM_HOST__|${eph}|g" \
    -e "s|__PLATFORM_PORT__|${epp}|g" \
    "$SQL_BASIS"
  rm -f "${SQL_BASIS}.bak"
  log_ok "SQL 占位符已替换"
}

run_ssl_if_requested() {
  local ip="${1:-}"
  [[ -n "$ip" ]] || return 0
  local gen="${ROOT}/config/generate-ssl.sh"
  if [[ ! -f "$gen" ]]; then
    log_err "未找到 $gen"
    exit 1
  fi
  [[ -x "$gen" ]] || chmod +x "$gen"
  log_info "生成 SSL 证书（generate-ssl.sh）..."
  "$gen" "$ip"
  log_ok "SSL 证书已生成"
}

list_config_services() {
  for entry in "${SERVICES[@]}"; do
    IFS='|' read -r repo dir compose_service build_cmd <<<"$entry"
    repo="${repo:-}"
    dir="${dir:-$repo}"
    build_cmd="${build_cmd:-./build.sh}"
    compose_service="${compose_service:-}"
    if [[ -z "$repo" ]]; then
      continue
    fi
    printf "%s\t%s\t%s\t%s\n" "$repo" "$dir" "$build_cmd" "$compose_service"
  done
}

build_with_retries() {
  local target="$1"
  local build_cmd="$2"
  local repo="$3"
  local attempts="${G2RAIN_BUILD_RETRIES:-3}"
  local sleep_s="${G2RAIN_BUILD_RETRY_SLEEP:-15}"
  local n=1

  while (( n <= attempts )); do
    log_info "构建镜像: ${repo}（${build_cmd}，第 ${n}/${attempts} 次）"
    if (cd "$target" && bash -lc "$build_cmd"); then
      log_ok "构建完成: ${repo}"
      return 0
    fi
    log_warn "构建失败: ${repo}（第 ${n}/${attempts} 次）"
    if (( n < attempts )); then
      log_info "等待 ${sleep_s}s 后重试..."
      sleep "$sleep_s"
    fi
    n=$((n + 1))
  done
  log_err "构建在 ${attempts} 次尝试后仍失败: ${repo}"
  return 1
}

ensure_build_script_executable_if_needed() {
  local target="$1"
  local build_cmd="$2"
  local first_token="${build_cmd%% *}"

  if [[ "$first_token" == ./*.sh && -f "${target}/${first_token}" && ! -x "${target}/${first_token}" ]]; then
    log_warn "检测到脚本不可执行，自动修复权限: ${target}/${first_token}"
    chmod +x "${target}/${first_token}"
  fi
}

sync_repo() {
  local target="$1"
  local url="$2"
  local repo="$3"

  if [[ -d "${target}/.git" ]]; then
    log_info "已存在仓库，跳过拉取: ${repo}"
  else
    if [[ -e "$target" ]]; then
      log_err "路径已存在但不是 git 仓库: $target （请手动处理后重试）"
      return 1
    fi
    log_info "克隆仓库: ${repo}"
    git clone "$url" "$target"
  fi
}

FORCE=false
SKIP_BUILD=false
PLATFORM_HOST_ARG=""
PLATFORM_PORT_ARG=""
SSL_IP=""
G2RAIN_SERVICE_CONFIG_NAMES=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    --force)
      FORCE=true
      shift
      ;;
    --skip-build)
      SKIP_BUILD=true
      shift
      ;;
    --service)
      if [[ -z "${2:-}" ]]; then log_err "--service 需要参数"; exit 1; fi
      G2RAIN_SERVICE_CONFIG_NAMES="${G2RAIN_SERVICE_CONFIG_NAMES}${G2RAIN_SERVICE_CONFIG_NAMES:+ }${2}"
      shift 2
      ;;
    --host)
      PLATFORM_HOST_ARG="${2:-}"
      if [[ -z "$PLATFORM_HOST_ARG" ]]; then log_err "--host 需要参数"; exit 1; fi
      shift 2
      ;;
    --port)
      PLATFORM_PORT_ARG="${2:-}"
      if [[ -z "$PLATFORM_PORT_ARG" ]]; then log_err "--port 需要参数"; exit 1; fi
      shift 2
      ;;
    --ssl-ip)
      SSL_IP="${2:-}"
      if [[ -z "$SSL_IP" ]]; then log_err "--ssl-ip 需要参数"; exit 1; fi
      shift 2
      ;;
    *)
      log_err "未知参数: $1"
      usage
      exit 1
      ;;
  esac
done

if [[ "${G2RAIN_DEPLOY_INIT_FORCE:-}" == "1" ]]; then
  FORCE=true
fi

if [[ -f "$MARKER" && "$FORCE" != true ]]; then
  log_warn "检测到已完成安装（标记: ${MARKER}）"
  log_warn "若需更新服务请运行: ./update.sh"
  log_warn "若确需重装: rm -f ${MARKER} 或 ./init-once.sh --force"
  exit 0
fi

if ! command -v docker >/dev/null 2>&1; then
  log_err "未检测到 Docker，请先安装并启动 Docker。"
  exit 1
fi

if docker compose version >/dev/null 2>&1; then
  :
elif command -v docker-compose >/dev/null 2>&1; then
  :
else
  log_err "未检测到 Docker Compose（需要「docker compose」插件或「docker-compose」命令其一）。"
  exit 1
fi

if [[ -f "${ROOT}/scripts/write-compose-cli-preference.sh" ]]; then
  if bash "${ROOT}/scripts/write-compose-cli-preference.sh" --write; then
    log_ok "已写入 Compose CLI 偏好: config/compose-cli.env（可用该脚本 --dry-run 预览）"
  else
    log_warn "未能写入 config/compose-cli.env，可稍后手动执行: ./scripts/write-compose-cli-preference.sh"
  fi
fi

if ! command -v git >/dev/null 2>&1; then
  log_err "未检测到 git，请先安装。"
  exit 1
fi

if ! command -v mvn >/dev/null 2>&1; then
  log_err "未检测到 Maven（mvn），请先安装。"
  exit 1
fi

if ! command -v java >/dev/null 2>&1; then
  log_err "未检测到 JDK（java 不在 PATH 中），请先安装 JDK。"
  exit 1
fi

if ! java -version >/dev/null 2>&1; then
  log_err "java -version 执行失败，请检查 JDK 安装。"
  exit 1
fi

if ! command -v docker-compose >/dev/null 2>&1; then
  log_warn "未找到 docker-compose 可执行文件；若已生成 config/compose-cli.env 且为 V2，则 start/stop/update 将使用 docker compose；亦可手动 ./scripts/write-compose-cli-preference.sh"
fi

log_ok "依赖检查通过（docker / compose / git / mvn / jdk）"

if [[ ! -f "$CONFIG" ]]; then
  log_err "未找到 $CONFIG"
  exit 1
fi
G2RAIN_DEPLOY_ROOT="$ROOT"
# shellcheck disable=SC1091
source "${ROOT}/services-merge.inc"
g2rain_load_services_config || exit 1
if g2rain_has_extra_service_config; then
  log_info "已合并 service_config.d 中的额外服务映射"
fi
_rel="${CODES_DIR:-./codes}"
if [[ "$_rel" == ./* ]]; then
  CODES="${ROOT}/${_rel#./}"
elif [[ "$_rel" == /* ]]; then
  CODES="$_rel"
else
  CODES="${ROOT}/${_rel}"
fi

ensure_env_file "$PLATFORM_HOST_ARG" "$PLATFORM_PORT_ARG"
apply_sql_placeholders
run_ssl_if_requested "$SSL_IP"

mkdir -p "$CODES"

mapfile -t service_rows < <(list_config_services)

for row in "${service_rows[@]}"; do
  IFS=$'\t' read -r repo dir build_cmd compose_service <<<"$row"
  target="${CODES}/${dir}"
  url="${GIT_BASE}/${repo}.git"
  sync_repo "$target" "$url" "$repo" || exit 1

  if [[ -z "$build_cmd" ]]; then
    log_err "未配置 build 命令: repo=${repo}"
    exit 1
  fi
done

if [[ "$SKIP_BUILD" == true ]]; then
  log_info "已 --skip-build，跳过全部仓库构建"
else
  for row in "${service_rows[@]}"; do
    IFS=$'\t' read -r repo dir build_cmd compose_service <<<"$row"
    target="${CODES}/${dir}"

    if [[ -z "$build_cmd" ]]; then
      log_err "未配置 build 命令: repo=${repo}"
      exit 1
    fi

    ensure_build_script_executable_if_needed "$target" "$build_cmd"

    if ! build_with_retries "$target" "$build_cmd" "$repo"; then
      exit 1
    fi
  done
fi

date -u +"%Y-%m-%dT%H:%M:%SZ" >"$MARKER"
log_ok "安装流程已完成。标记: ${MARKER}"
log_info "下一步在本目录执行: ${ROOT}/start.sh"
log_info "日常更新请使用: ${ROOT}/update.sh"
