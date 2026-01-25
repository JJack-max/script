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

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$stateFile = Join-Path $scriptDir 'merge_elastic_p12_his.json'
$crtPath = Join-Path $scriptDir 'elastic.crt'
$keyPath = Join-Path $scriptDir 'elastic.key'
$p12Path = Join-Path $scriptDir 'elastic.p12'

# 读取上次输入
$last = @{}
if (Test-Path $stateFile) {
    try {
        $last = Get-Content $stateFile | ConvertFrom-Json
    } catch {}
}

function Read-Multiline-End($prompt, $default) {
    Write-Host "$prompt (多行输入，单独一行输入end结束，直接回车使用上次内容)"
    $lines = @()
    while ($true) {
        $line = Read-Host
        if ($line -eq 'end') { break }
        $lines += $line
    }
    if ($lines.Count -eq 0 -and $default) {
        return $default
    }
    return ($lines -join "`n")
}

function Read-Input($prompt, $default, $isSecure=$false) {
    if ($default) {
        $prompt = "$prompt [默认: $default]"
    }
    if ($isSecure) {
        $input = Read-Host -AsSecureString $prompt
        if ($input.Length -eq 0 -and $default) { return $default }
        return [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($input))
    } else {
        $input = Read-Host $prompt
        if ([string]::IsNullOrWhiteSpace($input) -and $default) { return $default }
        return $input
    }
}

# 多行输入crt内容
$crt = Read-Multiline-End '请输入crt内容' $last.crt
# 多行输入key内容
$key = Read-Multiline-End '请输入key内容' $last.key
# 输入pass
$pass = Read-Input '请输入p12密码' $last.pass $true

# 保存输入
@{crt=$crt; key=$key; pass=$pass} | ConvertTo-Json | Set-Content $stateFile

# 写入crt和key文件
Set-Content -Path $crtPath -Value $crt -NoNewline
Set-Content -Path $keyPath -Value $key -NoNewline

# 生成p12
openssl pkcs12 -export -in "$crtPath" -inkey "$keyPath" -out "$p12Path" -legacy -passout pass:$pass

# 弹出保存对话框让用户选择保存位置
Add-Type -AssemblyName System.Windows.Forms
$dialog = New-Object System.Windows.Forms.SaveFileDialog
$dialog.Filter = "PKCS#12 Files (*.p12)|*.p12"
$dialog.Title = "请选择保存 p12 文件的位置"
$dialog.FileName = "elastic.p12"

if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
    $savePath = $dialog.FileName
    Copy-Item $p12Path $savePath -Force
    [System.Windows.Forms.MessageBox]::Show("p12 文件已保存到: $savePath", "保存成功", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
}