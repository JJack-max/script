# 设置脚本为 UTF8 编码（在脚本文件保存时选择 UTF8 无 BOM，PowerShell 7+ 默认即可）
# 如需在 PowerShell 5.1 保证输出 UTF8，可以使用以下代码：
[Console]::OutputEncoding = [Text.UTF8Encoding]::new()

function Check-And-Install($toolName, $installCommand) {
    if (-not (Get-Command $toolName -ErrorAction SilentlyContinue)) {
        Write-Host "⚠️ $toolName not found. Install it? (y/n): " -NoNewline
        $ans = Read-Host
        if ($ans -eq "y") {
            Write-Host "Installing $toolName..."
            Invoke-Expression $installCommand
        }
        else {
            Write-Host "$toolName is required. Exiting." -ForegroundColor Red
            exit 1
        }
    }
}

function Get-GpgKeys {
    $output = gpg --list-keys --with-colons
    $keys = @()
    $currentKey = $null
    $currentUid = $null

    foreach ($line in $output) {
        if ($line -like "pub:*") {
            # 开始一个新的主密钥
            if ($currentKey) {
                $keys += $currentKey
            }
            $currentKey = [PSCustomObject]@{
                Index = $keys.Count + 1
                Fingerprint = $null
                UserID = $null
            }
            $currentUid = $null
        }
        elseif ($line -like "fpr:*" -and $currentKey -and -not $currentKey.Fingerprint) {
            # 这是主密钥的指纹（第一个fpr行）
            $currentKey.Fingerprint = ($line -split ":")[9]
        }
        elseif ($line -like "uid:*" -and $currentKey -and -not $currentUid) {
            # 这是主密钥的用户ID（第一个uid行）
            $currentUid = ($line -split ":")[9]
            $currentKey.UserID = $currentUid
        }
    }
    
    # 添加最后一个密钥
    if ($currentKey) {
        $keys += $currentKey
    }

    return $keys
}

function Create-GpgKey {
    Write-Host "Starting GPG key generation, please follow prompts..."
    gpg --full-generate-key
    Write-Host "GPG key creation done."
}

function Ensure-GpgInstalledAndKeyExists {
    Check-And-Install "gpg" "winget install GnuPG.GnuPG"
    $keys = Get-GpgKeys
    if ($keys.Count -eq 0) {
        Write-Host "No GPG keys found, creating one now..."
        Create-GpgKey
    }
}

function Check-And-Install-Gopass {
    Check-And-Install "gopass" "winget install gopass"
}

function Choose-GpgKey {
    $keys = Get-GpgKeys
    Write-Host "`nAvailable GPG keys:"
    $keys | ForEach-Object { Write-Host "$($_.Index). $($_.UserID) [$($_.Fingerprint.Substring(0,8))...]" }
    $createIndex = $keys.Count + 1
    Write-Host "$createIndex. Create a new GPG key"

    do {
        $choice = Read-Host "Enter the number to select a key"
        if ($choice -eq "$createIndex") {
            Create-GpgKey
            $newKeys = Get-GpgKeys
            return $newKeys[0]
        }
        elseif ($choice -match '^\d+$' -and [int]$choice -le $keys.Count) {
            return $keys[[int]$choice - 1]
        }
        Write-Host "Invalid choice, please try again." -ForegroundColor Red
    } while ($true)
}

function Prompt-Password {
    $gen = Read-Host "Generate password automatically? (y/n)"
    if ($gen -eq "y") {
        $length = Read-Host "Enter password length (default 12)"
        if (-not $length) { $length = 12 }

        Write-Host "Select character sets (combine numbers):"
        Write-Host "1 - Numbers"
        Write-Host "2 - Letters (upper and lower case)"
        Write-Host "3 - Special characters"
        $combo = Read-Host "Example: 12 for numbers+letters, 13 for numbers+special"

        $chars = ""
        if ($combo -match "1") { $chars += "0123456789" }
        if ($combo -match "2") { $chars += "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ" }
        if ($combo -match "3") { $chars += "!@#$%^&*()_+-=[]{}|;:,.<>/?~" }

        if (-not $chars) {
            Write-Host "You must select at least one character type." -ForegroundColor Red
            return Prompt-Password
        }

        $passwordChars = for ($i = 0; $i -lt [int]$length; $i++) {
            ([char[]]$chars | Get-Random)
        }
        $password = -join $passwordChars

        Write-Host "Generated password: $password"
        return $password
    }
    else {
        do {
            $pw = Read-Host "Enter password (required)"
        } while (-not $pw)
        return $pw
    }
}

function Collect-EntryData($selectedKey) {
    # 从UserID中提取密钥名称（去掉括号中的描述）
    $keyName = $selectedKey.UserID -replace '\s*\([^)]*\)', ''
    
    do {
        $title = Read-Host "Enter title (required)"
        if (-not $title) {
            Write-Host "Title is required." -ForegroundColor Red
            continue
        }
        
        # 自动添加密钥名称前缀
        $fullTitle = "$keyName/$title"
        Write-Host "Full title will be: $fullTitle" -ForegroundColor Yellow
        
        $confirm = Read-Host "Confirm this title? (y/n, default: y)"
        if ($confirm -eq "" -or $confirm -eq "y") {
            $title = $fullTitle
            break
        }
        elseif ($confirm -eq "n") {
            # 重新输入标题
            continue
        }
    } while ($true)

    $username = Read-Host "Username (optional)"
    $password = Prompt-Password
    $url = Read-Host "URL (optional)"
    $notes = Read-Host "Notes (optional)"
    $tag = Read-Host "Tag (optional)"

    return @{
        Title    = $title
        Username = $username
        Password = $password
        URL      = $url
        Notes    = $notes
        Tag      = $tag
    }
}

function Confirm-And-Insert($entry) {
    Write-Host "`nPlease confirm the following info:"
    $entry.GetEnumerator() | Where-Object { $_.Value } | ForEach-Object {
        Write-Host ("{0}: {1}" -f $_.Key, $_.Value)
    }

    $yes = Read-Host "`nConfirm creation? (y/n)"
    if ($yes -ne "y") {
        Write-Host "Cancelled." -ForegroundColor Yellow
        exit
    }

    $titlePath = $entry.Title -replace '\s+', '_'

    # 构造要写入的内容
    $content = "$($entry.Password)`n"
    if ($entry.Username) { $content += "username: $($entry.Username)`n" }
    if ($entry.URL) { $content += "url: $($entry.URL)`n" }
    if ($entry.Notes) { $content += "notes: $($entry.Notes)`n" }
    if ($entry.Tag) { $content += "tag: $($entry.Tag)`n" }

    # 使用管道写入 gopass
    $content | gopass insert -m $titlePath

    Write-Host "`nPassword entry created successfully." -ForegroundColor Green
}

# ---------------- 主程序 ----------------

Check-And-Install-Gopass
Ensure-GpgInstalledAndKeyExists

$selectedKey = Choose-GpgKey
Write-Host "Selected GPG key: $($selectedKey.UserID) [$($selectedKey.Fingerprint.Substring(0,8))...]"

$entry = Collect-EntryData $selectedKey

Confirm-And-Insert $entry
