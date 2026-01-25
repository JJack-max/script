# scp 操作手册

## 简介

scp（secure copy）是基于 SSH 协议的安全文件拷贝命令，常用于在本地与远程主机之间安全地传输文件和目录。

适用平台：Linux、macOS、Windows（通过 WSL、Git Bash、PuTTY 等）

---

## 安装

### Linux/macOS

大多数系统自带，无需单独安装。

### Windows

- 推荐使用 [Git Bash](https://gitforwindows.org/)、[WSL](https://docs.microsoft.com/zh-cn/windows/wsl/) 或 [PuTTY](https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html)（pscp）。
- 安装 Git Bash 后可直接在命令行使用 scp。

---

## 基本用法

```bash
scp [参数] 源路径 目标路径
```

- 本地到远程：`scp file.txt user@remote:/path/`
- 远程到本地：`scp user@remote:/path/file.txt ./`
- 目录递归：`scp -r dir/ user@remote:/path/`

---

## 常用参数说明

- `-r` 递归复制整个目录
- `-P` 指定远程主机端口（注意大写）
- `-p` 保留原文件属性（时间戳、权限等）
- `-C` 启用压缩
- `-v` 显示详细过程（调试用）

---

## 常用命令

### 1. 上传文件到远程主机

```bash
scp file.txt user@192.168.1.10:/home/user/
```

### 2. 下载远程文件到本地

```bash
scp user@192.168.1.10:/home/user/file.txt ./
```

### 3. 递归上传目录

```bash
scp -r mydir/ user@192.168.1.10:/home/user/
```

### 4. 指定端口

```bash
scp -P 2222 file.txt user@192.168.1.10:/home/user/
```

### 5. 多文件传输

```bash
scp file1.txt file2.txt user@remote:/path/
```

### 6. 从远程拉取整个目录

```bash
scp -r user@192.168.1.10:/home/user/mydir/ ./
```

---

## 典型用例

### 1. 结合密钥免密登录

先用 ssh-copy-id 配置好公钥，再用 scp 传输无需输入密码。

### 2. 跨跳板机传输

```bash
scp -o ProxyJump=jumpuser@jump.host file.txt user@target:/path/
```

### 3. 限速传输

```bash
scp -l 8192 file.txt user@remote:/path/   # 限速 8Mbps
```

---

## 常见问题

- **Q: 连接超时/拒绝？**
  - A: 检查网络、端口、防火墙、SSH 服务是否开启。
- **Q: 权限不足？**
  - A: 检查目标目录权限，或用 sudo。
- **Q: 目录结尾斜杠有区别吗？**
  - A: 有，带 `/` 表示目录内容，不带表示整个目录。
- **Q: 如何跳过已存在文件？**
  - A: scp 不支持断点续传，建议用 rsync。

---

## 参考资料

- [官方手册](https://man.openbsd.org/scp)
- [scp 命令详解](https://www.runoob.com/linux/linux-comm-scp.html)
