# 检查管理员权限
$IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

if (-not $IsAdmin) {
    # 以管理员权限重新启动脚本
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = "powershell.exe"
    $psi.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    $psi.Verb = "runas"   # 提升权限
    try {
        [System.Diagnostics.Process]::Start($psi) | Out-Null
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Failed to elevate privileges: " + $_.Exception.Message, "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    }
    exit
}

# 引入 WinForms
Add-Type -AssemblyName System.Windows.Forms

# 打开文件选择框
$ofd = New-Object System.Windows.Forms.OpenFileDialog
$ofd.Filter = "Certificate Files (*.cer;*.crt;*.pem)|*.cer;*.crt;*.pem|All Files (*.*)|*.*"
$ofd.Title = "Please select a certificate file to import"

if ($ofd.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
    $certPath = $ofd.FileName
    try {
        # 加载待导入证书
        $cert = [System.Security.Cryptography.X509Certificates.X509Certificate2]::new($certPath)

        # 提取 CN（通用名称）用于匹配
        $subjectCN = ($cert.Subject -split ",\s*") -match "^CN=" | ForEach-Object { $_ -replace "^CN=", "" }

        # 打开证书存储（LocalMachine\Root）
        $store = New-Object System.Security.Cryptography.X509Certificates.X509Store "Root", "LocalMachine"
        $store.Open("ReadWrite")

        # 查找已有相同 CN 的证书
        $duplicates = $store.Certificates | Where-Object {
            ($_.Subject -split ",\s*") -match "^CN=" | ForEach-Object { $_ -replace "^CN=", "" } | Where-Object { $_ -eq $subjectCN }
        }

        # 如果找到重复项，则先删除
        if ($duplicates.Count -gt 0) {
            foreach ($dup in $duplicates) {
                $store.Remove($dup)
            }
        }

        # 添加新证书
        $store.Add($cert)
        $store.Close()

        [System.Windows.Forms.MessageBox]::Show("Certificate imported successfully (old one replaced if existed).", "Success", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    }
    catch {
        [System.Windows.Forms.MessageBox]::Show("Certificate import failed: " + $_.Exception.Message, "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    }
}
else {
    Write-Host "No certificate file selected. Script ended."
}
