#!/bin/bash

# JSON 工具: 格式化和压缩
# 用法示例:
#   json format <file>   - 格式化 JSON 文件
#   json minify <file>   - 压缩 JSON 文件
#   json help            - 显示帮助信息

show_help() {
    echo "Usage: json <command> [file]"
    echo ""
    echo "Commands:"
    echo "  format <file>   Format the JSON file."
    echo "  minify <file>   Minify the JSON file."
    echo "  help            Show this help message."
}

# 检查是否至少有一个参数
if [ $# -lt 1 ]; then
    show_help
    exit 1
fi

COMMAND="$1"
FILE="$2"

# 检查文件是否存在（format 或 minify 命令才需要文件）
check_file() {
    if [ ! -f "$FILE" ]; then
        echo "Error: File '$FILE' not found."
        exit 1
    fi
}

# JSON 格式化函数
json_format() {
    check_file
    tmp=$(mktemp)
    if ! jq . "$FILE" > "$tmp"; then
        echo "Error: Failed to format $FILE"
        rm -f "$tmp"
        exit 1
    fi
    mv "$tmp" "$FILE"
    echo "Formatted $FILE successfully."
}

# JSON 压缩函数
json_minify() {
    check_file
    tmp=$(mktemp)
    if ! jq -c . "$FILE" > "$tmp"; then
        echo "Error: Failed to minify $FILE"
        rm -f "$tmp"
        exit 1
    fi
    mv "$tmp" "$FILE"
    echo "Minified $FILE successfully."
}

# 解析命令
case "$COMMAND" in
    format)
        if [ -z "$FILE" ]; then
            echo "Error: No file specified."
            exit 1
        fi
        json_format
        ;;
    minify)
        if [ -z "$FILE" ]; then
            echo "Error: No file specified."
            exit 1
        fi
        json_minify
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo "Error: Unknown command '$COMMAND'"
        show_help
        exit 1
        ;;
esac
