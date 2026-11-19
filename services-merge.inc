#!/usr/bin/env bash
# G2Rain 服务映射合并：先加载 services.conf，再在内存中合并 service_config.d（及扩展目录）片段中的 SERVICES。
#
# 约定：
#   - 主配置：services.conf（含 CODES_DIR、GIT_BASE_DEFAULT 及默认 SERVICES）
#   - 片段目录：service_config.d/*.conf，以及可选的 ${G2RAIN_EXTENSION_DIR}/service_config.d/*.conf
#   - 每项为 "repo|dir|compose_service|build_cmd" 或可选第 5 段
#     "repo|dir|compose_service|build_cmd|git_url"；以第三段 compose_service 为键。
#     git_url 为完整克隆地址，可省略；省略时为 ${GIT_BASE}/${repo}.git。
#     后出现的一条若与先前某条 compose_service 相同，则整行替换（后继续扫描仍可再次替换）。
#   - service_config.d 下文件名**不做排序**：按 Bash 对该目录 "*.conf" 的展开顺序依次处理；
#     --service 罗列多个文件时，按所列顺序加载。始终在所有片段之前处理 services.conf。
#   - 不写入磁盘
#
# 可选环境变量：
#   G2RAIN_SERVICE_CONFIG_NAMES — 空格分隔的片段文件名（可带或不带 .conf）。
#     若已设置，则只加载所列名（本仓库与扩展目录按名查找），不再扫描目录下其余文件。
#     由 start.sh / update.sh / init-once.sh 解析重复出现的 --service <名> 后写入。
#   G2RAIN_EXTENSION_DIR — 扩展目录绝对路径（通常已由 compose-merge 的 g2rain_resolve_extension_dir 解析）。
#
# 使用前必须设置：
#   G2RAIN_DEPLOY_ROOT — g2rain-deploy 目录绝对路径
#
# 提供：g2rain_service_config_d_dir、g2rain_service_config_paths、g2rain_merge_services_from_fragment_file、
#       g2rain_load_services_config、g2rain_has_extra_service_config

g2rain_service_config_d_dir() {
  printf '%s/service_config.d' "${G2RAIN_DEPLOY_ROOT}"
}

g2rain_extension_service_config_d_dir() {
  if [[ -n "${G2RAIN_EXTENSION_DIR:-}" ]]; then
    printf '%s/service_config.d' "${G2RAIN_EXTENSION_DIR}"
  fi
}

g2rain_resolve_named_service_config() {
  local base="$1"
  local dir ext_dir f_local f_ext found=0
  dir="$(g2rain_service_config_d_dir)"
  ext_dir="$(g2rain_extension_service_config_d_dir)"
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
    echo "g2rain: 服务配置片段重名: ${base%.conf}" >&2
    return 1
  fi
  if ((found == 0)); then
    echo "g2rain: 未找到服务配置片段: ${base}" >&2
    return 1
  fi
  if [[ -f "$f_local" ]]; then
    printf '%s\n' "$f_local"
  else
    printf '%s\n' "$f_ext"
  fi
}

# 输出待加载的 service_config.d 片段路径，每行一条
g2rain_service_config_paths() {
  [[ -n "${G2RAIN_DEPLOY_ROOT:-}" ]] || return 1
  local dir ext_dir
  dir="$(g2rain_service_config_d_dir)"
  ext_dir="$(g2rain_extension_service_config_d_dir)"
  if [[ -n "${G2RAIN_SERVICE_CONFIG_NAMES:-}" ]]; then
    local token base f
    for token in ${G2RAIN_SERVICE_CONFIG_NAMES}; do
      base="$token"
      [[ "$base" == *.conf ]] || base="${base}.conf"
      f="$(g2rain_resolve_named_service_config "$base")" || return 1
      printf '%s\n' "$f"
    done
    return 0
  fi
  local f name local_names=""
  if [[ -d "$dir" ]]; then
    shopt -s nullglob
    for f in "${dir}"/*.conf; do
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
    for f in "${ext_dir}"/*.conf; do
      if [[ -f "$f" ]]; then
        name="$(basename "$f")"
        if [[ " ${local_names} " == *" ${name} "* ]]; then
          echo "g2rain: 服务配置片段重名: ${name%.conf}" >&2
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

g2rain_has_extra_service_config() {
  [[ -n "${G2RAIN_DEPLOY_ROOT:-}" ]] || return 1
  if [[ -n "${G2RAIN_SERVICE_CONFIG_NAMES:-}" ]]; then
    g2rain_service_config_paths >/dev/null 2>&1
    return $?
  fi
  local dir ext_dir
  dir="$(g2rain_service_config_d_dir)"
  ext_dir="$(g2rain_extension_service_config_d_dir)"
  shopt -s nullglob
  local files=()
  if [[ -d "$dir" ]]; then
    files+=("${dir}"/*.conf)
  fi
  if [[ -n "$ext_dir" && -d "$ext_dir" ]]; then
    files+=("${ext_dir}"/*.conf)
  fi
  shopt -u nullglob
  local f
  for f in "${files[@]+"${files[@]}"}"; do
    [[ -f "$f" ]] && return 0
  done
  return 1
}

g2rain_services_trim_for_compare() {
  local s="$1"
  s="${s//$'\r'/}"
  s="${s#"${s%%[![:space:]]*}"}"
  s="${s%"${s##*[![:space:]]}"}"
  printf '%s' "$s"
}

# 根据第三段 compose_service 将条目并入 SERVICES：已有同键则整行替换，否则追加。
g2rain_services_merge_entries_by_compose_service() {
  local entry compose_key idx replaced existing_compose
  for entry in "$@"; do
    [[ -z "${entry//[[:space:]]/}" ]] && continue
    IFS='|' read -r _ _ compose_key _ <<<"$entry"
    compose_key="$(g2rain_services_trim_for_compare "$compose_key")"
    [[ -z "$compose_key" ]] && continue

    replaced=0
    for idx in "${!SERVICES[@]}"; do
      IFS='|' read -r _ _ existing_compose _ <<<"${SERVICES[$idx]}"
      existing_compose="$(g2rain_services_trim_for_compare "$existing_compose")"
      if [[ "$existing_compose" == "$compose_key" ]]; then
        SERVICES[idx]="$entry"
        replaced=1
        break
      fi
    done
    if [[ "$replaced" -eq 0 ]]; then
      SERVICES+=("$entry")
    fi
  done
}

# 读取单个片段文件，将其 SERVICES 按 compose_service 键合并进当前 SERVICES（后读覆盖先读）。
g2rain_merge_services_from_fragment_file() {
  local f="$1"
  local _saved_services=("${SERVICES[@]:-}")
  local _fragment=()
  SERVICES=()
  # shellcheck disable=SC1090
  source "$f"
  _fragment=("${SERVICES[@]:-}")
  SERVICES=("${_saved_services[@]}")
  if ((${#_fragment[@]} > 0)); then
    g2rain_services_merge_entries_by_compose_service "${_fragment[@]}"
  fi
}

# 加载 services.conf 并合并 service_config.d；设置 SERVICES、CODES_DIR、GIT_BASE_DEFAULT 等
g2rain_load_services_config() {
  [[ -n "${G2RAIN_DEPLOY_ROOT:-}" ]] || {
    echo "g2rain: G2RAIN_DEPLOY_ROOT 未设置" >&2
    return 1
  }

  local main_conf="${G2RAIN_DEPLOY_ROOT}/services.conf"
  SERVICES=()
  CODES_DIR="./codes"
  GIT_BASE_DEFAULT="https://github.com/g2rain"

  if [[ -f "$main_conf" ]]; then
    # shellcheck disable=SC1090
    source "$main_conf"
  fi

  local f
  while IFS= read -r f || [[ -n "$f" ]]; do
    [[ -z "$f" ]] && continue
    g2rain_merge_services_from_fragment_file "$f"
  done < <(g2rain_service_config_paths)
}
