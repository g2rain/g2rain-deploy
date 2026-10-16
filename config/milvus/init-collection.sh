#!/bin/sh
# 幂等创建知识库 collection。已存在则直接返回；schema 不一致时不删除、不重建。
set -eu

collection="${KNOWLEDGE_MILVUS_COLLECTION:-g2rain_knowledge_chunks_qwen_4096_v1}"
token="${MILVUS_BOOTSTRAP_TOKEN:-root:Milvus}"
base="http://127.0.0.1:19530"
template="/milvus/configs/knowledge-collection.json"

case "$collection" in
  *[!A-Za-z0-9_]*)
    echo "invalid milvus collection name" >&2
    exit 1
    ;;
esac

post() {
  curl -sS \
    -H "Authorization: Bearer ${token}" \
    -H "Content-Type: application/json" \
    --data "$2" \
    "${base}$1"
}

code_of() {
  printf '%s' "$1" | sed -n 's/.*"code"[[:space:]]*:[[:space:]]*\([-0-9][0-9]*\).*/\1/p' | head -n 1
}

has_body="$(post /v2/vectordb/collections/has "{\"collectionName\":\"${collection}\"}")"
has_code="$(code_of "$has_body")"
if [ "$has_code" != "0" ]; then
  echo "milvus collection check failed: ${has_body}" >&2
  exit 1
fi
case "$has_body" in
  *'"has":true'*|*'\"has\":true'*|*'"has": true'*)
    exit 0
    ;;
esac

payload="$(sed "s/__COLLECTION_NAME__/${collection}/g" "$template")"
create_body="$(post /v2/vectordb/collections/create "$payload")"
create_code="$(code_of "$create_body")"
if [ "$create_code" != "0" ]; then
  echo "milvus collection create failed: ${create_body}" >&2
  exit 1
fi

load_body="$(post /v2/vectordb/collections/load "{\"collectionName\":\"${collection}\"}")"
load_code="$(code_of "$load_body")"
if [ "$load_code" != "0" ]; then
  echo "milvus collection load failed: ${load_body}" >&2
  exit 1
fi
