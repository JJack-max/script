# 使用官方 Python 镜像（Debian 12 基础）
FROM python:3.11-slim

# 环境变量（让 Chrome 无需沙箱运行，防止 /dev/shm 爆满）
ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    CHROME_BIN=/usr/bin/google-chrome \
    CHROMEDRIVER_PATH=/usr/bin/chromedriver

# 安装系统依赖 + Google Chrome 稳定版 + 常用字体
RUN apt-get update && apt-get install -y wget gnupg curl unzip fonts-noto-cjk ca-certificates && \
    mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /etc/apt/keyrings/google-chrome.gpg && \
    echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" \
        > /etc/apt/sources.list.d/google-chrome.list && \
    apt-get update && apt-get install -y google-chrome-stable && \
    rm -rf /var/lib/apt/lists/*

# 安装 Python 依赖（提前复制 requirements.txt，避免重建）
COPY requirements.txt /app/requirements.txt
WORKDIR /app
RUN pip install --upgrade pip && pip install -r requirements.txt