# ====== 读取 .env 文件 ======
$envFile = ".\.env"

Get-Content $envFile | ForEach-Object {
    if ($_ -match "^\s*([A-Z_]+)\s*=\s*(.+)\s*$") {
        $name = $matches[1]
        $value = $matches[2]
        Set-Variable -Name $name -Value $value
    }
}

# ====== 扫描 YAML 并创建 namespace ======
# $CLUSTER_ID, $PROJECT_ID, $YAML_PATH 从 .env 读取
$namespaces = @()
Get-ChildItem $YAML_PATH -Filter *.yaml | ForEach-Object {
    $nsMatches = Select-String -Path $_.FullName -Pattern "namespace:\s*(\S+)" -AllMatches
    foreach ($match in $nsMatches.Matches) {
        $namespaces += $match.Groups[1].Value
    }
}
$namespaces = $namespaces | Sort-Object -Unique

# ====== 创建 namespace 并绑定到 Default Project ======
foreach ($ns in $namespaces) {
    Write-Host "Creating namespace '$ns' in Default Project..."
    
    $namespaceYaml = @"
apiVersion: v1
kind: Namespace
metadata:
  name: $ns
  annotations:
    field.cattle.io/projectId: $CLUSTER_ID`:$PROJECT_ID
    cattle.io/creator: norman
"@

    $namespaceYaml | kubectl apply -f -
}
