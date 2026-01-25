#Requires -Version 5.1
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$ConfigFile = Join-Path $PSScriptRoot 'sync_his.json'

function Select-FolderDialog {
    $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $dialog.ShowNewFolderButton = $true
    $dialog.Description = '请选择要同步的本地文件夹'
    if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        return $dialog.SelectedPath
    }
    return $null
}

# 读取历史目录
if (Test-Path $ConfigFile) {
    $LocalPaths = @(Get-Content $ConfigFile -Raw | ConvertFrom-Json)
} else {
    $LocalPaths = @()
}

# 展示历史目录
Write-Host "可用本地目录："
for ($i = 0; $i -lt $LocalPaths.Count; $i++) {
    Write-Host "$($i + 1) - $($LocalPaths[$i])"
}
$lastOption = $LocalPaths.Count + 1
Write-Host "$lastOption - 选择新目录"

# 选择目录
$localInputText = Read-Host "输入要同步的本地目录编号（可用空格分隔多选，直接回车为全部，最后一个选项为新目录）:"
$SelectedLocalPaths = @()
$needAddNew = $false
if ([string]::IsNullOrWhiteSpace($localInputText)) {
    $SelectedLocalPaths = $LocalPaths
} else {
    foreach ($num in $localInputText -split '\s+') {
        if ($num -match '^-?\d+$') {
            $index = [int]$num - 1
            if ($index -ge 0 -and $index -lt $LocalPaths.Count) {
                $SelectedLocalPaths += $LocalPaths[$index]
            } elseif ($index -eq $LocalPaths.Count) {
                $needAddNew = $true
            } else {
                Write-Host "Note: $num 不是有效目录编号，已跳过。"
            }
        }
    }
}

# 新增目录
if ($needAddNew -or $LocalPaths.Count -eq 0) {
    $newPath = Select-FolderDialog
    if ($newPath) {
        if (-not ($LocalPaths -contains $newPath)) {
            $LocalPaths += $newPath
            $LocalPaths | ConvertTo-Json | Set-Content $ConfigFile
        }
        $SelectedLocalPaths += $newPath
    } else {
        Write-Host "未选择新目录，操作取消。"
        exit
    }
}

if ($SelectedLocalPaths.Count -eq 0) {
    Write-Host "未选择任何目录，脚本退出。"
    exit
}

# 获取rclone remotes
$Remotes = & rclone listremotes | ForEach-Object { $_.TrimEnd(":") }
if ($Remotes.Count -eq 0) {
    Write-Host "未找到rclone远程，请先运行 'rclone config' 添加远程。"
    exit
}

Write-Host "可用rclone远程："
for ($i = 0; $i -lt $Remotes.Count; $i++) {
    Write-Host "$($i + 1) - $($Remotes[$i])"
}
$inputText = Read-Host "输入要同步和校验的远程编号（可用空格分隔多选，直接回车为全部）："
if ([string]::IsNullOrWhiteSpace($inputText)) {
    $Selected = $Remotes
} else {
    $Selected = @()
    foreach ($num in $inputText -split '\s+') {
        if ($num -match '^\d+$') {
            $index = [int]$num - 1
            if ($index -ge 0 -and $index -lt $Remotes.Count) {
                $Selected += $Remotes[$index]
            } else {
                Write-Host "Note: $num 不是有效远程编号，已跳过。"
            }
        }
    }
}

foreach ($localPath in $SelectedLocalPaths) {
    $dirName = [System.IO.Path]::GetFileName($localPath)
    foreach ($remote in $Selected) {
        Write-Host "--------------------------------------------"
        Write-Host "Syncing $localPath to $remote/$dirName ..."
        & rclone sync $localPath ("$remote`:$dirName") --progress

        Write-Host "Verifying $localPath with $remote/$dirName ..."
        & rclone check $localPath ("$remote`:$dirName")

        Write-Host "Sync and verification complete for $localPath <-> $remote/$dirName."
    }
}

Write-Host "All sync and verification tasks are complete."
