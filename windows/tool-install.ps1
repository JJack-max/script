# scoop
Set-ExecutionPolicy RemoteSigned -scope CurrentUser
irm get.scoop.sh | iex
scoop --version

# powershell 7
# scoop bucket add extras
scoop install pwsh

# ripgrep
scoop install ripgrep

# fd
scoop install fd

# 7zip
# 7z a archive.zip file.txt     # 压缩
# 7z x archive.zip              # 解压
scoop install 7zip

# ext4.vhdx 压缩
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All -All

Install-WindowsFeature -Name Hyper-V -IncludeManagementTools

# 创建ps配置文件
New-Item -Path $PROFILE -ItemType File -Force

# 命令自动补全
Install-Module -Name PSReadLine -Force -SkipPublisherCheck

# 升级 PowerShellGet
Install-Module -Name PowerShellGet -Force -AllowClobber

# 安装 PSFramework
Install-Module -Name PSFramework -Scope CurrentUser

# 安装 Posh-Git
Install-Module -Name Posh-Git -Scope CurrentUser

# 安装 PSReadLine
Install-Module -Name PSReadLine -Force -Scope CurrentUser

# 安装 PSFzf（结合 fzf 的历史搜索工具）
Install-Module -Name PSFzf -Scope CurrentUser

Install-Module -Name Posh-ACME -Scope CurrentUser

# choco (administrator)
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# preview md
scoop install glow

# gh search repos "mini-redis" --limit 5 --sort stars
scoop install gh