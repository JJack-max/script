function search {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Keyword,
        [switch]$FileOnly,
        [switch]$ContentOnly
    )

    if (-not $FileOnly -and -not $ContentOnly) {
        $FileOnly = $true
        $ContentOnly = $true
    }

    if ($FileOnly) {
        Write-Host "Filename matches (fd):" -ForegroundColor Cyan
        try {
            fd --ignore-case $Keyword
        } catch {
            Write-Host "(fd not found or not installed)" -ForegroundColor DarkGray
        }
        Write-Host ""
    }

    if ($ContentOnly) {
        Write-Host "Content matches (rg):" -ForegroundColor Green
        try {
            rg --ignore-case --color=always -n $Keyword
        } catch {
            Write-Host "(rg not found or not installed)" -ForegroundColor DarkGray
        }
    }
}

function edit {
    notepad++ $PROFILE
}

function his {
    $path = (Get-PSReadLineOption).HistorySavePath
    & notepad++ $path
}

function drive {
    param([string]$Subcommand)

    $scriptPath = "$HOME\script\drive\$Subcommand.ps1"

    if (Test-Path $scriptPath) {
        . $scriptPath
    }
    else {
        Write-Host "❌ Unknown subcommand: $Subcommand" -ForegroundColor Red
    }
}

function file {
    param([string]$Subcommand)

    $scriptPath = "$HOME\script\file\$Subcommand.ps1"

    if (Test-Path $scriptPath) {
        . $scriptPath
    }
    else {
        Write-Host "❌ Unknown subcommand: $Subcommand" -ForegroundColor Red
    }
}

function sudo {
    param(
        [Parameter(Mandatory = $true, ValueFromRemainingArguments = $true)]
        [string[]]$Command
    )

    # 拼接命令
    $cmd = $Command -join ' '

    # 打印调试信息
    Write-Host "要执行的命令: $cmd"
    Write-Host "当前工作目录: $PWD"

    # 构造完整命令：先切换到当前目录，再执行命令
    $fullCommand = "Set-Location -LiteralPath '$PWD'; $cmd"

    # 转换为 Base64 传递
    $encodedCommand = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($fullCommand))

    # 提权启动 PowerShell，并保持工作目录
    Start-Process pwsh -Verb RunAs -ArgumentList "-NoProfile -EncodedCommand $encodedCommand"
}

function my-pub-ip {
    # 获取公网 IP
    $urls = @(
        "https://ifconfig.me/ip",
        "https://ipinfo.io/ip",
        "https://icanhazip.com",
        "https://ident.me"
    )

    $publicIp = $null
    foreach ($url in $urls) {
        try {
            $ip = (Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 5).Content.Trim()
            if ($ip -match "\b\d{1,3}(\.\d{1,3}){3}\b") {
                $publicIp = $ip
                break
            }
        } catch {
            # 忽略错误
        }
    }

    if (-not $publicIp) {
        Write-Host "无法获取公网 IP" -ForegroundColor Red
    } else {
        Write-Host "公网 IP: $publicIp" -ForegroundColor Cyan
    }

    # 获取本地出口端口
    try {
        # TCP 连接到外部服务（端口 80）
        $tcp = New-Object System.Net.Sockets.TcpClient("ifconfig.me", 80)
        $localEndPoint = $tcp.Client.LocalEndPoint
        $tcp.Close()

        Write-Host "本地出口 IP:Port = $localEndPoint" -ForegroundColor Green
    } catch {
        Write-Host "无法获取本地出口端口" -ForegroundColor Red
    }
}

function r_name {
    python "$HOME\script\windows\random_name.py"
}

# Function to create directory if it doesn't exist
function Create-DirectoryIfNeeded {
    param(
        [string]$Path
    )
    
    if (!(Test-Path $Path)) {
        New-Item -ItemType Directory -Path $Path -Force
    }
}

# Function to copy all files from source to brand directory using robocopy
function Copy-AllFilesToBrand {
    param(
        [string]$SourceDir,
        [string]$BrandDestDir
    )
    
    Write-Host "Copying all files to brand directory..."
    robocopy $SourceDir $BrandDestDir /E /IS /IT /NFL /NDL /NJH /NJS /NC /NS /NP
}

# Function to copy specific files to out/media directory
function Copy-SpecificFiles {
    param(
        [string]$SourceDir,
        [string]$OutMediaDestDir
    )
    
    $specificFiles = @(
        "code-icon-dark.svg",
        "code-icon-light.svg",
        "letter-dark.svg",
        "letter-light.svg"
    )
    
    Write-Host "Copying specific files to out/media directory..."
    foreach ($file in $specificFiles) {
        $sourceFile = Join-Path $SourceDir $file
        if (Test-Path $sourceFile) {
            Copy-Item $sourceFile -Destination $OutMediaDestDir -Force
        } else {
            Write-Warning "File not found: $file"
        }
    }
}

function Set-QoderIconToVSCode {
    param(
        # Qoder 快捷方式路径（默认 Start Menu）
        [string]$QoderShortcutPath = "$HOME\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Qoder\Qoder.lnk",

        # VSCode 可执行文件路径
        [string]$VSCodeExePath = "C:\Program Files\Microsoft VS Code\Code.exe"
    )

    # -----------------------------
    # Step 1: 检查文件是否存在
    # -----------------------------
    if (-Not (Test-Path $QoderShortcutPath)) {
        Write-Host "❌ 找不到 Qoder 快捷方式：$QoderShortcutPath" -ForegroundColor Red
        return
    }

    if (-Not (Test-Path $VSCodeExePath)) {
        Write-Host "❌ 找不到 VS Code 可执行文件：$VSCodeExePath" -ForegroundColor Red
        return
    }

    # -----------------------------
    # Step 2: 修改快捷方式图标
    # -----------------------------
    try {
        $ws = New-Object -ComObject WScript.Shell
        $sc = $ws.CreateShortcut($QoderShortcutPath)

        # IconLocation 指向 VS Code 可执行文件即可
        $sc.IconLocation = $VSCodeExePath
        $sc.Save()

        # 可选：刷新资源管理器图标缓存
        ie4uinit.exe -ClearIconCache
        Stop-Process -Name explorer -Force
        Start-Process explorer
    }
    catch {
        Write-Host "❌ 修改快捷方式失败：" $_ -ForegroundColor Red
    }
}


# Main function
function cover {
    # Define source directory
    $sourceDir = "$HOME\script\windows\qoder\media"
    
    # Define destination directories
    $brandDestDir = "$HOME\AppData\Local\Programs\Qoder\resources\app\resources\media\brand"
    $outMediaDestDir = "$HOME\AppData\Local\Programs\Qoder\resources\app\out\media"
    
    # Create destination directories if they don't exist
    Create-DirectoryIfNeeded -Path $brandDestDir
    Create-DirectoryIfNeeded -Path $outMediaDestDir
    
    # Copy all files from source to brand directory using robocopy
    Copy-AllFilesToBrand -SourceDir $sourceDir -BrandDestDir $brandDestDir
    
    # Copy specific files to out/media directory
    Copy-SpecificFiles -SourceDir $sourceDir -OutMediaDestDir $outMediaDestDir
    

    $win32SourceDir = "$HOME\script\windows\qoder\win32"
    $win32DestDir = "$HOME\AppData\Local\Programs\Qoder\resources\app\resources\win32"
    robocopy $win32SourceDir $win32DestDir /E /IS /IT /NFL /NDL /NJH /NJS /NC /NS /NP

    Set-QoderIconToVSCode

}

function Transfer-Rancher {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [SupportsWildcards()]
        [string[]]$Paths
    )

    foreach ($pattern in $Paths) {

        # 先删除已经存在的 .transferred.yaml 文件，防重复
        $existingTransferred = Get-ChildItem -Path (Split-Path $pattern) -Filter '*.transferred.yaml' -File -ErrorAction SilentlyContinue
        foreach ($f in $existingTransferred) {
            Remove-Item -Path $f.FullName -Force
            Write-Host "Deleted existing transferred file → $($f.Name)" -ForegroundColor Yellow
        }

        $files = Get-ChildItem -File -Path $pattern -ErrorAction SilentlyContinue
        if ($files.Count -eq 0) {
            Write-Host "No matched files: $pattern" -ForegroundColor Yellow
            continue
        }

        foreach ($file in $files) {

            $lines = Get-Content $file.FullName

            $apiVersion = ""
            $kind = ""
            $name = ""
            $namespace = ""

            $inMetadata = $false
            $metadataIndent = 0
            $otherBlocks = New-Object System.Collections.Generic.List[string]

            foreach ($line in $lines) {

                # 读取 apiVersion
                if ($line -match '^apiVersion:\s*(.+)') {
                    $apiVersion = "apiVersion: $($matches[1])"
                    continue
                }

                # 读取 kind
                if ($line -match '^kind:\s*(.+)') {
                    $kind = "kind: $($matches[1])"
                    continue
                }

                # 进入 metadata
                if ($line -match '^metadata:\s*$') {
                    $inMetadata = $true
                    $metadataIndent = ($line.Length - $line.TrimStart().Length)
                    continue
                }

                # 在 metadata 内解析字段
                if ($inMetadata) {
                    $currentIndent = ($line.Length - $line.TrimStart().Length)

                    # 缩进回到 metadata 以上层级 → metadata 结束
                    if ($currentIndent -le $metadataIndent -and $line.Trim() -ne "") {
                        $inMetadata = $false
                    } else {
                        # metadata 子字段，仅保留 name/namespace
                        if ($line -match '^\s*name:\s*(.+)') {
                            $name = $matches[1].Trim()
                        }
                        elseif ($line -match '^\s*namespace:\s*(.+)') {
                            $namespace = $matches[1].Trim()
                        }
                        # 忽略其余 metadata 字段
                        continue
                    }
                }

                # 非 metadata 内容保留
                $otherBlocks.Add($line)
            }

            # 重建 metadata 块
            $metadataBlock = @()
            $metadataBlock += "metadata:"
            if ($name -ne "")      { $metadataBlock += "  name: $name" }
            if ($namespace -ne "") { $metadataBlock += "  namespace: $namespace" }

            # 重新组合 YAML
            $outLines = New-Object System.Collections.Generic.List[string]
            $outLines.Add($apiVersion)
            $outLines.Add($kind)
            foreach ($l in $metadataBlock) { $outLines.Add($l) }

            foreach ($l in $otherBlocks) {
                if ($l -match '^apiVersion:' -or
                    $l -match '^kind:' -or
                    $l -match '^metadata:') {
                    continue
                }
                $outLines.Add($l)
            }

            $out = ($outLines -join "`n")

            $outPath = "$($file.DirectoryName)\$($file.BaseName).transferred.yaml"
            [System.IO.File]::WriteAllText($outPath, $out, [System.Text.UTF8Encoding]::new($false))

            Write-Host "Converted → $outPath" -ForegroundColor Green
        }
    }
}

function Show-PyImage {
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [string[]]$Path
    )

    # Python 脚本路径（根据实际位置修改）
    $pythonScript = "$HOME\script\windows\image\show.py"

    foreach ($p in $Path) {
        # 使用 Start-Process 异步调用 Python，避免阻塞 PowerShell
        Start-Process -FilePath "python" -ArgumentList "`"$pythonScript`" `"$p`"" -NoNewWindow
    }
}

function Invoke-DevEnvironment {
    <#
    .SYNOPSIS
        运行多语言开发环境容器
    .DESCRIPTION
        使用Docker Desktop为不同编程语言创建隔离的开发环境容器
    .PARAMETER Language
        开发语言 (python, node, rust, go, dotnet, flutter)
    .PARAMETER Command
        要在容器中执行的命令
    .PARAMETER Version
        (flutter only) Optional exact Flutter SDK tag/version to pick a specific image tag.
    .EXAMPLE
        # Python example
        Invoke-DevEnvironment -Language python -Command "python --version"

    .EXAMPLE
        # Flutter examples (project located at C:\Users\Bob\flutter-demo\aqua-wallet)
        Set-Location -Path 'C:\Users\Bob\flutter-demo\aqua-wallet'
        # Use default image (latest)
        Invoke-DevEnvironment -Language flutter -Command "flutter --version"

        # Use a specific version tag (best-effort image tag lookup)
        Invoke-DevEnvironment -Language flutter -Version 3.22.3 -Command "flutter --version"
    #>
    
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [ValidateSet("python", "node", "rust", "go", "dotnet", "flutter")]
        [string]$Language,

        # Positional convenience: allow version as optional positional
        [Parameter(Mandatory=$false, Position=1)]
        [string]$Version = $null,

        # Accept the command either via named -Command or as remaining positional args
        [Parameter(Mandatory=$false, ValueFromRemainingArguments=$true, Position=2)]
        [string[]]$CommandParts,

        [Parameter(Mandatory=$false)]
        [string]$Command
    )

    # Normalize version/command when users pass flexible positional args.
    # If Version was accidentally filled with the command (contains spaces), move it into command parts
    if ($Version -and $Version -match '\s') {
        $CommandParts = ,$Version + $CommandParts
        $Version = $null
    }

    # If CommandParts exist, join them into Command (unless named -Command provided)
    if (-not $Command -and $CommandParts) {
        $Command = ($CommandParts -join ' ')
    }

    
    # 设置语言特定的配置
    switch ($Language) {
        "python" {
            $Image = "python-selenium:latest"
            $CacheVol = "devcache_python"
            $CachePath = "/root/.cache/pip"
            if (Test-Path "requirements.txt") {
                $InstallCmd = "pip install -r requirements.txt"
            } elseif (Test-Path "pyproject.toml") {
                $InstallCmd = "pip install ."
            } else {
                $InstallCmd = ""
            }
        }
        "node" {
            $Image = "node:20"
            $CacheVol = "devcache_node"
            $CachePath = "/root/.npm"
            if (Test-Path "package.json") {
                $InstallCmd = "npm install"
            } else {
                $InstallCmd = ""
            }
        }
        "rust" {
            $Image = "rust:1.81"
            $CacheVol = "devcache_rust"
            $CachePath = "/usr/local/cargo/registry"
            if (Test-Path "Cargo.toml") {
                $InstallCmd = "cargo fetch"
            } else {
                $InstallCmd = ""
            }
        }
        "go" {
            $Image = "golang:1.23"
            $CacheVol = "devcache_go"
            $CachePath = "/go/pkg/mod"
            if (Test-Path "go.mod") {
                $InstallCmd = "go mod download"
            } else {
                $InstallCmd = ""
            }
        }
        "flutter" {
            # Image selection: prefer explicit Version if provided, else use latest
            if ($Version) {
                $Image = "ghcr.io/fischerscode/flutter:$Version"
            } else {
                $Image = "ghcr.io/fischerscode/flutter:latest"
            }

            $CacheVol = "devcache_flutter"
            $CachePath = "/root/.pub-cache"

            if (Test-Path "pubspec.yaml") {
                $InstallCmd = "flutter pub get"
            } else {
                $InstallCmd = ""
            }
        }
        "dotnet" {
            $Image = "mcr.microsoft.com/dotnet/sdk:8.0"
            $CacheVol = "devcache_dotnet"
            $CachePath = "/root/.nuget/packages"
            $ProjectFiles = Get-ChildItem -Path "*.csproj","*.sln" -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($ProjectFiles) {
                $InstallCmd = "dotnet restore $($ProjectFiles.Name)"
            } else {
                $InstallCmd = ""
            }
        }
    }
    
    # 检查Docker是否正在运行
    try {
        $dockerCheck = docker info 2>$null
        if (-not $dockerCheck) {
            throw "Docker is not running or not accessible"
        }
    } catch {
        Write-Error "❌ Docker Desktop未运行或无法访问，请启动Docker Desktop后再试"
        return
    }
    
    # 创建Volume（如不存在）
    $volumeExists = docker volume ls --format "{{.Name}}" | Where-Object { $_ -eq $CacheVol }
    if (-not $volumeExists) {
        Write-Host "📦 创建依赖缓存卷: $CacheVol"
        docker volume create $CacheVol > $null
    }
    
    # 显示信息
    Write-Host "🚀 使用镜像: $Image"
    Write-Host "📁 当前目录: $(Get-Location)"
    Write-Host "🧰 执行命令: $Command"
    
    # 构建运行命令
    $RunCmd = "set -e; "
    if ($InstallCmd) {
        $RunCmd += "$InstallCmd && "
    }
    $RunCmd += "$Command"
    
    # 获取当前目录的绝对路径并转换为Unix格式（适用于Docker Desktop for Windows）
    $CurrentDir = (Get-Location).Path
    # 将Windows路径转换为Unix路径格式（用于WSL2/Docker Desktop）
    if ($CurrentDir -match "^[A-Za-z]:") {
        # 移除盘符冒号并将反斜杠替换为正斜杠
        $UnixPath = "/$($CurrentDir.Substring(0,1).ToLower())$($CurrentDir.Substring(2).Replace('\', '/'))"
    } else {
        $UnixPath = $CurrentDir.Replace('\', '/')
    }
    
    # 运行容器
    docker run --rm -it `
        -v "${UnixPath}:/app" `
        -v "${CacheVol}:${CachePath}" `
        -w /app `
        $Image bash -c $RunCmd
}

# 设置别名以便更容易使用
Set-Alias -Name dev -Value Invoke-DevEnvironment
