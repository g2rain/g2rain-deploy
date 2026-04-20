#!/usr/bin/env bash
# g2rain-deploy 一次性初始化：依赖检查 → 克隆后端仓库到 codes/ → 各仓 build.sh → start.sh
# 成功后写入标记文件，再次执行会直接退出（除非强制）。
# 重试：未成功时不会写标记文件；再次执行时，codes/<repo> 若已是 git 仓库则 git pull（非重新 clone），
#       然后从未完成的仓库起继续 build，最后仍会执行 start.sh。
# SSL 证书由仓库内置（ssl/），本脚本不负责生成。
#
# 用法:
#   ./init-once.sh              首次完整初始化（需本机尚未存在完成标记）
#   ./init-once.sh --force      忽略「仅一次」标记重新执行全流程
#
# 环境变量:
#   G2RAIN_DEPLOY_INIT_FORCE=1           # 等同于 --force
#   G2RAIN_GIT_BASE=https://github.com/g2rain   # 克隆地址前缀（默认 g2rain 组织）
#
# 后续更新镜像/容器请使用本目录下的 ./update.sh

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MARKER="${ROOT}/.g2rain-deploy-one-shot-init.done"
CODES="${ROOT}/codes"
GIT_BASE="${G2RAIN_GIT_BASE:-https://github.com/g2rain}"
CONFIG="${ROOT}/services.conf"

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
  ./init-once.sh           首次完整初始化（需本机尚未存在完成标记）
  ./init-once.sh --force   忽略「仅一次」标记重新执行全流程

说明:
  - 会根据 services.conf 克隆/更新 GitHub 仓库到 ./codes/ 并依次执行各仓 build 脚本（默认 ./build.sh）。
  - 已克隆过的仓库再次执行时会 git pull（不会禁止「再下载」）；仅空目录才会 git clone。
  - 仅当全流程成功结束后才写入 .g2rain-deploy-one-shot-init.done；失败未写标记，可修正问题后直接重跑。
  - 成功后再次执行本脚本将直接退出；日常发布/更新请使用: ./update.sh

强制重新初始化:
  删除标记文件: rm -f .g2rain-deploy-one-shot-init.done
  或: G2RAIN_DEPLOY_INIT_FORCE=1 ./init-once.sh --force
EOF
}

list_config_services() {
  if [[ ! -f "$CONFIG" ]]; then
    log_err "未找到配置文件: $CONFIG"
    exit 1
  fi
  # shellcheck disable=SC1090
  source "$CONFIG"
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

FORCE=false

for arg in "$@"; do
  case "$arg" in
    -h|--help)
      usage
      exit 0
      ;;
    --force)
      FORCE=true
      ;;
    *)
      log_err "未知参数: $arg"
      usage
      exit 1
      ;;
  esac
done

if [[ "${G2RAIN_DEPLOY_INIT_FORCE:-}" == "1" ]]; then
  FORCE=true
fi

if [[ -f "$MARKER" && "$FORCE" != true ]]; then
  log_warn "检测到已完成一次性初始化（标记文件: ${MARKER}）"
  log_warn "本脚本不会再次执行。若需更新服务请运行: ./update.sh"
  log_warn "若确需重新跑初始化，请删除该标记文件或使用: ./init-once.sh --force"
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

if ! command -v git >/dev/null 2>&1; then
  log_err "未检测到 git，请先安装。"
  exit 1
fi

if ! command -v mvn >/dev/null 2>&1; then
  log_err "未检测到 Maven（mvn），请先安装。"
  exit 1
fi

if ! command -v java >/dev/null 2>&1; then
  log_err "未检测到 JDK（java 命令不在 PATH 中），请先安装 JDK 并配置 PATH。"
  exit 1
fi

if ! java -version >/dev/null 2>&1; then
  log_err "java -version 执行失败，请检查 JDK 安装。"
  exit 1
fi

if ! command -v docker-compose >/dev/null 2>&1; then
  log_warn "未找到 docker-compose 可执行文件；本仓库的 start.sh/stop.sh/update.sh 仍要求该命令。"
  log_warn "若仅有「docker compose」插件，请安装 docker-compose v1 兼容入口，或为 docker compose 提供同名包装。"
fi

log_ok "依赖检查通过（docker / compose / git / mvn / jdk）"

mkdir -p "$CODES"

while IFS=$'\t' read -r repo dir build_cmd compose_service; do
  target="${CODES}/${dir}"
  url="${GIT_BASE}/${repo}.git"
  if [[ -d "${target}/.git" ]]; then
    log_info "已存在仓库，拉取最新: ${repo}（git fetch + pull --ff-only）"
    git -C "$target" fetch --tags --prune
    git -C "$target" pull --ff-only
  else
    if [[ -e "$target" ]]; then
      log_err "路径已存在但不是 git 仓库: $target （请手动处理后重试）"
      exit 1
    fi
    log_info "克隆仓库: ${repo}"
    git clone "$url" "$target"
  fi

  if [[ -z "$build_cmd" ]]; then
    log_err "未配置 build 命令: repo=${repo}"
    exit 1
  fi
  log_info "构建镜像: ${repo}（${build_cmd}）"
  (cd "$target" && bash -lc "$build_cmd")
  log_ok "构建完成: ${repo}"
done < <(list_config_services)

start_sh="${ROOT}/start.sh"
if [[ ! -f "$start_sh" ]]; then
  log_err "未找到 start.sh: $start_sh"
  exit 1
fi
[[ -x "$start_sh" ]] || chmod +x "$start_sh"

log_info "启动 Docker Compose 栈（start.sh）"
"$start_sh"

date -u +"%Y-%m-%dT%H:%M:%SZ" >"$MARKER"
log_ok "一次性初始化已完成。标记文件: ${MARKER}"
log_info "后续更新请使用: ${ROOT}/update.sh"
