#!/usr/bin/env bash
# 解析「使用哪套 Compose CLI」：供 start / stop / update 在 source compose-merge.inc 之前调用。
#
# 约定：
#   - 配置文件：${deploy_root}/config/compose-cli.env（可由 scripts/write-compose-cli-preference.sh 生成）
#   - 键名：G2RAIN_USE_COMPOSE_V2=0|1（也接受 true/false、yes/no、v1/v2，大小写不敏感）
#   - 第二参数 override：空则从文件读；v2 / v1 为命令行强制（--compose-v2 / --compose-v1）
#
# 输出：设置 USE_COMPOSE_V2 为 0 或 1

g2rain_normalize_compose_v2_flag() {
  local raw="${1:-}"
  raw="$(printf '%s' "$raw" | tr '[:upper:]' '[:lower:]' | tr -d '\r' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
  case "$raw" in
    1 | true | yes | y | on | v2) printf '1' ;;
    0 | false | no | n | off | v1 | "") printf '0' ;;
    *) printf '0' ;;
  esac
}

# g2rain_resolve_use_compose_v2 <deploy_root> [override]
# override: 空 | v2 | v1
g2rain_resolve_use_compose_v2() {
  local root="${1:?}"
  local o="${2:-}"
  case "$o" in
    v2)
      USE_COMPOSE_V2=1
      return
      ;;
    v1)
      USE_COMPOSE_V2=0
      return
      ;;
  esac

  USE_COMPOSE_V2=0
  local f="${root}/config/compose-cli.env"
  [[ -f "$f" ]] || return 0

  local line val
  line="$(grep -E '^[[:space:]]*G2RAIN_USE_COMPOSE_V2=' "$f" | tail -n 1)" || true
  [[ -n "$line" ]] || return 0
  val="${line#*=}"
  val="$(g2rain_normalize_compose_v2_flag "$val")"
  if [[ "$val" == "1" ]]; then
    USE_COMPOSE_V2=1
  else
    USE_COMPOSE_V2=0
  fi
}
