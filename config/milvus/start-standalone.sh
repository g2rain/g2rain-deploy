#!/bin/sh
# 降权启动 Milvus，健康后再幂等建表。标记文件存在后健康检查才通过。
set -eu

uid="$(id -u milvus)"
gid="$(id -g milvus)"
ready="/var/lib/milvus/.knowledge-collection-ready"

mkdir -p /var/lib/milvus
chown -R "${uid}:${gid}" /var/lib/milvus
rm -f "$ready"

if command -v runuser >/dev/null 2>&1; then
  runuser -u milvus -- milvus run standalone &
elif command -v setpriv >/dev/null 2>&1; then
  setpriv --reuid=milvus --regid=milvus --clear-groups milvus run standalone &
else
  echo "milvus image has neither runuser nor setpriv" >&2
  exit 1
fi
child="$!"

terminate() {
  kill -TERM "$child" 2>/dev/null || true
  wait "$child" 2>/dev/null || true
}
trap 'terminate; exit 0' TERM INT

i=0
until curl -fsS http://127.0.0.1:9091/healthz >/dev/null 2>&1; do
  if ! kill -0 "$child" 2>/dev/null; then
    echo "milvus exited before healthz" >&2
    exit 1
  fi
  i=$((i + 1))
  if [ "$i" -gt 90 ]; then
    echo "milvus healthz timeout" >&2
    terminate
    exit 1
  fi
  sleep 2
done

if ! /bin/sh /milvus/configs/init-collection.sh; then
  terminate
  exit 1
fi
touch "$ready"

wait "$child"
