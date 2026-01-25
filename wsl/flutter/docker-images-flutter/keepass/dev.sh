#!/bin/bash


echo "🚀 启动Flutter Web调试服务..."

# 检查是否在Docker容器中运行
if [ -f /.dockerenv ]; then
    echo "🔧 在Docker容器中运行"
    
    # 启用Web支持（如果尚未启用）
    echo "🌐 启用Flutter Web支持..."
    flutter config --enable-web
    
    # 获取依赖
    echo "📦 获取项目依赖..."
    flutter pub get
    
    # 启动Web服务器，绑定到所有网络接口以便从宿主机访问
    echo "🏃 启动Flutter Web服务器..."
    echo "💡 服务启动后，请在宿主机浏览器中访问 http://localhost:8080"
    flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080
    
else
    echo "❌ 此脚本应在Docker容器内运行"
    echo "💡 请在Docker容器中执行此脚本"
    exit 1
fi