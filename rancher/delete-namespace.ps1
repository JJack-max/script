# ====== 读取 .env 文件 ======
$envFile = ".\.env"

Get-Content $envFile | ForEach-Object {
    if ($_ -match "^\s*([A-Z_]+)\s*=\s*(.+)\s*$") {
        $name = $matches[1]
        $value = $matches[2]
        Set-Variable -Name $name -Value $value
    }
}

# ====== 扫描 YAML 并收集 namespace ======
$namespaces = @()
Get-ChildItem $YAML_PATH -Filter *.yaml -Recurse | ForEach-Object {
    $nsMatches = Select-String -Path $_.FullName -Pattern "namespace:\s*(\S+)" -AllMatches
    foreach ($match in $nsMatches.Matches) {
        $namespaces += $match.Groups[1].Value
    }
}
$namespaces = $namespaces | Sort-Object -Unique

# ====== 异步删除 namespace ======
foreach ($ns in $namespaces) {
    Write-Host "Deleting namespace '$ns' asynchronously..."
    
    # 使用 Start-Job 异步执行 kubectl delete
    Start-Job -ScriptBlock {
        param($n)
        kubectl delete namespace $n --ignore-not-found
    } -ArgumentList $ns
}

Write-Host "All delete requests have been submitted."