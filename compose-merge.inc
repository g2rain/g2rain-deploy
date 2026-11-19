#!/usr/bin/env bash
# G2Rain Compose 合并：主 compose 始终第一位，其后追加 business.d（及扩展目录）下片段。
#
# 约定：
#   - 主文件：docker-compose.yml 或（USE_COMPOSE_V2=1 时）compose-v2/compose.yaml
#   - 业务片段：目录 business.d/ 下扩展名为 .yml 的文件；不排序，由 shell 展开顺序决定。
#   - 同一服务名不应在多个片段中重复定义，由部署方自行约束。
#
# 可选环境变量：
#   G2RAIN_BUSINESS_NAMES — 空格分隔的片段文件名（可带或不带 .yml）。
#     若已设置，则只加载列出的片段（本仓库 business.d/ 与扩展目录 business.d/ 按名查找），
#     不再自动加载目录下其余 .yml。由 start.sh / stop.sh / update.sh 解析 --business 后写入。
#   G2RAIN_EXTENSION_DIR — 扩展目录（相对路径以部署根为准）。未设置或为空表示不使用扩展。
#     片段还可放在 ${G2RAIN_EXTENSION_DIR}/business.d/；片段内引用扩展文件须写 ${G2RAIN_EXTENSION_DIR}/...。
#
# 使用前必须设置：
#   COMPOSE_DEPLOY_ROOT — g2rain-deploy 目录绝对路径
#   USE_COMPOSE_V2      — 0：docker-compose + docker-compose.yml；1：docker compose + compose-v2/compose.yaml
#                       （通常由 start/stop/update 在 source 本文件前调用 compose-cli-preference.inc 解析）
#
# 可选持久化：config/compose-cli.env 中 G2RAIN_USE_COMPOSE_V2=0|1（见 config/compose-cli.env.example
#   与 scripts/write-compose-cli-preference.sh）；命令行 --compose-v2 / --compose-v1 优先。
#
# 提供：g2rain_resolve_extension_dir、g2rain_compose_base_file、g2rain_business_yml_paths、
#       g2rain_compose_all_yml_fragments、g2rain_dc、g2rain_has_business_compose、g2rain_compose_cli_hint

# 将 G2RAIN_EXTENSION_DIR 解析为绝对路径并 export；未设置则清空。目录不存在时报错退出。
g2rain_resolve_extension_dir() {
  local raw="${G2RAIN_EXTENSION_DIR:-}"
  local abs
  if [[ -z "$raw" ]]; then
    export G2RAIN_EXTENSION_DIR=""
    return 0
  fi
  if [[ "$raw" != /* ]]; then
    raw="${COMPOSE_DEPLOY_ROOT:-$(pwd)}/${raw}"
  fi
  if [[ ! -d "$raw" ]]; then
    echo "扩展目录不存在: ${G2RAIN_EXTENSION_DIR}" >&2
    return 1
  fi
  abs="$(cd "$raw" && pwd)"
  export G2RAIN_EXTENSION_DIR="$abs"
}

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

g2rain_extension_business_d_dir() {
  if [[ -n "${G2RAIN_EXTENSION_DIR:-}" ]]; then
    printf '%s/business.d' "${G2RAIN_EXTENSION_DIR}"
  fi
}

# 按片段名在本仓库与扩展目录中查找；重名报错，都不存在报错。
g2rain_resolve_named_business_yml() {
  local base="$1"
  local dir ext_dir f_local f_ext found=0
  dir="$(g2rain_business_d_dir)"
  ext_dir="$(g2rain_extension_business_d_dir)"
  f_local="${dir}/${base}"
  f_ext=""
  if [[ -n "$ext_dir" ]]; then
    f_ext="${ext_dir}/${base}"
  fi
  if [[ -f "$f_local" ]]; then
    found=$((found + 1))
  fi
  if [[ -n "$f_ext" && -f "$f_ext" ]]; then
    found=$((found + 1))
  fi
  if ((found > 1)); then
    echo "业务片段重名: ${base%.yml}" >&2
    return 1
  fi
  if ((found == 0)); then
    echo "业务片段不存在: ${base%.yml}" >&2
    return 1
  fi
  if [[ -f "$f_local" ]]; then
    printf '%s\n' "$f_local"
  else
    printf '%s\n' "$f_ext"
  fi
}

# 仅输出 business 片段路径，每行一条（不含主 compose）
g2rain_business_yml_paths() {
  [[ -n "${COMPOSE_DEPLOY_ROOT:-}" ]] || return 1
  local dir ext_dir
  dir="$(g2rain_business_d_dir)"
  ext_dir="$(g2rain_extension_business_d_dir)"
  if [[ -n "${G2RAIN_BUSINESS_NAMES:-}" ]]; then
    local token base f
    for token in ${G2RAIN_BUSINESS_NAMES}; do
      base="$token"
      [[ "$base" == *.yml ]] || base="${base}.yml"
      f="$(g2rain_resolve_named_business_yml "$base")" || return 1
      printf '%s\n' "$f"
    done
    return 0
  fi
  local f name local_names=""
  if [[ -d "$dir" ]]; then
    shopt -s nullglob
    for f in "${dir}"/*.yml; do
      if [[ -f "$f" ]]; then
        name="$(basename "$f")"
        local_names="${local_names} ${name} "
        printf '%s\n' "$f"
      fi
    done
    shopt -u nullglob
  fi
  if [[ -n "$ext_dir" && -d "$ext_dir" ]]; then
    shopt -s nullglob
    for f in "${ext_dir}"/*.yml; do
      if [[ -f "$f" ]]; then
        name="$(basename "$f")"
        if [[ " ${local_names} " == *" ${name} "* ]]; then
          echo "业务片段重名: ${name%.yml}" >&2
          shopt -u nullglob
          return 1
        fi
        printf '%s\n' "$f"
      fi
    done
    shopt -u nullglob
  fi
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
  local dir ext_dir
  dir="$(g2rain_business_d_dir)"
  ext_dir="$(g2rain_extension_business_d_dir)"
  shopt -s nullglob
  local f
  if [[ -d "$dir" ]]; then
    for f in "${dir}"/*.yml; do
      if [[ -f "$f" ]]; then
        shopt -u nullglob
        return 0
      fi
    done
  fi
  if [[ -n "$ext_dir" && -d "$ext_dir" ]]; then
    for f in "${ext_dir}"/*.yml; do
      if [[ -f "$f" ]]; then
        shopt -u nullglob
        return 0
      fi
    done
  fi
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
  local tail line rel
  if [[ "${USE_COMPOSE_V2:-0}" = 1 ]]; then
    tail='docker compose -f compose-v2/compose.yaml'
  else
    tail='docker-compose -f docker-compose.yml'
  fi
  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ -n "$line" ]] || continue
    rel="${line#"${COMPOSE_DEPLOY_ROOT}/"}"
    if [[ "$rel" == "$line" ]]; then
      tail="${tail} -f ${line}"
    else
      tail="${tail} -f ${rel}"
    fi
  done < <(g2rain_business_yml_paths 2>/dev/null) || true
  if [[ "${USE_COMPOSE_V2:-0}" = 1 ]]; then
    tail="${tail} --project-directory ."
  fi
  printf '%s' "$tail"
}
