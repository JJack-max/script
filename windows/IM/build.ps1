param(
    [switch]$Debug  # 调试模式开关
)

Write-Host "=== Nuitka 发布版构建脚本 ===" -ForegroundColor Cyan

# 强制使用 scoop 安装的 Python
$PythonPath = Join-Path $env:USERPROFILE "scoop\apps\python\current\python.exe"

if (-not (Test-Path $PythonPath)) {
    Write-Host "✗ 未找到 Scoop 安装的 Python: $PythonPath" -ForegroundColor Red
    Write-Host "  请先执行: scoop install python" -ForegroundColor Yellow
    exit 1
} else {
    Write-Host "✓ 检测到 Python: $PythonPath" -ForegroundColor Green
    & $PythonPath --version
}

# 升级 pip
Write-Host "升级 pip ..." -ForegroundColor Cyan
& $PythonPath -m pip install --upgrade pip setuptools wheel

# 配置
$AppName    = "wechat"
$SourceFile = "wechat.py"
$OutputDir  = "dist"
$Mode       = "onefile"   # 可选: "standalone"

# 必要依赖列表（已去掉 zbar/pyzbar）
$Dependencies = @(
    "nuitka",
    "qrcode[pil]",
    "opencv-python",
    "cryptography"
)

# 检查并安装依赖
foreach ($pkg in $Dependencies) {
    Write-Host "检查依赖: $pkg ..." -ForegroundColor Cyan
    & $PythonPath -m pip show $pkg > $null 2>&1
    if ($LASTEXITCODE -eq 0) {
        if ($pkg -eq "nuitka") {
            Write-Host "✓ 已安装: $pkg，正在升级 ..." -ForegroundColor Yellow
            & $PythonPath -m pip install --upgrade nuitka
        } else {
            Write-Host "✓ 依赖已安装: $pkg" -ForegroundColor Green
        }
    } else {
        Write-Host "正在安装: $pkg ..." -ForegroundColor Yellow
        & $PythonPath -m pip install $pkg
    }
}

# 创建输出目录
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir | Out-Null
}

# 构建参数
$Args = @("--standalone", "--output-dir=$OutputDir")

# onefile 模式
if ($Mode -eq "onefile") {
    $Args += "--onefile"
}

# 根据 Debug 开关决定是否启用控制台（新版写法）
if (-not $Debug) {
    $Args += "--windows-console-mode=disable"
    Write-Host "⚙️  运行在发布模式（无控制台）" -ForegroundColor Green
} else {
    $Args += "--windows-console-mode=enable"
    Write-Host "🐞  运行在调试模式（带控制台）" -ForegroundColor Yellow
}

# 额外包含包，避免依赖丢失
$Args += @(
    "--include-package=cryptography",
    "--include-package=cv2",
    "--include-package=qrcode",
    "--enable-plugin=tk-inter"   # ✅ Tkinter 插件
)

# 开始构建
Write-Host "开始构建 ($Mode 模式) ..." -ForegroundColor Green
& $PythonPath -m nuitka @Args $SourceFile

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ 构建成功！" -ForegroundColor Green
    Get-ChildItem $OutputDir | ForEach-Object {
        Write-Host "输出文件: $($_.Name)" -ForegroundColor Cyan
    }
} else {
    Write-Host "✗ 构建失败！" -ForegroundColor Red
}
