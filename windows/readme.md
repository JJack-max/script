# cursor 将 terminal 默认设置为 pwsh

## pwsh 安装方式：scoop insatll pwsh

### 1. 打开 VS Code 的设置（settings.json）：

```
Ctrl + Shift + P → 输入并选择 Preferences: Open Settings (JSON)
```

---

### 2. 添加或修改以下内容（适用于 Windows，Linux/macOS 在下面补充）：

```
  "terminal.integrated.defaultProfile.windows": "PowerShell 7",
  "terminal.integrated.profiles.windows": {
    "PowerShell 7": {
      "path": "C:\\Users\\Bob\\scoop\\apps\\pwsh\7.5.2\\pwsh.exe",
      "args": []
    }
  }
```

---

### 3. 重启 cursor
