#requires -Version 5.0

if ([System.Threading.Thread]::CurrentThread.ApartmentState -ne 'STA') {
    $pwsh = (Get-Command pwsh -ErrorAction SilentlyContinue)?.Source
    if (-not $pwsh) {
        $pwsh = (Get-Command powershell -ErrorAction SilentlyContinue)?.Source
    }
    if (-not $pwsh) {
        Write-Host "未找到 pwsh 或 powershell，请手动用 -STA 参数运行本脚本。"
        exit 1
    }
    Write-Host "正在以 STA 模式重启脚本..."
    & $pwsh -STA -File $MyInvocation.MyCommand.Definition
    exit
}

# Interactive algorithm selection
Write-Host "Please select key algorithm:"
Write-Host "1 - RSA"
$algChoice = Read-Host "Enter algorithm number (default 1)"
if ([string]::IsNullOrWhiteSpace($algChoice)) { $algChoice = '1' }

switch ($algChoice) {
    '1' { $alg = 'RSA' }
    default {
        Write-Host "Unsupported algorithm, defaulting to RSA" -ForegroundColor Yellow
        $alg = 'RSA'
    }
}

# Enter certificate name
$name = Read-Host "Enter certificate name (without extension)"
if ([string]::IsNullOrWhiteSpace($name)) {
    Write-Host "Certificate name cannot be empty!" -ForegroundColor Red
    exit 1
}

# File names
$keyFile = "$name.key"
$crtFile = "$name.crt"

# Generate key and certificate
if ($alg -eq 'RSA') {
    $openssl = "openssl"
    if (-not (Get-Command $openssl -ErrorAction SilentlyContinue)) {
        Write-Host "openssl not found. Please install openssl and add it to PATH." -ForegroundColor Red
        exit 1
    }
    Write-Host "Generating 2048-bit RSA private key..."
    & $openssl genrsa -out $keyFile 2048
    if ($LASTEXITCODE -ne 0) { Write-Host "Key generation failed!" -ForegroundColor Red; exit 1 }
    Write-Host "Generating self-signed certificate..."
    & $openssl req -new -x509 -key $keyFile -out $crtFile -days 3650 -subj "/CN=$name"
    if ($LASTEXITCODE -ne 0) { Write-Host "Certificate generation failed!" -ForegroundColor Red; exit 1 }
    Write-Host "Certificate and key generated:"
    Write-Host "  Certificate: $crtFile"
    Write-Host "  Private Key: $keyFile"
    # 打包为 zip 并让用户选择保存位置
    $zipFile = "$name.zip"
    if (Test-Path $zipFile) { Remove-Item $zipFile -Force }
    Compress-Archive -Path $crtFile, $keyFile -DestinationPath $zipFile

    Add-Type -AssemblyName System.Windows.Forms
    $dialog = New-Object System.Windows.Forms.SaveFileDialog
    $dialog.Filter = "ZIP 文件 (*.zip)|*.zip"
    $dialog.Title = "请选择保存 zip 文件的位置"
    $dialog.FileName = $zipFile

    if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $savePath = $dialog.FileName
        Copy-Item $zipFile $savePath -Force
        [System.Windows.Forms.MessageBox]::Show("zip 文件已保存到: $savePath", "保存成功", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        # 删除本地生成的crt、key、zip文件
        Remove-Item -Force $crtFile, $keyFile, $zipFile -ErrorAction SilentlyContinue
    } else {
        Write-Host "未选择保存位置，已取消。" -ForegroundColor Yellow
        # 也删除本地生成的crt、key、zip文件
        Remove-Item -Force $crtFile, $keyFile, $zipFile -ErrorAction SilentlyContinue
        exit 1
    }
} else {
    Write-Host "Algorithm not supported yet." -ForegroundColor Red
    exit 1
} 