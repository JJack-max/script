# rsync 操作手册

## 简介

rsync 是一个高效的文件同步和传输工具，常用于本地与远程主机之间的数据备份、镜像和增量同步。支持 SSH、RSH 等多种协议，具备断点续传、压缩、排除等强大功能。

官网：[https://rsync.samba.org/](https://rsync.samba.org/)

---

## 安装

### Linux (大多数发行版自带)

```bash
sudo apt update && sudo apt install rsync   # Debian/Ubuntu
sudo yum install rsync                      # CentOS/RHEL
```

### macOS

```bash
brew install rsync
```

### Windows

- 推荐使用 [cwRsync](https://www.itefix.net/cwrsync) 或通过 WSL 安装：

```bash
wsl sudo apt install rsync
```

---

## 基本用法

```bash
rsync [选项] 源路径 目标路径
```

- 本地同步：`rsync -avh /src/ /dst/`
- 远程同步：`rsync -avh /src/ user@remote:/dst/`
- 从远程拉取：`rsync -avh user@remote:/src/ /dst/`

---

## 常用参数说明

- `-a` 归档模式，保留权限、时间戳等（常用）
- `-v` 显示详细过程
- `-h` 友好显示文件大小
- `-z` 传输时压缩
- `-P` 显示进度并支持断点续传
- `--delete` 目标中删除源已不存在的文件
- `--exclude` 排除指定文件/目录
- `--include` 只包含指定文件/目录

---

## 常用命令

### 1. 本地目录同步

```bash
rsync -avh /home/user/docs/ /backup/docs/
```

### 2. 远程推送（本地到远程）

```bash
rsync -avzP /data/ user@192.168.1.10:/backup/data/
```

### 3. 远程拉取（远程到本地）

```bash
rsync -avzP user@192.168.1.10:/backup/data/ /data/
```

### 4. 仅同步新/更新文件

```bash
rsync -au /src/ /dst/
```

### 5. 删除目标多余文件

```bash
rsync -av --delete /src/ /dst/
```

### 6. 排除/包含文件

```bash
rsync -av --exclude "*.tmp" --include "*.jpg" /src/ /dst/
```

### 7. 端口指定（如 SSH 2222）

```bash
rsync -avz -e 'ssh -p 2222' /src/ user@host:/dst/
```

---

## 典型用例

### 1. 定时备份脚本

结合 crontab 定时执行：

```bash
0 2 * * * rsync -avz /data/ user@backup:/bak/data/
```

### 2. 镜像网站目录

```bash
rsync -avz --delete /var/www/ user@web:/var/www/
```

### 3. 断点续传大文件

```bash
rsync -avP /bigfile user@remote:/backup/
```

---

## 常见问题

- **Q: 如何只同步文件内容变更？**
  - A: rsync 默认只传输变更部分，且支持增量。
- **Q: 如何跳过部分文件？**
  - A: 用 `--exclude` 参数。
- **Q: 目标目录必须加斜杠吗？**
  - A: 结尾 `/` 表示目录内容，不加表示整个目录。
- **Q: 如何加速传输？**
  - A: 用 `-z` 压缩，`-P` 断点续传，或多线程（配合 GNU Parallel）。

---

## 参考资料

- [官方文档](https://download.samba.org/pub/rsync/rsync.html)
- [命令速查](https://www.runoob.com/linux/linux-comm-rsync.html)

---

# 1. 前提条件

- 你已经在本地生成了 SSH 密钥对（如 `~/.ssh/id_rsa` 和 `~/.ssh/id_rsa.pub`）。
- 目标服务器已将你的公钥（`id_rsa.pub`）添加到 `~/.ssh/authorized_keys`。
- 你可以用 `ssh user@remote` 免密登录目标服务器。

---

# 2. rsync 基本命令（密钥登录）

rsync 默认通过 SSH 传输数据，密钥登录无需特殊参数，只要 ssh 能免密登录即可。

**本地推送到远程：**

```bash
rsync -avzP /local/path/ user@remote:/remote/path/
```

**从远程拉取到本地：**

```bash
rsync -avzP user@remote:/remote/path/ /local/path/
```

---

# 3. 指定私钥文件（如不是默认 id_rsa）

如果你的密钥不是默认路径，可以用 `-e` 参数指定 ssh 命令：

```bash
rsync -avz -e "ssh -i /path/to/private_key" /local/path/ user@remote:/remote/path/
```

---

# 4. 指定端口（如 SSH 端口不是 22）

```bash
rsync -avz -e "ssh -p 2222" /local/path/ user@remote:/remote/path/
```

或同时指定密钥和端口：

```bash
rsync -avz -e "ssh -i /path/to/private_key -p 2222" /local/path/ user@remote:/remote/path/
```

---

# 5. 常见用法举例

**推送本地目录到远程服务器：**

```bash
rsync -avzP /data/ user@192.168.1.10:/backup/data/
```

**拉取远程目录到本地：**

```bash
rsync -avzP user@192.168.1.10:/backup/data/ /data/
```

**排除某些文件：**

```bash
rsync -avz --exclude "*.log" /data/ user@remote:/backup/
```

---

# 6. 常见问题

- **Q: rsync 连接时还是要密码？**  
  A: 请确认 ssh 免密登录已配置好（可先用 `ssh user@remote` 测试），并且密钥权限正确（`chmod 600 ~/.ssh/id_rsa`）。
- **Q: 如何自动化脚本？**  
  A: 配置好密钥后，rsync 可直接用于 crontab、脚本等自动化任务，无需人工输入密码。

---

# 7. 参考命令速查

| 场景           | 命令示例                                                          |
| -------------- | ----------------------------------------------------------------- |
| 推送本地到远程 | rsync -avzP /src/ user@remote:/dst/                               |
| 拉取远程到本地 | rsync -avzP user@remote:/src/ /dst/                               |
| 指定密钥和端口 | rsync -avz -e "ssh -i ~/.ssh/key -p 2222" /src/ user@remote:/dst/ |
| 排除文件       | rsync -avz --exclude "\*.tmp" /src/ user@remote:/dst/             |

---

如需具体脚本或遇到连接问题，请提供详细报错信息，我可以帮你排查！
