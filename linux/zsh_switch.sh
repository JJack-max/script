#!/usr/bin/env bash
# fix_wsl_shell.sh
# 自动检测并修复 WSL 因 zsh 被卸载导致的启动错误问题
# 适用于 Ubuntu / Debian / 其他 WSL 发行版

set -e

echo "🔍 检测当前用户默认 shell 配置..."

# 当前用户名
USER_NAME=$(whoami)

# 在 /etc/passwd 中获取用户的 shell 配置
USER_SHELL=$(grep "^${USER_NAME}:" /etc/passwd | awk -F: '{print $7}')

# 输出当前配置
echo "👤 用户: $USER_NAME"
echo "🧩 当前 shell: $USER_SHELL"

# 检测是否为 zsh 或不存在的路径
if [[ "$USER_SHELL" == *"zsh"* ]] || [[ ! -f "$USER_SHELL" ]]; then
    echo "⚠️ 检测到无效 shell (${USER_SHELL})，将自动修复为 /bin/bash ..."
    sudo sed -i "s|^${USER_NAME}:.*:${USER_SHELL}$|${USER_NAME}:x:$(id -u):$(id -g):,,,:/home/${USER_NAME}:/bin/bash|" /etc/passwd
    echo "✅ 已修复为 /bin/bash"
else
    echo "✅ Shell 设置正常，无需修复。"
fi

echo "🔁 请执行以下命令以应用更改："
echo "   wsl --shutdown"
echo "   wsl"
