<#
.SYNOPSIS
    SSH密钥加载工具 - 带文件选择对话框

.DESCRIPTION
    这个脚本将启动 ssh-agent 服务并加载SSH密钥。
    特色功能：
    - 图形化文件选择对话框
    - 支持多选密钥文件
    - 智能默认路径检测
    - 详细的加载状态反馈
    - 显示当前SSH Agent中的所有密钥

.EXAMPLE
    .\Load-SSHKeys.ps1
    运行脚本，将弹出文件选择对话框

.NOTES
    需要 OpenSSH 客户端支持
    支持 Windows 10/11 与 PowerShell 5.1+
#>

# -------- 函数：显示文件选择对话框 --------
function Select-SSHKeyFiles {
    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
    
    $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $openFileDialog.InitialDirectory = "$env:USERPROFILE\.ssh"
    $openFileDialog.Filter = "SSH Private Keys (id_rsa;id_ecdsa;id_ed25519;*_rsa;*_ecdsa;*_ed25519)|id_rsa;id_ecdsa;id_ed25519;*_rsa;*_ecdsa;*_ed25519|All Files (*.*)|*.*"
    $openFileDialog.FilterIndex = 1
    $openFileDialog.Multiselect = $true
    $openFileDialog.Title = "选择SSH密钥文件"
    $openFileDialog.ShowHelp = $false
    
    $result = $openFileDialog.ShowDialog()
    
    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
        return $openFileDialog.FileNames
    } else {
        return @()
    }
}

# -------- 配置区 --------
# 默认密钥路径（如果用户取消选择，将使用这些路径）
$defaultSshKeys = @(
    "$env:USERPROFILE\.ssh\id_rsa",
    "$env:USERPROFILE\.ssh\id_ecdsa", 
    "$env:USERPROFILE\.ssh\id_ed25519"
)

# 显示选择对话框
Write-Host "[*] 请选择要加载的SSH密钥文件..."
$selectedKeys = Select-SSHKeyFiles

if ($selectedKeys.Count -eq 0) {
    Write-Host "[*] 未选择文件，使用默认密钥路径"
    $sshKeys = $defaultSshKeys | Where-Object { Test-Path $_ }
    if ($sshKeys.Count -eq 0) {
        Write-Warning "[!] 未找到任何默认SSH密钥文件"
        Write-Host "[*] 默认查找位置: $env:USERPROFILE\.ssh\"
        Write-Host "[*] 支持的密钥文件名: id_rsa, id_ecdsa, id_ed25519"
        Read-Host "按任意键退出"
        exit
    }
} else {
    Write-Host "[*] 已选择 $($selectedKeys.Count) 个密钥文件"
    $sshKeys = $selectedKeys
}

# -------- 设置 ssh-agent 服务为自动启动并启动 --------
Write-Host "[*] 确保 ssh-agent 服务已设置为自动启动..."
$service = Get-Service ssh-agent -ErrorAction SilentlyContinue
if ($service -eq $null) {
    Write-Warning "[!] ssh-agent 服务未找到，请确保已安装 OpenSSH 客户端"
    exit
}

if ($service.StartType -ne "Automatic") {
    Set-Service ssh-agent -StartupType Automatic
    Write-Host "[*] ssh-agent 服务启动类型已改为自动"
}

if ($service.Status -ne "Running") {
    Start-Service ssh-agent
    Write-Host "[*] ssh-agent 服务已启动"
} else {
    Write-Host "[*] ssh-agent 服务已经在运行中"
}

# -------- 添加密钥 --------
$successCount = 0
$totalKeys = $sshKeys.Count

foreach ($key in $sshKeys) {
    if (Test-Path $key) {
        $existingKeys = ssh-add -l 2>$null
        $keyName = Split-Path $key -Leaf
        
        if ($existingKeys -notmatch [regex]::Escape((Get-Item $key).FullName)) {
            Write-Host "[*] 正在添加密钥：$keyName" -ForegroundColor Green
            $addResult = ssh-add $key 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Host "    ✓ 成功添加: $key" -ForegroundColor Green
                $successCount++
            } else {
                Write-Warning "    ✗ 添加失败: $key"
                Write-Host "    错误信息: $addResult" -ForegroundColor Red
            }
        } else {
            Write-Host "[*] 密钥已在 agent 中：$keyName" -ForegroundColor Yellow
            $successCount++
        }
    } else {
        Write-Warning "[!] 找不到密钥文件：$key"
    }
}

Write-Host "\n[*] 密钥加载完成：$successCount/$totalKeys 成功" -ForegroundColor Cyan

# 显示当前已加载的所有密钥
Write-Host "[*] 当前 SSH Agent 中的所有密钥：" -ForegroundColor Cyan
$allKeys = ssh-add -l 2>$null
if ($allKeys) {
    $allKeys | ForEach-Object {
        Write-Host "    $_" -ForegroundColor White
    }
} else {
    Write-Host "    (暂无密钥)" -ForegroundColor Gray
}

# 用户交互
Write-Host "\n" -NoNewline
Read-Host "按 Enter 键退出"
