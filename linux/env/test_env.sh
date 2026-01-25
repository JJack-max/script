#!/bin/bash

# 获取脚本自身所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 加载同目录下的 .env 文件
ENV_FILE="$SCRIPT_DIR/.env"

# 判断 .env 是否存在
if [[ -f "$ENV_FILE" ]]; then
  # 加载环境变量（排除注释行）
  export $(grep -v '^#' "$ENV_FILE" | xargs)
else
  echo "Error: .env file not found in $SCRIPT_DIR"
  exit 1
fi

# 示例使用变量
echo "变量FOO的值是：$FOO"
echo "变量BAR的值是：$BAR"
echo "变量BAR的值是：$API_KEY"

# 你自己的逻辑写在这里
# 比如：curl -H "Authorization: Bearer $API_KEY" ...
