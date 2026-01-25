#Requires -Version 5.1

# 获取所有rclone远程（云盘）
$Remotes = & rclone listremotes | ForEach-Object { $_.TrimEnd(":") }

if ($Remotes.Count -eq 0) {
    Write-Host "未找到rclone远程，请先运行 'rclone config' 添加远程。"
    exit
}

foreach ($remote in $Remotes) {
    Write-Host "==============================="
    Write-Host "云盘: $remote"
    Write-Host "-------------------------------"
    # 列出云盘根目录下所有文件和文件夹
    $files = & rclone ls "${remote}:" 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "无法列出 $remote 的文件，错误信息:"
        Write-Host $files
    } elseif ([string]::IsNullOrWhiteSpace($files)) {
        Write-Host "(空目录)"
    } else {
        $files -split "`n" | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "" } | ForEach-Object { Write-Host $_ }
    }
    Write-Host "==============================="
    Write-Host ""
}
