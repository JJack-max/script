#!/usr/bin/env bash
# uninstall-zsh.sh
# Idempotent uninstaller (macOS)

set -e

# ---------- switch back ----------
[ "$SHELL" = "/bin/zsh" ] || chsh -s /bin/zsh

# ---------- remove managed parts ----------
rm -rf "$HOME/.oh-my-zsh"
rm -f "$HOME/.zshrc.d/ohmyzsh.zsh"
rm -f "$HOME/.zcompdump"*

echo
echo "👉 你可以稍后手动执行："
echo "    exec /bin/zsh"