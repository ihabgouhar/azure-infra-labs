# Day 06 teardown - Az PowerShell (keeps RG, VNet, Bastion, VMs)
$rg = 'rg-lab-core-eus2'; $vmName = 'vm-app01'
$vm = Get-AzVM -ResourceGroupName $rg -Name $vmName
Remove-AzVMDataDisk -VM $vm -DataDiskNames 'disk-app01-restore01','disk-app01-data01'
Update-AzVM -ResourceGroupName $rg -VM $vm
Remove-AzDisk -ResourceGroupName $rg -DiskName 'disk-app01-restore01' -Force
Remove-AzSnapshot -ResourceGroupName $rg -SnapshotName 'snap-app01-data01' -Force
Remove-AzDisk -ResourceGroupName $rg -DiskName 'disk-app01-data01' -Force
Stop-AzVM -ResourceGroupName $rg -Name $vmName -Force
Get-AzResource -ResourceGroupName $rg | Sort-Object ResourceType | Format-Table Name, ResourceType
