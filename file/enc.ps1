Add-Type -AssemblyName System.Windows.Forms

function Select-Path {
    Add-Type -AssemblyName System.Windows.Forms

    $form = New-Object System.Windows.Forms.Form
    $form.Text = "选择类型"
    $form.Size = New-Object System.Drawing.Size(320,150)
    $form.StartPosition = "CenterScreen"
    $form.Topmost = $true

    $label = New-Object System.Windows.Forms.Label
    $label.Text = "请选择要解密的对象类型："
    $label.AutoSize = $true
    $label.Location = New-Object System.Drawing.Point(10,15)
    $form.Controls.Add($label)

    $result = [ref] $null

    $btnFile = New-Object System.Windows.Forms.Button
    $btnFile.Text = "文件"
    $btnFile.Size = New-Object System.Drawing.Size(75,30)
    $btnFile.Location = New-Object System.Drawing.Point(15,60)
    $btnFile.Add_Click({
        $result.Value = "File"
        $form.Close()
    })
    $form.Controls.Add($btnFile)

    $btnFolder = New-Object System.Windows.Forms.Button
    $btnFolder.Text = "文件夹"
    $btnFolder.Size = New-Object System.Drawing.Size(75,30)
    $btnFolder.Location = New-Object System.Drawing.Point(120,60)
    $btnFolder.Add_Click({
        $result.Value = "Folder"
        $form.Close()
    })
    $form.Controls.Add($btnFolder)

    $btnCancel = New-Object System.Windows.Forms.Button
    $btnCancel.Text = "取消"
    $btnCancel.Size = New-Object System.Drawing.Size(75,30)
    $btnCancel.Location = New-Object System.Drawing.Point(225,60)
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
                return $fileDialog.FileName
            } else {
                throw "用户取消文件选择"
            }
        }
        "Folder" {
            $folderDialog = New-Object System.Windows.Forms.FolderBrowserDialog
            $folderDialog.Description = "选择加密文件夹"
            if ($folderDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
                return $folderDialog.SelectedPath
            } else {
                throw "用户取消文件夹选择"
            }
        }
        default {
            throw "用户取消操作"
        }
    }
}

function Encode-Name($name) {
    return [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($name))
}

function Encrypt-Item($inputPath, $outputRoot, $keyPath) {
    $isFile = Test-Path $inputPath -PathType Leaf
    # 直接使用 outputRoot，不再拼接时间戳目录
    New-Item -ItemType Directory -Path $outputRoot -Force | Out-Null

    if ($isFile) {
        # Encrypt single file
        $fileName = Split-Path $inputPath -Leaf
        $encodedName = Encode-Name $fileName + ".enc"
        $outputPath = Join-Path $outputRoot $encodedName
        Write-Host "Encrypting file: $fileName"
        rage -r (Get-Content $keyPath) -o $outputPath -e $inputPath
    } else {
        # Encrypt folder structure
        $folderName = Split-Path $inputPath -Leaf
        $encodedFolderName = Encode-Name $folderName
        $folderOutputPath = Join-Path $outputRoot $encodedFolderName
        New-Item -ItemType Directory -Path $folderOutputPath -Force | Out-Null
        
        Write-Host "Encrypting folder: $folderName"
        
        # Get all files recursively
        $allFiles = Get-ChildItem -Path $inputPath -Recurse -File
        $totalFiles = $allFiles.Count
        $currentFile = 0
        
        foreach ($file in $allFiles) {
            $currentFile++
            $relativePath = $file.FullName.Substring($inputPath.Length + 1)
            
            # Split the relative path into directory and filename
            $relativeDir = Split-Path $relativePath -Parent
            $fileName = Split-Path $relativePath -Leaf
            
            # Encode both directory and filename
            if ($relativeDir) {
                $encodedDir = Encode-Name $relativeDir
                $encodedFileName = Encode-Name $fileName + ".enc"
                $destDir = Join-Path $folderOutputPath $encodedDir
                $destPath = Join-Path $destDir $encodedFileName
            } else {
                $encodedFileName = Encode-Name $fileName + ".enc"
                $destPath = Join-Path $folderOutputPath $encodedFileName
            }
            
            # Create directory structure if needed
            if ($relativeDir) {
                New-Item -ItemType Directory -Force -Path $destDir | Out-Null
            }
            
            Write-Host "Encrypting ($currentFile/$totalFiles): $relativePath"
            rage -r (Get-Content $keyPath) -o $destPath -e $file.FullName
        }
    }

    Write-Host "`n✅ Encryption completed! Output directory: $outputRoot"
}

# Main execution flow
try {
    $target = Select-Path
    $keyPath = "$HOME/script/file/public"
    # $download = [Environment]::GetFolderPath("Downloads")
    $download = "$HOME/Downloads"
    Encrypt-Item -inputPath $target -outputRoot $download -keyPath $keyPath
} catch {
    Write-Warning $_.Exception.Message
}
