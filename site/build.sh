#!/bin/bash
# .NET 8 Web API Linux Deployment Build Script (Minimal)
# This script creates a self-contained, trimmed deployment for Linux

# -----------------------------
# 配置参数
# -----------------------------
OUTPUT_DIR=${1:-dist}      # 默认输出目录 dist
PROJECT_NAME=${2:-site}    # 默认项目名 site

# -----------------------------
# 确保在项目目录
# -----------------------------
cd "$(dirname "$0")" || exit 1

echo -e "\e[32mStarting minimal build process for $PROJECT_NAME...\e[0m"

# -----------------------------
# 清理上一次构建
# -----------------------------
if [ -d "$OUTPUT_DIR" ]; then
    echo -e "\e[33mCleaning previous build...\e[0m"
    rm -rf "$OUTPUT_DIR"
fi

# 创建输出目录
mkdir -p "$OUTPUT_DIR"

# -----------------------------
# 发布应用（Linux x64, 自包含, 单文件）
# -----------------------------
echo -e "\e[33mPublishing application for Linux (x64)...\e[0m"
dotnet publish -c Release -r linux-x64 --self-contained true \
  -p:PublishTrimmed=false \
  -p:PublishSingleFile=true \
  -p:IncludeNativeLibrariesForSelfExtract=true \
  -p:EnableCompressionInSingleFile=true \
  -p:DebuggerSupport=false \
  -p:EnableUnsafeBinaryFormatterSerialization=false \
  -p:EnableUnsafeUTF7Encoding=false \
  -p:HttpActivityPropagationSupport=false \
  -p:InvariantGlobalization=true \
  -o "$OUTPUT_DIR"

# -----------------------------
# 输出包信息
# -----------------------------
echo -e "\e[32mBuild completed successfully!\e[0m"
SIZE=$(du -sm "$OUTPUT_DIR" | cut -f1)
echo -e "\e[36mTotal package size: ${SIZE} MB\e[0m"

echo -e "\e[33mContents of deployment package:\e[0m"
ls -lh "$OUTPUT_DIR"

# -----------------------------
# 部署提示
# -----------------------------
echo -e "\e[32mDeployment package is ready at: $OUTPUT_DIR\e[0m"
echo -e "\e[33mTo run on Linux:\e[0m"
echo -e "  1. Copy the '$PROJECT_NAME' executable to your Linux server"
echo -e "  2. Set execute permissions: chmod +x $OUTPUT_DIR/$PROJECT_NAME"
echo -e "  3. Run directly: ./$OUTPUT_DIR/$PROJECT_NAME"
echo -e "  4. The application will listen on port 8080 by default"
