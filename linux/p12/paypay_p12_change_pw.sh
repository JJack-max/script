#!/bin/bash

set -e  # 脚本出错即退出

# 获取脚本自身所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 检查参数
if [[ -z "$1" ]]; then
  echo "用法: $0 <origin_p12_file>"
  exit 1
fi

origin_p12_file="$1"

# 判断 origin_p12_file 是否为绝对路径
case "$origin_p12_file" in
  /*|[a-zA-Z]:/*)
    origin_p12_file_full="$origin_p12_file"
    ;;
  *)
    origin_p12_file_full="$SCRIPT_DIR/$origin_p12_file"
    ;;
esac

# 交互式输入密码
read -s -p "请输入原始 p12 文件密码: " origin_p12_file_pw
echo
read -s -p "请输入新 p12 文件密码（JKS 密码同此）: " p12_file_pw
jks_file_pw="$p12_file_pw"
echo

# 文件名统一为 tmp
pem_file="$SCRIPT_DIR/tmp.pem"
p12_file="$SCRIPT_DIR/tmp.p12"
jks_file="$SCRIPT_DIR/tmp.jks"

echo "📄 PEM 目标文件: $pem_file"
echo "📄 新 P12 文件: $p12_file"
echo "📄 JKS 目标文件: $jks_file"

# 清理旧文件（如果存在）
rm -f "$pem_file" "$p12_file" "$jks_file"

# 步骤 1: p12 -> PEM
echo "📦 Step 1: Converting .p12 -> .pem"
openssl pkcs12 -in "$origin_p12_file_full" -nodes -out "$pem_file" -legacy -password pass:"$origin_p12_file_pw"

# 步骤 2: PEM -> 新的 P12
echo "🔁 Step 2: Creating new .p12 from .pem"
openssl pkcs12 -export -in "$pem_file" -out "$p12_file" -keypbe PBE-SHA1-3DES -certpbe PBE-SHA1-3DES -macalg sha1 -iter 2048 -passout pass:"$p12_file_pw"

# 步骤 3: P12 -> JKS
echo "🔐 Step 3: Creating .jks from .p12"
keytool -importkeystore \
  -srckeystore "$p12_file" \
  -srcstoretype PKCS12 \
  -srcstorepass "$p12_file_pw" \
  -deststoretype JKS \
  -destkeystore "$jks_file" \
  -deststorepass "$jks_file_pw" \
  -noprompt

echo "✅ All done. Final JKS file: $jks_file"
