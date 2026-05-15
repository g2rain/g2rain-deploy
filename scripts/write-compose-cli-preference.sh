#!/usr/bin/env bash
# 探测本机可用的 Docker Compose CLI，将偏好写入 config/compose-cli.env。
# 可单独执行，也可由 init-once.sh 调用。
#
# 探测策略：若 docker compose 可用则写 G2RAIN_USE_COMPOSE_V2=1；否则若 docker-compose 可用则写 0；均不可用则失败。
#
# 用法:
#   ./scripts/write-compose-cli-preference.sh           等同 --write
#   ./scripts/write-compose-cli-preference.sh --write
#   ./scripts/write-compose-cli-preference.sh --dry-run
#   ./scripts/write-compose-cli-preference.sh --print-export   # 输出一行 export，供 eval

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
OUT="${G2RAIN_COMPOSE_CLI_ENV:-${ROOT}/config/compose-cli.env}"

usage() {
  sed -n '1,20p' "$0" | tail -n +2
}

detect_mode() {
  if docker compose version >/dev/null 2>&1; then
    printf '1'
    return 0
  fi
  if command -v docker-compose >/dev/null 2>&1 && docker-compose version >/dev/null 2>&1; then
    printf '0'
    return 0
  fi
  echo "g2rain: 未检测到可用的「docker compose」或「docker-compose」。" >&2
  return 1
}

write_file() {
  local val="$1"
  mkdir -p "$(dirname "$OUT")"
  cat >"$OUT.tmp" <<EOF
# 由 scripts/write-compose-cli-preference.sh 生成或更新；start/stop/update 会读取。
# 1 = docker compose + compose-v2/compose.yaml；0 = docker-compose + docker-compose.yml
# 命令行 --compose-v2 / --compose-v1 优先于本文件。
G2RAIN_USE_COMPOSE_V2=${val}
EOF
  mv -f "$OUT.tmp" "$OUT"
  echo "g2rain: 已写入 ${OUT} （G2RAIN_USE_COMPOSE_V2=${val}）"
}

main() {
  local mode dry=0 printx=0
  mode="${1:-}"

  case "${mode:-}" in
    --help | -h)
      usage
      exit 0
      ;;
    --dry-run)
      dry=1
      ;;
    --print-export)
      printx=1
      ;;
    "" | --write)
      :
      ;;
    *)
      echo "未知参数: $mode" >&2
      usage >&2
      exit 2
      ;;
  esac

  local v
  v="$(detect_mode)" || exit 1

  if [[ "$printx" == 1 ]]; then
    printf 'export USE_COMPOSE_V2=%s\n' "$v"
    exit 0
  fi

  if [[ "$dry" == 1 ]]; then
    echo "dry-run: 将写入 G2RAIN_USE_COMPOSE_V2=${v} -> ${OUT}"
    exit 0
  fi

  write_file "$v"
}

main "$@"
