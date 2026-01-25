FROM cirrusci/flutter:2.12.0-4.1.pre


# 安装 openssh-server 和 sudo
RUN apt-get update && apt-get install -y \
    openssh-server \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# 创建 SSH 目录
RUN mkdir /var/run/sshd

# 设置 root 密码
RUN echo 'root:flutter123' | chpasswd

# 允许 root 密码登录
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/UsePAM yes/UsePAM no/' /etc/ssh/sshd_config

EXPOSE 22

# ====== 从 ENV 自动生成 /etc/profile.d/flutter.sh ======
RUN mkdir -p /etc/profile.d \
    && echo '#!/bin/bash' > /etc/profile.d/flutter.sh \
    && echo '# 自动加载 Docker ENV 环境变量' >> /etc/profile.d/flutter.sh \
    && echo '# This script is auto-generated from Docker ENV variables' >> /etc/profile.d/flutter.sh \
    && /bin/bash -c 'for var in PATH ANDROID_HOME JAVA_HOME FLUTTER_HOME FLUTTER_ROOT; do \
    if [ ! -z "${!var}" ]; then \
    echo "export $var=${!var}" >> /etc/profile.d/flutter.sh; \
    fi; \
    done' \
    && chmod +x /etc/profile.d/flutter.sh

# 启动 SSH 服务并保持容器运行
CMD ["/bin/bash", "-c", "service ssh start && sleep infinity"]
