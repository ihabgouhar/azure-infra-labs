# Day 07 teardown - Az PowerShell (auto-shutdown intentionally kept)
$rg = 'rg-lab-core-eus2'
(Get-AzVM -ResourceGroupName $rg -Name vm-app01).HardwareProfile.VmSize   # expect Standard_B2s
Stop-AzVM -ResourceGroupName $rg -Name vm-app01 -Force
Stop-AzVM -ResourceGroupName $rg -Name vm-web01 -Force
Get-AzVM -ResourceGroupName $rg -Status | Format-Table Name, @{n='Size';e={$_.HardwareProfile.VmSize}}, PowerState
