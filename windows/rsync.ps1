param(
    [Parameter(Mandatory = $true)]
    [string]$Source,

    [Parameter(Mandatory = $true)]
    [string]$Destination
)

# robocopy 增量同步 + 删除（类似 rsync --delete）
# /MIR = mirror (add + delete), /Z = restartable mode, /R:2 = retry 2 times, /W:5 = wait 5 sec
robocopy $Source $Destination /MIR /Z /R:2 /W:5 /TEE
