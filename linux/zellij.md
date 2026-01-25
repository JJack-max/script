# Zellij 操作手册

Zellij 是一个功能强大的终端多路复用器，支持面板分割、会话管理、自定义快捷键和插件扩展。适用于 Linux、macOS 及部分 Windows 环境。

---

## 目录

1. [安装](#安装)
2. [快速开始](#快速开始)
3. [基本操作与快捷键](#基本操作与快捷键)
4. [会话与面板管理](#会话与面板管理)
5. [配置与自定义](#配置与自定义)
6. [进阶用法](#进阶用法)
7. [常见问题与解决方案](#常见问题与解决方案)
8. [参考链接](#参考链接)

---

## 安装

### 1. 使用包管理器

- **Debian/Ubuntu**:
  ```bash
  sudo apt update && sudo apt install zellij
  ```
- **Arch Linux**:
  ```bash
  sudo pacman -S zellij
  ```
- **macOS (Homebrew)**:
  ```bash
  brew install zellij
  ```
- **Windows (scoop)**:
  ```powershell
  scoop install zellij
  ```

### 2. 使用 Cargo 安装（需 Rust 环境）

```bash
cargo install --locked zellij
```

### 3. 下载预编译二进制包

前往 [Zellij Releases](https://github.com/zellij-org/zellij/releases) 下载适合平台的压缩包，解压后将 `zellij` 可执行文件放入 `$PATH`。

---

## 快速开始

1. 启动 Zellij：
   ```bash
   zellij
   ```
2. 退出 Zellij：
   - 按 `Ctrl + q`，再按 `q` 确认退出。

---

## 基本操作与快捷键

> 默认前缀键为 `Ctrl + g`（可自定义）。

| 操作               | 快捷键             |
| ------------------ | ------------------ |
| 打开新面板（水平） | `Ctrl + g`，`h`    |
| 打开新面板（垂直） | `Ctrl + g`，`v`    |
| 关闭当前面板       | `Ctrl + g`，`x`    |
| 在面板间切换       | `Ctrl + g`，方向键 |
| 打开新 Tab         | `Ctrl + g`，`t`    |
| 在 Tab 间切换      | `Ctrl + g`，`Tab`  |
| 重命名 Tab         | `Ctrl + g`，`r`    |
| 分离会话           | `Ctrl + g`，`d`    |
| 重新连接会话       | `zellij attach`    |
| 显示帮助           | `Ctrl + g`，`?`    |
| 复制模式           | `Ctrl + g`，`y`    |
| 粘贴               | `Ctrl + g`，`p`    |
| 锁定界面           | `Ctrl + g`，`l`    |
| 退出 Zellij        | `Ctrl + q`，`q`    |

---

## 会话与面板管理

### 1. 会话管理

- 新建会话：
  ```bash
  zellij --session <session_name>
  ```
- 列出会话：
  ```bash
  zellij list-sessions
  ```
- 连接会话：
  ```bash
  zellij attach <session_name>
  ```
- 杀死会话：
  ```bash
  zellij kill-session <session_name>
  ```

### 2. 面板与 Tab 管理

- 新建面板：`Ctrl + g`，`h` 或 `v`
- 关闭面板：`Ctrl + g`，`x`
- 新建 Tab：`Ctrl + g`，`t`
- 切换 Tab：`Ctrl + g`，`Tab`
- 重命名 Tab：`Ctrl + g`，`r`

---

## 配置与自定义

Zellij 的配置文件为 `config.kdl`，默认路径：

- Linux/macOS: `~/.config/zellij/config.kdl`
- Windows: `%APPDATA%\zellij\config.kdl`

### 1. 修改前缀键

```kdl
keybinds {
  normal {
    bind "Ctrl + a" {
      action "SwitchToMode:locked"
    }
  }
}
```

### 2. 自定义快捷键

参考官方文档：[https://zellij.dev/documentation/keybinds.html](https://zellij.dev/documentation/keybinds.html)

### 3. 插件与主题

- 插件目录：`~/.config/zellij/plugins/`
- 主题配置：`themes` 字段，可自定义配色方案

---

## 进阶用法

### 1. 启动时运行命令

```bash
zellij -- run -- bash -c "htop"
```

### 2. 多人协作（实验性）

```bash
zellij options --attach-to-session <session_name>
```

### 3. 脚本化与自动化

可结合 shell 脚本批量创建面板、Tab。

### 4. 嵌套使用

Zellij 支持嵌套运行，但建议关闭部分快捷键避免冲突。

---

## 常见问题与解决方案

1. **快捷键冲突**：可通过自定义 `config.kdl` 修改前缀键。
2. **中文乱码**：确保终端字体支持中文，或调整终端编码为 UTF-8。
3. **无法复制粘贴**：部分终端需开启鼠标支持或使用复制模式。
4. **配置不生效**：检查配置文件路径及语法。

---

## 参考链接

- 官方文档：https://zellij.dev/
- GitHub：https://github.com/zellij-org/zellij
- 配置示例：https://zellij.dev/documentation/configuration.html
- 快捷键说明：https://zellij.dev/documentation/keybinds.html
- 插件开发：https://zellij.dev/documentation/plugins.html
