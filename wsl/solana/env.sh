#!/bin/bash

# Permanent environment variables
export CARGO_HOME=/root/.cargo
export SOLANA_HOME=/root/.local/share/solana/install/active_release
export PNPM_HOME=/root/.local/share/pnpm
export GO_HOME=/usr/local/go
export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
export DOTNET_HOME=/usr/share/dotnet
export PATH=$CARGO_HOME/bin:$SOLANA_HOME/bin:$PNPM_HOME:$GO_HOME/bin:$JAVA_HOME/bin:$DOTNET_HOME:$PATH

# Colorful Banner
figlet "Dev Container" | lolcat
echo -e "\n🌟 Welcome to your Ultimate Dev Container 🌟\n----------------------------------------\n🦀 Rust: cargo & rust-analyzer\n🪂 Solana CLI & Anchor CLI\n🐹 Go ${GO_VERSION}\n🟢 Node.js + npm + pnpm\n🍵 OpenJDK ${JAVA_VERSION} + Maven\n💡 .NET SDK ${DOTNET_VERSION}\n🐚 Zsh + Oh My Zsh with plugins\n🖥️ Next.js + Solana frontend example\n쉘 Linux utils: vim, tmux, htop, jq, tree, lsof, strace\n----------------------------------------\n🚀 Happy Hacking! 🚀\n"