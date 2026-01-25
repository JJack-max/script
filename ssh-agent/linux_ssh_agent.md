# Linux 多密钥免密登录指南

## 1. 前提条件
- Linux 系统（Ubuntu/Debian/CentOS 等）
- 已安装 OpenSSH 客户端

## 2. 生成 SSH 密钥（如果还没有）

```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```

- 可为每台服务器生成不同密钥：
```bash
ssh-keygen -t ed25519 -f ~/.ssh/id_rsa_server1
ssh-keygen -t ed25519 -f ~/.ssh/id_rsa_server2
ssh-keygen -t ed25519 -f ~/.ssh/id_rsa_server3
```

## 3. 上传公钥到服务器

```bash
ssh-copy-id -i ~/.ssh/id_rsa_server1.pub user@server1
ssh-copy-id -i ~/.ssh/id_rsa_server2.pub user@server2
ssh-copy-id -i ~/.ssh/id_rsa_server3.pub user@server3
```

## 4. 配置 SSH 客户端

编辑 `~/.ssh/config`：

```text
Host server1
    HostName 192.168.1.101
    User jack
    IdentityFile ~/.ssh/id_rsa_server1

Host server2
    HostName 192.168.1.102
    User jack
    IdentityFile ~/.ssh/id_rsa_server2

Host server3
    HostName 192.168.1.103
    User jack
    IdentityFile ~/.ssh/id_rsa_server3
```

## 5. 使用 ssh-agent 缓存密钥

```bash
# 启动 agent
eval "$(ssh-agent -s)"

# 添加密钥
ssh-add ~/.ssh/id_rsa_server1
ssh-add ~/.ssh/id_rsa_server2
ssh-add ~/.ssh/id_rsa_server3
```

- 系统会提示输入每个密钥的 passphrase（只需一次）  
- 后续登录无需再输入密码：

```bash
ssh server1
ssh server2
ssh server3
```

## 6. 可选：开机自动加载

在 `~/.bashrc` 或 `~/.zshrc` 添加：

```bash
# 自动启动 agent 并加载密钥
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa_server1
ssh-add ~/.ssh/id_rsa_server2
ssh-add ~/.ssh/id_rsa_server3
```
