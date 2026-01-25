# rclone 操作手册

## 简介

rclone 是一个命令行程序，用于与多种云存储服务进行文件同步、上传、下载和管理。支持 Google Drive、OneDrive、Dropbox、阿里云 OSS、S3 等。

官网：[https://rclone.org/](https://rclone.org/)

---

## 安装

### Windows

1. 访问 [rclone 下载页面](https://rclone.org/downloads/)
2. 下载对应的 Windows 版本 zip 包
3. 解压后，将 `rclone.exe` 放入系统 PATH 目录
4. 在命令行输入 `rclone version` 验证安装

### Linux/macOS

```bash
curl https://rclone.org/install.sh | sudo bash
# 或手动下载解压
```

---

## 配置

### 初始化配置

```bash
rclone config
```

- 选择 `n` 新建 remote
- 输入名称（如 `mydrive`）
- 选择云服务类型（如 Google Drive 选 `13`）
- 按提示输入 client_id、client_secret（可留空）
- 授权登录（浏览器跳转）
- 完成后保存

### 查看配置

```bash
rclone config show
```

---

## 常用命令

### 列出远程存储内容

```bash
rclone ls mydrive:
```

### 同步本地与云端目录

```bash
# 本地同步到云端
rclone sync ./local/dir mydrive:backup/dir
# 云端同步到本地
rclone sync mydrive:backup/dir ./local/dir
```

### 上传/下载文件

```bash
# 上传
rclone copy ./file.txt mydrive:docs/
# 下载
rclone copy mydrive:docs/file.txt ./
```

### 挂载云盘（需 WinFsp/FUSE）

```bash
rclone mount mydrive: X:
# Linux: rclone mount mydrive: /mnt/mydrive
```

### 检查差异

```bash
rclone check ./local/dir mydrive:backup/dir
```

---

## 典型用例

### 1. 定时备份

结合计划任务（Windows 任务计划、Linux crontab）定时执行 `rclone sync`。

### 2. 多线程加速

```bash
rclone copy ./dir mydrive:backup --transfers=8 --checkers=16 --progress
```

### 3. 过滤文件

```bash
rclone sync ./dir mydrive:backup --exclude "*.tmp" --include "*.jpg"
```

---

## 常见问题

- **Q: 如何跳过已存在文件？**
  - A: 使用 `--ignore-existing` 参数。
- **Q: 如何查看详细日志？**
  - A: 增加 `-v` 或 `-P` 参数。
- **Q: 授权失败怎么办？**
  - A: 删除 remote 重新 `rclone config`，或检查网络代理。

---

## 参考资料

- [官方文档](https://rclone.org/docs/)
- [命令速查](https://rclone.org/commands/)
