# 关闭 Hyper-V 相关 Windows 功能
Disable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All -NoRestart

# 关闭虚拟机平台（WSL2 / Docker 依赖）
Disable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart

# 关闭 Windows Hypervisor Platform
Disable-WindowsOptionalFeature -Online -FeatureName HypervisorPlatform -NoRestart

# 禁用 hypervisor 启动
bcdedit /set hypervisorlaunchtype off

Write-Host "Hyper-V 已关闭，请重启系统生效" -ForegroundColor Green
