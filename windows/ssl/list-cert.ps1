# 打开 LocalMachine 的 Root 存储
$store = New-Object System.Security.Cryptography.X509Certificates.X509Store "Root", "LocalMachine"
$store.Open([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadOnly)

# 获取证书并转换为对象集合
$certs = $store.Certificates | ForEach-Object {
    [PSCustomObject]@{
        Subject    = $_.Subject
        Issuer     = $_.Issuer
        Thumbprint = $_.Thumbprint
        NotBefore  = $_.NotBefore
        NotAfter   = $_.NotAfter
    }
}

# 关闭证书存储
$store.Close()

# 按 NotBefore 升序排序（越早越后）
$certs | Sort-Object NotBefore -Descending | Format-Table -AutoSize
