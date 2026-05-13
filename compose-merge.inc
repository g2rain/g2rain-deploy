#!/usr/bin/env bash
# G2Rain Compose 合并：主 compose 始终第一位，其后追加 business.d 下片段。
#
# 约定：
#   - 主文件：docker-compose.yml 或（USE_COMPOSE_V2=1 时）compose-v2/compose.yaml
#   - 业务片段：目录 business.d/ 下扩展名为 .yml 的文件；不排序，由 shell 展开顺序决定。
#   - 同一服务名不应在多个片段中重复定义，由部署方自行约束。
#
# 可选环境变量：
#   G2RAIN_BUSINESS_NAMES — 空格分隔的片段文件名（可带或不带 .yml）。
#     若已设置，则只加载列出的 business.d/<名>.yml，不再自动加载目录下其余 .yml。
#     由 start.sh / stop.sh / update.sh 解析重复出现的 --business <名> 后写入。
#
# 使用前必须设置：
#   COMPOSE_DEPLOY_ROOT — g2rain-deploy 目录绝对路径
#   USE_COMPOSE_V2      — 0：docker-compose + docker-compose.yml；1：docker compose + compose-v2/compose.yaml
#
# 提供：g2rain_compose_base_file、g2rain_business_yml_paths、g2rain_compose_all_yml_fragments、
#       g2rain_dc、g2rain_has_business_compose、g2rain_compose_cli_hint

g2rain_compose_base_file() {
  if [[ "${USE_COMPOSE_V2:-0}" = 1 ]]; then
    printf '%s/compose-v2/compose.yaml' "${COMPOSE_DEPLOY_ROOT}"
  else
    printf '%s/docker-compose.yml' "${COMPOSE_DEPLOY_ROOT}"
  fi
}

g2rain_business_d_dir() {
  printf '%s/business.d' "${COMPOSE_DEPLOY_ROOT}"
}

# 仅输出 business 片段路径，每行一条（不含主 compose）
g2rain_business_yml_paths() {
  [[ -n "${COMPOSE_DEPLOY_ROOT:-}" ]] || return 1
  local dir
  dir="$(g2rain_business_d_dir)"
  if [[ -n "${G2RAIN_BUSINESS_NAMES:-}" ]]; then
    local token base f
    for token in ${G2RAIN_BUSINESS_NAMES}; do
      base="$token"
      [[ "$base" == *.yml ]] || base="${base}.yml"
      f="${dir}/${base}"
      if [[ ! -f "$f" ]]; then
        echo "g2rain: 未找到业务 compose 片段: ${f}" >&2
        return 1
      fi
      printf '%s\n' "$f"
    done
    return 0
  fi
  if [[ ! -d "$dir" ]]; then
    return 0
  fi
  shopt -s nullglob
  local f
  for f in "${dir}"/*.yml; do
    [[ -f "$f" ]] && printf '%s\n' "$f"
  done
  shopt -u nullglob
  return 0
}

# 主 compose + 各 business 片段，每行一条（供镜像 grep 等）
g2rain_compose_all_yml_fragments() {
  printf '%s\n' "$(g2rain_compose_base_file)"
  g2rain_business_yml_paths || return 1
}

g2rain_has_business_compose() {
  [[ -n "${COMPOSE_DEPLOY_ROOT:-}" ]] || return 1
  if [[ -n "${G2RAIN_BUSINESS_NAMES:-}" ]]; then
    g2rain_business_yml_paths >/dev/null 2>&1
    return $?
  fi
  local dir
  dir="$(g2rain_business_d_dir)"
  [[ -d "$dir" ]] || return 1
  shopt -s nullglob
  local f
  for f in "${dir}"/*.yml; do
    if [[ -f "$f" ]]; then
      shopt -u nullglob
      return 0
    fi
  done
  shopt -u nullglob
  return 1
}

g2rain_dc() {
  local base cmd=()
  base="$(g2rain_compose_base_file)"
  if [[ "${USE_COMPOSE_V2:-0}" = 1 ]]; then
    cmd=(docker compose -f "$base")
    local line
    while IFS= read -r line || [[ -n "$line" ]]; do
      [[ -n "$line" ]] || continue
      cmd+=(-f "$line")
    done < <(g2rain_business_yml_paths) || return 1
    cmd+=(--project-directory "${COMPOSE_DEPLOY_ROOT}")
    "${cmd[@]}" "$@"
  else
    cmd=(docker-compose -f "$base")
    local line
    while IFS= read -r line || [[ -n "$line" ]]; do
      [[ -n "$line" ]] || continue
      cmd+=(-f "$line")
    done < <(g2rain_business_yml_paths) || return 1
    "${cmd[@]}" "$@"
  fi
}

# 供帮助文案：在部署根目录执行时与脚本等价的命令前缀（不含子命令）
g2rain_compose_cli_hint() {
  local tail line
  if [[ "${USE_COMPOSE_V2:-0}" = 1 ]]; then
    tail='docker compose -f compose-v2/compose.yaml'
  else
    tail='docker-compose -f docker-compose.yml'
  fi
  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ -n "$line" ]] || continue
    tail="${tail} -f business.d/$(basename "$line")"
  done < <(g2rain_business_yml_paths 2>/dev/null) || true
  if [[ "${USE_COMPOSE_V2:-0}" = 1 ]]; then
    tail="${tail} --project-directory ."
  fi
  printf '%s' "$tail"
}
