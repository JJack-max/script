# Windows PowerShell 多密钥免密登录指南

## 1. 前提条件
- Windows 10/11
- PowerShell 7 或系统自带 pwsh
- OpenSSH 客户端已安装（可用 `ssh -V` 检查）

## 2. 准备密钥
假设你的密钥文件：

```
C:\Users\<用户名>\.ssh\
  id_rsa_server1       (passphrase: abc)
  id_rsa_server2       (passphrase: 123)
  id_rsa_server3       (passphrase: xyz)
```

## 3. 配置 SSH 客户端

在 `C:\Users\<用户名>\.ssh\config` 文件中写入：

```text
Host server1
    HostName 192.168.1.101
    User jack
    IdentityFile C:\Users\<用户名>\.ssh\id_rsa_server1

Host server2
    HostName 192.168.1.102
    User jack
    IdentityFile C:\Users\<用户名>\.ssh\id_rsa_server2

Host server3
    HostName 192.168.1.103
    User jack
    IdentityFile C:\Users\<用户名>\.ssh\id_rsa_server3
```

## 4. 自动加载密钥的 PowerShell 脚本

保存为 `Load-SSHKeys.ps1`：

```powershell
# -------- 配置区 --------
$sshKeys = @(
    "$env:USERPROFILE\.ssh\id_rsa_server1",
    "$env:USERPROFILE\.ssh\id_rsa_server2",
    "$env:USERPROFILE\.ssh\id_rsa_server3"
)

# -------- 启动用户模式 ssh-agent --------
Write-Host "[*] 启动 ssh-agent..."
$agentProcess = Get-Process ssh-agent -ErrorAction SilentlyContinue
if (-not $agentProcess) {
    Start-Process "C:\Windows\System32\OpenSSH\ssh-agent.exe"
    Start-Sleep -Seconds 1
}

# -------- 添加密钥 --------
foreach ($key in $sshKeys) {
    if (Test-Path $key) {
        Write-Host "[*] 添加密钥：$key"
        ssh-add $key
    } else {
        Write-Warning "[!] 找不到密钥文件：$key"
    }
}

Write-Host "[*] 所有密钥已添加完毕。"
```

## 5. 使用方法

```powershell
.\Load-SSHKeys.ps1
ssh server1
ssh server2
ssh server3
```

## 6. 可选：开机自动加载

在 `$PROFILE` 中添加：

```powershell
& "C:\Users\<用户名>\Load-SSHKeys.ps1"
```

