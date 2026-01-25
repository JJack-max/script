#!/usr/bin/env bash
# uninstall-zsh.sh
# 卸载 Zsh 与所有相关文件
set -e

echo "🔹 切换回 bash..."
chsh -s /bin/bash || true
bash

echo "🔹 卸载 Zsh..."
sudo apt remove --purge zsh -y || true
sudo apt autoremove -y || true

echo "🔹 删除用户配置..."
rm -rf ~/.zshrc ~/.zprofile ~/.zlogin ~/.zlogout ~/.zshenv \
       ~/.oh-my-zsh ~/.zcompdump* ~/.zprezto

echo "✅ Zsh 已彻底卸载并恢复为 Bash 环境。"
echo "当前 shell: $(echo $SHELL)"
