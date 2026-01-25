#!/bin/bash
# .NET 8 Web API Clean Script
# This script cleans up build artifacts and packaged files

# -----------------------------
# 配置参数
# -----------------------------
OUTPUT_DIR=${1:-dist}      # 默认输出目录 dist

# -----------------------------
# 确保在项目目录
# -----------------------------
cd "$(dirname "$0")" || exit 1

echo -e "\e[32mStarting cleanup process...\e[0m"

# -----------------------------
# 清理构建产物
# -----------------------------
# 清理 dist 目录
if [ -d "$OUTPUT_DIR" ]; then
    echo -e "\e[33mRemoving $OUTPUT_DIR directory...\e[0m"
    rm -rf "$OUTPUT_DIR"
fi

# 清理 bin 目录
if [ -d "bin" ]; then
    echo -e "\e[33mRemoving bin directory...\e[0m"
    rm -rf "bin"
fi

# 清理 obj 目录
if [ -d "obj" ]; then
    echo -e "\e[33mRemoving obj directory...\e[0m"
    rm -rf "obj"
fi

echo -e "\e[32mCleanup completed successfully!\e[0m"