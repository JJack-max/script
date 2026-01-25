#!/usr/bin/env bash
# install-zsh.sh
# 安装 Zsh + Oh My Zsh + 常用插件
set -e

echo "🔹 更新软件源..."
sudo apt update -y

echo "🔹 安装 Zsh..."
sudo apt install -y zsh git curl

echo "🔹 设置 Zsh 为默认 shell..."
chsh -s $(which zsh)

echo "🔹 安装 Oh My Zsh..."
export RUNZSH=no  # 不立即进入 zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

echo "🔹 安装常用插件..."
ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}

# 自动建议插件
git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions

# 语法高亮插件
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting

# 补全增强插件
git clone https://github.com/zsh-users/zsh-completions $ZSH_CUSTOM/plugins/zsh-completions

echo "🔹 修改 ~/.zshrc 启用插件..."
sed -i 's/^plugins=(git)$/plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-completions)/' ~/.zshrc

echo "✅ 安装完成！"
echo "➡️ 请重新登录或执行：zsh"
