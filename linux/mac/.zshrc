# ~/.zshrc
# Minimal, SAFE, idempotent (zsh-correct)

ZSHRC_D="$HOME/.zshrc.d"

if [ -d "$ZSHRC_D" ]; then
  for f in "$ZSHRC_D"/*.zsh(N); do
    source "$f"
  done
fi