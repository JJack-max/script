#!/usr/bin/env bash
# install-zsh.sh
# Idempotent installer (macOS)

set -e

# ---------- basic tools ----------
command -v brew >/dev/null 2>&1 || {
  echo "Homebrew required"
  exit 1
}

brew install git curl zsh

# ---------- switch shell ----------
BREW_ZSH="$(brew --prefix)/bin/zsh"
if [ "$SHELL" != "$BREW_ZSH" ]; then
  grep -q "$BREW_ZSH" /etc/shells || sudo sh -c "echo $BREW_ZSH >> /etc/shells"
  chsh -s "$BREW_ZSH"
fi

# ---------- install oh-my-zsh ----------
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  export RUNZSH=no
  export KEEP_ZSHRC=yes
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# ---------- plugins ----------
ZSH_CUSTOM="$HOME/.oh-my-zsh/custom/plugins"
mkdir -p "$ZSH_CUSTOM"

for repo in \
  zsh-users/zsh-autosuggestions \
  zsh-users/zsh-syntax-highlighting \
  zsh-users/zsh-completions
do
  name="${repo##*/}"
  [ -d "$ZSH_CUSTOM/$name" ] || \
    git clone "https://github.com/$repo" "$ZSH_CUSTOM/$name"
done

# ---------- managed config ----------
mkdir -p "$HOME/.zshrc.d"

cat > "$HOME/.zshrc.d/ohmyzsh.zsh" <<'EOF'
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"

plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-completions
)

source "$ZSH/oh-my-zsh.sh"

# zsh-completions
fpath+=${ZSH_CUSTOM:-$ZSH/custom}/plugins/zsh-completions/src
autoload -Uz compinit && compinit
EOF

echo
echo "======================================"
echo "✅ Zsh / Oh My Zsh 安装完成"
echo
echo "⚠️ 当前 shell 尚未重新加载配置"
echo "👉 请执行以下命令使配置生效："
echo
echo "    exec zsh"
echo
echo "或者：关闭当前终端，重新打开一个窗口"
echo "======================================"