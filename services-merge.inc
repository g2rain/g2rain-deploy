#!/usr/bin/env bash
# G2Rain 服务映射合并：先加载 services.conf，再在内存中追加 service_config.d 片段中的 SERVICES。
#
# 约定：
#   - 主配置：services.conf（含 CODES_DIR、GIT_BASE_DEFAULT 及默认 SERVICES）
#   - 片段目录：service_config.d/*.conf，每文件仅需定义 SERVICES=(...)
#   - 片段中的条目追加到主 SERVICES 之后，不写入磁盘
#
# 可选环境变量：
#   G2RAIN_SERVICE_CONFIG_NAMES — 空格分隔的片段文件名（可带或不带 .conf）。
#     若已设置，则只加载列出的 service_config.d/<名>.conf，不再扫描目录下其余文件。
#     由 start.sh / update.sh / init-once.sh 解析重复出现的 --service <名> 后写入。
#
# 使用前必须设置：
#   G2RAIN_DEPLOY_ROOT — g2rain-deploy 目录绝对路径
#
# 提供：g2rain_service_config_d_dir、g2rain_service_config_paths、g2rain_append_services_from_config、
#       g2rain_load_services_config、g2rain_has_extra_service_config

g2rain_service_config_d_dir() {
  printf '%s/service_config.d' "${G2RAIN_DEPLOY_ROOT}"
}

# 输出待加载的 service_config.d 片段路径，每行一条
g2rain_service_config_paths() {
  [[ -n "${G2RAIN_DEPLOY_ROOT:-}" ]] || return 1
  local dir
  dir="$(g2rain_service_config_d_dir)"
  if [[ -n "${G2RAIN_SERVICE_CONFIG_NAMES:-}" ]]; then
    local token base f
    for token in ${G2RAIN_SERVICE_CONFIG_NAMES}; do
      base="$token"
      [[ "$base" == *.conf ]] || base="${base}.conf"
      f="${dir}/${base}"
      if [[ ! -f "$f" ]]; then
        echo "g2rain: 未找到服务配置片段: ${f}" >&2
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
  for f in "${dir}"/*.conf; do
    [[ -f "$f" ]] && printf '%s\n' "$f"
  done
  shopt -u nullglob
  return 0
}

g2rain_has_extra_service_config() {
  [[ -n "${G2RAIN_DEPLOY_ROOT:-}" ]] || return 1
  if [[ -n "${G2RAIN_SERVICE_CONFIG_NAMES:-}" ]]; then
    g2rain_service_config_paths >/dev/null 2>&1
    return $?
  fi
  local dir
  dir="$(g2rain_service_config_d_dir)"
  [[ -d "$dir" ]] || return 1
  shopt -s nullglob
  local files=("${dir}"/*.conf)
  shopt -u nullglob
  ((${#files[@]} > 0))
}

# 将单个片段中的 SERVICES 追加到当前 SERVICES 数组（内存合并）
g2rain_append_services_from_config() {
  local f="$1"
  local _saved=("${SERVICES[@]:-}")
  local _fragment=()
  # shellcheck disable=SC1090
  source "$f"
  _fragment=("${SERVICES[@]:-}")
  SERVICES=("${_saved[@]}" "${_fragment[@]}")
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
    g2rain_append_services_from_config "$f"
  done < <(g2rain_service_config_paths)
}
