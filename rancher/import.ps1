# ====== 读取 .env 文件 ======
$envFile = ".\.env"

Get-Content $envFile | ForEach-Object {
    if ($_ -match "^\s*([A-Z_]+)\s*=\s*(.+)\s*$") {
        $name = $matches[1]
        $value = $matches[2]
        Set-Variable -Name $name -Value $value
    }
}

# ====== 批量导入 YAML（包含子目录） ======
Get-ChildItem $YAML_PATH -Filter *.yaml -Recurse | ForEach-Object {
    Write-Host "Applying YAML: $($_.FullName)"
    kubectl apply -f $_.FullName
}
