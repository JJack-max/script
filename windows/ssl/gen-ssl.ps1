#requires -Version 5.1
Add-Type -AssemblyName System.Windows.Forms

# 创建表单
$form = New-Object System.Windows.Forms.Form
$form.Text = "Let's Encrypt 证书申请"
$form.Size = New-Object System.Drawing.Size(400,220)
$form.StartPosition = "CenterScreen"

# 标签和输入框：邮箱
$labelEmail = New-Object System.Windows.Forms.Label
$labelEmail.Text = "邮箱 (Contact Email):"
$labelEmail.Location = New-Object System.Drawing.Point(10,20)
$labelEmail.Size = New-Object System.Drawing.Size(150,20)
$form.Controls.Add($labelEmail)

$textEmail = New-Object System.Windows.Forms.TextBox
$textEmail.Location = New-Object System.Drawing.Point(160,18)
$textEmail.Size = New-Object System.Drawing.Size(200,20)
$form.Controls.Add($textEmail)

# 标签和输入框：域名
$labelDomains = New-Object System.Windows.Forms.Label
$labelDomains.Text = "域名 (逗号分隔):"
$labelDomains.Location = New-Object System.Drawing.Point(10,60)
$labelDomains.Size = New-Object System.Drawing.Size(150,20)
$form.Controls.Add($labelDomains)

$textDomains = New-Object System.Windows.Forms.TextBox
$textDomains.Location = New-Object System.Drawing.Point(160,58)
$textDomains.Size = New-Object System.Drawing.Size(200,20)
$form.Controls.Add($textDomains)

# 确认按钮
$btnOk = New-Object System.Windows.Forms.Button
$btnOk.Location = New-Object System.Drawing.Point(160,100)
$btnOk.Size = New-Object System.Drawing.Size(100,30)
$btnOk.Text = "申请证书"
$btnOk.Add_Click({
    $email = $textEmail.Text.Trim()
    $domainsInput = $textDomains.Text.Trim()
    
    if ([string]::IsNullOrWhiteSpace($email)) {
        [System.Windows.Forms.MessageBox]::Show("邮箱不能为空！","错误",[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Error)
        return
    }
    if ([string]::IsNullOrWhiteSpace($domainsInput)) {
        [System.Windows.Forms.MessageBox]::Show("域名不能为空！","错误",[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Error)
        return
    }

    $domains = $domainsInput -split '\s*,\s*' | Where-Object { $_ -ne "" }

    # 加载模块
    try {
        Import-Module Posh-ACME -ErrorAction Stop
    }
    catch {
        [System.Windows.Forms.MessageBox]::Show("加载 Posh-ACME 模块失败，请先安装模块。","错误",[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Error)
        return
    }

    try {
        # 申请证书，自动创建订单和验证
        $cert = New-PACertificate -Domain $domains -Contact $email -AcceptTOS -Verbose -ErrorAction Stop

        # 导出 PFX 文件，密码为空
        $pfxPath = Join-Path -Path (Get-Location) -ChildPath "$($domains[0]).pfx"
        $cert | Export-PfxCertificate -FilePath $pfxPath -Password (ConvertTo-SecureString -String "" -AsPlainText -Force)

        [System.Windows.Forms.MessageBox]::Show("证书申请成功！`nPFX 文件已保存: $pfxPath", "成功", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    }
    catch {
        [System.Windows.Forms.MessageBox]::Show("证书申请失败:`n" + $_.Exception.Message, "错误", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    }
})

$form.Controls.Add($btnOk)

# 显示表单
[void]$form.ShowDialog()
