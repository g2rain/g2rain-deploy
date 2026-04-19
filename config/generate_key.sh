#!/bin/sh

# ======================================================
# generate_key.sh
# 用途：生成 ES256 (P-256) 公私钥对，并导出为 PEM 和 DER 格式
#
# 使用方式：
#   ./generate_key.sh <target_dir> [name]
#
# 输出结果：
#   <target_dir>/<name>-private-key.pem
#   <target_dir>/<name>-public-key.pem
#   <target_dir>/<name>-private-key.der
#   <target_dir>/<name>-public-key.der
#
# 若 name 未提供，则生成：
#   <target_dir>/private-key.pem
#   <target_dir>/public-key.pem
#   <target_dir>/private-key.der
#   <target_dir>/public-key.der
# ======================================================

TARGET_DIR="$1"
KEY_NAME="$2"

# ---- 参数检查 ----
if [ -z "$TARGET_DIR" ]; then
    echo "❌ 错误：必须指定输出目录"
    echo "用法：$0 /path/to/keys [keyname]"
    exit 1
fi

# ---- 目录不存在则创建 ----
mkdir -p "$TARGET_DIR"

# ---- 文件名规则 ----
if [ -z "$KEY_NAME" ]; then
    PRIVATE_KEY_PEM="$TARGET_DIR/private-key.pem"
    PUBLIC_KEY_PEM="$TARGET_DIR/public-key.pem"
    PRIVATE_KEY_DER="$TARGET_DIR/private-key.der"
    PUBLIC_KEY_DER="$TARGET_DIR/public-key.der"
else
    PRIVATE_KEY_PEM="$TARGET_DIR/${KEY_NAME}-private-key.pem"
    PUBLIC_KEY_PEM="$TARGET_DIR/${KEY_NAME}-public-key.pem"
    PRIVATE_KEY_DER="$TARGET_DIR/${KEY_NAME}-private-key.der"
    PUBLIC_KEY_DER="$TARGET_DIR/${KEY_NAME}-public-key.der"
fi

echo "🔧 正在生成 ES256 密钥对..."
echo "📁 目录: $TARGET_DIR"
echo "📝 私钥: $PRIVATE_KEY_PEM"
echo "📝 公钥: $PUBLIC_KEY_PEM"
echo "📝 私钥 DER: $PRIVATE_KEY_DER"
echo "📝 公钥 DER: $PUBLIC_KEY_DER"
echo ""

# ---- 生成 EC(P-256) 私钥 (临时格式) ----
openssl ecparam -name prime256v1 -genkey -noout -out "$PRIVATE_KEY_PEM.tmp" 2>/dev/null
if [ $? -ne 0 ]; then
    echo "❌ EC 私钥生成失败"
    exit 1
fi

# ---- 转换为 PKCS#8 格式（lua-resty-openssl 必需） ----
openssl pkcs8 -topk8 -nocrypt -in "$PRIVATE_KEY_PEM.tmp" -out "$PRIVATE_KEY_PEM" 2>/dev/null
rm -f "$PRIVATE_KEY_PEM.tmp"

if [ $? -ne 0 ]; then
    echo "❌ 转换为 PKCS#8 格式失败"
    exit 1
fi

# ---- 生成公钥 PEM 格式 ----
openssl ec -in "$PRIVATE_KEY_PEM" -pubout -out "$PUBLIC_KEY_PEM" 2>/dev/null
if [ $? -ne 0 ]; then
    echo "❌ 公钥生成失败"
    exit 1
fi

# ---- 生成 DER 格式的公钥和私钥 ----
openssl ec -in "$PRIVATE_KEY_PEM" -outform DER -out "$PRIVATE_KEY_DER" 2>/dev/null
if [ $? -ne 0 ]; then
    echo "❌ 私钥 DER 格式生成失败"
    exit 1
fi

openssl ec -in "$PUBLIC_KEY_PEM" -pubin -outform DER -out "$PUBLIC_KEY_DER" 2>/dev/null
if [ $? -ne 0 ]; then
    echo "❌ 公钥 DER 格式生成失败"
    exit 1
fi

# ---- 设置只读权限 ----
chmod 644 "$PRIVATE_KEY_PEM" "$PUBLIC_KEY_PEM" "$PRIVATE_KEY_DER" "$PUBLIC_KEY_DER"

echo "✅ 密钥生成成功！"
echo ""
echo "预览："
echo "--------------------------------"
echo "$(head -n 1 "$PRIVATE_KEY_PEM")"
echo "$(head -n 1 "$PUBLIC_KEY_PEM")"
echo "$(head -n 1 "$PRIVATE_KEY_DER")"
echo "$(head -n 1 "$PUBLIC_KEY_DER")"
echo "--------------------------------"
echo "🎉 已完成"
