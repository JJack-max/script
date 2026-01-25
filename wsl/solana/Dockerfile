# -----------------------------
# 基础镜像
# -----------------------------
FROM ubuntu:24.04

# -----------------------------
# 版本定义
# -----------------------------
ENV DEBIAN_FRONTEND=noninteractive

# Go 相关版本
ENV GO_VERSION=1.23.2

# Java 相关版本
ENV JAVA_VERSION=21

# .NET 相关版本
ENV DOTNET_VERSION=8.0

# 路径环境变量
ENV CARGO_HOME=/root/.cargo
ENV SOLANA_HOME=/root/.local/share/solana/install/active_release
ENV PNPM_HOME=/root/.local/share/pnpm
ENV GO_HOME=/usr/local/go
ENV JAVA_HOME=/usr/lib/jvm/java-$JAVA_VERSION-openjdk-amd64
ENV DOTNET_HOME=/usr/share/dotnet

ENV PATH="$CARGO_HOME/bin:$SOLANA_HOME/bin:$PNPM_HOME:$GO_HOME/bin:$JAVA_HOME/bin:$DOTNET_HOME:$PATH"

RUN apt-get update && apt-get install -y \
    iputils-ping \
    net-tools \
    dnsutils \
    iproute2

RUN apt-get update && apt-get install -y curl ca-certificates tar gzip git && \
    rm -rf /var/lib/apt/lists/*

# Set SHELL environment variable explicitly for pnpm installer
ENV SHELL=/bin/bash
RUN curl -fsSL https://get.pnpm.io/install.sh | sh -

RUN pnpm env use --global 21

# -----------------------------
# 安装系统依赖 + openssh-server + 常用工具 + 开发环境
# -----------------------------
RUN apt-get update && apt-get install -y \
    # 基础系统工具
    curl git build-essential pkg-config libssl-dev libudev-dev python3 python3-pip unzip ca-certificates \
    openssh-server sudo software-properties-common gnupg wget \
    # 系统监控和诊断工具
    htop net-tools vim tmux jq tree lsof strace iproute2 less man figlet lolcat \
    # Node.js 依赖
    cmake \
    # Zsh shell
    zsh \
    && update-ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# -----------------------------
# 配置 SSH
# -----------------------------
RUN mkdir /var/run/sshd \
    && echo 'root:root' | chpasswd \
    && sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && sed -i 's@session\s*required\s*pam_loginuid.so@#session required pam_loginuid.so@g' /etc/pam.d/sshd

# -----------------------------
# 安装 Oh My Zsh + 插件
# -----------------------------
RUN export RUNZSH=no && export ZSH=~/.oh-my-zsh && \
    # 安装 Oh My Zsh
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended && \
    # 安装常用插件
    git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting && \
    git clone https://github.com/zsh-users/zsh-completions ~/.oh-my-zsh/custom/plugins/zsh-completions && \
    # 修改 ~/.zshrc 启用插件
    sed -i 's/^plugins=(git)$/plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-completions)/' ~/.zshrc && \
    # 设置 zsh 为默认 shell
    chsh -s $(which zsh)

# -----------------------------
# 使用Solana官方一键安装脚本
# -----------------------------
# RUN curl --proto '=https' --tlsv1.2 -sSfL https://solana-install.solana.workers.dev | bash
# -----------------------------
# 复制并执行本地Solana安装脚本 (转换行结束符)
# -----------------------------
COPY install.sh /tmp/install.sh
RUN sed -i 's/\r$//' /tmp/install.sh && chmod +x /tmp/install.sh && /tmp/install.sh

# Copy env.sh file
COPY env.sh /etc/profile.d/env.sh
RUN chmod +x /etc/profile.d/env.sh

# -----------------------------
# Install rust-analyzer
# -----------------------------
RUN rustup component add rust-analyzer || echo "rust-analyzer component not available, installing from crates.io"
RUN cargo install rust-analyzer || echo "rust-analyzer already installed or failed to install"

# -----------------------------
# Go
# -----------------------------
RUN curl -L https://go.dev/dl/go$GO_VERSION.linux-amd64.tar.gz -o go.tar.gz \
    && tar -C /usr/local -xzf go.tar.gz \
    && rm go.tar.gz \
    && /usr/local/go/bin/go version

# -----------------------------
# OpenJDK + Maven
# -----------------------------
RUN apt-get update && apt-get install -y openjdk-$JAVA_VERSION-jdk maven \
    && java -version && mvn -version

# -----------------------------
# .NET SDK
# -----------------------------
RUN wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb \
    && dpkg -i packages-microsoft-prod.deb \
    && rm packages-microsoft-prod.deb \
    && apt-get update && apt-get install -y dotnet-sdk-$DOTNET_VERSION \
    && dotnet --version

# -----------------------------
# 设置环境变量
# -----------------------------
RUN cat <<'EOF' >> ~/.zshrc
[[ -f /etc/profile.d/env.sh ]] && source /etc/profile.d/env.sh
EOF

RUN cat <<'EOF' >> ~/.bashrc
[[ -f /etc/profile.d/env.sh ]] && source /etc/profile.d/env.sh
EOF

# Docker 容器全局生效
ENV CARGO_HOME=/root/.cargo
ENV SOLANA_HOME=/root/.local/share/solana/install/active_release
ENV PNPM_HOME=/root/.local/share/pnpm
ENV GO_HOME=/usr/local/go
ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
ENV DOTNET_HOME=/usr/share/dotnet
ENV PATH=$CARGO_HOME/bin:$SOLANA_HOME/bin:$PNPM_HOME:$GO_HOME/bin:$JAVA_HOME/bin:$DOTNET_HOME:$PATH

# -----------------------------
# 创建工作目录
# -----------------------------
WORKDIR /workspace

# -----------------------------
# 持久化依赖缓存
# -----------------------------
VOLUME ["/root/.cargo", "/root/.rustup", "/root/.local/share/pnpm", "/root/.m2", "/root/.nuget", "/root/.solana"]

# -----------------------------
# 暴露端口（Solana + Next.js + SSH）
# -----------------------------
EXPOSE 8899 8900 3000 22

# -----------------------------
# 启动 SSH 并保持 Zsh 交互
# -----------------------------
CMD ["/bin/zsh", "-c", "source /etc/profile && /usr/sbin/sshd && exec /bin/zsh"]