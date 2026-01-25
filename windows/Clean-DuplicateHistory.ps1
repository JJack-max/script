# 清理 PowerShell 历史记录中的重复项（保留顺序，保持中文编码）

$historyFile = "$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt"

if (Test-Path $historyFile) {
    $history = Get-Content $historyFile

    $uniqueHistory = [System.Collections.Generic.HashSet[string]]::new()
    $orderedUnique = foreach ($line in $history) {
        if ($uniqueHistory.Add($line)) {
            $line
        }
    }

    $orderedUnique | Out-File -FilePath $historyFile -Encoding utf8
}
