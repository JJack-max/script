Add-Type -AssemblyName System.Windows.Forms

function Select-EncryptedPath {
    Add-Type -AssemblyName System.Windows.Forms

    $form = New-Object System.Windows.Forms.Form
    $form.Text = "选择解密类型"
    $form.Size = New-Object System.Drawing.Size(300,150)
    $form.StartPosition = "CenterScreen"
    $form.Topmost = $true

    $label = New-Object System.Windows.Forms.Label
    $label.Text = "请选择解密类型："
    $label.AutoSize = $true
    $label.Location = New-Object System.Drawing.Point(10,10)
    $form.Controls.Add($label)

    $result = [ref] $null  # 使用引用变量

    $btnFile = New-Object System.Windows.Forms.Button
    $btnFile.Text = "文件"
    $btnFile.Size = New-Object System.Drawing.Size(75,30)
    $btnFile.Location = New-Object System.Drawing.Point(10,50)
    $btnFile.Add_Click({
        $result.Value = "File"
        $form.Close()
    })
    $form.Controls.Add($btnFile)

    $btnFolder = New-Object System.Windows.Forms.Button
    $btnFolder.Text = "文件夹"
    $btnFolder.Size = New-Object System.Drawing.Size(75,30)
    $btnFolder.Location = New-Object System.Drawing.Point(100,50)
    $btnFolder.Add_Click({
        $result.Value = "Folder"
        $form.Close()
    })
    $form.Controls.Add($btnFolder)

    $btnCancel = New-Object System.Windows.Forms.Button
    $btnCancel.Text = "取消"
    $btnCancel.Size = New-Object System.Drawing.Size(75,30)
    $btnCancel.Location = New-Object System.Drawing.Point(190,50)
    $btnCancel.Add_Click({
        $result.Value = "Cancel"
        $form.Close()
    })
    $form.Controls.Add($btnCancel)

    $form.ShowDialog() | Out-Null

    switch ($result.Value) {
        "File" {
            $fileDialog = New-Object System.Windows.Forms.OpenFileDialog
            $fileDialog.Title = "选择加密文件"
            # $fileDialog.Filter = "Encrypted Files (*.enc)|*.enc|All Files (*.*)|*.*"
            if ($fileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
                return @{ Path = $fileDialog.FileName; IsFile = $true }
            } else {
                throw "用户取消文件选择"
            }
        }
        "Folder" {
            $folderDialog = New-Object System.Windows.Forms.FolderBrowserDialog
            $folderDialog.Description = "选择加密文件夹"
            if ($folderDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
                return @{ Path = $folderDialog.SelectedPath; IsFile = $false }
            } else {
                throw "用户取消文件夹选择"
            }
        }
        default {
            throw "用户取消操作"
        }
    }
}



function Decode-Name($encoded) {
    $name = $encoded -replace ".enc$", ""
    try {
        $bytes = [Convert]::FromBase64String($name)
        return [System.Text.Encoding]::UTF8.GetString($bytes)
    } catch {
        throw "无法解码名称：$encoded"
    }
}

function Decrypt-File($encFile, $keyPath, $outputDir) {
    $decodedName = Decode-Name (Split-Path $encFile -Leaf)
    $outputPath = Join-Path $outputDir $decodedName
    rage -i $keyPath -d -o $outputPath $encFile
    Write-Host "✅ 解密完成：$outputPath"
}

function Decrypt-Folder($encFolder, $keyPath, $outputDir) {
    $files = Get-ChildItem -Path $encFolder -Recurse -File -Force
    $total = $files.Count
    $i = 0

    foreach ($file in $files) {
        $i++

        $relativeEncPath = $file.FullName.Substring($encFolder.Length).TrimStart('\','/')
        $parts = $relativeEncPath -split "[\\/]"
        $decodedParts = @()

        foreach ($part in $parts) {
            if ($part -ne "") {
                try {
                    $decodedParts += Decode-Name $part
                } catch {
                    throw "❌ 无法解码路径部分：$part"
                }
            }
        }

        # 修复 Join-Path 参数错误
        if ($decodedParts.Count -gt 1) {
            $parentPath = $decodedParts[0..($decodedParts.Count - 2)] -join [IO.Path]::DirectorySeparatorChar
            $relativeDecodedPath = Join-Path -Path $parentPath -ChildPath $decodedParts[-1]
        } else {
            $relativeDecodedPath = $decodedParts[0]
        }

        $finalOutput = Join-Path $outputDir $relativeDecodedPath
        $targetDir = Split-Path $finalOutput -Parent

        if (-not (Test-Path $targetDir)) {
            New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
        }

        rage -i $keyPath -d -o $finalOutput $file.FullName

        Write-Host "[$i/$total] ✅ 解密：$finalOutput"
    }

    Write-Host "`n🎉 多级目录解密完成，共解密文件：$total，输出路径：$outputDir"
}


# ========= 主执行流程 =========
try {
    $selection = Select-EncryptedPath
    $encPath = $selection.Path
    $isFile = $selection.IsFile

    $keyPath = "$HOME/script/file/private"
    if (!(Test-Path $keyPath)) {
        throw "私钥路径无效"
    }

    $outputDir = Join-Path $HOME "Downloads"

    if ($isFile) {
        Decrypt-File -encFile $encPath -keyPath $keyPath -outputDir $outputDir
    } else {
        $encFolderName = Split-Path $encPath -Leaf
        $decodedName = Decode-Name $encFolderName
        $outputFolder = Join-Path $outputDir $decodedName
        if (-not (Test-Path $outputFolder)) {
            New-Item -ItemType Directory -Path $outputFolder -Force | Out-Null
        }
        Decrypt-Folder -encFolder $encPath -keyPath $keyPath -outputDir $outputFolder
    }
} catch {
    Write-Warning $_.Exception.Message
}
