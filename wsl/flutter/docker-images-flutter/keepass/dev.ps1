# ============================
# Flutter Device Selector Script
# ============================

adb start-server | Out-Null

# 获取所有设备
$devices = flutter devices --machine | ConvertFrom-Json

if (-not $devices) {
    Write-Host "❌ 未发现任何设备，请检查 ADB & 模拟器！" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "📱 可用设备列表：" -ForegroundColor Cyan
Write-Host "-------------------------------------"

for ($i = 0; $i -lt $devices.Count; $i++) {
    $name = $devices[$i].name
    $id = $devices[$i].id
    $platform = $devices[$i].targetPlatform
    Write-Host "[$i] $name — $platform — $id"
}

Write-Host ""
$choice = Read-Host "👉 请输入设备序号启动"

if ($choice -notmatch '^\d+$' -or $choice -ge $devices.Count) {
    Write-Host "❌ 输入错误，不存在该序号" -ForegroundColor Red
    exit 1
}

$selectedId = $devices[$choice].id
Write-Host ""
Write-Host "🚀 正在启动：$selectedId" -ForegroundColor Green
Write-Host ""

flutter run -d $selectedId
