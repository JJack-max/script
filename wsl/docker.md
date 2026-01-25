curl -fsSL https://get.docker.com -o get-docker.sh

sudo sh get-docker.sh

# 检查 Docker 版本
docker --version

# 添加当前用户到 docker 组（可选，避免每次使用 sudo）
sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker

# 登录到容器仓库
docker login

docker build -t my-image:latest .

# 给本地镜像打标签
docker tag my-image docker.io/username/my-image:latest

# 推送镜像到远程仓库
docker push docker.io/username/my-image:latest