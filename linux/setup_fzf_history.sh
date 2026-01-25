#!/bin/bash

echo "🚀 安装 zsh + fzf + autosuggestions，实现命令历史自动提示..."

# 安装基本工具
sudo apt update && sudo apt install -y zsh git fzf

# 安装 oh-my-zsh（非交互）
export RUNZSH=no
export CHSH=no
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# 设置 zsh 为默认 shell
chsh -s $(which zsh)

# 安装 autosuggestions 插件
ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"

# 配置 .zshrc
sed -i 's/^plugins=(.*)/plugins=(git zsh-autosuggestions)/' ~/.zshrc

# 启用 fzf 补全（Ctrl+R）
echo "
# Enable fuzzy history search with fzf
if [[ \$- == *i* ]]; then
  bindkey '^R' fzf-history-widget
  fzf-history-widget() {
    local selected=\$(history 1 | tac | fzf --no-sort --tac --reverse --height=10% | sed 's/^[ 0-9]*//')
    if [[ -n \$selected ]]; then
      LBUFFER=\$selected
    fi
    zle reset-prompt
  }
  zle -N fzf-history-widget
fi
" >> ~/.zshrc

# 自动提示颜色增强
echo "ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=240'" >> ~/.zshrc

# 加载配置
echo "✅ 配置完成，请重启终端或执行：exec zsh"
