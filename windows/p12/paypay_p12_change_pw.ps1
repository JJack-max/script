#requires -version 5.0

param(
    [Parameter(Mandatory = $true)]
    [string]$origin_p12_file
)

# 获取脚本目录
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

# 判断 origin_p12_file 是否为绝对路径
if ([System.IO.Path]::IsPathRooted($origin_p12_file)) {
    $origin_p12_file_full = $origin_p12_file
} else {
    $origin_p12_file_full = Join-Path $ScriptDir $origin_p12_file
}

# 交互式输入密码
$origin_p12_file_pw = Read-Host -AsSecureString '请输入原始 p12 文件密码'
$p12_file_pw = Read-Host -AsSecureString '请输入新 p12 文件密码（JKS 密码同此）'
$jks_file_pw = $p12_file_pw

# 转为明文（用于命令行参数）
function ConvertTo-UnsecureString([System.Security.SecureString]$secstr) {
    $ptr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secstr)
    try {
        [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($ptr)
    } finally {
        [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ptr)
    }
}
$origin_p12_file_pw_plain = ConvertTo-UnsecureString $origin_p12_file_pw
$p12_file_pw_plain = ConvertTo-UnsecureString $p12_file_pw
$jks_file_pw_plain = $p12_file_pw_plain

# 文件名统一为 tmp
$pem_file = Join-Path $ScriptDir 'tmp.pem'
$p12_file = Join-Path $ScriptDir 'tmp.p12'
$jks_file = Join-Path $ScriptDir 'tmp.jks'

Write-Host "📄 PEM 目标文件: $pem_file"
Write-Host "📄 新 P12 文件: $p12_file"
Write-Host "📄 JKS 目标文件: $jks_file"

# 清理旧文件
Remove-Item -Force -ErrorAction SilentlyContinue $pem_file, $p12_file, $jks_file

# 步骤 1: p12 -> PEM
Write-Host "📦 Step 1: Converting .p12 -> .pem"
$cmd1 = "openssl pkcs12 -in `"$origin_p12_file_full`" -nodes -out `"$pem_file`" -legacy -password pass:$origin_p12_file_pw_plain"
Invoke-Expression $cmd1

# 步骤 2: PEM -> 新的 P12
Write-Host "🔁 Step 2: Creating new .p12 from .pem"
$cmd2 = "openssl pkcs12 -export -in `"$pem_file`" -out `"$p12_file`" -keypbe PBE-SHA1-3DES -certpbe PBE-SHA1-3DES -macalg sha1 -iter 2048 -passout pass:$p12_file_pw_plain"
Invoke-Expression $cmd2

# 步骤 3: P12 -> JKS
Write-Host "🔐 Step 3: Creating .jks from .p12"
$cmd3 = "keytool -importkeystore -srckeystore `"$p12_file`" -srcstoretype PKCS12 -srcstorepass $p12_file_pw_plain -deststoretype JKS -destkeystore `"$jks_file`" -deststorepass $jks_file_pw_plain -noprompt"
Invoke-Expression $cmd3

Write-Host "✅ All done. Final JKS file: $jks_file" 

# 打包为 zip 并让用户选择保存位置
$zipFile = Join-Path $ScriptDir 'tmp.zip'
if (Test-Path $zipFile) { Remove-Item $zipFile -Force }
Compress-Archive -Path $pem_file, $p12_file, $jks_file -DestinationPath $zipFile

Add-Type -AssemblyName System.Windows.Forms
$dialog = New-Object System.Windows.Forms.SaveFileDialog
$dialog.Filter = "ZIP 文件 (*.zip)|*.zip"
$dialog.Title = "请选择保存 zip 文件的位置"
$dialog.FileName = "tmp.zip"

if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
    $savePath = $dialog.FileName
    Copy-Item $zipFile $savePath -Force
    [System.Windows.Forms.MessageBox]::Show("zip 文件已保存到: $savePath", "保存成功", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
} 