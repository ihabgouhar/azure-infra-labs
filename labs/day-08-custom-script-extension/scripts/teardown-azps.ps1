# Day 08 teardown - Az PowerShell (disk + NIC are deleted with the VM)
$rg = 'rg-lab-core-eus2'
Remove-AzVM -ResourceGroupName $rg -Name 'vm-iis01' -Force
Remove-AzResource -ResourceGroupName $rg -ResourceType 'Microsoft.DevTestLab/schedules' -ResourceName 'shutdown-computevm-vm-iis01' -Force -ErrorAction SilentlyContinue
Get-AzResource -ResourceGroupName $rg | Format-Table Name, ResourceType
